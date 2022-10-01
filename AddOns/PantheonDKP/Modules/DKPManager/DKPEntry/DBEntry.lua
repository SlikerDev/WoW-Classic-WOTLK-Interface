local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils

local Guild, DKPManager, _, Ledger, DKP_DB, CommsManager;

local dbEntry = {}
local core_details = { 'reason', 'dkp_change', 'officer', 'names' }

local GetServerTime = GetServerTime
local tsort, tonumber, pairs, type, tinsert = table.sort, tonumber, pairs, type, tinsert
local tContains = tContains
local ceil = math.ceil

local _BOSS_KILL = 'Boss Kill'
local _ITEM_WIN = 'Item Win'
local _OTHER = 'Other'
local _DECAY = 'Decay'
local _PHASE = 'Phase'
local _CONSOLIDATION = "Consolidation";

local _DECAY_AMOUNT = 0.9;
local _DECAY_REVERSAL = 1.111;
local _PHASE_AMOUNT = 0.5;
local _PHASE_REVERSAL = 2.0;

dbEntry.__index = dbEntry

--- Set modules up ---
function dbEntry:Initialize()
    Guild = MODULES.GuildManager;
    DKPManager = MODULES.DKPManager;
    --Lockouts = MODULES.Lockouts;
    Ledger = MODULES.LedgerManager;
    DKP_DB = MODULES.Database:DKP();
    CommsManager = MODULES.CommsManager;
end

--- New object creation ---
function dbEntry:new(entry_details)
    local self = {}
    setmetatable(self, dbEntry); -- Set the metatable so we used entry's __index

    if type(entry_details) == "table" then
        self.ed = entry_details;
    elseif type(entry_details) == "string" then
        self.ed = CommsManager:DatabaseDecoder(entry_details);
        self.adler = CommsManager:_Adler(entry_details);
    else
        return nil
    end

    self.adler = self.adler or nil;
    self.id = self.ed['id'] or GetServerTime()
    self.reason = self.ed['reason'] or 'No Valid Reason'
    self.dkp_change = tonumber(self.ed['dkp_change']) or 0;

    self.officer = self.ed['officer'];
    self.names = self.ed['names'];
    self.pugNames = self.ed['pugNames'] or {};

    self.deleted = self.ed['deleted'] or false
    self.deletedBy = self.ed['deletedBy'] or ''

    self.members = {}
    self.removedMembers = self.ed['removedMembers'] or {};
    self.sd = {} -- Save Details

    self.lockoutsChecked = false
    self.adEntry = self.ed['adEntry'] or false

    self.isNewPhaseEntry = false;

    if self.reason == _PHASE then
        local phaseDB = MODULES.Database:Phases()
        if not tContains(phaseDB, self.id) then
            self.isNewPhaseEntry = true;
        end
    end

    -- Grab the members, and non-members in the entry for later use.
    self:GetMembers()

    --- Local Entry Details
    self.wday = Utils:GetWDay(self.id)
    self.yday = Utils:GetYDay(self.id)
    self.weekNumber = Utils:GetWeekNumber(self.id)

    self:_GetSpecificDetails();
    self:_SetupDisplayInfo();

    self:GetPreviousTotals();
    self:GetDecayAmounts();

    return self;
end

function dbEntry:Save(exportEntry)
    wipe(self.sd)
    exportEntry = exportEntry or false
    self:GetSaveDetails()

    if exportEntry == false then
        self:GetSaveDetails();
        DKP_DB[self.id] = CommsManager:DatabaseEncoder(self.sd)
        return DKP_DB[self.id]
    elseif PDKP.canEdit and exportEntry then
        self.exportedBy = Utils:GetMyName()
        DKPManager:ExportEntry(self)
    end
end

function dbEntry:CalculateDecayAmounts()
end

--- Public Functions ---

function dbEntry:GetDecayAmounts(refresh)
    refresh = refresh or false;
    if self.reason == _DECAY and (next(self.decayAmounts) == nil or refresh) then
        for _, member in pairs(self.members) do
            if self.decayAmounts[member.name] == nil or refresh then
                if not self.decayReversal or self.deleted then
                    self.decayAmounts[member.name] = Utils:RoundToDecimal(member:GetDKP() * _DECAY_AMOUNT, 1);
                end
            end
        end
    elseif self.reason == _PHASE and (next(self.decayAmounts) == nil or refresh) then
        for _, member in pairs(self.members) do
            if self.decayAmounts[member.name] == nil or refresh then
                if not self.decayReversal or self.deleted then
                    self.decayAmounts[member.name] = Utils:RoundToDecimal(member:GetDKP() * _PHASE_AMOUNT, 1);
                    if self.officer == Utils:GetMyName() then
                        self.previousTotals[member.name] = member:GetDKP();
                    end
                end
            end
        end
    end
