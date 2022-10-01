local _, PDKP = ...
local _G = _G

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils
local GUtils = PDKP.GUtils
local Group = { _initialized = false }
local GuildManager

local IsInRaid = IsInRaid
local tinsert = table.insert
local GetNumGroupMembers, GetRaidRosterInfo = GetNumGroupMembers, GetRaidRosterInfo
local UnitIsGroupLeader = UnitIsGroupLeader
local ConvertToRaid, InviteUnit = ConvertToRaid, InviteUnit
local strtrim = strtrim
local wipe = wipe
local C_Timer = C_Timer
local LoggingCombat = LoggingCombat
local setmetatable = setmetatable

-- InstanceID's of all raids in TBC Classic
local MAPS_TO_LOG = {532, 534, 544, 548, 550, 564, 565, 580, }

function Group:Initialize()
    setmetatable(self, Group) -- Set the metatable so we used Group's __index

    GuildManager = MODULES.GuildManager

    self.classes = {}
    self.available = true
    self.requestedDKPOfficer = false
    self.portraitInitialized = false

    self.awardOnTimeAutomatically = false;
    self.onTimeAwarded = false;

    self.combatLoggingEnabled = false;

    self.myName = Utils:GetMyName()

    self.numGroupMembers = 0

    self:_RefreshClasses()
    self:InitializePortrait()

    self.memberNames = {}
    self.player = {}
    self.leadership = {
        assist = {},
        masterLoot = nil,
        dkpOfficer = nil,
        leader = nil,
    }
    self.LoggingFrame = CreateFrame("Frame", nil, nil);
    self._initialized = true;

    self:RegisterEvents()

    self:Refresh()

    self:_ToggleLogging();
end

function Group:InvitePlayer(name)
    if self:CanInvite(name) then
        if self:IsLeader() and GetNumGroupMembers() == 5 then
            ConvertToRaid()
        end
        InviteUnit(name)
        MODULES.CommsManager:SendCommsMessage('SentInv', name)
        return
    end
end

function Group:CanInvite(name)
    local ignore_pugs = MODULES.RaidManager.ignore_pugs
    if ignore_pugs and not MODULES.GuildManager:IsGuildMember(name) then
        return false
    end

    self:Refresh()

    return not self:IsInRaid() or self:IsLeader() or self:IsAssist()
end

function Group:Reinitialize()

    local function pdkp_clearFrameEvents(frame)
        frame:SetScript("OnEvent", nil);
    end

    if self.eventFrame ~= nil then
        pcall(pdkp_clearFrameEvents, self.eventFrame);
    end

    if self.loggingFrame ~= nil then
        pcall(pdkp_clearFrameEvents, self.loggingFrame);
    end

    self.eventFrame = nil;
    self.LoggingFrame = nil;

    self:Initialize();
end

-----------------------------
--     Event Functions     --
-----------------------------

function Group:RegisterEvents()
    local opts = {
        ['name'] = 'GROUP',
        ['events'] = { 'GROUP_ROSTER_UPDATE', 'BOSS_KILL' },
        ['tickInterval'] = 0.5,
        ['onEventFunc'] = function(arg1, arg2, arg3)
            self:_HandleEvent(arg1, arg2, arg3)
        end
    }
    self.eventFrame = GUtils:createThrottledEventFrame(opts)

    self:WatchLogging();
end

function Group:WatchLogging()
    local combatLoggingEvents = {'LOADING_SCREEN_DISABLED', 'ZONE_CHANGED_NEW_AREA', 'PLAYER_ENTERING_WORLD'};
    for _, event in pairs(combatLoggingEvents) do
        self.LoggingFrame:RegisterEvent(event);
    end

    self.LoggingFrame:SetScript("OnEvent", function(event, arg1, ...)
        self:_ToggleLogging();
    end)
end

function Group:_ToggleLogging()
    local optionsLoggingVal = MODULES.Options:GetCombatLogging()

    if optionsLoggingVal == nil then
        return;
    elseif optionsLoggingVal == false then
        self.LoggingFrame:SetScript("OnEvent", nil);
        return;
    end

    local prevState = self.combatLoggingEnabled and true;
    self.combatLoggingEnabled = LoggingCombat(self:_ShouldLoggingBeEnabled());
    if self.combatLoggingEnabled ~= prevState then
        if self.combatLoggingEnabled then
            PDKP.CORE:Print("Combat Logging has been enabled");
        else
            PDKP.CORE:Print("Combat Logging has been disabled");
        end
    end
