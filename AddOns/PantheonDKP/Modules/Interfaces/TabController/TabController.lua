local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI

local CreateFrame = CreateFrame

local Tab = { _initialized = false }

function Tab:Initialize()
    if PDKP.memberTable == nil then
        C_Timer.After(1, function()
            Tab:Initialize()
        end)
        return
    end

    Tab.tabs = {};
    Tab.tab_btns = {};
    Tab.tab_names = {};

    local f = CreateFrame("Frame", "$parentRightFrame", pdkp_frame)
    f:SetFrameStrata("DIALOG")

    f:SetHeight(500)
    f:SetWidth(395)
    f:SetPoint("TOPLEFT", PDKP.memberTable.frame, "TOPRIGHT", 0, 0)
    f:SetPoint("BOTTOMLEFT", PDKP.memberTable.filter_frame, "BOTTOMRIGHT", 0, 0)

    local tab_opts = {
        ['view_adjust_button'] = {
            ['text'] = 'Adjust',
        },
        ['view_history_button'] = {
            ['text'] = 'History',
        },
        ['view_loot_button'] = {
            ['text'] = 'Loot',
        },
        ['view_shame_leaderboard_button'] = {
            ['text'] = 'Shame',
        },
        ['view_options_button'] = {
            ['text'] = 'Options',
        },
    }

    local tab_names = { 'view_history_button', 'view_loot_button', 'view_options_button' }
    if PDKP.canEdit then
        tab_names = { 'view_adjust_button', unpack(tab_names) }
    end

    if MODULES.Options:GetNSFWSync() then
        table.insert(tab_names, 'view_shame_leaderboard_button');
    end

    local btn_pad = 35

    for i = 1, #tab_names do
        local name = tab_names[i]
        local tab_opt = tab_opts[name]
        local tf = CreateFrame("Frame", name .. '_frame', f, MODULES.Media.BackdropTemplate)
        tf:SetBackdrop({
            tile = true, tileSize = 0,
            edgeFile = MODULES.Media.SCROLL_BORDER, edgeSize = 8,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        tf:SetAllPoints(f)

        local b = CreateFrame("Button", "$parent_" .. name, f)
        b:SetSize(100, 30)

        if name == 'view_adjust_button' and PDKP.canEdit and i == 1 then
            b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 0)
        elseif #Tab.tabs == 0 then
            b:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 0)
        else
            b:SetPoint("TOPLEFT", Tab.tabs[i - 1], "TOPRIGHT", 0, 0)
            b:SetAlpha(0.5)
        end

        b:SetNormalTexture(MODULES.Media.TAB_TEXTURE)
        b:SetScript("OnClick", function()
            for _, btn in pairs(Tab.tabs) do
                if btn:GetName() ~= b:GetName() then
                    btn.frame:Hide()
                    btn:SetAlpha(0.5)
                    btn.active = false
                else
                    Tab.activeTab = btn:GetName()
                end
            end

            b:SetAlpha(1)

            if Tab.activeTab == 'pdkp_frameRightFrame_view_options_button' then
                InterfaceOptionsFrame_Show()
                InterfaceOptionsFrame_OpenToCategory("PantheonDKP")
                pdkp_frame:Hide();
                return;
            end
            b.frame:Show()
        end)

        local b_text = b:CreateFontString(b, "OVERLAY", "GameFontNormalLeft")
        b_text:SetPoint("CENTER", 0, -5)
        b_text:SetText(tab_opt['text'])
        b:SetWidth(b_text:GetWidth() + btn_pad)

        b.text = b_text
        b.frame = tf

        Tab.tab_names[name] = b
        Tab.tabs[i] = b
        Tab.tab_btns[i] = b
    end

    Tab.tab_btns[1]:Click()
    --pdkp_frame:Show();

    self._initialized = true
end

GUI.TabController = Tab
