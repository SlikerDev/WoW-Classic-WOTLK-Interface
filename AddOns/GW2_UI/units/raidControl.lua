local _, GW = ...
local GetSetting = GW.GetSetting

local function fnGMIG_OnEvent(self)
    local active = UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")

    if IsInRaid() then
        GwManageGroupButton.icon:SetTexCoord(0, 0.59375, 0.2968, 0.2968 * 2)
    else
        GwManageGroupButton.icon:SetTexCoord(0, 0.59375, 0, 0.2968)
    end

    for _, marker in pairs(self.markers) do
        marker:SetEnabled(active)
        marker:GetNormalTexture():SetDesaturated(not active)
    end

    self.convert:SetEnabled(UnitIsGroupLeader("player"))
    self.convert:SetText(IsInRaid() and CONVERT_TO_PARTY or CONVERT_TO_RAID)

    self.readyCheck:SetEnabled(active)
end

local function manageButton()
    local GwGroupManage = CreateFrame("Frame", "GwGroupManage", UIParent, "GwGroupManage")
    local fmGMGB = CreateFrame("Button", "GwManageGroupButton", UIParent, "GwManageGroupButtonTmpl")

    fmGMGB:SetFrameRef("GroupManager", GwGroupManage)
    fmGMGB:SetAttribute("state", "closed")
    fmGMGB:SetAttribute("_onclick", [=[
        local ref = self:GetFrameRef("GroupManager")
        local state = self:GetAttribute("state")

        if state == "closed" then
            ref:Show()
            self:SetAttribute("state", "open")
            ref:SetAttribute("state", "open")
        else
            ref:Hide()
            self:SetAttribute("state","closed")
            ref:SetAttribute("state", "closed")
        end
    ]=])

    GwGroupManage:SetFrameRef("GroupManagerGroup", GwGroupManage.inGroup)
    GwGroupManage:SetAttribute("_onshow", [=[
        local ref = self:GetFrameRef("GroupManagerGroup") 

        if PlayerInGroup() ~= false then
            ref:Show()
            self:SetHeight(230)
        else
            ref:Hide()
            self:SetHeight(80)
        end
    ]=])
    GwGroupManage:SetAttribute("_onstate-barlayout", [=[
        local ref = self:GetFrameRef("GroupManagerGroup") 
        local state = self:GetAttribute("state")

        if newstate == "show" and state == "open" then
            self:SetHeight(230)
            ref:Show()
        elseif newstate == "hide" and state == "open" then
            self:SetHeight(80)
            ref:Hide()
        end
    ]=])
    RegisterStateDriver(GwGroupManage, "barlayout", "[group:raid] show; [group:party] show; hide")

    local fnGMGIB_OnEscapePressed = function(self)
        self:ClearFocus()
    end
    local fnGMGIB_OnEditFocusGained = function(self)
        local sT = self:GetText()
        if sT == CALENDAR_PLAYER_NAME then
            self:SetText("")
            self:SetTextColor(1, 1, 1, 1)
        end
    end
    local fnGMGIB_OnEditFocusLost = function(self)
        local sT = self:GetText()
        if sT == nil or sT == "" then
            self:SetText(CALENDAR_PLAYER_NAME)
            self:SetTextColor(1, 1, 1, 0.5)
        end
    end
    local fnGMGIB_OnEnterPressed = function(self)
        InviteUnit(self:GetText())
        self:SetText("")
        self:ClearFocus()
    end
    GwGroupManage.groupInviteBox:SetScript("OnEscapePressed", fnGMGIB_OnEscapePressed)
    GwGroupManage.groupInviteBox:SetScript("OnEditFocusGained", fnGMGIB_OnEditFocusGained)
    GwGroupManage.groupInviteBox:SetScript("OnEditFocusLost", fnGMGIB_OnEditFocusLost)
    GwGroupManage.groupInviteBox:SetScript("OnEnterPressed", fnGMGIB_OnEnterPressed)
    local sT = GwGroupManage.groupInviteBox:GetText()
    if sT == nil or sT == "" then
        GwGroupManage.groupInviteBox:SetText(CALENDAR_PLAYER_NAME)
        GwGroupManage.groupInviteBox:SetTextColor(1, 1, 1, 0.5)
    end

    GwGroupManage.inviteToParty:SetScript("OnClick", function(self)
        InviteUnit(self:GetParent().groupInviteBox:GetText())
        self:GetParent().groupInviteBox:SetText("")
        self:GetParent().groupInviteBox:ClearFocus()
    end)

    GwGroupManage.groupLeaveButton:SetScript("OnClick", function()
        LeaveParty()
    end)

    local fnGGRC_OnClick = function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        DoReadyCheck()
    end
    GwGroupManage.inGroup.readyCheck:SetScript("OnClick", fnGGRC_OnClick)
    GwGroupManage.inGroup.readyCheck.hover:SetTexture("Interface/AddOns/GW2_UI/textures/party/readycheck-button-hover")
    GwGroupManage.inGroup.readyCheck:GetFontString():SetTextColor(218 / 255, 214 / 255, 200 / 255)
    GwGroupManage.inGroup.readyCheck:GetFontString():SetShadowColor(0, 0, 0, 1)
    GwGroupManage.inGroup.readyCheck:GetFontString():SetShadowOffset(1, -1)
    GwGroupManage.inGroup.readyCheck:SetEnabled(UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))


    local fnGGMC_OnClick = function()
        if IsInRaid() then
            ConvertToParty()
        else
            ConvertToRaid()
        end
    end
    GwGroupManage.inGroup.convert:SetScript("OnClick", fnGGMC_OnClick)
    GwGroupManage.inGroup.convert:GetFontString():SetShadowColor(0, 0, 0, 1)

    GwGroupManage.inGroup.header:SetFont(UNIT_NAME_FONT, 14)

    GwGroupManage.inGroup:RegisterEvent("GROUP_ROSTER_UPDATE")
    GwGroupManage.inGroup:RegisterEvent("RAID_ROSTER_UPDATE")
    GwGroupManage.inGroup:RegisterEvent("PLAYER_REGEN_ENABLED")
    GwGroupManage.inGroup:SetScript("OnEvent", fnGMIG_OnEvent)

    local fnF_OnEnter = function(self)
        self.texture:SetBlendMode("ADD")
    end
    local fnF_OnLeave = function(self)
        self.texture:SetBlendMode("BLEND")
    end

    local x, y, f = 15, -25, nil

    GwGroupManage.inGroup.markers = {}
    for i = 1, 8 do
        f = CreateFrame("Button", "GwRaidMarkerButton" .. i, GwGroupManage.inGroup, "GwRaidMarkerButton")
        f:SetScript("OnEnter", fnF_OnEnter)
        f:SetScript("OnLeave", fnF_OnLeave)

        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", GwGroupManage.inGroup, "TOPLEFT", x, y)
        f:SetNormalTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_" .. i)
        f:SetScript("OnClick", function()
            PlaySound(1115)
            SetRaidTargetIcon("target", i)
        end)

        x = x + 44
        if i == 4 then
            y = y + -40
            x = 15
        end
        GwGroupManage.inGroup.markers[i] = f
    end

    local fnGMGB_OnEnter = function(self)
        self.arrow:SetSize(21, 42)
        if GetSetting("FADE_GROUP_MANAGE_FRAME") then
            if GwGroupManage:IsShown() then
                return
            end
            fmGMGB.fadeIn()
        end
    end
    local fnGMGB_OnLeave = function(self)
        self.arrow:SetSize(16, 32)
        if GetSetting("FADE_GROUP_MANAGE_FRAME") then
            if GwGroupManage:IsShown() then
                return
            end
            fmGMGB.fadeOut()
        end
    end
    fmGMGB:SetScript("OnEnter", fnGMGB_OnEnter)
    fmGMGB:HookScript("OnLeave", fnGMGB_OnLeave)

    fnGMIG_OnEvent(GwGroupManage.inGroup)

    if GetSetting("FADE_GROUP_MANAGE_FRAME") then
        local fo = fmGMGB:CreateAnimationGroup("fadeOut")
        local fi = fmGMGB:CreateAnimationGroup("fadeIn")
        local fadeOut = fo:CreateAnimation("Alpha")
        local fadeIn = fi:CreateAnimation("Alpha")
        fo:SetScript("OnFinished", function(self)
            self:GetParent():SetAlpha(0)
        end)
        fi:SetScript("OnFinished", function(self)
            self:GetParent():SetAlpha(1)
        end)
        fadeOut:SetStartDelay(0.25)
        fadeOut:SetFromAlpha(1.0)
        fadeOut:SetToAlpha(0.0)
        fadeOut:SetDuration(0.15)
        fadeIn:SetFromAlpha(0.0)
        fadeIn:SetToAlpha(1.0)
        fadeIn:SetDuration(0.15)
        fmGMGB.fadeOut = function()
            fi:Stop()
            fo:Stop()
            fo:Play()
        end
        fmGMGB.fadeIn = function()
            fi:Stop()
            fo:Stop()
            fi:Play()
        end
        fmGMGB:SetAlpha(0)
    end
