local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting

local windowsList = {}
local hasBeenLoaded = false
local hideCharframe = true
local moveDistance, heroFrameX, heroFrameY, heroFrameLeft, heroFrameTop, heroFrameNormalScale, heroFrameEffectiveScale = 0, 0, 0, 0, 0, 1, 0

windowsList[1] = {
    ['OnLoad'] = "LoadPaperDoll",
    ['SettingName'] = 'USE_CHARACTER_WINDOW',
    ['TabIcon'] = 'tabicon_character',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/character-window-icon",
    ["HeaderText"] = CHARACTER,
    ["Bindings"] = {
        ["TOGGLECHARACTER0"] = "PaperDoll",
        ["TOGGLECHARACTER1"] = "Skills",
        ["TOGGLECHARACTER3"] = "PetPaperDollFrame",
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "paperdoll")
    ]=]
}

windowsList[2] = {
    ['OnLoad'] = "LoadReputation",
    ['SettingName'] = 'USE_CHARACTER_WINDOW',
    ['TabIcon'] = 'tabicon_reputation',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/character-window-icon",
    ["HeaderText"] = REPUTATION,
    ["Bindings"] = {
        ["TOGGLECHARACTER2"] = "Reputation"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "reputation")
    ]=]
}

windowsList[3] = {
    ['OnLoad'] = "LoadTalents",
    ['SettingName'] = "USE_TALENT_WINDOW",
    ['TabIcon'] = 'tabicon-talents',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/talents-window-icon",
    ["HeaderText"] = TALENTS,
    ["Bindings"] = {
        ["TOGGLETALENTS"] = "Talents"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "talents")
    ]=]
}

windowsList[4] = {
    ['OnLoad'] = "LoadSpellBook",
    ['SettingName'] = "USE_SPELLBOOK_WINDOW",
    ['TabIcon'] = 'tabicon_spellbook',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/spellbook-window-icon",
    ["HeaderText"] = SPELLS,
    ["Bindings"] = {
        ["TOGGLESPELLBOOK"] = "SpellBook",
        ["TOGGLEPETBOOK"] = "PetBook"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "spellbook")
    ]=]
}

windowsList[5] = {
    ['OnLoad'] = "LoadGlyphes",
    ['SettingName'] = "USE_TALENT_WINDOW",
    ['TabIcon'] = 'tabicon-glyph',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/glyph-window-icon",
    ["HeaderText"] = GLYPHS,
    ["Bindings"] = {
        ["TOGGLEINSCRIPTION"] = "Glyphes"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "glyphes")
    ]=]
}

windowsList[6] = {
    ['OnLoad'] = "LoadMounts",
    ['SettingName'] = 'USE_CHARACTER_WINDOW',
    ['TabIcon'] = 'tabicon_mounts',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/mount-window-icon",
    ["HeaderText"] = MOUNTS,
    ["Bindings"] = {
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "mounts")
    ]=]
}

windowsList[7] = {
    ['OnLoad'] = "LoadCritter",
    ['SettingName'] = 'USE_CHARACTER_WINDOW',
    ['TabIcon'] = 'tabicon_pet',
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/pet-window-icon",
    ["HeaderText"] = PETS,
    ["Bindings"] = {
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "critter")
    ]=]
}

windowsList[8] = {
    ["OnLoad"] = "LoadCurrency",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["TabIcon"] = "tabicon_currency",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/currency-window-icon",
    ["HeaderText"] = CURRENCY,
    ["TooltipText"] = CURRENCY,
    ["Bindings"] = {
        ["TOGGLECURRENCY"] = "Currency"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "currency")
    ]=]
}