end

function dbEntry:GetPreviousTotals(refresh)
    refresh = refresh or false;
    if (self.reason == _DECAY or self.reason == _PHASE or self.reason == _CONSOLIDATION) and (next(self.previousTotals) == nil or refresh) then
        for _, member in Utils:PairByKeys(self.members) do
            if self.previousTotals[member.name] == nil or refresh then
                self.previousTotals[member.name] = member:GetDKP('Decimal');
            end
        end
    end
end

function dbEntry:MarkAsDeleted(deletedBy)
    self.deleted = true
    self.deletedBy = deletedBy

    if self.reason == 'Decay' or self.reason == "Phase" then
        self.decayReversal = true
    end
    self:Save();
end

function dbEntry:UndoEntry()
    local members, _ = self:GetMembers();
    for _, member in pairs(members) do
        local memberDKP = member:GetDKP('Decimal');
        local dkp_change = self.dkp_change * -1;
        if self.reason == _DECAY then
            if self.decayReversal and not self.deleted then
                dkp_change = memberDKP - ceil(memberDKP * _DECAY_REVERSAL);
            else
                dkp_change = memberDKP - Utils:RoundToDecimal(memberDKP * _DECAY_AMOUNT, 1);
            end
        elseif self.reason == _PHASE then
            dkp_change = self.decayAmounts[member.name] * -1;
            self:_UpdateSnapshots();
        end

        member:UpdateDKP(dkp_change)
        member:Save();
    end
end

function dbEntry:ApplyEntry()
    local members, _ = self:GetMembers();
    for _, member in pairs(members) do

        member:AddEntry(self.id);

        local memberDKP = member:GetDKP();
        local dkp_change = self.dkp_change;

        if self.reason == _DECAY or self.reason == _PHASE then
            if self.decayReversal and not self.deleted then
                -- Actual Reversal
                local reversalAmount = Utils:ternaryAssign(self.reason == _DECAY, _DECAY_REVERSAL, _PHASE_REVERSAL)
                dkp_change = memberDKP - ceil(memberDKP * reversalAmount)
                dkp_change = dkp_change * -1;
            else
                local decayAmount = Utils:ternaryAssign(self.reason == _DECAY, _DECAY_AMOUNT, _PHASE_AMOUNT)
                dkp_change = memberDKP - Utils:RoundToDecimal(memberDKP * decayAmount, 1);
                dkp_change = dkp_change * -1;
            end

            if memberDKP <= 30 and not self.decayReversal then
                dkp_change = 0;
            end

            if self.isNewPhaseEntry and not self.decayReversal and not self.deleted then
                dkp_change = self.decayAmounts[member.name]
            end

            if (self.reason == _PHASE or self.reason == _DECAY) and dkp_change > 0 then
                dkp_change = dkp_change * -1;
            end

            if dkp_change < 0 and self.decayReversal and not self.deleted then
                dkp_change = dkp_change * -1;
            end

            self.decayAmounts[member.name] = dkp_change;
        end
        member:UpdateDKP(dkp_change);
        member:Save();
    end
    return true;
end

--- MISC Public functions ---

function dbEntry:GetSaveDetails()
    wipe(self.sd)

    self.sd['id'] = self.id or GetServerTime()
    self.sd['reason'] = self.reason or 'No Valid Reason'
    self.sd['dkp_change'] = self.dkp_change or 0
    self.sd['officer'] = self.officer
    self.sd['names'] = self.names
    self.sd['hash'] = self.hash or Ledger:GenerateEntryHash(self, true);
    self.sd['deleted'] = self.deleted
    self.sd['deletedBy'] = self.deletedBy

    if self.reason == _BOSS_KILL then
        self.sd['boss'] = self.boss
    elseif self.reason == _ITEM_WIN then
        self.sd['item'] = self.item
    elseif self.reason == _OTHER then
        self.sd['other_text'] = self.other_text
    elseif self.reason == _DECAY or self.reason == _PHASE or self.reason == _CONSOLIDATION then
        if self.previousTotals == nil or next(self.previousTotals) == nil then
            self:GetPreviousTotals()
            self:CalculateDecayAmounts()
        end
        if self.decayReversal then
            self.sd['decayReversal'] = true
            self.sd['previousDecayId'] = self.previousDecayId;
        end
    end

    local dependants = {
        ['previousTotals'] = self.previousTotals,
        ['pugNames'] = self.pugNames,
    }

    if self.reason == _DECAY or self.reason == _PHASE then
        dependants['decayAmounts'] = self.decayAmounts
    end

    if self.reason == _PHASE then
        dependants['previousTotals'] = self.previousTotals;
    end

    if #self.removedMembers > 0 then
        self.sd['removedMembers'] = self.removedMembers;
    end

    for name, val in pairs(dependants) do
        if type(val) == "table" then
            if val and next(val) ~= nil then
                self.sd[name] = val
            end
        end
    end

    return self.sd
