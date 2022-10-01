local _, GW = ...

GW.DispelClasses = {
    DRUID = { Magic = false, Curse = true, Poison = true, Disease = false },
    MAGE = { Curse = true },
    PALADIN = { Magic = true, Poison = true, Disease = true },
    PRIEST = { Magic = true, Disease = true },
    SHAMAN = { Magic = false, Poison = true, Disease = true, Curse = IsSpellKnown(51886) },
    WARLOCK = { Magic = true }
}

local PowerBarColorCustom = {}
GW.PowerBarColorCustom = PowerBarColorCustom

PowerBarColorCustom["MANA"] = {r = 37 / 255, g = 133 / 255, b = 240 / 255}
PowerBarColorCustom["RAGE"] = {r = 240 / 255, g = 66 / 255, b = 37 / 255}
PowerBarColorCustom["ENERGY"] = {r = 240 / 255, g = 200 / 255, b = 37 / 255}
PowerBarColorCustom["POWER_TYPE_ENERGY"] = PowerBarColorCustom["ENERGY"]
PowerBarColorCustom["LUNAR_POWER"] = {r = 130 / 255, g = 172 / 255, b = 230 / 255}
PowerBarColorCustom["RUNIC_POWER"] = {r = 37 / 255, g = 214 / 255, b = 240 / 255}
PowerBarColorCustom["FOCUS"] = {r = 240 / 255, g = 121 / 255, b = 37 / 255}
PowerBarColorCustom["FURY"] = {r = 166 / 255, g = 37 / 255, b = 240 / 255}
PowerBarColorCustom["PAIN"] = {r = 255/255, g = 156/255, b = 0}
PowerBarColorCustom["MAELSTROM"] = {r = 0.00, g = 0.50, b = 1.00}
PowerBarColorCustom["INSANITY"] = {r = 0.40, g = 0, b = 0.80}
PowerBarColorCustom["CHI"] = {r = 0.71, g = 1.0, b = 0.92}

-- vehicle colors
PowerBarColorCustom["AMMOSLOT"] = {r = 0.80, g = 0.60, b = 0.00}
PowerBarColorCustom["FUEL"] = {r = 0.0, g = 0.55, b = 0.5}
PowerBarColorCustom["STAGGER"] = {r = 0.52, g = 1.0, b = 0.52}

GW.nameRoleIcon = {
    TANK = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-tank:0:0:0:0:64:64:4:60:4:60|t ",
    HEALER = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-healer:0:0:0:0:64:64:4:60:4:60|t ",
    DAMAGER = "|TInterface/AddOns/GW2_UI/textures/party/roleicon-dps:0:0:0:0:64:64:4:60:4:60|t ",
    NONE = ""
}

local DEBUFF_COLOR = {}
GW.DEBUFF_COLOR = DEBUFF_COLOR
DEBUFF_COLOR["none"] = {r = 220 / 255, g = 0, b = 0}
DEBUFF_COLOR["Curse"] = {r = 97 / 255, g = 72 / 255, b = 177 / 255}
DEBUFF_COLOR["Disease"] = {r = 177 / 255, g = 114 / 255, b = 72 / 255}
DEBUFF_COLOR["Magic"] = {r = 72 / 255, g = 94 / 255, b = 177 / 255}
DEBUFF_COLOR["Poison"] = {r = 94 / 255, g = 177 / 255, b = 72 / 255}
DEBUFF_COLOR[""] = DEBUFF_COLOR["none"]

GW.TRACKER_TYPE_COLOR = {
    QUEST = {r = 221 / 255, g = 198 / 255, b = 68 / 255},
    CAMPAIGN = {r = 121 / 255, g = 222 / 255, b = 47 / 255},
    EVENT = {r = 240 / 255, g = 121 / 255, b = 37 / 255},
    SCENARIO = {r = 171 / 255, g = 37 / 255, b = 240 / 255},
    BOSS = {r = 240 / 255, g = 37 / 255, b = 37 / 255},
    ARENA = {r = 240 / 255, g = 37 / 255, b = 37 / 255},
    ACHIEVEMENT = {r = 37 / 255, g = 240 / 255, b = 172 / 255},
    DAILY = {r = 68 / 255, g = 192 / 255, b = 250 / 255},
    TORGHAST = {r = 109 / 255, g = 161 / 255, b = 207 / 255},
}

