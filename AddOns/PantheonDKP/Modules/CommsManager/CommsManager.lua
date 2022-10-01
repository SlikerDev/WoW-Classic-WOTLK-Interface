local _, PDKP = ...

local MODULES = PDKP.MODULES
local Utils = PDKP.Utils;
local GUtils = PDKP.GUtils;

local Comms = {}

function Comms:Initialize()
    self:_InitializeVariables()
    self.autoSyncData = self:DataEncoder({ ['type'] = 'request' });

    local opts = {
        ['name'] = 'OFFICER_COMMS',
        ['events'] = {'GUILD_ROSTER_UPDATE', 'ZONE_CHANGED_NEW_AREA'},
        ['tickInterval'] = 5,
        ['onEventFunc'] = function()
            MODULES.GuildManager:GetMembers()
        end,
    }
    self.eventFrame = GUtils:createThrottledEventFrame(opts)
end

function PDKP_OnCommsReceived(prefix, message, _, sender)
    local channel = Comms.channels[prefix]
    if channel then
        return channel:VerifyCommSender(message, sender)
    else
        --PDKP:PrintD("Could not find comm channel", prefix)
    end
end

function Comms:_InitializeVariables()
    self.commsRegistered = false
    self.cache = {}
    self.commsOpen = true
    self.allow_from_self = {}
    self.allow_in_combat = {}
    self.channels = {}
    self.officerCommPrefixes = {}
    self.syncInProgress = false;
end

function Comms:Reinitialize()
    self:UnregisterComms()
    self:_InitializeVariables();
    self:RegisterComms();
end

function Comms:RegisterComms()
    local commChannels = {
        --- GUILD COMMS
        -- defaults: self = false, combat = true, channel = Guild, requireCheck = true, officerOnly = false
        ['SyncSmall'] = { ['self'] = true, },
        ['SyncDelete'] = { ['self'] = true },
        ['SyncLarge'] = { ['combat'] = false, },
        ['SyncOver'] = { ['combat'] = false, },

        ['RaidOver'] = { ['combat'] = true, ['channel'] = 'RAID', ['self'] = true, },
        ['RaidMerge'] = { ['combat'] = true, ['channel'] = 'RAID', ['self'] = true, },

        --- RAID COMMS
        ['DkpOfficer'] = { ['self'] = true, ['channel'] = 'RAID',  },
        ['WhoIsDKP'] = { ['channel'] = 'RAID', ['requireCheck'] = false, },

        ['StartBids'] = { ['channel'] = 'RAID', ['self'] = true, },
        ['StopBids'] = { ['channel'] = 'RAID',  ['self'] = true, },

        ['BidSubmit'] = { ['channel'] = 'RAID', ['requireCheck'] = false, ['self'] = true, },
        ['BidCancel'] = { ['channel'] = 'RAID', ['requireCheck'] = false, ['self'] = true, },

        ['AddBid'] = { ['channel'] = 'RAID', ['self'] = true, },
        ['CancelBid'] = { ['channel'] = 'RAID', ['self'] = true, },
        ['AddTime'] = { ['channel'] = 'RAID', ['self'] = true, ['requireCheck'] = false },

        ['SentInv'] = { ['channel'] = 'WHISPER', },
        --['Version'] = { ['channel'] = 'GUILD', },
    }

    local syncInCombat = MODULES.Options:GetSyncInCombat();
    if syncInCombat ~= nil then
        commChannels['SyncOver']['combat'] = syncInCombat
        commChannels['RaidOver']['combat'] = syncInCombat
    end

    for prefix, opts in pairs(commChannels) do
        opts['prefix'] = prefix
        local comm = MODULES.Comm:new(opts)
        self.channels[comm.prefix] = comm
        if comm.allow_in_combat then
            self.allow_in_combat[comm.prefix] = true
        end
        if comm.allowed_from_self then
            self.allow_from_self[comm.prefix] = true
        end
    end
