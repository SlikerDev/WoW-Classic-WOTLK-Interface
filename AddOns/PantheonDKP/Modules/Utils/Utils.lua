local _, PDKP = ...
PDKP.Utils = {}

local Utils = PDKP.Utils;
local MODULES = PDKP.MODULES;

local strsplit, strlower, strmatch, _, _ = strsplit, strlower, strmatch, strfind, strupper;
local _, format, tostring, _, split, trim = string.rep, string.format, tostring, string.gsub, strsplit, strtrim
local floor, fmod = math.floor, math.fmod;
local _, _, next = table.insert, table.sort, next;
local date, type, _ = date, type, print
local _, pairs, _ = table.getn, pairs, ipairs
local GetServerTime, GetQuestResetTime = GetServerTime, GetQuestResetTime
local GetInstanceInfo = GetInstanceInfo
local substr = string.sub;

--local daysInWeek = 7
local daysInYear = 365
--local hoursInDay = 24
local secondsInMinute = 60
local secondsInHour = 60 * 60
local minutesInDay = 60 * 24
local secondsInDay = 60 * 60 * 24

Utils.CommPrefixNumber = "6"

function Utils:Initialize()
    self:GetResetInfo()
end

function Utils:BuildEntryStartHash(officer)
    local weekNumber = self:GetWeekNumber(GetServerTime())
    return string.format("%d__%s__", weekNumber, officer)
end

function Utils:GetCommPrefix(prefix)
    return 'pdkpV' .. self.CommPrefixNumber .. substr(prefix, 0, 10)
end

-----------------------------
--     Reset Functions     --
-----------------------------

function Utils:GetResetInfo()
    local server_time = GetServerTime()
    local daily_reset_time = GetQuestResetTime() -- Seconds until daily quests reset.
    local seconds_until_hour = fmod(daily_reset_time, secondsInHour)
    local seconds_until_daily_reset = daily_reset_time - seconds_until_hour
    local hours_until_daily_reset = seconds_until_daily_reset / 60 / 60

    -- Blizzard Format Sunday (1), Monday (2), Tuesday (3), Wednesday (4), Thursday (5), Friday (6), Saturday (7)
    local day = date("*t", server_time)
    local wday = day.wday
    local yday = day.yday

    -- custom date schedule.
    local customWeeklySchedule = {
        [1] = { -- Old Sunday
            ['daysFromReset'] = 2
        },
        [2] = { -- Old Monday
            ['daysFromReset'] = 1
        },
        [3] = { -- Old Tuesday
            ['daysFromReset'] = 0 -- Tuesday can either be 0 or 7 depending on time of day.
        },
        [4] = { -- Old Wednesday
            ['daysFromReset'] = 6
        },
        [5] = { -- Old Thursday
            ['daysFromReset'] = 5
        },
        [6] = { -- Old Friday
            ['daysFromReset'] = 4
        },
        [7] = { -- Old Saturday
            ['daysFromReset'] = 3
        },
    }

    local customDay = customWeeklySchedule[wday]
    local daysUntilReset = customDay['daysFromReset']
    local isResetDay = daysUntilReset == 0
    local serverReset = false

    -- Today is weekly reset day, Daily reset happens at 9:59:59 AM, server time.
    if daysUntilReset == 0 and hours_until_daily_reset >= 10 then
        serverReset = true
        daysUntilReset = 7
    end

    local dayOfReset = yday + daysUntilReset

    if dayOfReset > daysInYear then
        dayOfReset = dayOfReset - daysInYear
    end

    isResetDay = isResetDay or yday == dayOfReset

    -- Set our globals
    Utils.isResetDay = isResetDay
    Utils.serverHasReset = serverReset
    Utils.dayOfReset = dayOfReset
    Utils.daysUntilReset = daysUntilReset
    Utils.wday = wday
    Utils.yday = yday
    Utils.weekNumber = Utils:GetWeekNumber(server_time)
end

function Utils:GetTimeSince(time)
    local days = floor(time / 86400);
    local hours = floor(fmod(time, 86400) / 3600);
    local minutes = floor(fmod(time, 3600) / 60);
    local seconds = floor(fmod(time, 60));
    return days,hours,minutes,seconds
end

function Utils:GetTimeSinceFormat(time)
    local days = floor(time / 86400);
    local hours = floor(fmod(time, 86400) / 3600);
    local minutes = floor(fmod(time, 3600) / 60);
    local seconds = floor(fmod(time, 60));

    if days > 0 then
        return format("%d Days, %02d Hours", days, hours);
    elseif hours > 0 then
        return format("%02d Hours, %02d Minutes", hours, minutes);
    elseif minutes > 0 then
        return format("%02d Minutes", minutes);
    else
        return format("%02d Seconds", seconds);
    end

    --return format("%d Days %02d Hrs",days,hours,minutes)
