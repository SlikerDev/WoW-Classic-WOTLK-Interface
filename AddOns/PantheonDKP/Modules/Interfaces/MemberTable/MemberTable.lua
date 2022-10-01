local _, PDKP = ...
local _G = _G;

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;

local CreateFrame = CreateFrame
local GameFontNormalSmall = GameFontNormalSmall
local tinsert, pairs = tinsert, pairs

local MemberTable = { _initialized = false }

function MemberTable:Initialize()
    local st = {};

    local function compare(a, b)
        local sortDir = st.sortDir;
        local sortBy = st.sortBy;
        -- Set the data object explicitly here
        -- Since this is pointing to a row object originally.
        -- Not a member object.
        a = a.dataObj;
        b = b.dataObj;

        if sortBy == 'name' then
            a, b = a['name'], b['name']
        elseif sortBy == 'class' then
            if a['class'] == b['class'] then
                return a['name'] < b['name']
            end
            a, b = a['class'], b['class']
        end

        if sortBy == 'dkp' then
            local aDKP = a:GetDKP('display')
            local bDKP = b:GetDKP('display')
            if aDKP ~= bDKP then
                a, b = aDKP, bDKP
            elseif a['class'] ~= b['class'] then
                b, a = a['class'], b['class']
            else
                b, a = a['name'], b['name']
            end
        end

        if sortDir == 'ASC' then
            return a > b
        else
            return a < b
        end
    end

    local table_settings = {
        ['name'] = 'ScrollTable',
        ['parent'] = pdkp_frame,
        ['height'] = 350,
        ['width'] = 330,
        ['movable'] = true,
        ['enableMouse'] = true,
        ['retrieveDataFunc'] = function()
            MODULES.GuildManager:GetMembers()
            return MODULES.GuildManager.memberNames;
        end,
        ['retrieveDisplayDataFunc'] = function(_, name)
            return MODULES.GuildManager:GetMemberByName(name)
        end,
        ['anchor'] = {
            ['point'] = 'TOPLEFT',
            ['rel_point_x'] = 8,
            ['rel_point_y'] = -70,
        },
        ['onSelectChanged'] = function()
            GUI.Adjustment:DropdownChanged()

            if GUI.HistoryGUI.frame and GUI.HistoryGUI.frame:IsVisible() then
                GUI.HistoryGUI:HistoryUpdated(true)
            end

            if GUI.LootGUI.frame and GUI.LootGUI.frame:IsVisible() then
                GUI.LootGUI:HistoryUpdated(true)
            end
        end
    }
    local col_settings = {
        ['height'] = 14,
        ['width'] = 90,
        ['firstSort'] = 3, -- Denotes the header we want to sort by originally.
        ['firstSortDir'] = 'DESC',
        ['headers'] = {
            [1] = {
                ['label'] = 'name',
                ['sortable'] = true,
                ['point'] = 'LEFT',
                ['showSortDirection'] = true,
                ['compareFunc'] = compare
            },
            [2] = {
                ['label'] = 'class',
                ['sortable'] = true,
                ['point'] = 'CENTER',
                ['showSortDirection'] = true,
                ['compareFunc'] = compare,
                ['colored'] = true,
            },
            [3] = {
                ['label'] = 'dkp',
                ['sortable'] = true,
                ['point'] = 'RIGHT',
                ['showSortDirection'] = true,
                ['compareFunc'] = compare,
                ['getValueFunc'] = function(member)
                    return member:GetDKP('display');
                end,
            },
        }
    }
    local row_settings = {
        ['height'] = 20,
        ['width'] = 285,
        ['max_values'] = 425,
        ['showHighlight'] = true,
        ['indexOn'] = col_settings['headers'][1]['label'], -- Helps us keep track of what is selected, if it is filtered.
    }

    st = PDKP.ScrollTable:newHybrid(table_settings, col_settings, row_settings)

    PDKP.memberTable = st;
    PDKP.memberTable._initialized = true

    st.searchFrame = self:TableSearch()
    --
    ---- Entries label
    ---- 0 Entries shown | 0 selected
    local label = st.searchFrame:CreateFontString(st.searchFrame, 'OVERLAY', 'GameFontNormalLeftYellow')
    label:SetSize(200, 15)
    label:SetPoint("LEFT", st.searchFrame.clearButton, "LEFT", 60, -1)
    label:SetText("0 Players shown | 0 selected")

    st.entryLabel = label

    PDKP.memberTable.filter_frame = self:Filters()

    self._initialized = true
