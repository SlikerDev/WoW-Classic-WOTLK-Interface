local name, CLM = ...

local LIB_CLM, _ = LibStub:NewLibrary("ClassicLootManager", 1)
if LIB_CLM then
    LIB_CLM.CLM = CLM
end

CLM.CORE = LibStub("AceAddon-3.0"):NewAddon(name, "AceEvent-3.0", "AceBucket-3.0")

CLM.MODULES = {}
CLM.MODELS = { LEDGER = {} }
CLM.CONSTANTS = {}
CLM.GUI = {}
CLM.OPTIONS = {}
CLM.ALERTS = {}

CLM.AUTOVERSION = "v2.3.1"

CLM.LOG = LibStub("LibLogger"):New()

local CORE = CLM.CORE
local LOG = CLM.LOG
local MODULES = CLM.MODULES

local function Initialize_SavedVariables()
    if type(CLM2_DB) ~= "table" then
        CLM2_DB = {
            global = {
                version = {
                    major = 0,
                    minor = 0,
                    patch = 0,
                    changeset = ""
                },
                logger = {
                    severity = CLM.LOG.SEVERITY.ERROR,
                    verbosity = false
                }
            }
        }
    end

    if type(CLM2_Logs) ~= "table" then
        CLM2_Logs = {}
    end
end

local function Initialize_Logger()
    LOG:SetSeverity(CLM2_DB.global.logger.severity)
    LOG:SetVerbosity(CLM2_DB.global.logger.verbosity)
    LOG:SetPrefix("CLM")
    LOG:SetDatabase(CLM2_Logs)
end

local function Initialize_Versioning()
    -- Parse autoversion
    local major, minor, patch, changeset = string.match(CLM.AUTOVERSION, "^v(%d+).(%d+).(%d+)-?(.*)")
    local old = CLM2_DB.global.version
    local new = {
        major = tonumber(major) or 2,
        minor = tonumber(minor) or 0,
        patch = tonumber(patch) or 0,
        changeset = changeset or ""
    }
    -- set new version
    CLM2_DB.global.version = new
    -- update string
    changeset = new.changeset
    if changeset and changeset ~= "" then
        changeset = "-" .. changeset
    else
        changeset = ""
    end
    CORE.versionString = string.format(
        "v%s.%s.%s%s",
        new.major or 0,
        new.minor or 0,
        new.patch or 0,
        changeset)
    -- return both for update purposes
    return old, new
end

function CORE:GetVersion()
    return CLM2_DB.global.version
end

function CORE:GetVersionString()
    return self.versionString or ""
end

function CORE:_InitializeCore()
    LOG:Trace("CORE:_InitializeCore()")

    MODULES.Database:Initialize()
    MODULES.ConfigManager:Initialize()
    MODULES.ACL:Initialize()
end

function CORE:_InitializeBackend()
    LOG:Trace("CORE:_InitializeBackend()")
    MODULES.Logger:Initialize()
    MODULES.Comms:Initialize()
    MODULES.EventManager:Initialize()
    MODULES.GuildInfoListener:Initialize()
    MODULES.LedgerManager:Initialize()
    -- if type(self.Debug) == "function" then
    --     self.Debug()
    -- end
end

function CORE:_InitializeFeatures()
    LOG:Trace("CORE:_InitializeFeatures()")
    -- We keep the order
    MODULES.ProfileManager:Initialize()
    MODULES.RosterManager:Initialize()
    MODULES.PointManager:Initialize()
    MODULES.LootManager:Initialize()
    MODULES.RaidManager:Initialize()
    MODULES.StandbyStagingManager:Initialize()
    MODULES.AuctionManager:Initialize()
    MODULES.AutoAward:Initialize()
    MODULES.BiddingManager:Initialize()
    MODULES.ProfileInfoManager:Initialize()
    MODULES.AutoAwardManager:Initialize()
    MODULES.LootQueueManager:Initialize()
    MODULES.AuctionHistoryManager:Initialize()
    MODULES.SandboxManager:Initialize()
    -- Globals
    CLM.Migration:Initialize() -- Initialize Migration
    CLM.GlobalConfigs:Initialize() -- Initialize global configs
    CLM.GlobalSlashCommands:Initialize() -- Initialize global slash handlers
    CLM.GlboalChatMessageHandlers:Initialize() -- Initialize global chat message handlers
    CLM.Integration:Initialize() -- Initialize external (to wow) integrations
    CLM.DatabaseUpgradeImporter:Initialize() -- Initialize import for JSON data from CLM1
    CLM.ItemValueOverrideImporter:Initialize() -- Initialize import for item value overrides through CSV