end

function Group:_ShouldLoggingBeEnabled()
    local _, _, _, _, _, _, _, instanceMapId, _ = GetInstanceInfo()
    if tContains(MAPS_TO_LOG, instanceMapId) then
        return true
    elseif self:IsInRaid() and self:IsInInstance() then
        return true
    end
    return false
end

function Group:_HandleEvent(event, arg1, ...)
    if not self:IsInRaid() then
        return
    end
    self:Refresh()
    if not self.available then
        return C_Timer.After(1.5, self:_HandleEvent(event, arg1, ...))
    end

    if event == 'BOSS_KILL' and PDKP.canEdit then
        local isDKP = self:HasDKPOfficer() and self:IsDKPOfficer()
        local isMLNoDKP = not self:HasDKPOfficer() and self:IsMasterLoot()
        if isDKP or isMLNoDKP then
            MODULES.DKPManager:BossKillDetected(arg1, ...)
        end
    end
end

function Group:Refresh()
    local numGroupMembers = GetNumGroupMembers()

    self:_RefreshClasses()
    self:_RefreshLeadership()
    self:_RefreshMembers()

    for i = 1, numGroupMembers do
        local name, rank, _, _, _, _, _, _, _, _, isML, _ = GetRaidRosterInfo(i);

        tinsert(self.memberNames, name)

        -- leadership
        if rank > 0 then
            tinsert(self.leadership.assist, name)
            if rank == 2 then
                self.leadership.leader = name
            end
        end

        if isML then
            self.leadership.masterLoot = name
        end

        if name == self.myName then
            self.isML = isML
            self.isLeader = rank == 2
            self.isAssist = rank >= 1
            self.isDKP = name == self.leadership.dkpOfficer
        end
    end

    if self:IsInRaid() and not self:HasDKPOfficer() and not self.requestedDKPOfficer then
        self:RequestDKPOfficer()
    elseif not self:IsInRaid() then
        self.requestedDKPOfficer = false;
        self.leadership.dkpOfficer = nil
    end
    self.available = true

    self:AutoAward();
end

function Group:AutoAward()
    if not PDKP.canEdit then return end;
    if not self:IsInRaid() then return end;
    if not self.awardOnTimeAutomatically then return end;
    if self.onTimeAwarded then return end;

    print('Got here, time to check award status');
end

-----------------------------
--    Get/Set Functions    --
-----------------------------

-- Returns if the user is in a raid GROUP.
function Group:IsInRaid()
    return IsInRaid() and GetNumGroupMembers() >= 1
end

function Group:IsDKPOfficer()
    return self.isDKP
end

function Group:IsAssist()
    return self.isAssist or false
end

function Group:IsLeader()
    return self.isLeader or UnitIsGroupLeader("PLAYER")
end

function Group:IsMasterLoot()
    return self.isML
end

function Group:IsMemberDKPOfficer(name)
    return self.leadership.dkpOfficer == name
end

function Group:HasDKPOfficer()
    return self.leadership.dkpOfficer ~= nil
end

function Group:SetDKPOfficer(data)
    local charName, previous, fromRequest = unpack(data)

    fromRequest = fromRequest or false

    local isDKPOfficer = charName == previous

    if isDKPOfficer and fromRequest and self:IsMemberDKPOfficer(charName) then
        return
    end

    if fromRequest then
        isDKPOfficer = false
    end

    self.leadership.dkpOfficer = Utils:ternaryAssign(isDKPOfficer, nil, charName);
    local officerText = Utils:ternaryAssign(isDKPOfficer, 'is no longer the DKP Officer', 'is now the DKP Officer')
    PDKP.CORE:Print(charName .. ' ' .. officerText)
    self.classes['DKP'] = { charName }

    self.isDKP = Utils:GetMyName() == self.leadership.dkpOfficer

    if self:HasDKPOfficer() then
        self.requestedDKPOfficer = true
    end

    if self:IsLeader() then
        MODULES.RaidManager:PromoteLeadership(true)
    end