local FACTION_BAR_COLORS = {
    [1] = {r = 0.8, g = 0.3, b = 0.22},
    [2] = {r = 0.8, g = 0.3, b = 0.22},
    [3] = {r = 0.75, g = 0.27, b = 0},
    [4] = {r = 0.9, g = 0.7, b = 0},
    [5] = {r = 0, g = 0.6, b = 0.1},
    [6] = {r = 0, g = 0.6, b = 0.1},
    [7] = {r = 0, g = 0.6, b = 0.1},
    [8] = {r = 0, g = 0.6, b = 0.1}
}
GW.FACTION_BAR_COLORS = FACTION_BAR_COLORS

local BAG_TYP_COLORS = {
    [0x0001] = {r = 1, g = 1, b = 1},            --Quivers       1
    [0x0002] = {r = 1, g = 1, b = 1},            --Quivers       2
    [0x0004] = {r = 0.251, g = 0.878, b = 0.816},--Soul          3
    [0x0020] = {r = 0.451, g = 1, b = 0},        --Herbs         6
    [0x0040] = {r = 1, g = 0, b = 1}             --Enchanting    7

}
GW.BAG_TYP_COLORS = BAG_TYP_COLORS

local COLOR_FRIENDLY = {
    [1] = {r = 88 / 255, g = 170 / 255, b = 68 / 255},
    [2] = {r = 159 / 255, g = 36 / 255, b = 20 / 255},
    [3] = {r = 159 / 255, g = 159 / 255, b = 159 / 255}
}
GW.COLOR_FRIENDLY = COLOR_FRIENDLY

local trackingTypes = {}
GW.trackingTypes = trackingTypes

trackingTypes[136025] = {l = 0.125, r = 0.250, t = 0, b = 0.5} --mining
trackingTypes[133939] = {l = 0, r = 0.125, t = 0, b = 0.5} --herbalism
trackingTypes[135974] = {l = 0.750, r = 0.875, t = 0, b = 0.5} --undead
trackingTypes[136142] = {l = 0.750, r = 0.875, t = 0, b = 0.5} --undead
trackingTypes["1323283"] = {l = 0.875, r = 1, t = 0, b = 0.5} --beast for hunter
trackingTypes["13232811"] = {l = 0, r = 0.125, t = 0.5, b = 1} --human for druid
trackingTypes[135942] = {l = 0, r = 0.125, t = 0.5, b = 1} --human
trackingTypes[136172] = {l = 0.250, r = 0.375, t = 0.5, b = 1} --demon
trackingTypes[136217] = {l = 0.250, r = 0.375, t = 0.5, b = 1} --demon
trackingTypes[135725] = {l = 0.375, r = 0.5, t = 0.5, b = 1} --treasure
trackingTypes[133888] = {l = 0.125, r = 0.250, t = 0.5, b = 1} --fish
trackingTypes[134153] = {l = 0.5, r = 0.625, t = 0, b = 0.5} --Dragonkin
trackingTypes[135861] = {l = 0.250, r = 0.375, t = 0, b = 0.5} --Elementals
trackingTypes[132275] = {l = 0.375, r = 0.5, t = 0, b = 0.5} --Giants
trackingTypes[132320] = {l = 0.625, r = 0.750, t = 0, b = 0.5} --Hidden

local bloodSpark = {}
GW.BLOOD_SPARK = bloodSpark

bloodSpark[0] = {left = 0, right = 0.125, top = 0, bottom = 0.5}
bloodSpark[1] = {left = 0, right = 0.125, top = 0, bottom = 0.5}
bloodSpark[2] = {left = 0.125, right = 0.125 * 2, top = 0, bottom = 0.5}
bloodSpark[3] = {left = 0.125 * 2, right = 0.125 * 3, top = 0, bottom = 0.5}
bloodSpark[4] = {left = 0.125 * 3, right = 0.125 * 4, top = 0, bottom = 0.5}
bloodSpark[5] = {left = 0.125 * 4, right = 0.125 * 5, top = 0, bottom = 0.5}
bloodSpark[6] = {left = 0.125 * 5, right = 0.125 * 6, top = 0, bottom = 0.5}
bloodSpark[7] = {left = 0.125 * 6, right = 0.125 * 7, top = 0, bottom = 0.5}
bloodSpark[8] = {left = 0.125 * 7, right = 0.125 * 8, top = 0, bottom = 0.5}

