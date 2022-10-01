local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils;

local CommsManager, GroupManager, DKPManager, GuildManager, _;
local Comm = {}

Comm.__index = Comm

local setmetatable, pairs, tremove, tinsert = setmetatable, pairs, table.remove, table.insert
local type, floor = type, math.floor
local format = string.format
local GetServerTime = GetServerTime

function Comm:new(opts)
    local self = {}
    setmetatable(self, Comm); -- Set the metatable so we used entry's __index

    CommsManager = MODULES.CommsManager
    GroupManager = MODULES.GroupManager
    DKPManager = MODULES.DKPManager
    GuildManager = MODULES.GuildManager
    --SettingsDB = MODULES.Database:Settings()

    self.ogPrefix = opts['prefix']
    self.prefix = Utils:GetCommPrefix(self.ogPrefix)

    self.allowed_from_self = Utils:ternaryAssign(opts['self'] ~= nil, opts['self'], false)
    self.allowed_in_combat = Utils:ternaryAssign(opts['combat'] ~= nil, opts['combat'], true)
    self.channel = Utils:ternaryAssign(opts['channel'] ~= nil, opts['channel'], 'GUILD')
    self.requireCheck = Utils:ternaryAssign(opts['requireCheck'] ~= nil, opts['requireCheck'], true)
    self.officerOnly = Utils:ternaryAssign(opts['officerOnly'] ~= nil, opts['officerOnly'], false)
    self.forcedCache = Utils:ternaryAssign(opts['forcedCache'] ~= nil, opts['forcedCache'], false)
    self.isOfficerComm = Utils:ternaryAssign(opts['officerComm'] ~= nil, opts['officerComm'], false);
    self.forcedCacheTimer = nil

    self.registered = false;

    self.timeSinceLastRequest = nil

    if opts['isSelfComm'] then
        self.timeSinceLastRequest = MODULES.Options:GetLastSyncSent()
    end

    self.officersSyncd = {}

    self.channel, self.sendTo, self.priority, self.callbackFunc, self.onCommReceivedFunc = self:_Setup()

    if self:IsValid() and (not self.officerOnly or PDKP.canEdit) then
        if not opts['combat'] then
            self:_InitializeCache()
        end
        self:RegisterComm()
    else
        --PDKP:PrintD('Comm is not valid', self.ogPrefix)
    end

    return self
end

function Comm:CanSend()
    local member = GuildManager:GetMemberByName(Utils:GetMyName())
    if member ~= nil then
        return member.canEdit
    end
    return false
end

function Comm:VerifyCommSender(message, sender)
    if self.requireCheck then
        local sentMember = MODULES.GuildManager:GetMemberByName(sender)
        if sentMember == nil or not sentMember.canEdit then
            return
        end
    end

    if not self.allowed_from_self and sender == Utils:GetMyName() then
        return
    end

    if not self.allowed_in_combat and not self.open then
        if #self.cache == 0 then
            --PDKP:PrintD("Message received, waiting for combat to drop to process it.")
        end

        tinsert(self.cache, { ['message'] = message, ['sender'] = sender })
        return
    end

    self.onCommReceivedFunc(self, message, sender)
end

function Comm:RegisterComm()
    --PDKP:PrintD('Registering comm', self.prefix)
    self.registered = true;
    PDKP.CORE:RegisterComm(self.prefix, PDKP_OnCommsReceived)
end

function Comm:UnregisterComm()
    self.registered = false;
    PDKP.CORE:UnregisterComm(self.prefix);
end

function Comm:IsValid()
    local hasChannel = self.channel ~= nil and type(self.channel) == 'string'
    local hasPriority = self.priority == 'BULK' or self.priority == 'NORMAL' or self.priority == 'ALERT'
    local hasCommReceivedFunc = self.onCommReceivedFunc ~= nil and type(self.onCommReceivedFunc) == 'function'
    local hasCallbackFunc = self.callbackFunc == nil or type(self.callbackFunc) == 'function'
    return hasChannel and hasPriority and hasCommReceivedFunc and hasCallbackFunc
end

function Comm:GetSendParams()
    return { self.channel, self.sendTo, self.priority, self.callbackFunc }
end