windowsList[9] = {
    ["OnLoad"] = "LoadPvp",
    ["SettingName"] = "USE_CHARACTER_WINDOW",
    ["TabIcon"] = "tabicon-pvp",
    ["HeaderIcon"] = "Interface/AddOns/GW2_UI/textures/character/pvp-window-icon",
    ["HeaderText"] = PVP,
    ["TooltipText"] = PVP,
    ["Bindings"] = {
        ["TOGGLECHARACTER4"] = "Pvp"
    },
    ["OnClick"] = [=[
        self:GetFrameRef("GwCharacterWindow"):SetAttribute("windowpanelopen", "pvp")
    ]=]
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local charSecure_OnClick = [=[
    --print("secure click handler button: " .. button)
    local f = self:GetFrameRef("GwCharacterWindow")
    if button == "Close" then
        f:SetAttribute("windowpanelopen", nil)
    elseif button == "PaperDoll" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdoll")
    elseif button == "Reputation" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "reputation")
    elseif button == "SpellBook" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "spellbook")
    elseif button == "PetBook" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "petbook")
    elseif button == "Glyphes" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "glyphes")
    elseif button == "Mounts" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "mounts")
    elseif button == "Critter" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "critter")
    elseif button == "Currency" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "currency")
    elseif button == "Talents" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "talents")
    elseif button == "PetPaperDollFrame" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdollpet")
    elseif button == "Skills" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "paperdollskills")
    elseif button == "Titles" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "titles")
    elseif button == "GearSet" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "gearset")
    elseif button == "Pvp" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "pvp")
    end
]=]