end

function dbEntry:GetMembers()
    wipe(self.members)

    for _, name in pairs(self.names) do
        local member = Guild:GetMemberByName(name)
        if member ~= nil then
            tinsert(self.members, member)
        elseif not tContains(self.pugNames, name) then
            tinsert(self.pugNames, name)
        end
    end
    return self.members, self.pugNames
end

function dbEntry:IsMemberInEntry(name)
    return tContains(self.names, name)
end

function dbEntry:IsValid()
    local isValid = true

    for i = 1, #core_details do
        local detail = self[core_details[i]]
        if type(detail) == "string" then
            isValid = isValid and not (Utils:IsEmpty(detail))
        elseif type(detail) == "table" then
            isValid = isValid and not (Utils:tEmpty(detail))
        end
    end

    if self.reason == _BOSS_KILL then
        local hasRaid = not Utils:IsEmpty(self.raid)
        local hasBoss = not Utils:IsEmpty(self.boss)
        isValid = isValid and hasRaid and hasBoss
    end

    return isValid
end

function dbEntry:RemoveMember(name)
    local memberIndex;

    for i = 1, #self.names do
        if self.names[i] == name then
            memberIndex = i
            break ;
        end
    end

    table.insert(self.removedMembers, name);
    table.remove(self.names, memberIndex)

    self:GetMembers()
    self.formattedNames = self:_GetFormattedNames()

    if self.previousTotals[name] ~= nil then
        self.previousTotals[name] = nil
    end
end

function dbEntry:GetSerializedSelf()
    local sd = self:GetSaveDetails();
    local serializedSD = {};
    local keys = {};
    for key, val in Utils:PairByKeys(sd) do
        serializedSD[key] = PDKP.CORE:Serialize(val)
        table.insert(keys, key);
    end
    return serializedSD, keys;
end

--- Private functions ---

function dbEntry:_SetupDisplayInfo()
    self.formattedNames = self:_GetFormattedNames()
    self.formattedOfficer = self:_GetFormattedOfficer()
    self.change_text = self:_GetChangeText()
    self.historyText = self:_GetHistoryText()
    self.formattedID = Utils:Format12HrDateTime(self.id)
    self.collapsedHistoryText = self:_GetCollapsedHistoryText()
end

function dbEntry:_GetSpecificDetails()
    self.boss = self.ed['boss'] or nil
    self.raid = self.ed['raid'] or self:_GetRaid()
    self.item = self.ed['item'] or 'Not linked'
    self.other_text = self.ed['other_text'] or ''
    self.previousTotals = self.ed['previousTotals'] or {}
    self.decayAmounts = self.ed['decayAmounts'] or {}
    self.decayReversal = self.ed['decayReversal'] or false
end

function dbEntry:_GetRaid()
    if self.boss == nil then
        return nil
    end
    self.raid = MODULES.Constants.BOSS_TO_RAID[self.boss]
    return self.raid
end

--- Visual Displays ---

function dbEntry:_GetFormattedNames()
    tsort(self.members, function(a, b)
        return Utils:ternaryAssign(b.class == a.class, b.name > a.name, b.class > a.class);
    end)

    local formattedNames = ''
    for key, member in pairs(self.members) do
        if key ~= 1 then
            formattedNames = formattedNames .. ', '
        end
        formattedNames = formattedNames .. member.formattedName
    end

    tsort(self.pugNames, function(a, b)
        return a < b
    end)

    for _, nonMember in pairs(self.pugNames) do
        if nonMember ~= nil then
            formattedNames = formattedNames .. ', '
            formattedNames = formattedNames .. '|cffE71D36' .. nonMember .. ' (P)' .. "|r"
        end
    end

    return formattedNames
