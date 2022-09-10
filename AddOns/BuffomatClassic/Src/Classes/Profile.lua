local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BomAddon

---@class BomProfileModule
local stateModule = BuffomatModule.New("Profile") ---@type BomProfileModule

BOM.Class = BOM.Class or {}

---@class BomProfile Snapshot of current options state as selected by the player
---Named options: Are addressed by their string name in translations, control names, etc
---@field ArgentumDawn boolean Warn if AD trinket is equipped while in an instance 
---@field AutoDismount boolean Dismount if necessary for buff cast 
---@field AutoDisTravel boolean Remove travel form if necessary for buff cast 
---@field AutoOpen boolean Open buffomat if required 
---@field AutoStand boolean Stand up if required for a cast 
---@field BuffTarget boolean Also try and buff the current target 
---@field Carrot boolean Whether to track carrot equipped in dungeons 
---@field DeathBlock boolean Don't cast group buffs, when somebody is dead
---@field DisableInRestArea boolean Hide BOM and clear tasks if in resting area ZZZ/city or inn
---@field DontUseConsumables boolean Prevent use of consumables
---@field SomeoneIsDrinking string When someone is drinking low-prio - Show as a comment; hide - no show; show - Show as a task and show buffomat window
---@field ActivateBomOnSpiritTap number Activate Buffomat while Priest talent 'Spirit tap' is active and mana is below X%
---@field InInstance boolean Buff while in an instance
---@field InPVP boolean Buff while in PvP instance
---@field InWorld boolean Buff in the open world
---@field MainHand boolean Warn about mainhand missing temporary enchant
---@field NoGroupBuff boolean Avoid casting group buffs
---@field OpenLootable boolean List lootable items for opening in the task list
---@field ReplaceSingle boolean Replace single buffs with group
---@field ResGhost boolean Attempt resurrecting ghosts
---@field SameZone boolean Check only in the same zone
---@field SecondaryHand boolean Warn about offhand temporary enchant missing
---@field SelfFirst boolean Buff self first
---@field ShowClassicConsumables boolean Will show pre-TBC consumables
---@field ShowTBCConsumables boolean Will show TBC consumables in the list
---@field UseRank boolean Use ranked spells
---@field SlowerHardware boolean Less frequent updates
---
---@field Cache table<number, table> Caches responses from GetItemInfo() and GetSpellInfo()

---@type BomProfile
BOM.Class.Profile = {}
BOM.Class.Profile.__index = BOM.Class.Profile

local CLASS_TAG = "buffomat_state"