-- use the windowpanelopen attr to show/hide the char frame with correct tab open
local charSecure_OnAttributeChanged = [=[
    if name ~= "windowpanelopen" then
        return
    end

    local fmDoll = self:GetFrameRef("GwCharacterWindowContainer")
    local fmDollMenu = self:GetFrameRef("GwCharacterMenu")
    local fmDollRepu = self:GetFrameRef("GwPaperReputationContainer")
    local fmDollSkills = self:GetFrameRef("GwPaperSkills")
    local fmDollPetCont = self:GetFrameRef("GwPetContainer")
    local fmDollDress = self:GetFrameRef("GwDressingRoom")
    local fmDollTitles = self:GetFrameRef("GwPaperTitles")
    local fmDollGearSets = self:GetFrameRef("GwPaperGearSets")
    
    local showDoll = false
    local showDollMenu = false
    local showDollRepu = false
    local showDollSkills = false
    local showDollTitles = false
    local showDollGearSets = false
    local showDollPetCont = false
    local fmSBM = self:GetFrameRef("GwSpellbook")
    local showSpell = false
    local fmTal = self:GetFrameRef("GwTalentFrame")
    local showTal = false
    local fmGlyphes = self:GetFrameRef("GwGlyphesFrame")
    local showGlyphes = false
    local fmMounts = self:GetFrameRef("GwMountsFrame")
    local showMounts = false
    local fmCritter = self:GetFrameRef("GwCritterFrame")
    local showCritter = false
    local fmCurrency = self:GetFrameRef("GwCurrencyDetailsFrame")
    local showCurrency = false
    local fmPvp = self:GetFrameRef("GwPvpDetailsFrame")
    local showPvp = false

    local hasPetUI = self:GetAttribute("HasPetUI")

    local close = false
    local keytoggle = self:GetAttribute("keytoggle")

    if fmTal ~= nil and value == "talents" then
        if keytoggle and fmTal:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showTal = true
        end
    elseif fmGlyphes ~= nil and value == "glyphes" then
        if keytoggle and fmGlyphes:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showGlyphes = true
        end
    elseif fmMounts ~= nil and value == "mounts" then
        if keytoggle and fmMounts:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showMounts = true
        end
    elseif fmCritter ~= nil and value == "critter" then
        if keytoggle and fmCritter:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showCritter = true
        end
    elseif fmCurrency ~= nil and value == "currency" then
        if keytoggle and fmCurrency:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showCurrency = true
        end
    elseif fmPvp ~= nil and value == "pvp" then
        if keytoggle and fmPvp:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showPvp = true
        end
    elseif fmSBM ~= nil and value == "spellbook" then
        if keytoggle and fmSBM:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showSpell = true
        end
    elseif fmSBM ~= nil and value == "petbook" then
        if keytoggle and fmSBM:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showSpell = true
        end
    elseif fmDoll ~= nil and value == "paperdoll" then
        if keytoggle and fmDoll:IsVisible() and (not fmDollSkills:IsVisible() and not fmDollPetCont:IsVisible() and not fmDollTitles:IsVisible() and not fmDollGearSets:IsVisible()) then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDoll = true
        end
    elseif fmDollRepu ~= nil and value == "reputation" then
        if keytoggle and fmDollRepu:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollRepu = true
        end
    elseif fmDollSkills ~= nil and value == "paperdollskills" then
        if keytoggle and fmDollSkills:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollSkills = true
        end
    elseif fmDollTitles ~= nil and value == "titles" then
        if keytoggle and fmDollTitles:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollTitles = true
        end
    elseif fmDollGearSets ~= nil and value == "gearset" then
        if keytoggle and fmDollGearSets:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollGearSets = true
        end
    elseif fmDollPetCont ~= nil and value == "paperdollpet" and hasPetUI then
        if keytoggle and fmDollPetCont:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showDollPetCont = true
        end
    else
        close = true
    end

    if keytoggle then
        self:SetAttribute("keytoggle", nil)
    end

    if fmDoll then
        if showDoll and not close then
            fmDoll:Show()
            fmDollMenu:Show()
            fmDollDress:Show()

            fmDollRepu:Hide()
            fmDollSkills:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmTal then
        if showTal and not close then
            fmTal:Show()
        else
            fmTal:Hide()
        end
    end
    if fmGlyphes then
        if showGlyphes and not close then
            fmGlyphes:Show()
        else
            fmGlyphes:Hide()
        end
    end
    if fmMounts then
        if showMounts and not close then
            fmMounts:Show()
        else
            fmMounts:Hide()
        end
    end
    if fmCritter then
        if showCritter and not close then
            fmCritter:Show()
        else
            fmCritter:Hide()
        end
    end
    if fmCurrency then
        if showCurrency and not close then
            fmCurrency:Show()
        else
            fmCurrency:Hide()
        end
    end
    if fmPvp then
        if showPvp and not close then
            fmPvp:Show()
        else
            fmPvp:Hide()
        end
    end
    if fmSBM then
        if showSpell and not close then
            fmSBM:Show()
        else
            fmSBM:Hide()
        end
    end
    if fmDollRepu then
        if showDollRepu and not close then
            fmDollRepu:Show()
        else
            fmDollRepu:Hide()
        end
    end
    if fmDollSkills and showDollSkills then
        if showDollSkills and not close then
            fmDoll:Show()
            fmDollSkills:Show()
            fmDollDress:Show()

            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollPetCont and showDollPetCont then
        if showDollPetCont and not close then
            fmDoll:Show()
            fmDollPetCont:Show()

            fmDollSkills:Hide()
            fmDollDress:Hide()
            fmDollMenu:Hide()
            fmDollTitles:Hide()
            fmDollGearSets:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollTitles and showDollTitles then
        if showDollTitles and not close then
            fmDoll:Show()
            fmDollTitles:Show()
            fmDollDress:Show()

            fmDollSkills:Hide()
            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollGearSets:Hide()
        else
            fmDoll:Hide()
        end
    end
    if fmDollGearSets and showDollGearSets then
        if showDollGearSets and not close then
            fmDoll:Show()
            fmDollGearSets:Show()
            fmDollDress:Show()

            fmDollSkills:Hide()
            fmDollMenu:Hide()
            fmDollPetCont:Hide()
            fmDollTitles:Hide()
        else
            fmDoll:Hide()
        end
    end

    if close then
        self:Hide()
        self:CallMethod("SoundExit")
    elseif not self:IsVisible() then
        self:Show()
        self:CallMethod("SoundOpen")
    else
        self:CallMethod("SoundSwap")
    end
]=]

local mover_OnDragStart = [=[
    if button ~= "LeftButton" then
        return
    end
    local f = self:GetParent()
    if self:GetAttribute("isMoving") then
        f:CallMethod("StopMovingOrSizing")
    end
    self:SetAttribute("isMoving", true)
    f:CallMethod("StartMoving")
]=]

local mover_OnDragStop = [=[
    if button ~= "LeftButton" then
        return
    end
    if not self:GetAttribute("isMoving") then
        return
    end
    self:SetAttribute("isMoving", false)
    local f = self:GetParent()
    f:CallMethod("StopMovingOrSizing")
    local x, y, _ = f:GetRect()

    -- re-anchor to UIParent after the move
    f:ClearAllPoints()
    f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)

    -- store the updated position
    self:CallMethod("savePosition", x, y)
]=]