end

function Comms:RegisterOfficerAdComms()
    local myName = Utils:GetMyName()

    local syncStatus = MODULES.Options:GetAutoSyncStatus()

    for name, member in pairs(MODULES.GuildManager:GetOfficers()) do
        if member:IsStrictRaidReady() then
            local pfx = self.officerCommPrefixes[name]
            local comm;

            if pfx == nil then
                local opts = {
                    ['combat'] = false,
                    ['self'] = false,
                    ['requireCheck'] = false,
                    ['prefix'] = member.name,
                    ['officerComm'] = true,
                    ['isSelfComm'] = name == myName,
                }
                comm = MODULES.Comm:new(opts)
                self.channels[comm.prefix] = comm;
                self.officerCommPrefixes[name] = comm.prefix;
            else
                comm = self.channels[pfx]
            end

            comm:HandleOfficerCommStatus(member, myName, syncStatus)

            if comm.registered and name ~= myName then
                --PDKP:PrintD("Sending Officer Comms message", member.name)
                self:SendCommsMessage(name, self.autoSyncData, true);
            end
        end
    end
end

function Comms:RegisterSyncShame()
    local participating = MODULES.Options:GetNSFWSync()
    if participating then
        local opts = {
            ['combat'] = true,
            ['self'] = true,
            ['requireCheck'] = false,
            ['prefix'] = 'SyncShame',
            ['officerComm'] = false,
            ['isSelfComm'] = false,
        }

        local optsSync = {
            ['combat'] = true,
            ['self'] = false,
            ['requireCheck'] = true,
            ['prefix'] = 'SyncShameSync',
            ['officerComm'] = false,
            ['isSelfComm'] = false,
        }

        local comm = MODULES.Comm:new(opts)
        self.channels[comm.prefix] = comm

        local commSync = MODULES.Comm:new(optsSync)
        self.channels[commSync.prefix] = commSync
    end
end

function Comms:UnregisterComms()
    PDKP.CORE:UnregisterAllComm()
end

function Comms:SendCommsMessage(prefix, data, skipEncoding)
    skipEncoding = skipEncoding or false
    local transmitData = data

    if not skipEncoding then
        transmitData = self:DataEncoder(data)
    end

    local comm = self.channels[Utils:GetCommPrefix(prefix)]

    if comm ~= nil and comm:IsValid() then
        if comm.requireCheck and not comm:CanSend() then
            return
        end

        if self.syncInProgress and comm.isSelfComm then
            return
        end

        local params = comm:GetSendParams()
        if prefix == 'SentInv' then
            params[2] = data
        end

        return PDKP.CORE:SendCommMessage(comm.prefix, transmitData, unpack(params))
    else
        --PDKP:PrintD(comm.ogPrefix, comm ~= nil, comm:IsValid())
    end
end

-----------------------------
--     Data Functions      --
-----------------------------

function Comms:_Serialize(data)
    return PDKP.CORE:Serialize(data)
end

function Comms:_Compress(serialized)
    return PDKP.LibDeflate:CompressDeflate(serialized, { level = 4 })
end

function Comms:_Encode(compressed)
    return PDKP.LibDeflate:EncodeForWoWAddonChannel(compressed)
end

function Comms:_Adler(string)
    return PDKP.LibDeflate:Adler32(string)
end

function Comms:_Deserialize(string)
    local success, data = PDKP.CORE:Deserialize(string)
    if not success then
        return nil
    end
    return data;
end

function Comms:_Decompress(decoded, chunksMode)
    return PDKP.LibDeflate:DecompressDeflate(decoded)
end

function Comms:_Decode(transmitData)
    return PDKP.LibDeflate:DecodeForWoWAddonChannel(transmitData)
end

-----------------------------
--    Encoders Functions   --
-----------------------------

function Comms:DataEncoder(data)
    local serialized = self:_Serialize(data)
    local compressed = self:_Compress(serialized)
    local encoded = self:_Encode(compressed)
    return encoded