end

function Utils:GetWeekInfo()
    return Utils.weekNumber, Utils.wday, Utils.yday
end

function Utils:GetYDay(unixtimestamp)
    return date("*t", unixtimestamp).yday
end

function Utils:GetWDay(unixtimestamp)
    return date("*t", unixtimestamp).wday
end

function Utils:GetYear(unixtimestamp)
    unixtimestamp = unixtimestamp or GetServerTime()
    return date("%y", unixtimestamp)
end

function Utils:GenerateHashTimestamp(unixtimestamp)
    local wday = self:GetWDay(unixtimestamp)
    local weekNumber = self:GetWeekNumber(unixtimestamp)
    local year = self:GetYear(unixtimestamp)

    return tostring(year) .. "_" .. tostring(weekNumber) .. '_' .. tostring(wday)
end

-- Return the 1-based unix epoch week number. Seems to be off by 2 weeks?
function Utils:GetWeekNumber(unixtimestamp)
    return 1 + floor(unixtimestamp / 604800)
end

function Utils:WeekStart(week)
    return (week - 1) * 604800
end

-- Subtracts two timestamps from one another.
function Utils:SubtractTime(baseTime, subTime)
    local diffInSeconds = (subTime - baseTime) -- the seconds since our last sync
    local diffInMins = floor(diffInSeconds / 60) -- Minutes since last sync.
    return diffInSeconds, diffInMins
end

function Utils:GetSecondsInDay()
    return secondsInDay
end

function Utils:GetMinutesInDay()
    return minutesInDay
end

function Utils:GetSecondsInMinute()
    return secondsInMinute
end

function Utils:GetSecondsInFiveMinutes()
    return secondsInMinute * 5
end

-----------------------------
--      Time Functions     --
-----------------------------

function Utils:Format12HrDateTime(dateTime)
    return date("%a, %b %d | %I:%M %p", dateTime)
end

-----------------------------
--      MISC Functions     --
-----------------------------

function Utils:ternaryAssign(cond, a, b)
    if cond then
        return a
    end
    return b
end

