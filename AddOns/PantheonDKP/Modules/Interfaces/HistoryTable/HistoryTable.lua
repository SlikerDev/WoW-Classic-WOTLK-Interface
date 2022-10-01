local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local HistoryTable = { _initialized = false }

local SimpleScrollFrame, MemberTable, Media, DKPManager;

local CreateFrame = CreateFrame
local _, _, _, _, _, _ = type, math.floor, strupper, math.pi, string.match, string.gsub
local tinsert, _ = tinsert, tremove

local tabName = 'view_history_button';

local EXPAND_ALL, COLLAPSE_ALL

local ROW_COL_HEADERS = {
    { ['variable'] = 'formattedOfficer', ['display'] = 'Officer', },
    { ['variable'] = 'historyText', ['display'] = 'Reason', ['OnClick'] = true, },
    { ['variable'] = 'formattedNames', ['display'] = 'Members', ['OnClick'] = true, },
    { ['variable'] = 'change_text', ['display'] = 'Amount' }
}

local ROW_MARGIN_TOP = 16 -- The margin between rows.

HistoryTable.__index = HistoryTable; -- Set the __index parameter to reference

function HistoryTable:Initialize()
    if not GUI.TabController._initialized then
        return C_Timer.After(0.1, function()
            self:Initialize()
        end)
    end

    SimpleScrollFrame = PDKP.SimpleScrollFrame
    MemberTable = PDKP.memberTable
    Media = MODULES.Media
    DKPManager = MODULES.DKPManager

    EXPAND_ALL = Media.EXPAND_ALL
    COLLAPSE_ALL = Media.COLLAPSE_ALL

    self.parentFrame = GUI.TabController.tab_names[tabName].frame;

    self.frame = GUtils:createBackdropFrame('history_frame', self.parentFrame, '', false)

    self.frame:SetPoint("TOPLEFT", self.parentFrame, "TOPLEFT", 0, 0)
    self.frame:SetPoint("BOTTOMRIGHT", self.parentFrame, "BOTTOMRIGHT", 0, 0)

    self.frame.border:SetAllPoints(self.frame)

    self.frame.content:SetPoint("TOPLEFT", 10, -40)
    self.frame.content:SetPoint("BOTTOMRIGHT", -10, 10)

    self.frame.title:SetPoint("TOPLEFT", 14, -15)
    self.frame.title:SetPoint("TOPRIGHT", -14, -15)

    HistoryTable.frame = self.frame

    local sb = CreateFrame("Button", "$parent_load_more_btn", self.frame, "UIPanelButtonTemplate")
    sb:SetSize(80, 22) -- width, height
    sb:SetText("Load More")
    sb:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 4, -22)

    self.refreshPending = false;

    local function toggleSB()
        local numLeft = DKPManager:GetNumEncoded()
        if numLeft <= 0 then
            sb:Disable()
        else
            sb:Enable()
        end
    end

    sb:SetScript("OnClick", function()
        MODULES.DKPManager:LoadPrevFourWeeks()
        self:RefreshData()
        toggleSB()
    end)

    self.frame.content:SetScript("OnShow", function()
        toggleSB()
        if self.refreshPending then
            self:RefreshData(true)
            self:HistoryUpdated(true)
            self:CollapseAllRows(self.collapsed)
            self.refreshPending = false;
        end
    end)

    local scroll = SimpleScrollFrame:new(self.frame.content)
    local scrollFrame = scroll.scrollFrame
    local scrollContent = scrollFrame.content;
    local scrollBar = scrollFrame.scrollBar

    scrollBar.bg:SetColorTexture(unpack({ 0, 0, 0, 1 }))

    self.scrollContent = scrollContent;

    self.appliedFilters = {};
    self.rows = {};
    self.entry_keys = {}; -- Our Entry Keys from the history table.
    self.entries = {};
    self.updateNextOpen = false;
    self.displayedRows = {};
    self.collapsed = false;
    self.table_init = false;
    self.collapsed_raids = {};

    self.RefreshDataFrame = CreateFrame("Frame");
    self.RefreshDisplayFrame = CreateFrame("Frame");

    self.title_text = 'PantheonDKP History'

    for i = 1, #MODULES.Constants.RAID_NAMES do
        local raid_name = MODULES.Constants.RAID_NAMES[i]
        self.collapsed_raids[raid_name] = true
    end

    local collapse_all = CreateFrame("Button", nil, self.frame)
    collapse_all:SetPoint("TOPRIGHT", -12, -20)
    collapse_all:SetSize(16, 16)
    collapse_all:SetNormalTexture(EXPAND_ALL)
    collapse_all:SetScript("OnClick", function()
        self.collapsed = not self.collapsed;
        self:CollapseAllRows(self.collapsed)
    end)

    collapse_all.UpdateTexture = function()
        collapse_all:SetNormalTexture(Utils:ternaryAssign(self.collapsed, COLLAPSE_ALL, EXPAND_ALL))
    end

    self.collapse_all = collapse_all;

    self.frame:SetScript("OnShow", function()
        if not self.collapse_init then
            self.collapse_all:Click()
            self.collapse_init = true
        end
    end)

    self.frame:HookScript("OnShow", function()
        if #MemberTable:GetSelected() == 1 then
            self:HistoryUpdated(true)
        end
    end)

    self:_OnLoad()

    self:RefreshData()

    self._initialized = true

    return self
