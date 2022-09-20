local PROSPECT_ITEMS = {
  COPPER_ORE = "2770",
  TIN_ORE = "2771",
  IRON_ORE = "2772",
  MITHRIL_ORE = "3858",
  THORIUM_ORE = "10620",
  FEL_IRON_ORE = "23424",
  ADAMANTITE_ORE = "23425",

  TIGERSEYE = "818",
  MALACHITE = "774",
  SHADOWGEM = "1210",
  LESSER_MOONSTONE = "1705",
  MOSS_AGATE = "1206",
  CITRINE = "3864",
  JADE = "1529",
  AQUAMARINE = "7909",
  STAR_RUBY = "7910",
  BLUE_SAPPHIRE = "12361",
  LARGE_OPAL = "12799",
  AZEROTHIAN_DIAMOND = "12800",
  HUGE_EMERALD = "12364",

  BLOOD_GARNET = "23077",
  DEEP_PERIDOT = "23079",
  FLAME_SPESSARITE = "21929",
  GOLDEN_DRAENITE = "23112",
  SHADOW_DRAENITE = "23107",
  AZURE_MOONSTONE = "23117",
  NOBLE_TOPAZ = "23439",
  DAWNSTONE = "23440",
  LIVING_RUBY = "23436",
  NIGHTSEYE = "23441",
  STAR_OF_ELUNE = "23438",
  TALASITE = "23437",
  ADAMANTITE_POWDER = "24243",
}

Auctionator.Prospect.PROSPECT_TABLE = {
  [PROSPECT_ITEMS.COPPER_ORE] = {
    [PROSPECT_ITEMS.TIGERSEYE] = 0.5,
    [PROSPECT_ITEMS.MALACHITE] = 0.5,
    [PROSPECT_ITEMS.SHADOWGEM] = 0.1,
  },
  [PROSPECT_ITEMS.TIN_ORE] = {
    [PROSPECT_ITEMS.SHADOWGEM] = 0.375,
    [PROSPECT_ITEMS.LESSER_MOONSTONE] = 0.375,
    [PROSPECT_ITEMS.MOSS_AGATE] = 0.375,

    [PROSPECT_ITEMS.CITRINE] = 0.0333,
    [PROSPECT_ITEMS.JADE] = 0.0333,
    [PROSPECT_ITEMS.AQUAMARINE] = 0.0333,
  },
  [PROSPECT_ITEMS.IRON_ORE] = {
    [PROSPECT_ITEMS.CITRINE] = 0.35,
    [PROSPECT_ITEMS.LESSER_MOONSTONE] = 0.35,
    [PROSPECT_ITEMS.JADE] = 0.35,

    [PROSPECT_ITEMS.AQUAMARINE] = 0.05,
    [PROSPECT_ITEMS.STAR_RUBY] = 0.05,
  },
  [PROSPECT_ITEMS.MITHRIL_ORE] = {
    [PROSPECT_ITEMS.STAR_RUBY] = 0.35,
    [PROSPECT_ITEMS.AQUAMARINE] = 0.35,
    [PROSPECT_ITEMS.CITRINE] = 0.35,

    [PROSPECT_ITEMS.BLUE_SAPPHIRE] = 0.025,
    [PROSPECT_ITEMS.LARGE_OPAL] = 0.025,
    [PROSPECT_ITEMS.AZEROTHIAN_DIAMOND] = 0.025,
    [PROSPECT_ITEMS.HUGE_EMERALD] = 0.025,
  },
  [PROSPECT_ITEMS.THORIUM_ORE] = {
    [PROSPECT_ITEMS.AZEROTHIAN_DIAMOND] = 0.31,
    [PROSPECT_ITEMS.BLUE_SAPPHIRE] = 0.31,
    [PROSPECT_ITEMS.HUGE_EMERALD] = 0.31,
    [PROSPECT_ITEMS.LARGE_OPAL] = 0.31,
    [PROSPECT_ITEMS.STAR_RUBY] = 0.15,
  },
  [PROSPECT_ITEMS.FEL_IRON_ORE] = {
    [PROSPECT_ITEMS.BLOOD_GARNET] = 0.18,
    [PROSPECT_ITEMS.DEEP_PERIDOT] = 0.18,
    [PROSPECT_ITEMS.FLAME_SPESSARITE] = 0.18,
    [PROSPECT_ITEMS.GOLDEN_DRAENITE] = 0.18,
    [PROSPECT_ITEMS.SHADOW_DRAENITE] = 0.18,
    [PROSPECT_ITEMS.AZURE_MOONSTONE] = 0.18,
    [PROSPECT_ITEMS.NOBLE_TOPAZ] = 0.012,
    [PROSPECT_ITEMS.DAWNSTONE] = 0.012,
    [PROSPECT_ITEMS.LIVING_RUBY] = 0.012,
    [PROSPECT_ITEMS.NIGHTSEYE] = 0.012,
    [PROSPECT_ITEMS.STAR_OF_ELUNE] = 0.012,
    [PROSPECT_ITEMS.TALASITE] = 0.012,
  },
  [PROSPECT_ITEMS.ADAMANTITE_ORE] = {
    [PROSPECT_ITEMS.ADAMANTITE_POWDER] = 1,
    [PROSPECT_ITEMS.BLOOD_GARNET] = 0.18,
    [PROSPECT_ITEMS.DEEP_PERIDOT] = 0.18,
    [PROSPECT_ITEMS.FLAME_SPESSARITE] = 0.18,
    [PROSPECT_ITEMS.GOLDEN_DRAENITE] = 0.18,
    [PROSPECT_ITEMS.SHADOW_DRAENITE] = 0.18,
    [PROSPECT_ITEMS.AZURE_MOONSTONE] = 0.18,
    [PROSPECT_ITEMS.NOBLE_TOPAZ] = 0.0375,
    [PROSPECT_ITEMS.DAWNSTONE] = 0.0375,
    [PROSPECT_ITEMS.LIVING_RUBY] = 0.0375,
    [PROSPECT_ITEMS.NIGHTSEYE] = 0.0375,
    [PROSPECT_ITEMS.STAR_OF_ELUNE] = 0.0375,
    [PROSPECT_ITEMS.TALASITE] = 0.0375,
  },
}