end
GW.manageButton = manageButton
GW.AddForProfiling("raidControl", "manageButton", manageButton)

local function UpdateRaidCounterVisibility()
    local VisibilityStates = {
        ["NEVER"] = "hide",
        ["ALWAYS"] = "[petbattle] hide; show",
        ["IN_GROUP"] = "[petbattle] hide; [group:raid] hide; [group:party] show; hide",
        ["IN_RAID"] = "[petbattle] hide; [group:raid] show; [group:party] hide; hide",
        ["IN_RAID_IN_PARTY"] = "[petbattle] hide; [group] show; hide",
    }

    RegisterStateDriver(GW_RaidCounter_Frame, "visibility", VisibilityStates[GetSetting("ROLE_BAR")])
    GW_RaidCounter_Frame:GetScript("OnEvent")(GW_RaidCounter_Frame)
end
GW.UpdateRaidCounterVisibility = UpdateRaidCounterVisibility

local function Create_Raid_Counter()
    local raidCounterFrame = CreateFrame("Button", "GW_RaidCounter_Frame", UIParent, "SecureHandlerClickTemplate")

    if GwSocialWindow then
        raidCounterFrame:SetFrameRef("GwSocialWindow", GwSocialWindow)
    end
    raidCounterFrame:SetAttribute("ourWindow", GetSetting("USE_SOCIAL_WINDOW"))
    raidCounterFrame.func = function() ToggleRaidFrame() end
    raidCounterFrame:SetAttribute(
        "_onclick",
        [=[
            if self:GetAttribute("ourWindow") then
                local f = self:GetFrameRef("GwSocialWindow")
                f:SetAttribute("keytoggle", true)
                f:SetAttribute("windowpanelopen", "raidlist")
            else
                self:CallMethod("func")
            end
        ]=]
    )
    raidCounterFrame:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)

    raidCounterFrame:SetSize(100, 25)

    raidCounterFrame.tank = raidCounterFrame:CreateFontString(nil, "ARTWORK")
    raidCounterFrame.tank:SetFont(UNIT_NAME_FONT, 12)
    raidCounterFrame.tank:SetPoint("LEFT", raidCounterFrame, "LEFT", 5, 0)
    raidCounterFrame.tank:SetTextColor(1, 1, 1)

    raidCounterFrame.heal = raidCounterFrame:CreateFontString(nil, "ARTWORK")
    raidCounterFrame.heal:SetFont(UNIT_NAME_FONT, 12)
    raidCounterFrame.heal:SetPoint("CENTER", raidCounterFrame, "CENTER", 0, 0)
    raidCounterFrame.heal:SetTextColor(1, 1, 1)

    raidCounterFrame.damager = raidCounterFrame:CreateFontString(nil, "ARTWORK")
    raidCounterFrame.damager:SetFont(UNIT_NAME_FONT, 12)
    raidCounterFrame.damager:SetPoint("RIGHT", raidCounterFrame, "RIGHT", -5, 0)
    raidCounterFrame.damager:SetTextColor(1, 1, 1)

    raidCounterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    raidCounterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    raidCounterFrame:RegisterEvent("ROLE_CHANGED_INFORM")
    
    raidCounterFrame:SetScript("OnEvent", function(self)
        if not self:IsShown() then return end

        local unit = (IsInRaid() and "raid" or "party")
        local tank, damage, heal = 0, 0, 0
        for i = 1, GetNumGroupMembers() do
            local role = UnitGroupRolesAssigned(unit .. i)

            if role then
                if role == "TANK" then
                    tank = tank + 1
                elseif role == "HEALER" then
                    heal = heal + 1
                elseif role == "DAMAGER" then
                    damage = damage + 1
                end
            end
        end

        if GetNumGroupMembers() == 0 or unit == "party" then
            local plyerRole = UnitGroupRolesAssigned("player")
            if plyerRole then
                if plyerRole == "TANK" then
                    tank = tank + 1
                elseif plyerRole == "HEALER" then
                    heal = heal + 1
                elseif plyerRole == "DAMAGER" then
                    damage = damage + 1
                end
            end
        end

        raidCounterFrame.tank:SetText("|TInterface/AddOns/GW2_UI/textures/party/roleicon-tank:0:0:0:2:64:64:4:60:4:60|t " .. tank)
        raidCounterFrame.heal:SetText("|TInterface/AddOns/GW2_UI/textures/party/roleicon-healer:0:0:0:1:64:64:4:60:4:60|t " .. heal)
        raidCounterFrame.damager:SetText("|TInterface/AddOns/GW2_UI/textures/party/roleicon-dps:15:15:0:0:64:64:4:60:4:60|t" .. damage)
    end)

    GW.RegisterMovableFrame(raidCounterFrame, GW.L["Role Bar"], "ROLE_BAR_pos", "VerticalActionBarDummy", nil, {"default", "scaleable"})
    raidCounterFrame:ClearAllPoints()
    raidCounterFrame:SetPoint("TOPLEFT", raidCounterFrame.gwMover)

    UpdateRaidCounterVisibility()
end
GW.Create_Raid_Counter = Create_Raid_Counter