local charSecure_OnShow = [=[
    local keyEsc = GetBindingKey("TOGGLEGAMEMENU")
    if keyEsc ~= nil then
        self:SetBinding(false, keyEsc, "CLICK GwCharacterWindowClick:Close")
    end
]=]

local charSecure_OnHide = [=[
    self:ClearBindings()
]=]

local charCloseSecure_OnClick = [=[
    self:GetParent():SetAttribute("windowpanelopen", nil)
]=]

local function mover_SavePosition(self, x, y)
    local setting = self.onMoveSetting
    if setting then
        local pos = GetSetting(setting)
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point = "BOTTOMLEFT"
        pos.relativePoint = "BOTTOMLEFT"
        pos.xOfs = x
        pos.yOfs = y
        SetSetting(setting, pos)
    end
end

local function click_OnEvent(self, event)
    if event ~= "UPDATE_BINDINGS" then
        return
    end
    ClearOverrideBindings(self)

    for _, win in pairs(windowsList) do
        if win.TabFrame and win.Bindings then
            for key, click in pairs(win.Bindings) do
                local keyBind = GetBindingKey(key)
                if keyBind then
                    SetOverrideBinding(self, false, keyBind, "CLICK GwCharacterWindowClick:" .. click)
                end
            end
        end
    end
end
GW.AddForProfiling("character", "click_OnEvent", click_OnEvent)

local function GetScaleDistance()
    local left, top = heroFrameLeft, heroFrameTop
    local scale = heroFrameEffectiveScale
    local x, y = GetCursorPosition()
    x = x / scale - left
    y = top - y / scale
    return sqrt(x * x + y * y)
end

local function loadBaseFrame()
    if hasBeenLoaded then
        return
    end
    hasBeenLoaded = true

    local fmGCW = CreateFrame('Button', 'GwCharacterWindow', UIParent, 'GwCharacterWindow')
    fmGCW.WindowHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    fmGCW.WindowHeader:SetTextColor(255/255, 241/255, 209/255)
    fmGCW:SetAttribute('windowpanelopen', nil)
    fmGCW.secure:SetAttribute("_onclick", charSecure_OnClick)
    fmGCW.secure:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
    fmGCW:SetAttribute("_onattributechanged", charSecure_OnAttributeChanged)
    fmGCW.SoundOpen = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    end
    fmGCW.SoundSwap = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end
    fmGCW.SoundExit = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    end

    -- secure hook ESC to close char window when it is showing
    fmGCW:WrapScript(fmGCW, "OnShow", charSecure_OnShow)
    fmGCW:WrapScript(fmGCW, "OnHide", charSecure_OnHide)

    -- the close button securely closes the char window
    fmGCW.close:SetAttribute("_onclick", charCloseSecure_OnClick)

    -- setup movable stuff
    local pos = GetSetting("HERO_POSITION")
    local scale = GetSetting("HERO_POSITION_SCALE")

    fmGCW:SetScale(scale)
    fmGCW:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    fmGCW.mover.onMoveSetting = "HERO_POSITION"
    fmGCW.mover.savePosition = mover_SavePosition
    fmGCW.mover:SetAttribute("_onmousedown", mover_OnDragStart)
    fmGCW.mover:SetAttribute("_onmouseup", mover_OnDragStop)
    fmGCW.sizer.texture:SetDesaturated(true)
    fmGCW.sizer:SetScript("OnEnter", function(self)
        fmGCW.sizer.texture:SetDesaturated(false)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
        GameTooltip:ClearLines()
        GameTooltip_SetTitle(GameTooltip, L["Scale with Right Click"])
        GameTooltip:Show()
    end)
    fmGCW.sizer:SetScript("OnLeave", function()
        fmGCW.sizer.texture:SetDesaturated(true)
        GameTooltip_Hide()
    end)
    fmGCW.sizer:SetFrameStrata(fmGCW:GetFrameStrata())
    fmGCW.sizer:SetFrameLevel(fmGCW:GetFrameLevel() + 15)
    fmGCW.sizer:SetScript("OnMouseDown", function(self, btn)
        if btn ~= "RightButton" then
            return
        end
        heroFrameLeft, heroFrameTop = GwCharacterWindow:GetLeft(), GwCharacterWindow:GetTop()
        heroFrameNormalScale = GwCharacterWindow:GetScale()
        heroFrameX,heroFrameY = heroFrameLeft, heroFrameTop - (UIParent:GetHeight() / heroFrameNormalScale)
        heroFrameEffectiveScale = GwCharacterWindow:GetEffectiveScale()
        moveDistance = GetScaleDistance()
        self:SetScript("OnUpdate", function()
            local scale = GetScaleDistance() / moveDistance * heroFrameNormalScale
            if scale < 0.2 then scale = 0.2 elseif scale > 3.0 then scale = 3.0 end
            GwCharacterWindow:SetScale(scale)
            local s = heroFrameNormalScale / GwCharacterWindow:GetScale()
            local x = heroFrameX * s
            local y = heroFrameY * s
            GwCharacterWindow:ClearAllPoints()
            GwCharacterWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
        end)
    end)
    fmGCW.sizer:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
        SetSetting("HERO_POSITION_SCALE", GwCharacterWindow:GetScale())
        -- Save hero frame position
        local pos = GetSetting("HERO_POSITION")
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = GwCharacterWindow:GetPoint()
        SetSetting("HERO_POSITION", pos)
        --Reset Model Camera
        GwDressingRoom.model:RefreshCamera()
    end)
    -- set binding change handlers
    fmGCW.secure:HookScript("OnEvent", function(self, event)
        GW.CombatQueue_Queue(click_OnEvent, {self, event})
    end)
    fmGCW.secure:RegisterEvent("UPDATE_BINDINGS")