end

function MemberTable:Reinitialize()
    PDKP.memberTable.frame:Hide();
    PDKP.memberTable = nil;
    MemberTable:Initialize();

    GUI.MemberScrollTable = MemberTable;
end

function MemberTable:TableSearch()

    -- edit frame
    local ef = CreateFrame("Frame", "$parent_edit_frame", pdkp_frame)
    ef:SetHeight(25)
    ef:SetWidth(165)
    ef:SetPoint('BOTTOMLEFT', pdkp_frame, "BOTTOMLEFT", 10, 10)

    -- search label
    local sl = ef:CreateFontString(ef, 'OVERLAY', 'GameFontNormalSmall')
    sl:SetText("Search:")
    sl:SetPoint("LEFT", ef, "LEFT", -12, 0)
    sl:SetWidth(80)

    -- edit clear button
    local clearButton = CreateFrame("Button", "$parent_clear_button", ef, "UIPanelButtonTemplate")
    clearButton:SetText("Clear")
    clearButton:SetSize(45, 15)
    clearButton:SetPoint("RIGHT", ef, "RIGHT", -2, 0)

    -- edit box
    local eb = CreateFrame("EditBox", "$parent_editBox", pdkp_frame)
    eb:SetWidth(75)
    eb:SetHeight(50)
    eb:SetPoint("LEFT", ef, "LEFT", 48, 0)
    eb:SetFontObject(GameFontNormalSmall)
    eb:SetFrameStrata("DIALOG")
    eb:SetMaxLetters(11)
    eb:SetAutoFocus(false)

    local function toggleClearButton(text)
        if text == nil or text == "" then
            clearButton:Hide()
        else
            clearButton:Show()
        end
    end

    local function resetSearch()
        eb:ClearFocus()
        toggleClearButton(eb:GetText())
    end

    eb:SetScript("OnEscapePressed", function()
        resetSearch()
    end)
    eb:SetScript("OnEnterPressed", function()
        resetSearch()
    end)
    eb:SetScript("OnTextChanged", function()
        local text = eb:GetText()
        toggleClearButton(text)
        PDKP.memberTable:SearchChanged(text)
    end)
    eb:SetScript("OnEditFocusLost", function()
        toggleClearButton(eb:GetText())
    end)
    eb:SetScript("OnEditFocusGained", function()
        toggleClearButton(eb:GetText())
    end)

    clearButton:SetScript("OnClick", function()
        eb:SetText("")
        resetSearch()
    end)

    clearButton:Hide()

    ef.editBox = eb
    ef.searchLabel = sl
    ef.clearButton = clearButton

    return ef
end

