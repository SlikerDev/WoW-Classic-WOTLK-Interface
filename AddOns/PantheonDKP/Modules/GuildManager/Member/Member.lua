local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils

local GetGuildRosterInfo, GetGuildRosterLastOnline = GetGuildRosterInfo, GetGuildRosterLastOnline
local setmetatable = setmetatable
local strsplit, strlower = strsplit, strlower
local tinsert, tremove, unpack = table.insert, table.remove, unpack
local floor = math.floor;
local GetServerTime = GetServerTime

local Member = {}

local guildDB, _;

local playerName = UnitName("PLAYER")

Member.__index = Member; -- Set the __index parameter to reference Member

function Member:new(guildIndex, server_time, leadershipRanks)
    local self = {};
    setmetatable(self, Member); -- Set the metatable so we used Members's __index

    guildDB = MODULES.Database:Guild()

    self.guildIndex = guildIndex
    self.server_time = server_time

    self.officerRank, self.classLeadRank = unpack(leadershipRanks)

    self:_GetMemberData(guildIndex)

    if self:IsRaidReady() then
        self:_InitializeDKP()
        self:Save()
    end

    if strlower(self.name) == strlower(playerName) then
        PDKP.char = self;
    end
    return self
end

function Member:Save()
    local dkp = {
        ['total'] = self.dkp['total'],
        ['snapshot'] = self.dkp['snapshot'],
    }

    if not Utils:tEmpty(self.dkp['entries']) then
        dkp['entries'] = self.dkp['entries']
    else
        return -- Don't save guildies who have no data associated with them.
    end

    guildDB[self.name] = dkp
end

function Member:IsRaidReady()
    return self.lvl >= 68 or self.canEdit or self.isOfficer
end

function Member:IsStrictRaidReady()
    if PDKP:IsDev() then
        return self.canEdit or self.isOfficer;
    end
    return self.lvl >= 70 and (self.canEdit or self.isOfficer)
end

function Member:CanEdit()
    return self.canEdit or self.rankIndex <= 3 or self.isOfficer
end

function Member:GetDKP(dkpVariable)
    if self.dkp['total'] == nil then
        return 0;
    end
    if dkpVariable == nil then
        return floor(self.dkp['total']);
    elseif dkpVariable == 'display' then
        if PDKP:IsDev() and PDKP.showInternalDKP then
            return self.dkp['total'];
        end
        return floor(self.dkp['total']);
    elseif dkpVariable == 'Decimal' then
        return self.dkp['total'];
    end
    return self.dkp[dkpVariable]
end

function Member:HasEntries()
    return self.dkp['entries'] ~= nil and #self.dkp['entries'] > 0;
end

function Member:AddEntry(entryId)
    local memberEntries = self.dkp['entries']
    local _, entryIndex = Utils:tfind(memberEntries, entryId);

    if entryIndex == nil then
        tinsert(self.dkp['entries'], entryId);
    end
end

function Member:RemoveEntry(entryId)
    local memberEntries = self.dkp['entries']
    local _, entryIndex = Utils:tfind(memberEntries, entryId);

    if entryIndex ~= nil then
        tremove(self.dkp['entries'], entryIndex);
    end
end

function Member:UpdateDKP(dkpChange)
    self.dkp['total'] = self:GetDKP('Decimal') + dkpChange;
    self:Save();
end

function Member:UpdateSnapshot(previousTotal)
    if previousTotal == nil then
        --PDKP:PrintD(self.name, "PreviousTotal was nil still");
        return;
    end;

    if previousTotal < 0 then
        previousTotal = previousTotal * -1;
    end

    self.dkp['snapshot'] = previousTotal;
    self:Save();
end

function Member:_InitializeDKP()
    if Utils:tEmpty(guildDB[self.name]) and self.dkp['total'] == nil then
    end

    if Utils:tEmpty(guildDB[self.name]) then
        --PDKP:PrintD("Initializing Default DKP For", self.name);
        self:_DefaultDKP()
    else
        self:_LoadDatabaseData()
    end

    self:Save()
end

function Member:_DefaultDKP()
    self.dkp = {
        ['total'] = 30,
        ['snapshot'] = 30,
        ['entries'] = {},
    }
end

function Member:Reinitialize()
    guildDB = MODULES.Database:Guild()
    self:_LoadDatabaseData();
end

function Member:_LoadDatabaseData()
    local dbData = guildDB[self.name]
    if dbData ~= nil then
        self.dkp = {
            ['total'] = dbData['total'] or 0,
            ['snapshot'] = dbData['snapshot'] or 30,
            ['entries'] = dbData['entries'] or {},
        }
    end
end

function Member:_GetMemberData(index)
    index = index or self.guildIndex;

    self.name, self.rank, self.rankIndex, self.lvl, self.class, self.zone,
    self.note, self.officerNote, self.online, self.status, self.classFileName = GetGuildRosterInfo(index)

    if self.name == nil then
        self.name = '';
    end

    self.name, self.server = strsplit('-', self.name) -- Remove the server name from their name.

    self.isOfficer = self.rankIndex <= self.officerRank
    self.canEdit = self.isOfficer
    self.isOfficer = self.canEdit

    --self.isClassLeader = self.rankIndex == self.classLeadRank -- BUG: A bunch of people are getting this flag set. Probably a guild permission issue?
    self.isClassLeader = false;

    self.isInLeadership = self.isOfficer or self.isClassLeader

    self.lastOnline = {}
    self.lastOnline['years'], self.lastOnline['months'], self.lastOnline['days'], self.lastOnline['hours'] = GetGuildRosterLastOnline(index);

    self.formattedName, self.coloredClass = Utils:FormatTextByClass(self.name, self.class) -- Color their name & class.
    self.isBank = self.name == MODULES.Constants.BANK_NAME


    self.visible = true

    self.dkp = {};
    self.lockouts = {}
end

function Member:RecentlyPlayed()
    local years = self.lastOnline['years']
    local months = self.lastOnline['months']
    local days = self.lastOnline['days']
    if years ~= nil and years > 0 then
        return false;
    elseif months ~= nil and months > 0 then
        return false
    elseif days ~= nil and days > 21 then
        return false
    end
    return true
end

function Member:HasSub30DKP()
    return self.dkp['total'] ~= nil and self.dkp['total'] < 30;
end

function Member:GetEntries()
    if self:HasEntries() then
        return true, self.dkp['entries'];
    end
    return false, {};
end

function Member:CheckForWrongfulDecay()
    return self:CheckForEmptyEntries() and self.dkp['total'] < 30;
end

function Member:IsSyncReady()
    if not self.isInLeadership then return false end

    local syncSettings = MODULES.Database:Sync()

    if syncSettings['autoSync'] == nil or syncSettings['autoSync'] == false then
        return false;
    else
        local server_time = GetServerTime()
        local officerSyncs = syncSettings['officerSyncs']
        local lastSync = officerSyncs[self.name]
        if lastSync == nil then
            return true
        else
            local timeSinceSync = Utils:SubtractTime(lastSync, server_time)
            return timeSinceSync > Utils:GetSecondsInDay()
        end
    end
end

function Member:MarkSyncReceived()
    local syncSettings = MODULES.Database:Sync()
    local server_time = GetServerTime()
    syncSettings['officerSyncs'][self.name] = server_time
end

MODULES.Member = Member;