end

function dbEntry:_GetChangeText()
    local color = Utils:ternaryAssign(self.dkp_change >= 0, MODULES.Constants.SUCCESS, MODULES.Constants.WARNING)

    if self.reason == _DECAY or self.reason == _PHASE then
        local percent = Utils:ternaryAssign(self.reason == _DECAY, "10% DKP", "50% DKP");

        if self.decayReversal then
            return Utils:FormatTextColor(percent, MODULES.Constants.SUCCESS)
        end
        return Utils:FormatTextColor(percent, MODULES.Constants.WARNING)
    elseif self.reason == _CONSOLIDATION then

    else
        return Utils:FormatTextColor(self.dkp_change .. ' DKP', color)
    end
end

function dbEntry:_GetHistoryText()
    if self.reason == _BOSS_KILL and (self.raid == nil or self.boss == nil) then
        return Utils:FormatTextColor('Boss Kill: None Selected', MODULES.Constants.WARNING)
    end

    local text;
    if self.reason == _BOSS_KILL then
        text = self.raid .. ' - ' .. self.boss
    elseif self.reason == _ITEM_WIN then
        text = 'Item Win - ' .. self.item
    elseif self.reason == _OTHER then
        text = Utils:ternaryAssign(not (Utils:IsEmpty(self.other_text)), 'Other - ' .. self.other_text, 'Other')
    elseif self.reason == _DECAY or self.reason == _PHASE then
        local dtext = Utils:ternaryAssign(self.reason == _DECAY, 'Weekly Decay', 'Phase Decay')

        if self.decayReversal then
            return Utils:FormatTextColor(dtext .. ' - Reversal', MODULES.Constants.SUCCESS)
        end
        return Utils:FormatTextColor(dtext, MODULES.Constants.WARNING)
    elseif self.reason == _CONSOLIDATION then
        return Utils:FormatTextColor('DKP Consolidation', MODULES.Constants.SUCCESS);
    end

    local color = Utils:ternaryAssign(self.dkp_change > 0, MODULES.Constants.SUCCESS, MODULES.Constants.WARNING)
    return Utils:FormatTextColor(text, color)
end

function dbEntry:_GetCollapsedHistoryText()
    local texts = {
        ['On Time Bonus'] = self.reason,
        ['Completion Bonus'] = self.reason,
        ['Unexcused Absence'] = self.reason,
        ['Boss Kill'] = self.boss,
        ['Item Win'] = 'Item Win - ' .. self.item,
        ['Other'] = Utils:ternaryAssign(self.other_text ~= '', 'Other - ' .. self.other_text, 'Other'),
        ['Decay'] = 'Weekly Decay',
        ['Phase'] = 'Phase Decay',
        ['Consolidation'] = 'Database Consolidation',
    }
    local text = texts[self.reason]

    if self.reason == _DECAY or self.reason == _PHASE then
        local dtext = Utils:ternaryAssign(self.reason == _DECAY, 'Weekly Decay', 'Phase Decay')

        if self.decayReversal then
            return Utils:FormatTextColor(dtext .. ' - Reversal', MODULES.Constants.SUCCESS)
        end
        return Utils:FormatTextColor(dtext, MODULES.Constants.WARNING)
    elseif self.reason == _CONSOLIDATION then
        return Utils:FormatTextColor('DKP Consolidation', MODULES.Constants.SUCCESS);
    end

    local color = Utils:ternaryAssign(self.dkp_change > 0, MODULES.Constants.SUCCESS, MODULES.Constants.WARNING)
    return Utils:FormatTextColor(text, color)
end

function dbEntry:_GetFormattedOfficer()
    local officer = MODULES.GuildManager:GetMemberByName(self.officer)

    if officer == nil then
        return '|CFF' .. 'E71D36' .. self.officer .. '|r'
    end

    return officer.formattedName
end

function dbEntry:_UpdateSnapshots()
    self:GetSaveDetails();
    for _, member in pairs(self.members) do
        local pt = self.previousTotals[member.name];
        if pt == nil then
            local dv = self.decayAmounts[member.name];
            member:UpdateSnapshot(dv * 2);
        else
            member:UpdateSnapshot(pt)
        end
    end
end

MODULES.DKPEntry = dbEntry
