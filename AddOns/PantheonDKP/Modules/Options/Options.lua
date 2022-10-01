local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils;

local Options = {}

local strlower = string.lower
local GetServerTime = GetServerTime
local random = math.random

function Options:Initialize()
    self.db = MODULES.Database:Settings() or {};
    self:_InitializeDBDefaults()
    self:SetupLDB()
end

function Options:SetupLDB()
    local pdkp_options = {
        name = "PantheonDKP",
        handler = PDKP,
        type = "group",
        childGroups = "tab",
        args = {
            showMinimapButton = {
                type = "toggle",
                name = "Show the Minimap button",
                desc = "Display a Minimap button to quickly access the addon interface or options",
                get = function(info)
                    return not self.db['minimap'].hide
                end,
                set = function(info, val)
                    if val then
                        GUI.Minimap:Show()
                    else
                        GUI.Minimap:Hide()
                    end
                    self.db['minimap'].hide = not val
                end,
                width = 2.5,
                order = 1,
            },
            ignorePUGS = {
                type = "toggle",
                name = "Ignore PUGS",
                desc = "Ignore PUG auto invite requests",
                get = function(info)
                    return not self.db['ignore_pugs']
                end,
                set = function(info, val)
                    GUI.RaidTools.options['ignore_PUGS']:SetChecked(val)
                    self.db['ignore_pugs'] = not val
                end,
                width = 2.5,
                order = 2,
            },
            bossKillPopup = {
                type = "toggle",
                name = "Boss Kill Popup",
                desc = "Shows the boss kill popup if you are DKP Officer / Master Looter",
                get = function(info)
                    return self.db['boss_kill_popup']
                end,
                set = function(info, val)
                    self.db['boss_kill_popup'] = val
                end,
                width = 2.5,
                order = 3,
            },
            autoCombatLog = {
                type = "toggle",
                name = "Automatic Combat Logging",
                desc = "Automatically Enables / Disables combat logging when in a raid",
                get = function(info)
                    return self.db['auto_combat_log']
                end,
                set = function(info, val)
                    self.db['auto_combat_log'] = val
                end,
                width = 2.5,
                order = 3,
            },
            tab1 = {
                type = "group",
                name = "Syncing",
                width = "full",
                order = 5,
                args = {
                    --spacer1 = {
                    --    type = "description",
                    --    name = "Once per day, per officer, your addon will automatically sync the last two weeks worth of data. Auto sync will not work while in a dungeon, raid, battleground or arena.",
                    --    width = "full",
                    --    order = 1,
                    --},
                    --autoSync = {
                    --    type = "toggle",
                    --    name = "Auto Sync",
                    --    desc = "Synchronize DKP entries with officers automatically, once per day.",
                    --    get = function(info)
                    --        return self.db['sync']['autoSync']
                    --    end,
                    --    set = function(info, val)
                    --        self.db['sync']['autoSync'] = val
                    --    end,
                    --    width = 2.5,
                    --    order = 2,
                    --},
                    autoDBBackup = {
                        type = "toggle",
                        name = "Automatic Database Backup",
                        desc = "Automatically backup your database when an overwrite is detected",
                        get = function(info)
                            return self.db['sync']['autoBackup']
                        end,
                        set = function(info, val)
                            self.db['sync']['autoBackup'] = val
                        end,
                        width = 2.5,
                        order = 2,
                    },
                    syncInCombat = {
                        type = "toggle",
                        name = "Sync In Combat (Reload Required)",
                        desc = "Allows overwrite syncs to occur while in combat. Disable this if you experience lag spikes during the overwrite.",
                        get = function(info)
                            return self.db['sync']['syncInCombat']
                        end,
                        set = function(info, val)
                            self.db['sync']['syncInCombat'] = val
                        end,
                        width = 2.5,
                        order = 3,
                    },
                    spacer2 = {
                        type = "description",
                        name = "These values decide how many entries you want to process at a time when receiving a push (auto or manual) from an officer. Higher values result in faster processing, but may cause lag.",
                        width = "full",
                        order = 4,
                    },
                    processingChunkSize = {
                        type = "select",
                        name = "Processing Chunk Size",
                        values = {
                            [2] = "2x",
                            [3] = "3x",
                            [4] = "4x",
                            [5] = "5x",
                        },
                        desc = "The amount of items you want to process in one frame update.",
                        get = function(info)
                            return self.db['sync']['processingChunkSize'] or 2
                        end,
                        set = function(info, val)
                            self.db['sync']['processingChunkSize'] = val
                        end,
                        style = "dropdown",
                        width = 1,
                        order = 5,
                    },
                    decompressChunkSize = {
                        type = "select",
                        name = "Decompression Chunk Size",
                        desc = "The amount of items you want to decompress in one frame update.",
                        values = {
                            [2] = "2x",
                            [4] = "4x",
                            [8] = "8x",
                            [16] = "16x",
                            [32] = "32x",
                        },
                        style = "dropdown",
                        get = function(info)
                            return self.db['sync']['decompressChunkSize'] or 4
                        end,
                        set = function(info, val)
                            self.db['sync']['decompressChunkSize'] = val
                        end,
                        width = 1,
                        order = 6,
                    },
                    spacer3 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 7,
                    },
                    changeCommPrefix = {
                        type = "select",
                        name = "Comm Channel Prefix",
                        desc = "Changes your comm channel prefix, so that you can sync without affecting the whole guild.",
                        values = {
                            ["1"] = "1",
                            ["4"] = "4",
                            ["5"] = "5",
                        },
                        get = function(info)
                            return Utils.CommPrefixNumber
                        end,
                        set = function(info, val)
                            MODULES.CommsManager:UnregisterComms()
                            Utils.CommPrefixNumber = val;
                            MODULES.CommsManager:Reinitialize()
                        end,
                        width = 1,
                        order = 8,
                    },
                    spacer4 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 7,
                    },
                    displayProcessingSpeed = {
                        type = "select",
                        name = "Display Processing Speed",
                        values = {
                            [2] = "2x",
                            [4] = "4x",
                            [8] = "8x",
                            [16] = "16x",
                            [32] = "32x",
                            [64] = "64x",
                        },
                        desc = "The amount of items you want to visually update in one frame update.",
                        get = function(info)
                            return self.db['sync']['displayProcessingChunkSize'] or 16
                        end,
                        set = function(info, val)
                            self.db['sync']['displayProcessingChunkSize'] = val
                        end,
                        style = "dropdown",
                        width = 1,
                        order = 5,
                    },
                    spacer5 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 7,
                    },
                    nsfwSync = {
                        type = "toggle",
                        name = "Sync Shame Mini-game",
                        desc = "A mini game within PantheonDKP. Once enabled, you will be able to compete with other Sync Shame users for the title of Master Sync",
                        get = function(info)
                            return self.db['sync']['nsfwSync']
                        end,
                        set = function(info, val)
                            self.db['sync']['nsfwSync'] = val
                            self:SetLastSyncRec()
                            if val == true then
                                PDKP.CORE:Print("Your participation in Sync Shame game is appreciated. Hold in yer sync!");
                            end
                            GUI.Options:announce(val, true)
                        end,
                        width = 2.5,
                        order = 4,
                    },
                },
            },
            tab2 = {
                type = "group",
                name = "Database",
                width = "full",
                order = 6,
                args = {
                    spacer0Tab2 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 1,
                    },
                    createBackup = {
                        type = "execute",
                        name = "Create DB Backup",
                        desc = "Create a database snapshot for use in the future",
                        func = function()
                            MODULES.Database:CreateSnapshot()
                        end,
                        disabled = function()
                            return MODULES.Database:HasSnapshot()
                        end,
                        width = 1,
                        order = 1,
                    },
                    spacer1Tab2 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 2,
                    },
                    ApplyBackup = {
                        type = "execute",
                        name = "Restore DB Backup",
                        desc = "Restore your database to it's previously backed up state",
                        disabled = function()
                            return not MODULES.Database:HasSnapshot()
                        end,
                        func = function()
                            MODULES.Database:ApplySnapshot()
                            ReloadUI()
                        end,
                        width = 1,
                        order = 3,
                    },
                    spacer2Tab2 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 4,
                    },
                    ResetBackup = {
                        type = "execute",
                        name = "Wipe DB Backup",
                        desc = "Wipe your database backup",
                        func = function()
                            MODULES.Database:ResetSnapshot()
                        end,
                        disabled = function()
                            return not MODULES.Database:HasSnapshot()
                        end,
                        width = 1,
                        order = 5,
                    },
                    spacer3Tab2 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 6,
                    },
                    ResetAllDB = {
                        type = "execute",
                        name = "Purge All Databases",
                        desc = "This is irreversible. All database tables will be reset. Backups & settings will not be affected.",
                        func = function()
                            MODULES.Database:ResetAllDatabases()
                            ReloadUI()
                        end,
                        width = 1,
                        order = 7,
                    },
                    spacer4Tab2 = {
                        type = "description",
                        name = "This will consolidate (Reduce the size) of your Database. You should only execute this command if you're an officer, who has been told to do so.",
                        width = "full",
                        order = 8,
                    },
                    ConsolidateDB = {
                        type = "execute",
                        name = "Consolidate Database",
                        desc = "This is irreversible. Use at your own risk.",
                        func = function()
                            MODULES.DKPManager:ConsolidateEntries(false);
                        end,
                        width = 1,
                        order = 9,
                    },
                },
            },
        }
    }


    LibStub("AceConfig-3.0"):RegisterOptionsTable("PantheonDKP", pdkp_options, nil)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PantheonDKP"):SetParent(InterfaceOptionsFramePanelContainer)