function Comm:HandleOfficerCommStatus(member, myName, syncStatus)
    local instanceStatus, _ = Utils:GetInstanceStatus()

    if instanceStatus or syncStatus == false then
        if self.registered then
            return self:UnregisterComm()
        end
        return
    end

    if member.online and member:IsSyncReady() and not self.registered then
        self:RegisterComm()
    elseif self.registered and member.name ~= myName and not (member.online and member:IsSyncReady()) then
        self:UnregisterComm()
    end
end

-----------------------------
--    Private Functions    --
-----------------------------

function Comm:_Setup()
    local p = self.ogPrefix
    -- Comm: Channel, SendTo, Prio, CallbackFunc, OnCommReceivedFunc
    local commParams = {
        -- Sync Section
        ['SyncSmall'] = { 'GUILD', nil, 'NORMAL', nil, PDKP_OnComm_EntrySync }, -- Single Adds
        ['SyncDelete'] = { 'GUILD', nil, 'NORMAL', nil, PDKP_OnComm_EntrySync }, -- Single Deletes
        ['SyncLarge'] = { 'GUILD', nil, 'BULK', PDKP_SyncProgressBar, PDKP_OnComm_EntrySync }, -- Large merges to the guild
        ['SyncOver'] = { 'GUILD', nil, 'BULK', PDKP_SyncProgressBar, PDKP_OnComm_EntrySync }, -- Large overwrites to the guild

        ['RaidOver'] = { 'RAID', nil, 'BULK', PDKP_SyncProgressBar, PDKP_OnComm_EntrySync }, -- Large Overwrites for the raid group.
        ['RaidMerge'] = { 'RAID', nil, 'BULK', PDKP_SyncProgressBar, PDKP_OnComm_EntrySync }, -- Large overwrites directly to players.

        -- Auction Section
        ['StartBids'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },
        ['StopBids'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },

        -- Officer Bid Section
        ['AddBid'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },
        ['CancelBid'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },

        -- Player Bid section
        ['BidSubmit'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },
        ['BidCancel'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },
        ['AddTime'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_BidSync },

        -- DKP Section
        ['DkpOfficer'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_SetDKPOfficer },
        ['WhoIsDKP'] = { 'RAID', nil, 'ALERT', nil, PDKP_OnComm_GetDKPOfficer },

        ['SentInv'] = { 'WHISPER', nil, 'NORMAL', nil, PDKP_OnComm_SentInv },

        -- Sync Shame
        ['SyncShame'] = { 'GUILD', nil, 'ALERT', nil, PDKP_OnComm_SyncShame },
        ['SyncShameSync'] = { 'GUILD', nil, 'ALERT', nil, PDKP_OnComm_SyncShame },
    }

    if self.isOfficerComm == true then
        commParams[p] = { 'GUILD', nil, 'BULK', PDKP_SyncLockout, PDKP_OnComm_OfficerSync }
    end

    if commParams[p] then
        return unpack(commParams[p])
    end
    return nil
end

function Comm:_InitializeCache()
    self.cache = {};
    self.open = true
    self.eventsFrame = CreateFrame("Frame", nil, UIParent)
    local COMMS_EVENTS = { 'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED' };

    if self.ogPrefix == 'SentInv' then
        COMMS_EVENTS = { unpack(COMMS_EVENTS), 'GROUP_ROSTER_UPDATE'}
    end

    self.eventsFrame.comm = self
    for _, eventName in pairs(COMMS_EVENTS) do
        self.eventsFrame:RegisterEvent(eventName)
    end

    self.eventsFrame:SetScript("OnEvent", PDKP_Comms_OnEvent)
end

