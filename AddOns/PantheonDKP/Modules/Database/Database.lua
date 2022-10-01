local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;

local DB = {}

local database_names = { 'personal', 'guild', 'dkp', 'pug', 'settings', 'lockouts', 'ledger', 'decayTracker', 'sync', 'phases', 'snapshot', 'cache', 'consolidations', 'shame' }

local function UpdateGuild()
    DB.server_faction_guild = string.lower(UnitFactionGroup("player") .. " " .. GetNormalizedRealmName() .. " " .. (GetGuildInfo("player") or "unguilded"))
end

function DB:Initialize()
    -- Below API requires delay after loading to work after variables loaded event
    UpdateGuild()

    local dbRef = self.server_faction_guild;

    if type(PDKP_DB[dbRef]) ~= "table" then
        PDKP_DB[dbRef] = {}
    end

    for i = 1, #database_names do
        local db = database_names[i]
        if type(PDKP_DB[dbRef][db]) ~= "table" then
            PDKP_DB[dbRef][db] = {}
        end
    end

    self:Personal()[UnitName("PLAYER")] = true

    self:_Migrations()
end

function DB:_Migrations()

    -- Remove incorrect ledger
    local db = self:Server()
    if db['Ledger'] and db['ledger'] then
        db['Ledger'] = nil;
    end
end

function DB:Global()
    return PDKP_DB['global']
end

function DB:Server()
    return PDKP_DB[self.server_faction_guild]
end

function DB:Personal()
    return PDKP_DB[self.server_faction_guild]['personal']
end

function DB:Guild()
    return PDKP_DB[self.server_faction_guild]['guild']
end

function DB:DKP()
    return PDKP_DB[self.server_faction_guild]['dkp']
end

function DB:Pug()
    return PDKP_DB[self.server_faction_guild]['pug']
end

function DB:Settings()
    return PDKP_DB[self.server_faction_guild]['settings']
end

function DB:Sync()
    return PDKP_DB[self.server_faction_guild]['settings']['sync']
end

function DB:Lockouts()
    return PDKP_DB[self.server_faction_guild]['lockouts']
end

function DB:Ledger()
    return PDKP_DB[self.server_faction_guild]['ledger']
end

function DB:Decay()
    return PDKP_DB[self.server_faction_guild]['decayTracker']
end

function DB:Phases()
    return PDKP_DB[self.server_faction_guild]['phases']
end

function DB:Consolidations()
    return PDKP_DB[self.server_faction_guild]['consolidations'];
end

function DB:Snapshot()
    return PDKP_DB[self.server_faction_guild]['snapshot']
end

function DB:Cache()
    return PDKP_DB[self.server_faction_guild]['cache']
end

function DB:Shame()
    return PDKP_DB[self.server_faction_guild]['shame']
end


function DB:CheckForDKPMigrations()
    local global = self:Global();

    if global['migratedDKP'] == nil then
       -- PDKP:PrintD("FixingDKP");
        global['migratedDKP'] = true
        MODULES.CommsManager:FixDKPDB();
    end
end

function DB:CreateSnapshot()
    PDKP.CORE:Print("Creating Database Backup");
    PDKP_DB[self.server_faction_guild]['snapshot'] = {
        ['guild'] = Utils:DeepCopy(self:Guild()),
        ['dkp'] = Utils:DeepCopy(self:DKP()),
        ['phases'] = Utils:DeepCopy(self:Phases()),
        ['decay'] = Utils:DeepCopy(self:Decay()),
        ['ledger'] = Utils:DeepCopy(self:Ledger()),
        ['sync'] = Utils:DeepCopy(self:Sync()),
        ['consolidations'] = Utils:DeepCopy(self:Consolidations()),
    }
end

function DB:TestDKP()
    if PDKP_DB['TESTDKP'] == nil then
        PDKP_DB['TESTDKP'] = {};
    end
    return PDKP_DB['TESTDKP']
end

function DB:ApplySnapshot()
    PDKP.CORE:Print("Applying Snapshot");
    local snap = self:Snapshot()
    PDKP_DB[self.server_faction_guild]['guild'] = Utils:DeepCopy(snap['guild'])
    PDKP_DB[self.server_faction_guild]['dkp'] = Utils:DeepCopy(snap['dkp'])
    PDKP_DB[self.server_faction_guild]['phases'] = Utils:DeepCopy(snap['phases'])
    PDKP_DB[self.server_faction_guild]['decay'] = Utils:DeepCopy(snap['decay'])
    PDKP_DB[self.server_faction_guild]['Ledger'] = Utils:DeepCopy(snap['Ledger'])
    PDKP_DB[self.server_faction_guild]['sync'] = Utils:DeepCopy(snap['sync'])
    PDKP_DB[self.server_faction_guild]['consolidations'] = Utils:DeepCopy(snap['consolidations'])
end

function DB:ResetSnapshot()
    PDKP.CORE:Print("Resetting Snapshot");
    PDKP_DB[self.server_faction_guild]['snapshot'] = nil;
    PDKP_DB[self.server_faction_guild]['snapshot'] = {};
end

function DB:HasSnapshot()
    local snap = self:Snapshot();
    return snap['guild'] ~= nil;
end

function DB:ResetAllDatabases()
    for i = 1, #database_names do
        local db = database_names[i]
        if db ~= 'snapshot' and db ~= 'settings' then
            PDKP_DB[self.server_faction_guild][db] = {}
        end
    end
end

function DB:ProcessDBOverwrite(db, data)
    wipe(PDKP_DB[self.server_faction_guild][db])
    for k, v in pairs(data) do
        PDKP_DB[self.server_faction_guild][db][k] = v
    end
    PDKP_DB[self.server_faction_guild][db] = Utils:DeepCopy(data);
end

function DB:ResetLockouts()
    PDKP_DB[self.server_faction_guild]['lockouts'] = {}
    return PDKP_DB[self.server_faction_guild]['lockouts']
end

function DB:UpdateSetting(settingName, value)
    if settingName == 'disallow_invite' then
        PDKP_DB[self.server_faction_guild]['settings']['ignore_from'] = value
    elseif settingName == 'invite_commands' then
        PDKP_DB[self.server_faction_guild]['settings']['invite_commands'] = value
    elseif settingName == 'ignore_pugs' then
        PDKP_DB[self.server_faction_guild]['settings']['ignore_pugs'] = value
    end
end

function DB:MarkPhaseStart(phaseNumber)
    phaseNumber = phaseNumber or MODULES.Constants.PHASE
    PDKP_DB['global']['phases'][phaseNumber] = true;
end

function DB:HasPhaseStarted()
    local phase = MODULES.Constants.PHASE;
    return PDKP_DB['global']['phases'][phase]
end

function DB:HasAutoBackupEnabled()
    local settings = self:Settings();
    return settings['sync']['autoBackup'] == true
end

function DB:GetSyncInCombat()
    local settings = self:Settings()
    if settings and settings['sync'] then
        return settings['sync']['syncInCombat'] == true
    end
    return false;
end

MODULES.Database = DB
