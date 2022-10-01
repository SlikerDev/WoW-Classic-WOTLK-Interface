local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils;
local GUtils = PDKP.GUtils

--local Utils = PDKP.Utils;

local GetServerTime = GetServerTime;
local sort = table.sort;
--local random = math.random;
local tinsert = table.insert;

local opts = {};

local db;

opts.__index = opts; -- Set the __index parameter to reference

local tabName = 'view_shame_leaderboard_button';

function opts:Initialize()
    if not GUI.TabController._initialized then
        return C_Timer.After(2, function()
            self:Initialize()
        end)
    end

    self.players = {};

    local isPlayer = MODULES.Options:GetNSFWSync();
    MODULES.CommsManager:RegisterSyncShame();
    db = MODULES.Database:Shame();
    self:announce(isPlayer);

    self.updateNextOpen = false;

    if isPlayer ~= true then
        return ;
    end

    self:CreateInterface();
end

function opts:CreateInterface()

    self.parentFrame = GUI.TabController.tab_names[tabName].frame;

    local slf = GUtils:createBackdropFrame('pdkp_shame_list', self.parentFrame, 'Standings');
    slf:SetPoint("TOPLEFT", self.parentFrame, "TOPLEFT", 5, -15)
    slf:SetPoint("BOTTOMRIGHT", self.parentFrame, "BOTTOMRIGHT", -5, 0)

    local scroll = PDKP.SimpleScrollFrame:new(slf.content)
    local scrollFrame = scroll.scrollFrame
    local scrollContent = scrollFrame.content;

    slf.scrollContent = scrollContent;
    slf.scrollContent:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT");
    slf.scroll = scroll;
    slf.scrollFrame = scrollFrame;

    self.list_frame = slf;

    self.list_frame:SetScript("OnShow", function()
        self:ShamesUpdated();
    end)

    local sb = CreateFrame("Button", "$parent_load_more_btn", self.parentFrame, "UIPanelButtonTemplate")
    sb:SetSize(80, 22) -- width, height
    sb:SetText("Refresh")
    sb:SetPoint("BOTTOMRIGHT", self.parentFrame, "BOTTOMRIGHT", 4, -22)

    sb:SetScript("OnClick", function()
        self:CreatePlayerList()
    end)
end

function opts:CreatePlayerList()

    self:RefreshData();

    if #self.players == 0 then
        self.list_frame.desc:SetText("No players have been sync shamed");
        return ;
    end

    local scrollContent = self.list_frame.scrollContent;

    scrollContent:WipeChildren() -- Wipe previous children frames;

    local scrollWidth = scrollContent:GetWidth()

    local createPlayerFrame = function()
        local f = CreateFrame("Frame", nil, scrollContent, nil)
        f:SetSize(scrollWidth, 18)
        f.name = f:CreateFontString(f, "OVERLAY", "GameFontHighlightLeft")
        f.breakdown = f:CreateFontString(f, 'OVERLAY', 'GameFontHighlightRight')
        f.name:SetHeight(18)
        f.breakdown:SetHeight(18)
        f.name:SetPoint("LEFT")
        f.breakdown:SetPoint("RIGHT")
        return f
    end

    local masterFrame = CreateFrame("Frame", nil, scrollContent, nil);
    masterFrame:SetSize(scrollWidth, 18);
    masterFrame.name = masterFrame:CreateFontString(masterFrame, "OVERLAY", "GameFontNormalLeft")
    masterFrame.name:SetHeight(18);
    masterFrame.name:SetPoint("LEFT");
    masterFrame.name:SetText("Master Syncer");

    scrollContent:AddChild(masterFrame);

    local masterLabel = createPlayerFrame();

    masterLabel.name:SetText(self.players[1].name);
    masterLabel.breakdown:SetText(self.players[1].breakdown);

    scrollContent:AddChild(masterLabel);

    local spacer = createPlayerFrame();

    scrollContent:AddChild(spacer);

    local shamedSyncs = CreateFrame("Frame", nil, scrollContent, nil);
    shamedSyncs:SetSize(scrollWidth, 18);
    shamedSyncs.name = shamedSyncs:CreateFontString(shamedSyncs, "OVERLAY", "GameFontNormalLeft")
    shamedSyncs.name:SetHeight(18);
    shamedSyncs.name:SetPoint("LEFT");
    shamedSyncs.name:SetText("Shamed Syncs");
    shamedSyncs.breakdown = shamedSyncs:CreateFontString(shamedSyncs, "OVERLAY", "GameFontNormalLeft")
    shamedSyncs.breakdown:SetHeight(18);
    shamedSyncs.breakdown:SetPoint("RIGHT");
    shamedSyncs.breakdown:SetText("Last Shamed");

    scrollContent:AddChild(shamedSyncs);

    for i = 2, #self.players do
        local player_frame = createPlayerFrame()
        local player = self.players[i]

        if player ~= nil then
            player_frame.name:SetText("#" .. i .. " " .. player['name'])
            player_frame.breakdown:SetText(player['breakdown'])
            scrollContent:AddChild(player_frame)
        end
    end

    self.updateNextOpen = false;
end

function opts:RefreshData()
    local players = db
    local listPlayers = {};
    local now = GetServerTime();

    for name, player in pairs(players) do
        if player.active then
            local member = MODULES.GuildManager:GetMemberByName(name);
            if member ~= nil then
                local lastShame = player.lastShame --floor(random(now - 86400, now));
                local timeSince = now - lastShame;

                local details = {
                    ['name'] = member.formattedName,
                    ['active'] = player.active,
                    ['lastShame'] = lastShame,
                    ['id'] = now,
                    ['breakdown'] = Utils:GetTimeSinceFormat(timeSince),
                    ['count'] = 0,
                }

                tinsert(listPlayers, details);
            else
                PDKP:PrintD("Player " .. name .. " not found in guild");
            end
        end
    end

    sort(listPlayers, function(a, b)
        return a['lastShame'] < b['lastShame']
    end)

    self.players = listPlayers;
end

function opts:ShamesUpdated()
    if self.list_frame:IsVisible() then
        self:CreatePlayerList();
    else
        self.updateNextOpen = true;
    end
end

-- Announce shame streaks

function opts:announce(isPlayer, isShamed)
    isShamed = isShamed or false;

    if isShamed then
        MODULES.Options:SetLastSyncRec();
    end

    local lastShame = MODULES.Options:GetLastSyncRec();
    local data = {
        ['lastShame'] = lastShame,
        ['active'] = isPlayer,
        ['id'] = GetServerTime(),
        ['count'] = 0
    }
    MODULES.CommsManager:SendCommsMessage('SyncShame', data)
end

GUI.Options = opts