end

function Options:_InitializeDBDefaults()
    if type(self.db['minimap']) ~= 'table' then
        self.db['minimap'] = nil;
    end

    local dbTopLevelKeys = {
        ['ignore_from'] = { ['value'] = self.db['ignore_from'], ['default'] = {}, },
        ['minimap'] = { ['value'] = self.db['minimap'], ['default'] = { ['pos'] = 207, ['hide'] = false }, },
        ['sync'] = { ['value'] = self.db['sync'], ['default'] = {}, },
        ['ignore_pugs'] = { ['value'] = self.db['ignore_pugs'], ['default'] = true, },
        ['boss_kill_popup'] = {['value'] = self.db['boss_kill_popup'], ['default'] = true},
        ['auto_combat_log'] = {['value'] = self.db['auto_combat_log'], ['default'] = true},
        ['invite_commands'] = { ['value'] = self.db['invite_commands'], ['default'] = { 'inv', 'invite' }, },
    }

    for key, obj in pairs(dbTopLevelKeys) do
        self.db[key] = Utils:ternaryAssign(obj['value'] ~= nil, obj['value'], obj['default']);
    end

    local syncTableKeys = {
        ['lastSyncSent'] = { ['default'] = nil, },
        ['officerSyncs'] = { ['default'] = {}, },
        ['totalEntries'] = { ['default'] = 0, },
        ['autoSync'] = { ['default'] = false, },
        ['nsfwSync'] = { ['default'] = false, },
        ['lastSyncRec'] = {['default'] = nil},
        ['processingChunkSize'] = { ['default'] = 2, },
        ['decompressChunkSize'] = { ['default'] = 4, },
        ['autoBackup'] = { ['default'] = true },
        ['syncInCombat'] = { ['default'] = false, },
        ['displayProcessingChunkSize'] = { ['default'] = 16 }
    }

    for key, obj in pairs(syncTableKeys) do
        self.db['sync'][key] = Utils:ternaryAssign(self.db['sync'][key] ~= nil, self.db['sync'][key], obj['default']);
    end

    -- Set this as the default for now.
    self.db['sync']['autoBackup'] = true;

    if self.db['sync']['lastSyncRec'] == nil then
        self.db['sync']['lastSyncRec'] = self:SetLastSyncRec();
    end

    -- Disable this until it's tested to be stable.
    if self.db['sync']['autoSync'] ~= nil then
        self.db['sync']['autoSync'] = false;
    end
