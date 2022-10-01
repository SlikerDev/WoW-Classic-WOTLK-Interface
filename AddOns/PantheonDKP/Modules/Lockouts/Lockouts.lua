local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;

local Lockouts = {}

function Lockouts:Initialize()
    self.weekNumber = Utils:GetWeekNumber(GetServerTime())
    self.db = MODULES.Database:Lockouts()
    self.newWeek = false

    if self.db[self.weekNumber] == nil then
        self.newWeek = true
        self.db = MODULES.Database:ResetLockouts()
        self.db[self.weekNumber] = {}
    end
end

function Lockouts:GetLastDecayId()
    local entries = MODULES.DKPManager.entries;
    for _, entry in Utils:PairByKeys(entries) do
        if entry.reason == 'Decay' then
            return entry.id;
        end
    end
end

function Lockouts:VerifyMemberLockouts(_)
    return true;
    --local validMembers = {};
    --local boss = entry.boss;
    -- TODO: This may cause issues for entries that are not from this week...
    -- TODO: Maybe skip this for now?

    --if entry.weekNumber == self.weekNumber then
    --    entry.lockoutsChecked = true;
    --    local lockout = self:_CreateWeeklyLockout(boss)
    --
    --    -- Do it from the end, since we're removing people.
    --    for i=#entry.names, 1, -1 do
    --        local name = entry.names[i];
    --        if tContains(lockout, name) then
    --            entry:RemoveMember(name);
    --        else
    --            table.insert(self.db[self.weekNumber][boss], name)
    --            table.insert(validMembers, name)
    --        end
    --    end
    --end
    --return #validMembers > 0;
end

function Lockouts:DeleteMemberFromLockout(entry)
    if entry.reason ~= 'Boss Kill' then return end
    local lockout = self.db[entry.weekNumber];

    if lockout == nil or lockout[entry.boss] == nil then return end
    lockout = lockout[entry.boss]

    for _, name in pairs(entry.names) do
        for i=#lockout, 1, -1 do
            if lockout[i] == name then
                table.remove(self.db[entry.weekNumber][entry.boss], i)
            end
        end
    end
end

function Lockouts:_CreateWeeklyLockout(bossName)
    if self.db[self.weekNumber] == nil then
        self.db[self.weekNumber] = {};
    end
    if self.db[self.weekNumber][bossName] == nil then
        self.db[self.weekNumber][bossName] = {};
    end
    return self.db[self.weekNumber][bossName]
end

function Lockouts:AddMemberLockouts(entry)
    entry.lockoutsChecked = true;
    if entry.lockoutsChecked or entry.reason ~= 'Boss Kill' then
        return entry.names
    end
    --local validMembers = {}
    --entry.lockoutsChecked = true
    --
    --if entry.weekNumber == self.weekNumber then
    --    if self.db[self.weekNumber][entry.boss] == nil then
    --        self.db[self.weekNumber][entry.boss] = {}
    --    end
    --
    --    for i=1, #entry.names do
    --        local memberName = entry.names[i]
    --        if not tContains(self.db[self.weekNumber][entry.boss], memberName) then
    --            table.insert(self.db[self.weekNumber][entry.boss], memberName)
    --            table.insert(validMembers, memberName)
    --        else
    --            entry:RemoveMember(memberName)
    --        end
    --    end
    --end
    --
    --return #validMembers > 0;
end

function Lockouts:CheckForMemberLockouts(memberName, bossName)
    if self.db[self.weekNumber] == nil then
        return false
    end
    if self.db[self.weekNumber][bossName] == nil then
        return false
    end
    return tContains(self.db[self.weekNumber][bossName], memberName)
end

MODULES.Lockouts = Lockouts