end

function Comms:DataDecoder(data, chunksMode)
    local detransmit = self:_Decode(data)
    local decompressed = self:_Decompress(detransmit, chunksMode)
    if decompressed == nil then
        -- It wasn't a message that can be decompressed.
        return self:_Deserialize(detransmit) -- Return the regular deserialized messge
    end
    local deserialized = self:_Deserialize(decompressed)
    return deserialized -- Deserialize the compressed message
end

function Comms:ChunkedEncoder(data)
    local serialized = self:_Serialize(data);
    local chunkSize = 1024 * MODULES.Options:decompressChunkSize();
    local total = 0;

    local Wow_compress_co = PDKP.LibDeflate:CompressDeflate(serialized, {chunksMode=true, yieldOnChunkSize=chunkSize })

    local processing = CreateFrame("Frame");
    processing:SetScript("OnUpdate", function()
        local ongoing, compressed_data;

        if type(Wow_compress_co) ~= "string" then
            ongoing, compressed_data = Wow_compress_co()
        else
            ongoing = false;
            compressed_data = Wow_compress_co;
        end

        total = chunkSize + total;

        if not ongoing then
            processing:SetScript('OnUpdate', nil)
            --PDKP:PrintD("Chunked Encoding Finished")
            local encoded = self:_Encode(compressed_data);
            return encoded;
        end
    end)
end

function Comms:ChunkedDecoder(data, sender)
    local detransmit = self:_Decode(data)
    local chunkSize = 1024 * MODULES.Options:decompressChunkSize();
    local nsfwSync = MODULES.Options:GetNSFWSync();

    local total = 0;
    local bytes = (string.len(detransmit) + 17) * 10 * 10;

    local WoW_decompress_co = PDKP.LibDeflate:DecompressDeflate(detransmit, {chunksMode=true, yieldOnChunkSize=chunkSize })
    local processing = CreateFrame('Frame')

    if nsfwSync then
        PDKP.CORE:Print("Processing throbbing import from", sender .. "...")
        MODULES.Options:NSFWSync();
    else
        PDKP.CORE:Print("Processing large import from", sender .. "...")
    end

    processing:SetScript('OnUpdate', function()
        local ongoing, WoW_decompressed;

        if type(WoW_decompress_co) ~= "string" then
            ongoing, WoW_decompressed = WoW_decompress_co()
        else
            ongoing = false
            WoW_decompressed = WoW_decompress_co;
        end

        total = chunkSize + total;

        if total > bytes then
            total = bytes;
        end

        MODULES.DKPManager:UpdateSyncProgress(sender, '1/4', total, bytes);
        if not ongoing then
            processing:SetScript('OnUpdate', nil)
            --PDKP:PrintD("Chunk Processing finished", sender);
            local deserialized = self:_Deserialize(WoW_decompressed)



            return MODULES.DKPManager:ImportBulkEntries(deserialized, sender, true);
        end
    end)
end

function Comms:DatabaseEncoder(data, save)
    local serialized = self:_Serialize(data)
    return serialized
end

function Comms:DatabaseDecoder(data, save)
    local decompressed = self:_Decompress(data)
    if decompressed == nil then
        -- It wasn't a message that can be decompressed.
        return self:_Deserialize(data) -- Return the regular deserialized messge
    end
    return self:_Deserialize(decompressed)
end

function Comms:FixDKPDB()
    local DKP_DB = MODULES.Database:DKP();
    local decoded_entries = {};
    for index, entry in pairs(DKP_DB) do
        local decoded_entry = MODULES.DKPEntry:new(entry)
        local sd = decoded_entry:GetSaveDetails();
        decoded_entries[index] = sd;
    end

    for index, entry in pairs(decoded_entries) do
        DKP_DB[index] = self:_Serialize(entry);
    end
end

function Comms:TestCompress()

end

MODULES.CommsManager = Comms