end

function CORE:_InitializeMinimap()
    LOG:Trace("CORE:_InitializeMinimap()")
    -- Initialize Minmap
    MODULES.Minimap:Initialize()
end

function CORE:_InitializeOptions()
    LOG:Trace("CORE:_InitializeOptions()")
    -- No GUI / OPTIONS should be dependent on each other ever, only on the managers
    for _, module in pairs(CLM.OPTIONS) do
        module:Initialize()
    end
end

function CORE:_InitializeGUI()
    LOG:Trace("CORE:_InitializeGUI()")
    for _, module in pairs(CLM.GUI) do
        module:Initialize()
    end
end

function CORE:_Enable()
    LOG:Trace("CORE:_Enable()")
    MODULES.Comms:Enable()
    MODULES.LedgerManager:Enable()
end

local stages = {
    "_InitializeCore",
    "_InitializeBackend",
    "_InitializeMinimap",
    "_InitializeFeatures",
    "_InitializeOptions",
    "_InitializeGUI"
}

local finalStage = "_Enable"

local function getStage(stage)
    return stages[stage] or finalStage
end

function CORE:_SequentialInitialize(stageNum)
    LOG:Trace("CORE:_SequentialInitialize()")
    local stage = getStage(stageNum)
    LOG:Info("Initialization stage [%s]", stage)
    self[stage]()

    if stage == finalStage then
        LOG:Info(CLM.L["Boot complete"])
        return
    end
    C_Timer.After(0.1, function() CORE:_SequentialInitialize(stageNum + 1) end)
end

function CORE:_ExecuteInitialize()
    if self._initialize_fired then return end
    self._initialize_fired = true
    C_Timer.After(1, function() CORE:_SequentialInitialize(1) end)
end

function CORE:_Initialize()
    LOG:Trace("CORE:_Initialize()")
    -- Block direct lib timetravel
    --@non-debug@
    if SLASH_LibEventSourcing_TimeTravel1 then
        SLASH_LibEventSourcing_TimeTravel1 = nil
    end
    --@end-non-debug@
    if not self._initialize_fired then
        CORE:_ExecuteInitialize()
        self:UnregisterEvent("GUILD_ROSTER_UPDATE")
    end
end

function CORE:OnInitialize()
    -- Fix ML UI issue - https://bit.ly/3tc8nvw
    hooksecurefunc(MasterLooterFrame, 'Hide', function(s) s:ClearAllPoints() end);
    -- Initialize SavedVariables
    Initialize_SavedVariables()
    --  Early Initialize logger
    Initialize_Logger()
    -- Initialize Versioning
    Initialize_Versioning()
    -- Initialize AddOn
    LOG:Trace("OnInitialize")
    self._initialize_fired = false
    CORE:RegisterEvent("GUILD_ROSTER_UPDATE")
    SetGuildRosterShowOffline(true)
    GuildRoster()
    -- We schedule this in case GUILD_ROSTER_UPDATE won't come early enough
    C_Timer.After(20, function()
        CORE:_ExecuteInitialize()
    end)
end

function CORE:OnEnable()
      -- Called when the addon is enabled
end

function CORE:OnDisable()
      -- Called when the addon is disabled
end

function CORE:GUILD_ROSTER_UPDATE(...)
    LOG:Trace("GUILD_ROSTER_UPDATE")
    local inGuild = IsInGuild()
    local numTotal = GetNumGuildMembers()
    if inGuild and numTotal ~= 0 then
        self:_Initialize()
    end
end