bloodSpark[9] = {left = 0, right = 0.125, top = 0.5, bottom = 1}
bloodSpark[10] = {left = 0.125, right = 0.125 * 2, top = 0.5, bottom = 1}
bloodSpark[11] = {left = 0.125 * 2, right = 0.125 * 3, top = 0.5, bottom = 1}
bloodSpark[12] = {left = 0.125 * 3, right = 0.125 * 4, top = 0.5, bottom = 1}
bloodSpark[13] = {left = 0.125 * 4, right = 0.125 * 5, top = 0.5, bottom = 1}
bloodSpark[14] = {left = 0.125 * 5, right = 0.125 * 6, top = 0.5, bottom = 1}
bloodSpark[15] = {left = 0.125 * 6, right = 0.125 * 7, top = 0.5, bottom = 1}
bloodSpark[16] = {left = 0.125 * 7, right = 0.125 * 8, top = 0.5, bottom = 1}

bloodSpark[17] = {left = 0, right = 0.125, top = 0, bottom = 0.5}
bloodSpark[18] = {left = 0.125, right = 0.125 * 2, top = 0, bottom = 0.5}
bloodSpark[19] = {left = 0.125 * 2, right = 0.125 * 3, top = 0, bottom = 0.5}
bloodSpark[20] = {left = 0.125 * 3, right = 0.125 * 4, top = 0, bottom = 0.5}
bloodSpark[21] = {left = 0.125 * 4, right = 0.125 * 5, top = 0, bottom = 0.5}
bloodSpark[22] = {left = 0.125 * 5, right = 0.125 * 6, top = 0, bottom = 0.5}
bloodSpark[23] = {left = 0.125 * 6, right = 0.125 * 7, top = 0, bottom = 0.5}
bloodSpark[24] = {left = 0.125 * 7, right = 0.125 * 8, top = 0, bottom = 0.5}

GW.CLASS_ICONS = {
    [0] = {l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1},

    [1] = {l = 0.0625 * 11, r = 0.0625 * 12, t = 0, b = 1},
    [2] = {l = 0.0625 * 10, r = 0.0625 * 11, t = 0, b = 1},
    [3] = {l = 0.0625 * 9, r = 0.0625 * 10, t = 0, b = 1},
    [4] = {l = 0.0625 * 8, r = 0.0625 * 9, t = 0, b = 1},
    [5] = {l = 0.0625 * 7, r = 0.0625 * 8, t = 0, b = 1},
    [6] = {l = 0.0625 * 6, r = 0.0625 * 7, t = 0, b = 1},
    [7] = {l = 0.0625 * 5, r = 0.0625 * 6, t = 0, b = 1},
    [8] = {l = 0.0625 * 4, r = 0.0625 * 5, t = 0, b = 1},
    [9] = {l = 0.0625 * 3, r = 0.0625 * 4, t = 0, b = 1},
    [10] = {l = 0.0625 * 2, r = 0.0625 * 3, t = 0, b = 1},
    [11] = {l = 0.0625 * 1, r = 0.0625 * 2, t = 0, b = 1},
    [12] = {l = 0, r = 0.0625 * 1, t = 0, b = 1},
    dead = {l = 0.0625 * 12, r = 0.0625 * 13, t = 0, b = 1}
}
GW.CLASS_ICONS.WARRIOR = GW.CLASS_ICONS[1]
GW.CLASS_ICONS.PALADIN = GW.CLASS_ICONS[2]
GW.CLASS_ICONS.HUNTER = GW.CLASS_ICONS[3]
GW.CLASS_ICONS.ROGUE = GW.CLASS_ICONS[4]
GW.CLASS_ICONS.PRIEST = GW.CLASS_ICONS[5]
GW.CLASS_ICONS.DEATHKNIGHT = GW.CLASS_ICONS[6]
GW.CLASS_ICONS.SHAMAN = GW.CLASS_ICONS[7]
GW.CLASS_ICONS.MAGE = GW.CLASS_ICONS[8]
GW.CLASS_ICONS.WARLOCK = GW.CLASS_ICONS[9]
GW.CLASS_ICONS.MONK = GW.CLASS_ICONS[10]
GW.CLASS_ICONS.DRUID = GW.CLASS_ICONS[11]
GW.CLASS_ICONS.DEMONHUNTER = GW.CLASS_ICONS[12]