function MemberTable:Filters()
    self.FilterButtons = {}

    local f = CreateFrame("Frame", "$parentFilterFrame", pdkp_frame, MODULES.Media.BACKDROPTEMPLATE)

    f:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = MODULES.Media.SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetHeight(150)
    f:SetPoint("TOPLEFT", PDKP.memberTable.frame, "BOTTOMLEFT", 0, 0)
    f:SetPoint("TOPRIGHT", PDKP.memberTable.frame, "BOTTOMRIGHT", 0, 0)

    f:Show()

    local rows = { -- Our filter rows
        { -- Row 1
            { ['point'] = 'TOPLEFT', ['x'] = 15, ['y'] = -10, ['displayText'] = 'Online', ['filterOn'] = 'online', ['enabled'] = false },
            { ['point'] = 'TOPLEFT', ['x'] = 30, ['y'] = 0, ['displayText'] = 'In Raid', ['filterOn'] = 'raid', ['enabled'] = false },
            { ['point'] = 'TOPLEFT', ['x'] = 30, ['y'] = 0, ['displayText'] = 'Selected', ['filterOn'] = 'selected', ['enabled'] = false },
            { ['point'] = 'TOPLEFT', ['x'] = 30, ['y'] = 0, ['displayText'] = 'Select All', ['filterOn'] = 'Select_All', ['enabled'] = false },
        },
        { -- Row 2
            { ['point'] = 'TOPLEFT', ['x'] = 0, ['y'] = 0, ['displayText'] = 'All Classes', ['filterOn'] = 'Class_All',
              ['center'] = true, ['enabled'] = true
            },
        },
        {}, -- First Class Row
        {}, -- Second Class Row
        {}, -- Third Class Row
    }

    local class_row = 3

    local CLASSES = MODULES.Constants.CLASSES

    for key, class in pairs(CLASSES) do
        local classBtn = {
            ['point'] = 'TOPLEFT', ['x'] = 60, ['y'] = 70, ['displayText'] = class,
            ['filterOn'] = 'Class_' .. class, ['center'] = true, ['enabled'] = true
        }
        if key >= 4 and key <= 6 then
            class_row = 4
        elseif key >= 7 then
            class_row = 5
        end
        tinsert(rows[class_row], classBtn)
    end

    for rowKey, row in pairs(rows) do
        for fKey, filter in pairs(row) do
            local parent = f -- Default parent.
            tinsert(self.FilterButtons, {})

            if fKey > 1 or rowKey > 1 then
                local pcb = self.FilterButtons[#self.FilterButtons - 1];
                local pcbt = _G[pcb:GetName() .. 'Text']
                parent = pcb;
                if #row > 1 then
                    -- To better space out the buttons.
                    filter['x'] = filter['x'] + pcbt:GetWidth();
                end
            end

            local opts = {
                ['parent'] = parent,
                ['center'] = filter['center'],
                ['uniqueName'] = filter['filterOn'],
                ['x'] = filter['x'],
                ['y'] = filter['y'],
                ['point'] = filter['point'],
                ['text'] = filter['displayText'],
                ['enabled'] = filter['enabled'],
                ['frame'] = f,
            }

            local cb = GUtils:createCheckButton(opts)

            -- Clear all points, to reassign their points to the previous section's checkbutton.
            if rowKey >= 2 then
                cb:ClearAllPoints();
            end

            if rowKey == 2 then
                cb:SetPoint("LEFT", self.FilterButtons[#self.FilterButtons - 4], "LEFT", 0, -25);
            elseif rowKey == 3 then
                if fKey == 1 then
                    cb:SetPoint("LEFT", self.FilterButtons[#self.FilterButtons - 1], "LEFT", 0, -25);
                else
                    cb:SetPoint("TOPRIGHT", self.FilterButtons[#self.FilterButtons - 1], "TOPRIGHT", filter['x'], 0);
                end
            elseif rowKey >= 4 then
                cb:SetPoint("TOPLEFT", self.FilterButtons[#self.FilterButtons - 3], "TOPLEFT", 0, -20);
            end

            cb:SetScript("OnClick", function(b)
                local function loop_all_class(setStatus)
                    local all_checked = true;
                    for i = 1, #CLASSES do
                        local button = _G['pdkp_filter_Class_' .. CLASSES[i]];
                        if setStatus ~= nil then
                            button:SetChecked(setStatus);
                        end
                        if not button:GetChecked() then
                            all_checked = false
                        end
                    end
                    return all_checked
                end
                if rowKey == 2 then
                    loop_all_class(b:GetChecked());
                elseif rowKey >= 3 then
                    local all_checked = loop_all_class();
                    _G['pdkp_filter_Class_All']:SetChecked(all_checked);
                end

                local st = PDKP.memberTable;
                st:ApplyFilter(b.filterOn, b:GetChecked());
            end)
            self.FilterButtons[#self.FilterButtons] = cb;
        end
    end

    local st = PDKP.memberTable;
    for _, b in pairs(self.FilterButtons) do
        st:ApplyFilter(b.filterOn, b:GetChecked());
    end

    f.filterButtons = self.FilterButtons;

    return f;
end

function MemberTable:GetDisplayedRows()
    if self.displayedRows == nil then return 0 end;
    return #self.displayedRows
end

GUI.MemberScrollTable = MemberTable;
