local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;

local Member;

local tContains = tContains

local GetServerTime = GetServerTime

local IsInGuild, GetNumGuildMembers, GuildRoster = IsInGuild, GetNumGuildMembers, GuildRoster
local _, _ = GuildRosterSetOfficerNote, GetGuildInfo

local GuildManager = {}

function GuildManager:Initialize()
    self.initiated = false
    self.bankIndex = nil
    self.officers = {}
    self.classLeaders = {}
    self.online = {}
    self.members = {}
    self.memberNames = {}
    self.guildies = {}
    self.guildFrameOpened = false;
    self.numOfMembers, self.numOnlineMembers = 0, 0

    self.lastMembersUpdate = 0;

    PDKP.player = {}
    self.playerName = Utils:GetMyName()

    if not IsInGuild() then
        return
    end

    Member = MODULES.Member
    self.GuildDB = MODULES.Database:Guild()

    if PDKP:IsDev() then
        --Utils:WatchVar(self.members, 'Guild Members');
    end

    self:GetMembers()
    self.initiated = true
end

function GuildManager:Reinitialize()
    for _, member in pairs(self.members) do
        member:Reinitialize();
    end
end

function GuildManager:IsNewMemberObject(name)
    return not tContains(self.memberNames, name)
end

function GuildManager:IsMemberInDatabase(name)
    return self.GuildDB[name] ~= nil
end

function GuildManager:IsGuildMember(name)
    return tContains(self.guildies, name)
end

function GuildManager:GetMembers()
    if not self:AllowMemberUpdate() then
        --PDKP:PrintD("Stopping Member Update Request");
        return self.online, self.members
    end;

    GuildRoster()

    self:_GetLeadershipRanks()

    self.classLeaders, self.officers, self.online = {}, {}, {}

    self.numOfMembers, self.numOnlineMembers, _ = GetNumGuildMembers()

    local server_time = GetServerTime()
    self.lastMembersUpdate = server_time;

    for i = 1, self.numOfMembers do
        local member = Member:new(i, server_time, { self.officerRank, self.classLeadRank })
        local isNew = self:IsNewMemberObject(member.name)

        if member.name ~= nil then
            self.guildies[#self.guildies + 1] = member.name;
        end

        if member.name == self.playerName then
            PDKP.canEdit = member.canEdit
        end

        if member:IsRaidReady() then
            if member.name == nil then
                member.name = ''
            end
            if member.isOfficer then
                self.officers[member.name] = member
            end
            if member.isClassLeader then
                self.classLeaders[member.name] = member
            end

            if isNew then
                self.members[member.name] = member;
                self.memberNames[#self.memberNames + 1] = member.name
            end

            if member.online then
                self.online[member.name] = member
            elseif self.online[member.name] ~= nil then
                self.online[member.name] = nil
            end
        end
    end
    return self.online, self.members -- Always return, even if it's empty for edge cases.
end

function GuildManager:GetMemberByName(name)
    if tContains(self.memberNames, name) then
        return self.members[name]
    end
    return nil
end

function GuildManager:AllowMemberUpdate()
    return true;
end

function GuildManager:IsMemberOfficer(name)
    local member = self:GetMemberByName(name)

    if member == nil then
        return false
    end

    return member.isOfficer
end

function GuildManager:GetOnlineNames()
    local onlineMembers, _ = self:GetMembers()
    local onlineNames = {}
    for name, val in pairs(onlineMembers) do
        if val ~= nil then
            tinsert(onlineNames, name)
        end
    end
    return onlineNames
end

function GuildManager:_GetLeadershipRanks()
    if self.officerRank ~= nil then return end

    local numRanks = GuildControlGetNumRanks()
    for i = 1, numRanks do
        local perm = C_GuildInfo.GuildControlGetRankFlags(i)
        local listen, speak, promote, demote, invite, kick, o_note = perm[3], perm[4], perm[5], perm[6], perm[7], perm[8], perm[12]
        if listen and speak and promote and demote and invite and kick and o_note and i ~= 1 then
            self.officerRank = i -1
        elseif invite and kick and promote and demote then
            self.classLeadRank = i -1
        end

        --local testOut = string.format("Rank %d: %s, listen: %s, speak: %s, promote: %s, demote: %s, invite: %s,
        --kick: %s, o_note: %s", i, GuildControlGetRankName(i), tostring(listen), tostring(speak), tostring(promote),
        --tostring(demote), tostring(invite), tostring(kick), tostring(o_note))
        --PDKP:PrintD(testOut)
    end
end

function GuildManager:CheckForNegatives()
    for _, member in pairs(self.members) do
        if member:GetDKP() < 0 then
            return true;
        end
    end
    return false;
end

function GuildManager:GetOfficers()
    return self.officers;
end

MODULES.GuildManager = GuildManager