GW.GW_CLASS_COLORS = {
    WARRIOR = {r = 90 / 255, g = 54 / 255, b = 38 / 255, a = 1},
    PALADIN = {r = 177 / 255, g = 72 / 255, b = 117 / 255, a = 1},
    HUNTER = {r = 99 / 255, g = 125 / 255, b = 53 / 255, a = 1},
    ROGUE = {r = 190 / 255, g = 183 / 255, b = 79 / 255, a = 1},
    PRIEST = {r = 205 / 255, g = 205 / 255, b = 205 / 255, a = 1},
    DEATHKNIGHT = {r = 148 / 255, g = 62 / 255, b = 62 / 255, a = 1},
    SHAMAN = {r = 30 / 255, g = 44 / 255, b = 149 / 255, a = 1},
    MAGE = {r = 62 / 255, g = 121 / 255, b = 149 / 255, a = 1},
    WARLOCK = {r = 125 / 255, g = 88 / 255, b = 154 / 255, a = 1},
    MONK = {r = 66 / 255, g = 151 / 255, b = 112 / 255, a = 1},
    DRUID = {r = 158 / 255, g = 103 / 255, b = 37 / 255, a = 1},
    DEMONHUNTER = {r = 72 / 255, g = 38 / 255, b = 148 / 255, a = 1}
}

GW.FACTION_COLOR = {
    [1] = {r = 163 / 255, g = 46 / 255, b = 54 / 255}, --Horde
    [2] = {r = 57 / 255, g = 115 / 255, b = 186 / 255} --Alliance
}