end

function Options:GetLastSyncSent()
    return self.db['sync']['lastSyncSent']
end

function Options:GetLastSyncRec()
    return self.db['sync']['lastSyncRec'] or GetServerTime();
end

function Options:GetBossKillPopup()
    return self.db['boss_kill_popup'];
end

function Options:GetCombatLogging()
    if self.db == nil then
        return nil
    else
        return self.db['auto_combat_log']
    end
end

function Options:SetLastSyncSent()
    self.db['sync']['lastSyncSent'] = GetServerTime()
end

function Options:SetLastSyncRec()
    --print("Setting new last sync rec");
    self.db['sync']['lastSyncRec'] = GetServerTime()
    return self.db['sync']['lastSyncRec'];
end

function Options:GetAutoSyncStatus()
    if self.db == nil then
        return false
    else
        return self.db['sync']['autoSync'];
    end
end

function Options:GetSyncInCombat()
    return MODULES.Database:GetSyncInCombat();
end

function Options:IsPlayerIgnored(playerName)
    for _, name in pairs(self.db['ignore_from']) do
        if strlower(playerName) == strlower(name) then
            return true
        end
    end
    return false
end

function Options:NSFWSync()
    local chance = 10;
    --if PDKP:IsDev() then
    --    chance = 2;
    --end

    local triggered = random(chance) == 2;

    if triggered then
        local lastSyncTimestamp = self:GetLastSyncRec();
        local currentTimestamp = GetServerTime();

        local timeSince = currentTimestamp - lastSyncTimestamp;

        local days, hours, minutes, seconds = Utils:GetTimeSince(timeSince);

        SendChatMessage("Oh fuck you're gonna make me sync...", "SAY", nil, nil);
        SendChatMessage("Oh fuck you're gonna make me sync...", "EMOTE", nil, nil);
        SendChatMessage("Oh fuck you're gonna make me sync...", "RAID", nil, nil);
        SendChatMessage("Oh fuck you're gonna make me sync...", "PARTY", nil, nil);
        SendChatMessage("Oh fuck you're gonna make me sync...", "GUILD", nil, nil);
        PDKP:PrintError("You failed to hold in your sync. Pathetic...");

        self:SetLastSyncRec();

        C_Timer.After(5, function()
            local msg = "I - ... I uncontrollably sync'd after: " .. days .. " days, " .. hours .. " hours, " .. minutes .. " minutes and " .. seconds .. " seconds. That... That was euphoric...";
            SendChatMessage(msg, "GUILD", nil, nil);
            GUI.Options:announce(true, true);
        end);
    else
        PDKP.CORE:Print("You held in your sync. Well done soldier, you live to sync another day.");
    end
end

function Options:processingChunkSize()
    return self.db['sync']['processingChunkSize'] or 2
end

function Options:displayProcessingChunkSize()
    return self.db['sync']['displayProcessingChunkSize'] or 16;
end

function Options:decompressChunkSize()
    return self.db['sync']['decompressChunkSize'] or 32
end

function Options:GetInviteCommands()
    return self.db['invite_cmds'] or { 'inv', 'invite' }
end

function Options:GetNSFWSync()
    return self.db['sync']['nsfwSync'] or false
end

MODULES.Options = Options