end

local function setTabIconState(self, b)
    if b then
        self.icon:SetTexCoord(0, 0.5, 0, 0.625)
    else
        self.icon:SetTexCoord(0.5, 1, 0, 0.625)
    end
end

local function createTabIcon(iconName, tabIndex)
    local f = CreateFrame('Button', nil, GwCharacterWindow, 'CharacterWindowTabSelect')
    f.icon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\' .. iconName)
    f:SetPoint('TOP', GwCharacterWindow, 'TOPLEFT', -32, -25 + -((tabIndex - 1) * 45))
    setTabIconState(f, false)

    return f
end

local function styleCharacterMenuButton(self, shadow)
    if shadow then
        self.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        self:GetFontString():SetTextColor(1,1,1,1)
        self:GetFontString():SetShadowColor(0,0,0,0)
        self:GetFontString():SetShadowOffset(1,-1)
        self:GetFontString():SetFont(DAMAGE_TEXT_FONT,14)
        self:GetFontString():SetJustifyH('LEFT')
        self:GetFontString():SetPoint('LEFT',self,'LEFT',5,0)
    else
        self.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
        self:SetNormalTexture(nil)
        self:GetFontString():SetTextColor(1,1,1,1)
        self:GetFontString():SetShadowColor(0,0,0,0)
        self:GetFontString():SetShadowOffset(1,-1)
        self:GetFontString():SetFont(DAMAGE_TEXT_FONT,14)
        self:GetFontString():SetJustifyH('LEFT')
        self:GetFontString():SetPoint('LEFT',self,'LEFT',5,0)
    end
    self:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
end

local function styleCharacterMenuBackButton(self)
    self.hover:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover')
    self:SetNormalTexture(nil)
    local fontString = self:GetFontString()
    fontString:SetTextColor(1,1,1,1)
    fontString:SetShadowColor(0,0,0,0)
    fontString:SetShadowOffset(1,-1)
    fontString:SetFont(DAMAGE_TEXT_FONT,14)
    self:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
end

local function container_OnShow(self)
    setTabIconState(self.TabFrame, true)
    self.CharWindow.windowIcon:SetTexture(self.HeaderIcon)
    self.CharWindow.WindowHeader:SetText(self.HeaderText)
end