function Utils:RoundToDecimal(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function Utils:GetInstanceStatus()
    local _, instance_type, _, _, _,
    _, _, _, _ = GetInstanceInfo()

    local isInInstance = instance_type ~= 'none'
    local dungeon = instance_type == 'party';
    local raid = instance_type == 'raid';
    local bg = instance_type == 'pvp';
    local arena = instance_type == 'arena';

    return isInInstance, { ['dungeon'] = dungeon, ['raid'] = raid, ['battlegrounds'] = bg, ['arena'] = arena }

end

-----------------------------
--     Debug Functions     --
-----------------------------

local watchedVars = {};
function Utils:WatchVar(tData, strName)
    if ViragDevTool_AddData ~= nil and PDKP:IsDev() and watchedVars[strName] ~= true then
        ViragDevTool_AddData(tData, strName)
        PDKP:PrintD('Watching Var', strName)
        watchedVars[strName] = true
    end
end

-----------------------------
--     Item Functions      --
-----------------------------

function Utils:IsItemLink(iLink)
    return strmatch(iLink, "|Hitem:(%d+):")
end

function Utils:GetItemLink(itemIdentifier)
    -- Call instant first, since it assures that we'll get the item info.
    GetItemInfoInstant(itemIdentifier)
    -- Then call the actual item info, so we can get the texture, and link.
    local _, itemLink, _, _, _, _, _, _, _, _,
    _ = GetItemInfo(itemIdentifier)

    return itemLink
end

-----------------------------
--     Color Functions     --
-----------------------------

-- Formats text color
function Utils:FormatTextColor(text, color_hex)
    if text == nil then
        return text
    end
    if not color_hex then
        PDKP:PrintD("No Default Color given")
        color_hex = 'ff0000'
    end
    return "|cff" .. color_hex .. text .. "|r"
end

-- Formats text color based on class
function Utils:FormatTextByClass(text, class)
    local class_color = MODULES.Constants.CLASS_COLORS[class]
    local colored_text, colored_class = Utils:FormatTextColor(text, class_color), Utils:FormatTextColor(class, class_color)
    return colored_text, colored_class
end

--- Converts a hex value to RGBA components.
-- The values returned are floats between 0 and 1 inclusive. The alpha channel is option and set to 1 if not specified.
-- @tparam string hex The hex color string
-- @treturn number The red value
-- @treturn number The green value
-- @treturn number The blue value
-- @treturn number The alpha value
function Utils:HexToRGBA(hex)
    local a, r, g, b = strmatch(strlower(hex), "^#([0-9a-f]?[0-9a-f]?)([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])$")
    assert(a and r and g and b, format("Invalid color (%s)!", hex))
    return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, (a ~= "") and (tonumber(a, 16) / 255) or 1
end

-----------------------------
--     String Functions    --
-----------------------------

-- Utility function to help determine if the string is empty or nil.
function Utils:IsEmpty(string)
    return string == nil or string == '';
end
-- Utility function to help tell if the baseString contains the searchString
function Utils:StringsMatch(baseString, searchString)
    return not Utils:IsEmpty(strmatch(strlower(baseString), strlower(searchString), nil, true));
end

-- Utility function to remove non-numerics (except minus) from a number.
function Utils:RemoveNonNumerics(str)
    if str == nil then
        return str
    end
    return str:gsub("%D+", "")
end

function Utils:RemoveAllNonNumerics(str)
    if str == nil then
        return str
    end
    return str:gsub("^-?[0-9]", "")
end

function Utils:RemoveNonAlphaNumerics(str)
    if str == nil then
        return str
    end
    return str:gsub("[^a-zA-Z]", "")
end

function Utils:RemoveColors(str)
    str = string.gsub( str, "|c%x%x%x%x%x%x%x%x", "" )
    str = string.gsub( str, "|c%x%x %x%x%x%x%x", "" ) -- the trading parts colour has a space instead of a zero for some weird reason
    str = string.gsub( str, "|r", "" )
    return str
end

function Utils:GetMyName()
    return UnitName("PLAYER")
end

function Utils:RemoveServerName(name)
    if Utils:IsEmpty(name) then
        return nil
    end ;
    return strsplit('-', name)
end

function Utils:SplitString(string, delim)
    local arr = { split(delim, string) }

    for i = 1, #arr do
        local v = arr[i]
        arr[i] = trim(v, " \t\r") -- Trims  spaces, tabs or newlines from the left or right of the string.
    end

    return arr
end

-----------------------------
--     Table Functions     --
-----------------------------

function Utils:PairByKeys(t, f)
    if type(t) ~= "table" then return nil end

    local a = {};
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0;
    local iter = function()
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter;
end

function Utils:PairByReverseKeys(t, f)
    local a = {};
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = #a + 1;
    local iter = function()
        i = i - 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter;
end

-- http://lua-users.org/wiki/CopyTable
function Utils:ShallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else
        -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- http://lua-users.org/wiki/CopyTable
function Utils:DeepCopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[Utils:DeepCopy(orig_key, copies)] = Utils:DeepCopy(orig_value, copies)
            end
            setmetatable(copy, Utils:DeepCopy(getmetatable(orig), copies))
        end
    else
        -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- For finding the index of an object item.
function Utils:tfind(t, item, objIndex)
    objIndex = objIndex or nil;
    t = t or {};
    local index = 1;
    while t[index] do
        if objIndex and (item == t[index]['dataObj'][objIndex]) then
            return true, index
        elseif (item == t[index]) then
            return true, index
        end
        index = index + 1;
    end
    return nil, nil;
end

-- Finds the index of an object in a table, based on a sub-index in the object.
function Utils:tfindObj(t, item, objIndex)
    t = t or {};
    local index = 1;
    while t[index] do
        if (item == t[index][objIndex]) then
            return true, index
        end
        index = index + 1
    end
    return nil, nil
end

function Utils:tEmpty(t)
    if type(t) ~= "table" then
        return true
    end
    return next(t) == nil;
end

local waitTable = {};
local waitFrame;

function PDKP__wait(delay, func, ...)
    if (type(delay) ~= "number" or type(func) ~= "function") then
        return false;
    end
    if (waitFrame == nil) then
        waitFrame = CreateFrame("Frame", "WaitFrame", UIParent);
        waitFrame:SetScript("onUpdate", function(_, elapse)
            local count = #waitTable;
            local i = 1;
            while (i <= count) do
                local waitRecord = tremove(waitTable, i);
                local d = tremove(waitRecord, 1);
                local f = tremove(waitRecord, 1);
                local p = tremove(waitRecord, 1);
                if (d > elapse) then
                    tinsert(waitTable, i, { d - elapse, f, p });
                    i = i + 1;
                else
                    count = count - 1;
                    f(unpack(p));
                end
            end
        end);
    end
    tinsert(waitTable, { delay, func, { ... } });
    return true;
end