function Comm:_ProcessCache(frameCache)
    --PDKP:PrintD('Processing', #self.cache, 'cached messages')

    for i = #self.cache, 1, -1 do
        local transmission = self.cache[i]
        self:VerifyCommSender(transmission['message'], transmission['sender'])
        tremove(self.cache, i)
        tremove(frameCache, i)
    end
end

-----------------------------
--    OnComm Functions     --
-----------------------------

function PDKP_Comms_OnEvent(eventsFrame, event, _, ...)
    local comm = eventsFrame.comm

    if event == 'PLAYER_REGEN_DISABLED' then
        comm.open = false
    elseif event == 'PLAYER_REGEN_ENABLED' then
        comm.open = true
        if #comm.cache > 0 then
            --PDKP:PrintD("Start Cached message', #comm.cache")
            comm:_ProcessCache(comm.cache)
            --PDKP:PrintD('End Cached message', #comm.cache)
        end
    end
end

function PDKP_OnComm_SetDKPOfficer(_, message, _)
    local data = CommsManager:DataDecoder(message)
    GroupManager:SetDKPOfficer(data)
end

function PDKP_OnComm_GetDKPOfficer(_, message, sender)
    --PDKP:PrintD(sender, "RequestingDKP Officer")

    local data = CommsManager:DataDecoder(message)
    if data == 'request' and PDKP.canEdit and GroupManager:HasDKPOfficer() then
        CommsManager:SendCommsMessage('DkpOfficer', { GroupManager.leadership.dkpOfficer, GroupManager.leadership.dkpOfficer, true })
    end
end

function PDKP_OnComm_OfficerSync(comm, message, sender)
    local self = comm
    local pfx = self.ogPrefix
    if pfx == Utils:GetMyName() then
        local options = MODULES.Options
        --PDKP:PrintD("Processing Sync Request from:", sender)
        local shouldContinue = true

        self.timeSinceLastRequest = options:GetLastSyncSent()

        -- Check to see how long it's been since you've been requested to send a sync.
        if self.timeSinceLastRequest ~= nil then
            local server_time = GetServerTime()
            local timeSinceSync = Utils:SubtractTime(self.timeSinceLastRequest, server_time)
            if timeSinceSync <= Utils:GetSecondsInFiveMinutes() then
                shouldContinue = false;
                --PDKP:PrintD("TimeSinceSync", timeSinceSync);
            end
        end

        if MODULES.CommsManager.syncInProgress then
            shouldContinue = false;
        end

        --PDKP:PrintD("Should Continue:", shouldContinue)

        if shouldContinue == true then
            options:SetLastSyncSent()
            return MODULES.DKPManager:PrepareAdRequest()
        end
    elseif sender == pfx then
        PDKP.CORE:Print("Auto-syncing DKP with: ", sender)
        MODULES.CommsManager:ChunkedDecoder(message, sender)
    end
end

function PDKP_OnComm_EntrySync(comm, message, sender)
    local self = comm
    local pfx = self.ogPrefix
    local data

    if pfx == 'SyncSmall' or pfx == 'SyncDelete' or pfx == 'RaidMerge' then
        data = CommsManager:DataDecoder(message)
    end

    if pfx == 'SyncSmall' then
        return DKPManager:ImportEntry2(data, CommsManager:_Adler(message), 'Small')
    elseif pfx == 'SyncDelete' then
        return DKPManager:DeleteEntry(data, sender)
    elseif pfx == 'SyncLarge' or pfx == 'RaidMerge' then
        return MODULES.CommsManager:ChunkedDecoder(message, sender)
    elseif pfx == 'SyncOver' or pfx == 'RaidOver' then
        if MODULES.Database:HasAutoBackupEnabled() then
            MODULES.Database:CreateSnapshot();
        end
        data = CommsManager:DataDecoder(message)
        local group = MODULES.GroupManager;
        if PDKP.canEdit and group:IsInRaid() and group:HasDKPOfficer() then
            if not group:IsMemberInRaid(sender) then
               return GUI.Dialogs:Show('PDKP_OFFICER_OVERWRITE_CONFIRM', nil, {['data'] = data, ['sender'] = sender})
            end
        end
        DKPManager:ProcessOverwriteSync(data, sender)
        self:UnregisterComm()
    end
end

function PDKP_OnComm_BidSync(comm, message, sender)
    local self = comm
    local data = CommsManager:DataDecoder(message)

    local Auction = MODULES.AuctionManager
    local AuctionGUI = GUI.AuctionGUI

    if self.ogPrefix == 'StartBids' then
        Auction:ResetBeforeStart();
        local itemLink, itemName, iTexture = unpack(data)
        Auction.auctionInProgress = true
        AuctionGUI:StartAuction(itemLink, itemName, iTexture, sender)
        PDKP.AuctionTimer.startTimer()
        if PDKP.canEdit then
            GUI.Adjustment:InsertItemLink(itemLink)
        end

        if sender == Utils:GetMyName() then
            local channel = "RAID"
            if GroupManager:IsAssist() or GroupManager:IsLeader() then
                channel = "RAID_WARNING"
            end

            local text;

            local isTier, classTier = Auction:IsTierGear(itemName);

            if isTier then
                local classSpecific = '';
                for i, class in pairs(classTier) do
                    classSpecific = classSpecific .. class
                    if i ~= #classTier then
                        classSpecific = classSpecific .. ', ';
                    end
                end
                text = string.format("Starting bids for %s (%s)", itemLink, classSpecific);
            else
                text = string.format("Starting bids for %s", itemLink)
            end

            SendChatMessage(text, channel, nil, nil)
        end

    elseif self.ogPrefix == 'BidSubmit' then
        if not Auction:CanChangeAuction() then
            return
        end
        local member = MODULES.GuildManager:GetMemberByName(sender)
        local maxBid = MODULES.DKPManager:GetMaxBid()
        local memberDKP = member:GetDKP('total');

        if data > maxBid then
            data = maxBid
        end

        if data > memberDKP then
            data = memberDKP
        end

        local bidder_info = { ['name'] = member.name, ['bid'] = data, ['dkpTotal'] = memberDKP }
        CommsManager:SendCommsMessage('AddBid', bidder_info)
    elseif self.ogPrefix == 'StopBids' then
        if Auction:IsAuctionInProgress() then
            local manualStop = data['manualEnd']
            Auction:EndAuction(manualStop, sender)
        end
    elseif self.ogPrefix == 'AddBid' then
        GUI.AuctionGUI:CreateNewBidder(data)
    elseif self.ogPrefix == 'CancelBid' then
        GUI.AuctionGUI:CancelBidder(sender)
    elseif self.ogPrefix == 'RemoveBid' then
        GUI.AuctionGUI:CreateNewBidder(data);
    elseif self.ogPrefix == 'AddTime' then
        if Auction:IsAuctionInProgress() then
            AuctionGUI:AddTimeToAuction(sender)
        end
    end
end

function PDKP_OnComm_SentInv(comm, message, sender)
    local self = comm
    if self.ogPrefix ~= 'SentInv' then return end

    C_Timer.NewTicker(0.5, function()
        if StaticPopup_Visible("PARTY_INVITE") then
            AcceptGroup();
            StaticPopup_Hide("PARTY_INVITE")
        end
    end, 5)
end

function PDKP_OnComm_SyncShame(comm, message, sender)
    local self = comm
    local pfx = self.ogPrefix
    local data = CommsManager:DataDecoder(message)

    local db = MODULES.Database:Shame();

    if pfx == 'SyncShame' then
        db[sender] = data
    elseif pfx == 'SyncShameSync' then
        for name, player in pairs(data) do
            local dbPlayer = db[name];
            if dbPlayer then
                if dbPlayer.lastShame < player.lastShame then
                    dbPlayer.lastShame = player.lastShame
                    dbPlayer.active = player.active
                    dbPlayer.count = player.count
                end
                dbPlayer['id'] = player.id
            else
                db[name] = player
            end
        end
    end
end

function PDKP_SyncLockout(_, sent, total)
    local DKP = DKPManager
    local percentage = floor( (sent / total) * 100)

    --PDKP:PrintD("Sync Percentage: ", percentage);

    if percentage < 100 then
        DKP.autoSyncInProgress = true
    elseif percentage >= 100 then
        DKP.autoSyncInProgress = false
    end
end

function PDKP_SyncProgressBar(_, sent, total)
    local percentage = floor((sent / total) * 100)

    if Comm.start_time == nil then
        Comm.start_time = time()
    end

    if MODULES.CommsManager.syncInProgress == false then
        MODULES.CommsManager.syncInProgress = true;
    end

    if Comm.progress ~= percentage then
        Comm.progress = percentage
        local elapsed = time() - Comm.start_time
        PDKP_UpdatePushBar(percentage, elapsed)
    end

    if Comm.progress == nil or Comm.progress >= 100 then
        if Comm.progress >= 100 then
            PDKP.CORE:Print('Sync Complete')
        end
        MODULES.CommsManager.syncInProgress = false;
        Comm.progress = 0
        Comm.start_time = nil
    end
end

function PDKP_UpdatePushBar(percent, elapsed)
    local remaining = 100 - percent
    -- Percent per second
    local eta = (elapsed / percent) * remaining
    eta = floor(eta)

    local hours = format("%02.f", floor(eta / 3600));
    local mins = format("%02.f", floor(eta / 60 - (hours * 60)));
    local secs = format("%02.f", floor(eta - hours * 3600 - mins * 60));

    local etatext = mins .. ':' .. secs
    local statusText = 'PDKP Push: ' .. percent .. '%' .. ' ETA: ' .. etatext
    PDKP.PushBar.setAmount(percent, statusText)
end

MODULES.Comm = Comm