local function container_OnHide(self)
    setTabIconState(self.TabFrame, false)
end

local function charTab_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
    GameTooltip:ClearLines()
    GameTooltip_AddNormalLine(GameTooltip, self.gwTipLabel)
    GameTooltip:Show()
end

local function CharacterMenuButton_OnLoad(self, odd)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    if not odd then
        self:SetNormalTexture(nil)
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
    end
    self:GetFontString():SetTextColor(1, 1, 1, 1)
    self:GetFontString():SetShadowColor(0, 0, 0, 0)
    self:GetFontString():SetShadowOffset(1, -1)
    self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14)
    self:GetFontString():SetJustifyH("LEFT")
    self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
end
GW.CharacterMenuButton_OnLoad = CharacterMenuButton_OnLoad

local nextShadow, nextAnchor
local function addAddonButton(name, setting, shadow, anchor, showFunction, hideOurFrame)
    if IsAddOnLoaded(name) and (setting == nil or setting == true) then
        GwCharacterMenu.buttonName = CreateFrame("Button", nil, GwCharacterMenu, shadow and "GwCharacterMenuButtonTemplate,SecureHandlerClickTemplate" or "SecureHandlerClickTemplate,GwCharacterMenuButtonTemplate2")
        GwCharacterMenu.buttonName:SetText(select(2, GetAddOnInfo(name)))
        GwCharacterMenu.buttonName:SetSize(231, 36)
        GwCharacterMenu.buttonName:ClearAllPoints()
        GwCharacterMenu.buttonName:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT")
        CharacterMenuButton_OnLoad(GwCharacterMenu.buttonName, shadow)
        GwCharacterMenu.buttonName:SetFrameRef("charwin", GwCharacterWindow)
        GwCharacterMenu.buttonName.ui_show = showFunction
        GwCharacterMenu.buttonName:SetAttribute("hideOurFrame", hideOurFrame)
        GwCharacterMenu.buttonName:SetAttribute("_onclick", [=[
            local fchar = self:GetFrameRef("charwin")
            local hideOurFrame = self:GetAttribute("hideOurFrame")
            if fchar and hideOurFrame == true then
                fchar:SetAttribute("windowpanelopen", nil)
            end
            self:CallMethod("ui_show")
        ]=])
        nextShadow = not nextShadow
        nextAnchor = GwCharacterMenu.buttonName

        if name == "GearQuipper-TBC" then
            GwCharacterMenu.buttonName:SetText("GearQuipper TBC")
            GqUiFrame:ClearAllPoints()
            GqUiFrame:SetParent(GwCharacterWindow)
            GqUiFrame:SetPoint("TOPRIGHT", GwCharacterWindow, "TOPRIGHT", 350, -12)
            GW.SkinGearQuipper()
        end
    end
end

