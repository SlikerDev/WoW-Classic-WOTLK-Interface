--[[ Local Files:

    Icons/icon.tga
    Icons/collapse_all.tga
    Icons/expand_all.tga

    Frames/PDKPFrame-TopRight.tga
    Frames/PDKPFrame-TopLeft.tga
    Frames/PDKPFrame-Top.tga
    Frames/PDKPFrame-MidRight.tga
    Frames/PDKPFrame-MidLeft.tga
    Frames/PDKPFrame-Middle.tga
    Frames/PDKPFrame-BotRight.tga
    Frames/PDKPFrame-BotMid.tga
    Frames/PDKPFrame-BotLeft.tga
    Frames/PDKPFrame-BG.tga

    Frames/BidFrame.tga
]]--


local _, PDKP = ...
local MODULES = PDKP.MODULES

local Media = {}

-- The base path for all interface media
Media.PDKP_MEDIA_PATH = "Interface\\Addons\\PantheonDKP\\Media\\"

-- The base path for our frames
Media.PDKP_FRAMES_PATH = Media.PDKP_MEDIA_PATH .. "Frames\\"

-- The base path for our icons
Media.PDKP_ICONS_PATH = Media.PDKP_MEDIA_PATH .. "Icons\\"

Media.PDKP_ADDON_ICON = Media.PDKP_ICONS_PATH .. "icon.tga"

-- Main Interface textures are denoted with "PDKPFrame-"
Media.PDKP_TEXTURE_BASE = Media.PDKP_FRAMES_PATH .. "PDKPFrame-"

-- FRAMES
Media.BID_FRAME = Media.PDKP_FRAMES_PATH .. 'BidFrame.tga'
Media.PDKP_BG = Media.PDKP_TEXTURE_BASE .. "BG.tga"

-- BORDERS
Media.SHROUD_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
Media.SCROLL_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"

-- TEXTURES
Media.CHAR_INFO_TEXTURE = 'Interface\\CastingBar\\UI-CastingBar-Border-Small'
Media.HIGHLIGHT_TEXTURE = 'Interface\\QuestFrame\\UI-QuestTitleHighlight'
Media.ROW_SEP_TEXTURE = 'Interface\\Artifacts\\_Artifacts-DependencyBar-BG'

-- ARROWS
Media.ARROW_RIGHT_TEXTURE = 'Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up'
Media.ARROW_LEFT_TEXTURE = 'Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up'
Media.ARROW_TEXTURE = 'Interface\\MONEYFRAME\\Arrow-Left-Up'
Media.COLLAPSE_ALL = Media.PDKP_ICONS_PATH .. 'collapse_all.tga'
Media.EXPAND_ALL = Media.PDKP_ICONS_PATH .. 'expand_all.tga'

-- MISC
Media.CLOSE_BUTTON_TEXT = "|TInterface\\Buttons\\UI-StopButton:0|t"
Media.TRANSPARENT_BACKGROUND = "Interface\\TutorialFrame\\TutorialFrameBackground"
Media.TAB_TEXTURE = "Interface\\CHATFRAME\\ChatFrameTab"

Media.TANK_ICON = 'Interface\\ICONS\\Ability_Defend'
Media.TOTAL_ICON = 'Interface\\ICONS\\Achievement_GuildPerk_EverybodysFriend'
Media.DKP_OFFICER_ICON = 'Interface\\ICONS\\INV_MISC_Coin_01'
Media.STATUS_BAR_TEXTURE = "Interface\\TARGETINGFRAME\\UI-StatusBar";
Media.STATUS_BAR_FILL = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-BarFill"
Media.STATUS_BAR_BG_FRAME = "Interface\\CastingBar\\UI-CastingBar-Border"
Media.PLUS_BUTTON_UP = "Interface\\Buttons\\UI-PlusButton-Up"
Media.PLUS_BUTTON_DOWN = "Interface\\Buttons\\UI-PlusButton-Down"
Media.EXPAND_OUT = "Interface\\Buttons\\UI-Panel-BiggerButton-Up"

Media.STATUS_BAR_FONT = "Fonts\\FRIZQT__.TTF"

Media.addon_version_hex = '0059C5'

local BackdropTemplateMixin = BackdropTemplateMixin
Media.BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate"
Media.BACKDROPTEMPLATE = Media.BackdropTemplate

Media.PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = Media.SCROLL_BORDER,
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}
Media.PaneColor = { 0.1, 0.1, 0.1, 0.5 }
Media.PaneBorderColor = { 0.4, 0.4, 0.4 }
Media.PaneBorderColorTransparent = { 0, 0, 0, 0 }
Media.PaneColorDark = { 0.0, 0.0, 0.0, 0.8 }

Media.SolidBackDrop  = {
    bgFile = Media.PDKP_TEXTURE_BASE .. "BG.tga",
    edgeFile = Media.SCROLL_BORDER,
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

-- Publish API
MODULES.Media = Media