local TARGET_FRAME_ART = {
    ["minus"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow",
    ["normal"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow",
    ["elite"] = "Interface\\AddOns\\GW2_UI\\textures\\targetShadowElit",
    ["rare"] = "Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare",
    ["rareelite"] = "Interface\\AddOns\\GW2_UI\\textures\\targetShadowRare",
    ["worldboss"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow",
    ["boss"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow_boss",
    ["realboss"] = "Interface\\AddOns\\GW2_UI\\textures\\targetshadow-raidboss" 
}
GW.TARGET_FRAME_ART = TARGET_FRAME_ART

local INDICATORS = {"BAR", "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT"}
local indicatorsText = {"Bar", "Top Left", "Top", "Top Right", "Left", "Center", "Right"}
GW.INDICATORS = INDICATORS
GW.indicatorsText = indicatorsText

GW.bossFrameExtraEnergyBar = {}

-- Taken from ElvUI: https://git.tukui.org/elvui/elvui/blob/master/ElvUI/Settings/Filters/UnitFrame.lua
-- Format: {class = {id = {r, g, b[, <spell-id-same-slot>]} ...}, ...}
local AURAS_INDICATORS = {
    PRIEST = {
        [1243]    = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 1)
        [1244]    = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 2)
        [1245]    = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 3)
        [2791]    = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 4)
        [10937]   = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 5)
        [10938]   = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 6)
        [25389]   = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 7)
        [48161]   = {1, 1, 0.66}, -- Power Word: Fortitude(Rank 8)
        [21562]   = {1, 1, 0.66}, -- Prayer of Fortitude(Rank 1)
        [21564]   = {1, 1, 0.66}, -- Prayer of Fortitude(Rank 2)
        [25392]   = {1, 1, 0.66}, -- Prayer of Fortitude(Rank 3)
        [48162]   = {1, 1, 0.66}, -- Prayer of Fortitude(Rank 4)
        [14752]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 1)
        [14818]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 2)
        [14819]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 3)
        [27841]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 4)
        [25312]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 5)
        [48073]   = {0.2, 0.7, 0.2}, -- Divine Spirit(Rank 6)
        [27681]   = {0.2, 0.7, 0.2}, -- Prayer of Spirit(Rank 1)
        [32999]   = {0.2, 0.7, 0.2}, -- Prayer of Spirit(Rank 2)
        [48074]   = {0.2, 0.7, 0.2}, -- Prayer of Spirit(Rank 3)
        [976]     = {0.7, 0.7, 0.7}, -- Shadow Protection(Rank 1)
        [10957]   = {0.7, 0.7, 0.7}, -- Shadow Protection(Rank 2)
        [10958]   = {0.7, 0.7, 0.7}, -- Shadow Protection(Rank 3)
        [25433]   = {0.7, 0.7, 0.7}, -- Shadow Protection(Rank 4)
        [48169]   = {0.7, 0.7, 0.7}, -- Shadow Protection(Rank 5)
        [27683]   = {0.7, 0.7, 0.7}, -- Prayer of Shadow Protection(Rank 1)
        [39374]   = {0.7, 0.7, 0.7}, -- Prayer of Shadow Protection(Rank 2)
        [48170]   = {0.7, 0.7, 0.7}, -- Prayer of Shadow Protection(Rank 3)
        [17]      = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 1)
        [592]     = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 2)
        [600]     = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 3)
        [3747]    = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 4)
        [6065]    = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 5)
        [6066]    = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 6)
        [10898]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 7)
        [10899]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 8)
        [10900]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 9)
        [10901]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 10)
        [25217]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 11)
        [25218]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 12)
        [48065]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 13)
        [48066]   = {0.00, 0.00, 1.00}, -- Power Word: Shield(Rank 14)
        [139]     = {0.33, 0.73, 0.75}, -- Renew(Rank 1)
        [6074]    = {0.33, 0.73, 0.75}, -- Renew(Rank 2)
        [6075]    = {0.33, 0.73, 0.75}, -- Renew(Rank 3)
        [6076]    = {0.33, 0.73, 0.75}, -- Renew(Rank 4)
        [6077]    = {0.33, 0.73, 0.75}, -- Renew(Rank 5)
        [6078]    = {0.33, 0.73, 0.75}, -- Renew(Rank 6)
        [10927]   = {0.33, 0.73, 0.75}, -- Renew(Rank 7)
        [10928]   = {0.33, 0.73, 0.75}, -- Renew(Rank 8)
        [10929]   = {0.33, 0.73, 0.75}, -- Renew(Rank 9)
        [25315]   = {0.33, 0.73, 0.75}, -- Renew(Rank 10)
        [25221]   = {0.33, 0.73, 0.75}, -- Renew(Rank 11)
        [25222]   = {0.33, 0.73, 0.75}, -- Renew(Rank 12)
        [48067]   = {0.33, 0.73, 0.75}, -- Renew(Rank 13)
        [48068]   = {0.33, 0.73, 0.75}, -- Renew(Rank 14)
    },
    DRUID = {
        [1126]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 1)
        [5232]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 2)
        [6756]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 3)
        [5234]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 4)
        [8907]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 5)
        [9884]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 6)
        [9885]    = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 7)
        [26990]   = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 8)
        [48469]   = {0.2, 0.8, 0.8}, -- Mark of the Wild(Rank 9)
        [21849]   = {0.2, 0.8, 0.8}, -- Gift of the Wild(Rank 1)
        [21850]   = {0.2, 0.8, 0.8}, -- Gift of the Wild(Rank 2)
        [26991]   = {0.2, 0.8, 0.8}, -- Gift of the Wild(Rank 3)
        [48470]   = {0.2, 0.8, 0.8}, -- Gift of the Wild(Rank 4)
        [467]     = {0.4, 0.2, 0.8}, -- Thorns(Rank 1)
        [782]     = {0.4, 0.2, 0.8}, -- Thorns(Rank 2)
        [1075]    = {0.4, 0.2, 0.8}, -- Thorns(Rank 3)
        [8914]    = {0.4, 0.2, 0.8}, -- Thorns(Rank 4)
        [9756]    = {0.4, 0.2, 0.8}, -- Thorns(Rank 5)
        [9910]    = {0.4, 0.2, 0.8}, -- Thorns(Rank 6)
        [26992]   = {0.4, 0.2, 0.8}, -- Thorns(Rank 7)
        [53307]   = {0.4, 0.2, 0.8}, -- Thorns(Rank 8)
        [774]     = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 1)
        [1058]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 2)
        [1430]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 3)
        [2090]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 4)
        [2091]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 5)
        [3627]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 6)
        [8910]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 7)
        [9839]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 8)
        [9840]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 9)
        [9841]    = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 10)
        [25299]   = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 11)
        [26981]   = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 12)
        [26982]   = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 13)
        [48440]   = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 14)
        [48441]   = {0.83, 1.00, 0.25}, -- Rejuvenation(Rank 15)
        [8936]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 1)
        [8938]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 2)
        [8939]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 3)
        [8940]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 4)
        [8941]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 5)
        [9750]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 6)
        [9856]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 7)
        [9857]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 8)
        [9858]    = {0.33, 0.73, 0.75}, -- Regrowth(Rank 9)
        [26980]   = {0.33, 0.73, 0.75}, -- Regrowth(Rank 10)
        [48442]   = {0.33, 0.73, 0.75}, -- Regrowth(Rank 11)
        [48443]   = {0.33, 0.73, 0.75}, -- Regrowth(Rank 12)
        [29166]   = {0.49, 0.60, 0.55}, -- Innervate
        [33763]   = {0.33, 0.37, 0.47}, -- Lifebloom(Rank 1)
        [48450]   = {0.33, 0.37, 0.47}, -- Lifebloom(Rank 2)
        [48451]   = {0.33, 0.37, 0.47}, -- Lifebloom(Rank 3)
    },
    PALADIN = {
        [1044]    = {0.89, 0.45, 0}, -- Blessing of Freedom
        [1038]    = {0.11, 1.00, 0.45}, --Blessing of Salvation
        [6940]    = {0.89, 0.1, 0.1}, -- Blessing Sacrifice(Rank 1)
        [20729]   = {0.89, 0.1, 0.1}, -- Blessing Sacrifice(Rank 2)
        [27147]   = {0.89, 0.1, 0.1}, -- Blessing Sacrifice(Rank 3)
        [27148]   = {0.89, 0.1, 0.1}, -- Blessing Sacrifice(Rank 4)
        [19740]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 1)
        [19834]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 2)
        [19835]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 3)
        [19836]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 4)
        [19837]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 5)
        [19838]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 6)
        [25291]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 7)
        [27140]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 8)
        [48931]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 9)
        [48932]   = {0.2, 0.8, 0.2}, -- Blessing of Might(Rank 10)
        [19742]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 1)
        [19850]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 2)
        [19852]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 3)
        [19853]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 4)
        [19854]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 5)
        [25290]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 6)
        [27142]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 7)
        [48935]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 8)
        [48936]   = {0.2, 0.8, 0.2}, -- Blessing of Wisdom(Rank 9)
        [25782]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Might(Rank 1)
        [25916]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Might(Rank 2)
        [27141]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Might(Rank 3)
        [48933]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Might(Rank 4)
        [48934]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Might(Rank 5)
        [25894]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Wisdom(Rank 1)
        [25918]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Wisdom(Rank 2)
        [27143]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Wisdom(Rank 3)
        [48937]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Wisdom(Rank 4)
        [48938]   = {0.2, 0.8, 0.2}, -- Greater Blessing of Wisdom(Rank 5)
        [465]     = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 1)
        [10290]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 2)
        [643]     = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 3)
        [10291]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 4)
        [1032]    = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 5)
        [10292]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 6)
        [10293]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 7)
        [27149]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 8)
        [48941]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 9)
        [48942]   = {0.58, 1.00, 0.50}, -- Devotion Aura(Rank 10)
        [19977]   = {0.17, 1.00, 0.75}, -- Blessing of Light(Rank 1)
        [19978]   = {0.17, 1.00, 0.75}, -- Blessing of Light(Rank 2)
        [19979]   = {0.17, 1.00, 0.75}, -- Blessing of Light(Rank 3)
        [27144]   = {0.17, 1.00, 0.75}, -- Blessing of Light(Rank 4)
        [1022]    = {0.17, 1.00, 0.75}, -- Blessing of Protection(Rank 1)
        [5599]    = {0.17, 1.00, 0.75}, -- Blessing of Protection(Rank 2)
        [10278]   = {0.17, 1.00, 0.75}, -- Blessing of Protection(Rank 3)
        [19746]   = {0.83, 1.00, 0.07}, -- Concentration Aura
        [32223]   = {0.83, 1.00, 0.07}, -- Crusader Aura
    },
    SHAMAN = {
        [29203]   = {0.7, 0.3, 0.7}, -- Healing Way
        [16237]   = {0.2, 0.2, 1}, -- Ancestral Fortitude
        [8185]    = {0.05, 1.00, 0.50}, -- Fire Resistance Totem(Rank 1)
        [10534]   = {0.05, 1.00, 0.50}, -- Fire Resistance Totem(Rank 2)
        [10535]   = {0.05, 1.00, 0.50}, -- Fire Resistance Totem(Rank 3)
        [25563]   = {0.05, 1.00, 0.50}, -- Fire Resistance Totem(Rank 4)
        [58737]   = {0.05, 1.00, 0.50}, -- Fire Resistance Totem(Rank 5)
        [58739]   = {0.05, 1.00, 0.50}, -- Fire Resistance Totem(Rank 6)
        [8182]    = {0.54, 0.53, 0.79}, -- Frost Resistance Totem(Rank 1)
        [10476]   = {0.54, 0.53, 0.79}, -- Frost Resistance Totem(Rank 2)
        [10477]   = {0.54, 0.53, 0.79}, -- Frost Resistance Totem(Rank 3)
        [25560]   = {0.54, 0.53, 0.79}, -- Frost Resistance Totem(Rank 4)
        [58741]   = {0.54, 0.53, 0.79}, -- Frost Resistance Totem(Rank 5)
        [58745]   = {0.54, 0.53, 0.79}, -- Frost Resistance Totem(Rank 6)
        [10596]   = {0.33, 1.00, 0.20}, -- Nature Resistance Totem(Rank 1)
        [10598]   = {0.33, 1.00, 0.20}, -- Nature Resistance Totem(Rank 2)
        [10599]   = {0.33, 1.00, 0.20}, -- Nature Resistance Totem(Rank 3)
        [25574]   = {0.33, 1.00, 0.20}, -- Nature Resistance Totem(Rank 4)
        [58746]   = {0.33, 1.00, 0.20}, -- Nature Resistance Totem(Rank 5)
        [58749]   = {0.33, 1.00, 0.20}, -- Nature Resistance Totem(Rank 6)
        [5672]    = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 1)
        [6371]    = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 2)
        [6372]    = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 3)
        [10460]   = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 4)
        [10461]   = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 5)
        [25567]   = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 6)
        [58755]   = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 7)
        [58756]   = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 8)
        [58757]   = {0.67, 1.00, 0.50}, -- Healing Stream Totem(Rank 9)
        [16191]   = {0.67, 1.00, 0.80}, -- Mana Tide Totem(Rank 1)
        [17355]   = {0.67, 1.00, 0.80}, -- Mana Tide Totem(Rank 2)
        [17360]   = {0.67, 1.00, 0.80}, -- Mana Tide Totem(Rank 3)
        [5677]    = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 1)
        [10491]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 2)
        [10493]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 3)
        [10494]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 4)
        [25570]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 5)
        [58775]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 6)
        [58776]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 7)
        [58777]   = {0.67, 1.00, 0.80}, -- Mana Spring Totem(Rank 8)
        [8072]    = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 1)
        [8156]    = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 2)
        [8157]    = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 3)
        [10403]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 4)
        [10404]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 5)
        [10405]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 6)
        [25508]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 7)
        [25509]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 8)
        [58752]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 9)
        [58754]   = {0.00, 0.00, 0.26}, -- Stoneskin Totem(Rank 10)
        [974]     = {0.08, 0.21, 0.43}, -- Earth Shield(Rank 1)
        [32593]   = {0.08, 0.21, 0.43}, -- Earth Shield(Rank 2)
        [32594]   = {0.08, 0.21, 0.43}, -- Earth Shield(Rank 3)
        [49283]   = {0.08, 0.21, 0.43}, -- Earth Shield(Rank 4)
        [49284]   = {0.08, 0.21, 0.43}, -- Earth Shield(Rank 5)
    },
    ROGUE = {}, --No buffs
    WARRIOR = {
        [6673]    = {0.2, 0.2, 1}, -- Battle Shout(Rank 1)
        [5242]    = {0.2, 0.2, 1}, -- Battle Shout(Rank 2)
        [6192]    = {0.2, 0.2, 1}, -- Battle Shout(Rank 3)
        [11549]   = {0.2, 0.2, 1}, -- Battle Shout(Rank 4)
        [11550]   = {0.2, 0.2, 1}, -- Battle Shout(Rank 5)
        [11551]   = {0.2, 0.2, 1}, -- Battle Shout(Rank 6)
        [25289]   = {0.2, 0.2, 1}, -- Battle Shout(Rank 7)
        [2048]    = {0.2, 0.2, 1}, -- Battle Shout(Rank 8)
        [47436]    = {0.2, 0.2, 1}, -- Battle Shout(Rank 9)
        [469]     = {0.4, 0.2, 0.8}, -- Commanding Shout(Rank 1)
        [47439]     = {0.4, 0.2, 0.8}, -- Commanding Shout(Rank 5)
        [47440]     = {0.4, 0.2, 0.8}, -- Commanding Shout(Rank 3)
    },
    HUNTER = {
        [19506]   = {0.89, 0.09, 0.05}, -- Trueshot Aura (Rank 1)
        [20905]   = {0.89, 0.09, 0.05}, -- Trueshot Aura (Rank 2)
        [20906]   = {0.89, 0.09, 0.05}, -- Trueshot Aura (Rank 3)
        [27066]   = {0.89, 0.09, 0.05}, -- Trueshot Aura (Rank 4)
        [13159]   = {0.00, 0.00, 0.85}, -- Aspect of the Pack
        [20043]   = {0.33, 0.93, 0.79}, -- Aspect of the Wild (Rank 1)
        [20190]   = {0.33, 0.93, 0.79}, -- Aspect of the Wild (Rank 2)
        [27045]   = {0.33, 0.93, 0.79}, -- Aspect of the Wild (Rank 3)
        [49071]   = {0.33, 0.93, 0.79}, -- Aspect of the Wild (Rank 4)
    },
    WARLOCK = {
        [5597]    = {0.89, 0.09, 0.05}, -- Unending Breath
        [6512]    = {0.2, 0.8, 0.2}, -- Detect Lesser Invisibility
        [2970]    = {0.2, 0.8, 0.2}, -- Detect Invisibility
        [11743]   = {0.2, 0.8, 0.2}, -- Detect Greater Invisibility
    },
    MAGE = {
        [1459]    = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 1)
        [1460]    = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 2)
        [1461]    = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 3)
        [10156]   = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 4)
        [10157]   = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 5)
        [27126]   = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 6)
        [42995]   = {0.89, 0.09, 0.05}, -- Arcane Intellect(Rank 7)
        [23028]   = {0.89, 0.09, 0.05}, -- Arcane Brilliance(Rank 1)
        [27127]   = {0.89, 0.09, 0.05}, -- Arcane Brilliance(Rank 2)
        [43002]   = {0.89, 0.09, 0.05}, -- Arcane Brilliance(Rank 3)
        [604]     = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 1)
        [8450]    = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 2)
        [8451]    = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 3)
        [10173]   = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 4)
        [10174]   = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 5)
        [33944]   = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 6)
        [43015]   = {0.2, 0.8, 0.2}, -- Dampen Magic(Rank 7)
        [1008]    = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 1)
        [8455]    = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 2)
        [10169]   = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 3)
        [10170]   = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 4)
        [27130]   = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 5)
        [33946]   = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 6)
        [43017]   = {0.2, 0.8, 0.2}, -- Amplify Magic(Rank 7)
        [130]     = {0.00, 0.00, 0.50}, -- Slow Fall
    },
    DEATHKNIGHT = {
        -- TODO: Hysteria / Unholy Frenzy
    },
}
GW.AURAS_INDICATORS = AURAS_INDICATORS

-- Never show theses auras
local AURAS_IGNORED = {
    --57723, -- Sated
    --57724, -- Exhaustion
    --80354, -- Temporal Displacement
    --264689 -- Fatigued
}
GW.AURAS_IGNORED = AURAS_IGNORED

-- Show these auras only when they are missing
local AURAS_MISSING = {
    --21562,  -- Power Word: Fortitude
    --6673,   -- Battle Shout
    --1459    -- Arcane Intellect
}
GW.AURAS_MISSING = AURAS_MISSING