end

function Group:RequestDKPOfficer()
    if self.requestedDKPOfficer or self:HasDKPOfficer() then
        return
    end
    self.requestedDKPOfficer = true
    MODULES.CommsManager:SendCommsMessage('WhoIsDKP', 'request')
end

function Group:GetNumClass(class)
    if class == 'Total' then
        return #self.memberNames
    elseif self.classes[class] then
        return #self.classes[class]
    end
    return 0
end

function Group:GetRaidMemberObjects()
    local memberNames, members = {}, {}
    for i = 1, #self.memberNames do
        local member = GuildManager:GetMemberByName(self.memberNames[i])
        if member then
            tinsert(memberNames, member.name)
            tinsert(members, member)
        end
    end
    return memberNames, members
end

function Group:IsInInstance()
    local _, type, _, _, _, _, _, _, _ = GetInstanceInfo()
    return type ~= "none" and type ~= nil
end

function Group:IsInRaidInstance()

end

function Group:IsMemberInRaid(name)
    return tContains(self.memberNames, name) or false
end

-----------------------------
--    Refresh Functions    --
-----------------------------

function Group:_RefreshClasses()
    local CLASSES = MODULES.Constants.CLASSES
    for i = 1, #CLASSES do
        if type(self.classes[CLASSES[i]]) == "table" then
            wipe(self.classes[CLASSES[i]])
            if self.classes[CLASSES[i]] == nil then
                self.classes[CLASSES[i]] = {}
            end
        else
            self.classes[CLASSES[i]] = {}
        end
    end
    self.classes['Tank'] = {}
    self.classes['Total'] = {}
    self.classes['DKP'] = {}
end

function Group:_RefreshLeadership()
    for key, val in pairs(self.leadership) do
        if type(val) == "table" then
            wipe(self.leadership[key])
        else
            if key ~= 'dkpOfficer' then
                self.leadership[key] = nil
            elseif key == 'dkpOfficer' and (not self:IsInRaid() or val == nil) then
                self.leadership[key] = nil
            end
        end
    end
end

function Group:_RefreshMembers()
    wipe(self.memberNames)
    if type(self.memberNames) ~= "table" then
        self.memberNames = {}
    end
end

function Group:InitializePortrait()
    if ((not PDKP.canEdit) and (not self:IsLeader())) or self._initialized then
        return
    end

    local lineSep = _G['UIDropDownMenu_AddSeparator']
    local addBtn = _G['UIDropDownMenu_AddButton']

    local commonSettings = {
        hasArrow = false;
        notCheckable = true;
        iconOnly = false;
        tCoordLeft = 0;
        tCoordRight = 1;
        tCoordTop = 0;
        tCoordBottom = 1;
        tSizeX = 0;
        tSizeY = 8;
        tFitDropDownSizeX = true;
    }
    local titleSettings = {
        text = 'PDKP',
        isTitle = true;
        isUninteractable = true;
    }
    local dkpOfficerSettings = {
        text = '',
        isTitle = false;
        isUninteractable = false;
        keepShownOnClick = false;
        func = nil;
    }

    for key, val in pairs(commonSettings) do
        titleSettings[key] = val
        dkpOfficerSettings[key] = val
    end

    local dropdownList = _G['DropDownList1']
    dropdownList:HookScript('OnShow', function()
        local charName = strtrim(_G['DropDownList1Button1']:GetText())

        charName = Utils:RemoveColors(charName);

        local member = GuildManager:GetMemberByName(charName)

        if not (member and self:IsMemberInRaid(charName) and member.canEdit) then
            return
        end

        dkpOfficerSettings.text = Utils:ternaryAssign(self:IsMemberDKPOfficer(charName), 'Demote from DKP Officer', 'Promote to DKP Officer')
        dkpOfficerSettings.func = function(...)
            MODULES.CommsManager:SendCommsMessage('DkpOfficer', { charName, self.leadership.dkpOfficer, false })
        end

        lineSep(1)
        addBtn(titleSettings, 1) -- Title
        addBtn(dkpOfficerSettings, 1)
        lineSep(1)
    end)
end

MODULES.GroupManager = Group