end

function HistoryTable:Reinitialize()
    self.frame:Hide();
    self.frame = nil;
    self:Initialize();
end

function HistoryTable:CollapseAllRows(collapse)
    for i = 1, #self.rows do
        local row = self.rows[i]
        row:collapse_frame(collapse)
    end

    --self.collapsed_raids[Settings.current_raid] = self.collapsed;
    self.scrollContent:ResizeByChild(0, 0)
    self.collapse_all:UpdateTexture()
end

function HistoryTable:ToggleRows()
    for i = 1, #self.displayedRows do
        local row = self.displayedRows[i]
        row:collapse_frame(row.collapsed)
    end
end

function HistoryTable:RefreshData(justData)
    if self.scrollContent == nil then return end
    --PDKP:PrintD("Refreshing History Table Data");

    self.scrollContent:WipeChildren(self.scrollContent)
    wipe(self.entry_keys)
    wipe(self.entries)
    self.entry_keys = DKPManager:GetEntryKeys(true, { 'Item Win' });

    for i = 1, #self.entry_keys do
        self.entries[i] = DKPManager:GetEntryByID(self.entry_keys[i]);
    end

    if justData == nil or justData == false then
        self:RefreshTable();
    end

    if #self.entry_keys == 0 then
        self:_NoEntriesFound()
    else
        self:_EntriesFound()
    end
end

function HistoryTable:RefreshTable()
    --PDKP:PrintD("Refreshing History Table Display");

    wipe(self.displayedRows)

    for i = 1, #self.entry_keys do
        local row = self.rows[i]
        row:Hide()
        row:ClearAllPoints()

        row:UpdateRowValues(self.entries[i])

        if not row:ApplyFilters() then
            tinsert(self.displayedRows, row)
            row:Show()
            row.display_index = #self.displayedRows
        end
    end

    self.scrollContent:AddBulkChildren(self.displayedRows)
    self:CollapseAllRows(self.collapsed)
end

-- Refresh the data, resize the table, re-add the children?
function HistoryTable:HistoryUpdated(selectedUpdate)
    -- Don't do unnecessary updates.

    if self.table_init and not selectedUpdate then
        return
    end

    local selected = PDKP.memberTable.selected;
    if #selected > 0 then
        self.appliedFilters['selected'] = selected;
    elseif #selected == 0 then
        self.appliedFilters['selected'] = nil;
    end
    self:UpdateTitleText(selected)

    local collapse_rows = false
    if collapse_rows then
        self:CollapseAllRows(self.collapsed)
    end

    self:RefreshTable()

    self:ToggleRows()

    if not self.table_init then
        self.table_init = true
    end
end

function HistoryTable:UpdateTitleText(selected)
    local text;

    if #selected == 1 then
        text = selected[1] .. ' History';
    else
        text = GetGuildInfo("PLAYER") .." DKP History"
    end

    self.frame.title:SetText(text)
end

