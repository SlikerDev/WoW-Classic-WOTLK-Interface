local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
--local GUtils = PDKP.GUtils;
--local Utils = PDKP.Utils;

local Sync = {};

function Sync:Initialize()
    if not PDKP.canEdit then return end;

    self.settings = {
        ['type'] = nil,
        ['group'] = nil,
    };
end

function Sync:ResetSettings()
    self.settings['type'] = nil
    self.settings['group'] = nil
end

function Sync:AdjustSettings(setting, value)
    self.settings[setting] = value
end

function Sync:Reset()
    self:ResetSettings();
    GUI.SyncGUI:ClearChecked();
    GUI.SyncGUI:ToggleSubmit();
end

function Sync:GetSyncCommChannel(group, type)
    if group == 'Guild' and type == 'Merge' then
        return 'SyncLarge'
    elseif group == 'Guild' and type == 'Overwrite' then
        return 'SyncOver'
    elseif group == 'Raid' and type == 'Merge' then
        return 'RaidMerge'
    elseif group == 'Raid' and type == 'Overwrite' then
        return 'RaidOver'
    end
    return nil;
end

function Sync:GetSyncData(type)
    local syncData = {};
    if type == 'Overwrite' then
        syncData = MODULES.DKPManager:PrepareOverwriteExport();
    elseif type == 'Merge' then
        local DKP = MODULES.DKPManager
        local entries, total = DKP.currentLoadedWeekEntries, DKP.numCurrentLoadedWeek
        syncData = { ['total'] = total, ['entries'] = entries }
    end
    return syncData;
end

function Sync:SendShameSync()
    local syncData = MODULES.Database:Shame();
    return MODULES.CommsManager:SendCommsMessage("SyncShameSync", syncData);
end

function Sync:SendSync()

    if MODULES.Options:GetNSFWSync() then
        self:SendShameSync();
    end

    local syncType = self.settings['type']
    local syncGroup = self.settings['group']

    local syncData = self:GetSyncData(syncType);
    local commsChannel = self:GetSyncCommChannel(syncGroup, syncType);

    if syncData ~= nil and commsChannel ~= nil then
        MODULES.CommsManager:SendCommsMessage(commsChannel, syncData)
        self:Reset();
    else
        PDKP.CORE:Print("Something went wrong during the sync process");
    end
end

function Sync:IsSyncReady()
    return self.settings['type'] ~= nil and self.settings['group'] ~= nil
end

MODULES.SyncManager = Sync;