local LoadCharWindowAfterCombat = CreateFrame("Frame", nil, UIParent)
local function LoadWindows()
    if InCombatLockdown() then
        LoadCharWindowAfterCombat:SetScript(
            "OnUpdate",
            function()
                local inCombat = UnitAffectingCombat("player")
                if inCombat == true then
                    return
                end
                LoadWindows()
                LoadCharWindowAfterCombat:SetScript("OnUpdate", nil)
            end)
        return
    end

    local anyThingToLoad = false
    for _, v in pairs(windowsList) do
        if GetSetting(v.SettingName) then
            anyThingToLoad = true
        end
    end
    if not anyThingToLoad then
        return
    end

    loadBaseFrame()

    local fmGCW = GwCharacterWindow
    local tabIndex = 1
    for _, v in pairs(windowsList) do
        if GetSetting(v.SettingName) then
            local container = GW[v.OnLoad](fmGCW)
            local tab = createTabIcon(v.TabIcon, tabIndex)

            fmGCW:SetFrameRef(container:GetName(), container)
            container:SetScript("OnShow", container_OnShow)
            container:SetScript("OnHide", container_OnHide)
            tab:SetFrameRef('GwCharacterWindow', fmGCW)
            tab:SetAttribute('_OnClick', v.OnClick)

            container.TabFrame = tab
            container.CharWindow = fmGCW
            container.HeaderIcon = v.HeaderIcon
            container.HeaderText = v.HeaderText
            tab.gwTipLabel = v.HeaderText

            tab:SetScript("OnEnter", charTab_OnEnter)
            tab:SetScript("OnLeave", GameTooltip_Hide)

            if container:GetName() == "GwCharacterWindowContainer" then
                fmGCW:SetFrameRef("GwCharacterMenu", GwCharacterMenu)
                fmGCW:SetFrameRef("GwPaperSkills", GwPaperSkills)
                fmGCW:SetFrameRef("GwPaperTitles", GwPaperTitles)
                fmGCW:SetFrameRef("GwDressingRoom", GwDressingRoom)
                fmGCW:SetFrameRef("GwPetContainer", GwPetContainer)
                fmGCW:SetFrameRef("GwPaperGearSets", GwPaperGearSets)

                styleCharacterMenuButton(GwCharacterMenu.skillsMenu, true)
                styleCharacterMenuButton(GwCharacterMenu.titleMenu, false)
                styleCharacterMenuButton(GwCharacterMenu.gearMenu, true)
                styleCharacterMenuButton(GwCharacterMenu.petMenu, false)
                styleCharacterMenuBackButton(GwPaperSkills.backButton)
                styleCharacterMenuBackButton(GwPaperTitles.backButton)
                styleCharacterMenuBackButton(GwPaperGearSets.backButton)
                styleCharacterMenuBackButton(GwDressingRoomPet.backButton)

                -- add addon buttons here
                if GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6 then
                    nextShadow = false
                else
                    nextShadow = true
                end
                nextAnchor = (GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6) and GwCharacterMenu.petMenu or GwCharacterMenu.gearMenu
                addAddonButton("Outfitter", GetSetting("USE_CHARACTER_WINDOW"), nextShadow, nextAnchor, function() hideCharframe = false Outfitter:OpenUI() end, true)
                addAddonButton("GearQuipper-TBC", GetSetting("USE_CHARACTER_WINDOW"), nextShadow, nextAnchor, function() gearquipper:ToggleUI() end, false)
                addAddonButton("Clique", GetSetting("USE_SPELLBOOK_WINDOW"), nextShadow, nextAnchor, function() ShowUIPanel(CliqueConfig) end, true)
                addAddonButton("Pawn", GetSetting("USE_CHARACTER_WINDOW"), nextShadow, nextAnchor, PawnUIShow, false)

                GwCharacterMenu.skillsMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdollskills")
                ]=])
                GwCharacterMenu.titleMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "titles")
                ]=])
                GwCharacterMenu.gearMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "gearset")
                ]=])
                GwCharacterMenu.petMenu:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdollpet")
                ]=])
                GwPaperSkills.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
                GwPaperTitles.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
                GwPaperGearSets.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])
                GwDressingRoomPet.backButton:SetAttribute("_onclick", [=[
                    local f = self:GetFrameRef("GwCharacterWindow")
                    f:SetAttribute("keytoggle", true)
                    f:SetAttribute("windowpanelopen", "paperdoll")
                ]=])

                -- pet GwDressingRoom
                GwCharacterMenu.petMenu:SetAttribute("_onstate-petstate", [=[
                    if newstate == "nopet" then
                        self:Disable()
                        self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", false)
                    elseif newstate == "hasPet" then
                        self:Enable()
                        self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", true)
                    end
                ]=])
                RegisterStateDriver(GwCharacterMenu.petMenu, "petstate", "[target=pet,noexists] nopet; [target=pet,help] hasPet;")
            end
            v.TabFrame = tab

            tabIndex = tabIndex + 1
        end
    end

    if GetSetting("USE_CHARACTER_WINDOW") then
        CharacterFrame:SetScript("OnShow", function()
            if hideCharframe then
                HideUIPanel(CharacterFrame)
            end
            hideCharframe = true
        end)

        CharacterFrame:UnregisterAllEvents()
    end

    -- set bindings on secure instead of char win to not interfere with secure ESC binding on char win
    click_OnEvent(fmGCW.secure, "UPDATE_BINDINGS")
end
GW.LoadWindows = LoadWindows