function HistoryTable:_OnLoad()
    local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Frame", nil, self.scrollContent, Media.BackdropTemplate)
        row:SetSize(350, 50)
        row.index = i;
        row.display_index = nil;
        row.dataObj = self.entries[i];
        row.cols = {};

        row.isFiltered, row.collapsed, row.max_width, row.max_height = false, true, 0, 0

        local collapse_text, row_title;
        local expand_tex = 'Interface\\Buttons\\UI-Panel-CollapseButton-Up'
        local collapse_tex = 'Interface\\Buttons\\UI-Panel-ExpandButton-Up'

        local border = CreateFrame("Frame", nil, row, Media.BackdropTemplate)
        border:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -ROW_MARGIN_TOP)
        border:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -1, 0)
        border:SetBackdrop(Media.PaneBackdrop)
        border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
        border:SetBackdropBorderColor(0.4, 0.4, 0.4)

        row_title = border:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
        row_title:SetPoint("TOPLEFT", 14, 14)
        row_title:SetPoint("TOPRIGHT", 20, 14)
        row_title:SetHeight(18)
        row_title:SetText(i)

        local content = CreateFrame("Frame", nil, border, Media.BackdropTemplate)
        content:SetWidth(row:GetWidth() - 20)
        content:SetPoint("TOPLEFT", border, "TOPLEFT", 5, -5)
        content:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -10, 0)
        content:SetBackdropColor(0.5, 0.5, 0.5, 1)

        collapse_text = border:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        collapse_text:SetHeight(18)
        collapse_text:SetPoint("LEFT", 14, 0)
        collapse_text:SetJustifyH("LEFT")
        collapse_text:Hide()

        row.border = border
        row.content = content

        local collapse_button = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        collapse_button:SetPoint("TOPRIGHT", -2, -2)
        collapse_button:SetNormalTexture(collapse_tex)
        collapse_button:SetSize(15, 15)

        row.super = self;

        row.collapse_frame = function(_, collapse)
            if collapse then
                row.content:Hide()
                collapse_button:SetNormalTexture(collapse_tex)
                row:SetHeight(50)
                row.collapsed = true
                collapse_text:Show()
                row:HideColClicks()
            else
                collapse_button:SetNormalTexture(expand_tex)
                row.content:Show()
                row:SetHeight(row.max_height + ROW_MARGIN_TOP)
                row.collapsed = false
                collapse_text:Hide()
                row:HideColClicks()
            end
        end

        collapse_button:SetScript("OnClick", function()
            row:collapse_frame(not row.collapsed)
            self.scrollContent:ResizeByChild(0, 0, row.display_index)
        end)

        function row:ApplyFilters()
            local self = row.super;
            local dataObj = row.dataObj;
            row.isFiltered = false;
            if dataObj['deleted'] == true then
                row.isFiltered = true
            end

            local selected = self.appliedFilters['selected']

            for filter, val in pairs(self.appliedFilters or {}) do
                if row.isFiltered then
                    break
                end -- No need to continue the loop.
                if filter == 'raid' then
                    row.isFiltered = row.dataObj['raid'] ~= val
                elseif filter == 'selected' and selected ~= nil and #selected == 1 then
                    for _, n in pairs(selected) do
                        row.isFiltered = not row.dataObj:IsMemberInEntry(n)
                        if row.isFiltered then
                            break
                        end
                    end
                end
            end

            return row.isFiltered;
        end

        function row:HideColClicks()
            for _, c in pairs(row.cols) do
                local cf = c.click_frame
                if row.content:IsVisible() then
                    c:Show()
                    if cf then
                        cf:Show()
                    end
                else
                    c:Hide()
                    if cf then
                        cf:Hide()
                    end
                end
            end
        end

        function row:UpdateRowValues(entry)

            if entry then
                row.dataObj = entry
            end
            row.max_height = 0
            row:SetID(row.dataObj['id'])

            for key = 1, #ROW_COL_HEADERS do
                local header = ROW_COL_HEADERS[key]
                local variable, displayName = header['variable'], header['display']
                local col = row.cols[key]
                local val = row.dataObj[variable] or ''

                if col == nil then
                    col = content:CreateFontString(nil, 'OVERLAY', "GameFontHighlightLeft")
                    col.click_frame = nil;
                end

                col:SetWidth(content:GetWidth() - 5)
                if key == 1 then
                    col:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
                else
                    col:SetPoint("TOPLEFT", row.cols[key - 1], "BOTTOMLEFT", 0, -2)
                end
                col:SetText(displayName .. ": " .. val)
                row.max_height = row.max_height + col:GetStringHeight() + 6

                if header['OnClick'] then
                    local cf = col.click_frame;
                    if cf == nil then
                        cf = CreateFrame("Frame", nil, row)
                        cf.value = val;
                        cf.label = header['display']
                        cf:SetAllPoints(col)
                        cf:SetScript("OnMouseDown", PDKP_History_OnClick)
                        col.click_frame = cf;
                    end
                end

                row.cols[key] = col

            end

            row:SetHeight(row.max_height + ROW_MARGIN_TOP)
            row:UpdateTextValues()
        end

        function row:UpdateTextValues()
            row_title:SetText(row.dataObj['formattedID'])

            if PDKP:IsDev() and PDKP.showHistoryIds then
                row_title:SetText(row.dataObj['id']);
            end

            local c_raid = row.dataObj['raid'] or ''
            local c_officer = row.dataObj['formattedOfficer'] or ''
            local c_hist = row.dataObj['collapsedHistoryText'] or ''
            local c_sep = ' | '
            local c_text = c_officer .. c_sep
            if c_raid ~= '' then
                c_text = c_text .. c_raid .. c_sep
            end

            c_text = c_text .. c_hist

            collapse_text:SetText(c_text)
            if collapse_text:GetStringWidth() > 325 then
                collapse_text:SetWidth(315)
            end
        end

        row:UpdateRowValues()

        rawset(t, i, row)
        return row
    end })

    self.rows = rows
end

function HistoryTable:_NoEntriesFound()
    self.frame.title:SetText("No Entries Found")
    self.frame.desc:SetText("This will be populated once your database has a valid entry")

    self.collapse_all:Hide()
end

function HistoryTable:_EntriesFound()
    self.frame.title:SetText(GetGuildInfo("PLAYER") .." DKP History")
    self.frame.desc:SetText("")

    self.collapse_all:Show()
end

function PDKP_History_OnClick(frame, buttonType)
    if not PDKP.canEdit or not IsShiftKeyDown() then
        return
    end

    local label = frame.label;
    local dataObj = frame:GetParent()['dataObj']

    if dataObj['deleted'] then
        --PDKP:PrintD("Entry has already been deleted")
        return
    end

    if label == 'Members' then
        return PDKP.memberTable:SelectNames(dataObj['names'])
    elseif label == 'Reason' and buttonType == 'RightButton' then
        GUI.Dialogs:Show('PDKP_DKP_ENTRY_POPUP', nil, dataObj)
    end
end

pdkp_HistoryTableMixin = HistoryTable;

GUI.HistoryGUI = HistoryTable;
