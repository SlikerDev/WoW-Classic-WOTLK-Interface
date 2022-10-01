local _, PDKP = ...
local _G = _G;

local MODULES = PDKP.MODULES

PDKP.ScrollTable = {}

local Utils = PDKP.Utils

local ScrollTable = PDKP.ScrollTable

ScrollTable.__index = ScrollTable; -- Set the __index parameter to reference

local type, floor, pi = type, math.floor, math.pi
local strupper, substr, strsplit = strupper, string.match, strsplit
local tinsert, tremove, tContains, unpack, wipe, setmetatable, rawset, tsort = tinsert, tremove, tContains, unpack, wipe, setmetatable, rawset, table.sort
local pairs = pairs

local coroutine_create = coroutine.create
local coroutine_resume = coroutine.resume
local coroutine_yield = coroutine.yield

local maxProcessCount = 16;

local IsControlKeyDown, IsShiftKeyDown = IsControlKeyDown, IsShiftKeyDown
local HybridScrollFrame_Update, HybridScrollFrame_GetOffset, HybridScrollFrame_SetDoNotHideScrollBar = HybridScrollFrame_Update, HybridScrollFrame_GetOffset, HybridScrollFrame_SetDoNotHideScrollBar
local CreateFrame = CreateFrame

local rotate_up = (pi / 180) * 270
local rotate_down = (pi / 180) * 90

----- MISC FUNCTIONS -----

function ScrollTable:SetParent(parent)
    if parent == nil then
        error('ScrollTable parent is nil');
    end

    local ptype = type(parent)

    if ptype == "table" then
        return parent
    elseif ptype == "string" then
        return _G[parent]
    end

    error('ScrollTable parent must be a string or table')
end

----- HIGHLIGHT FUNCTIONS -----

-- Determines if the row should be highlighted or not.
function ScrollTable:_HighlightRow(row, shouldHighlight)
    if shouldHighlight then
        row:LockHighlight()
    else
        row:UnlockHighlight()
    end
end

----- SELECT FUNCTIONS -----

-- Clears everyone you have selected currently.
function ScrollTable:ClearSelected()
    wipe(self.selected)
    self.lastSelect = nil
    _G['pdkp_filter_Select_All']:SetChecked(false)
end

-- Populate the last select, for other functions.
function ScrollTable:_UpdateLastSelect(objIndex, isSelected)
    local selectCount = #self.selected;
    if isSelected then
        self.lastSelect = objIndex;
    elseif selectCount >= 1 then
        self.lastSelect = self.selected[selectCount]
    else
        self.lastSelect = nil;
    end
end

function ScrollTable:_RowShiftClicked(objIndex, selectIndex)
    local previousSelect = self.lastSelect

    if previousSelect == objIndex then
        return
    end -- Do nothing if the same thing is clicked again.

    -- Shift clicks always add to the lastSelect.
    self:_UpdateSelectStatus(objIndex, selectIndex, false, false)
    if #self.selected <= 1 then
        return
    end -- Only one thing selected, do nothing.

    local _, prevSelectIndex = Utils:tfind(self.displayedRows, previousSelect, self.ROW_SELECT_ON)
    local _, currSelectIndex = Utils:tfind(self.displayedRows, self.lastSelect, self.ROW_SELECT_ON)

    local startIndex = prevSelectIndex < currSelectIndex and prevSelectIndex or currSelectIndex
    local endIndex = prevSelectIndex > currSelectIndex and prevSelectIndex or currSelectIndex

    -- Grab the list items between startIndex and endIndex.
    local betweenRows = { unpack(self.displayedRows, startIndex, endIndex) }
    for i = 1, #betweenRows do
        local rowObjIndex = betweenRows[i]['dataObj'][self.ROW_SELECT_ON]
        local rowSelected = Utils:tfind(self.selected, rowObjIndex)
        if not rowSelected then
            -- Add it to the list, if it is not already selected.
            tinsert(self.selected, rowObjIndex)
            self:_HighlightRow(betweenRows[i], true)
        end
    end
end

function ScrollTable:_UpdateSelectStatus(objIndex, selectIndex, isSelected, clear)
    clear = clear or false
    if clear then
        self:ClearSelected()
    end

    if isSelected then
        tremove(self.selected, selectIndex)
    else
        tinsert(self.selected, objIndex)
    end
    self:_UpdateLastSelect(objIndex, not isSelected)
end

function ScrollTable:_CheckSelect(row, clickType)
    local selectOn = row.selectOn
    local objIndex = row.dataObj[selectOn]

    if clickType == 'LeftButton' then
        local hasCtrl = IsControlKeyDown()
        local hasShift = IsShiftKeyDown()
        local isSelected, selectIndex = Utils:tfind(self.selected, objIndex)

        if hasShift and hasCtrl then
            -- Do nothing here.
            return
        elseif hasShift then
            -- Shift click
            self:_RowShiftClicked(objIndex, selectIndex)
        else
            -- Control or Regular Click.
            self:_UpdateSelectStatus(objIndex, selectIndex, isSelected, not hasCtrl)
        end

        if self.onSelectChanged then
            self:onSelectChanged()
        end

        return self:RefreshLayout()
    end

    local isSelected, _ = Utils:tfind(self.selected, objIndex)
    self:_HighlightRow(row, isSelected)
    if self.onSelectChanged then
        self:onSelectChanged()
    end
end

function ScrollTable:ClearAll(isNamesSelect)
    self:SelectAll(true, isNamesSelect)
end

function ScrollTable:SelectAll(remove, isNamesSelect)
    isNamesSelect = isNamesSelect or false

    for i = 1, #self.displayData do
        local row = self.rows[i];
        if not row.isFiltered then
            local selectOn = row.selectOn
            local objIndex = row.dataObj[selectOn]
            local isSelected, removeIndex = Utils:tfind(self.selected, objIndex)

            if isSelected and remove then
                tremove(self.selected, removeIndex)
            elseif not isSelected and not remove then
                tinsert(self.selected, objIndex)
            end
        end
    end

    if not isNamesSelect then
        self.onSelectChanged()
    end
    self:RefreshLayout()
end

function ScrollTable:SelectNames(names)
    self:ClearAll(true)
    for i = 1, #self.displayedRows do
        local row = self.rows[i]
        local selectOn = row.selectOn
        local objIndex = row.dataObj[selectOn]

        if tContains(names, objIndex) then
            local isSelected, _ = Utils:tfind(self.selected, objIndex)
            if not isSelected then
                tinsert(self.selected, objIndex)
            end
        end
    end
    _G['pdkp_filter_selected']:SetChecked(true);
    self:ApplyFilter('selected', true);
    self:RefreshLayout()
end

----- REFRESH FUNCTIONS -----

function ScrollTable:LagglessUpdate()
    self.refreshPending = false;

    self.data = self.retrieveDataFunc();
    wipe(self.displayData);
    self.displayData = {};

    local dataToIterate = { self.data, self.displayData }

    local refreshCallback = coroutine_create(function()
        for index, dataObj in pairs(dataToIterate) do
            local processCount = 0;
            for i=1, #dataObj do
                processCount = processCount + 1;
                if index == 1 then
                    self.displayData[i] = self:retrieveDisplayDataFunc(self.data[i]);
                elseif index == 2 then
                    self.rows[i]:UpdateRowValues();
                end

                if processCount >= maxProcessCount and processCount % maxProcessCount == 0 then
                    coroutine_yield()
                end
            end
        end
    end)

    self.RefreshDataFrame:SetScript("OnUpdate", function()
        local ongoing = coroutine_resume(refreshCallback);
        if not ongoing then
            self.RefreshDataFrame:SetScript("OnUpdate", nil);
            if self.sortCol then
                -- resort the column
                self.sortCol:Click()
                self.sortCol:Click()
            end
            self:ApplyFilter('Select_All', false)
        end
    end)
end

-- Refreshes the data that we are utilizing.
function ScrollTable:RefreshData()
    self:LagglessUpdate()
end

function ScrollTable:DataChanged()
    self:LagglessUpdate()
end

function ScrollTable:GetDisplayRows()
    wipe(self.displayedRows); -- Return to initial value.

    local selected_button = _G['pdkp_filter_selected'];

    if self.appliedFilters['selected'] and #self.selected == 0 then
        self.appliedFilters['selected'] = false
        selected_button:SetChecked(false)
    end

    for i = 1, #self.displayData do
        local row = self.rows[i];
        if not row:ApplyFilters() then
            tinsert(self.displayedRows, row);
        else
            row:Hide();
        end
    end
end

function ScrollTable:GetDisplayCount()
    return #self.displayedRows;
end

function ScrollTable:IsMemberShown(name, class)
    for _, row in pairs(self.displayedRows) do
        local data = row['dataObj'];
        local matchForwards = Utils:StringsMatch(data['name'], name);
        local matchBackwards = Utils:StringsMatch(name, data['name']);
        if Utils:StringsMatch(data['name'], name) and strlower(class) == strlower(data['class']) then
            return true, data['name'];
        elseif matchForwards and matchBackwards then
            return true, data['name'];
        end
    end
    return false, nil;
end

function ScrollTable:Reinitialize()
    self:RefreshData();
    self:DataChanged();
    self:RefreshLayout();
end

function ScrollTable:RefreshTableSize()
    -- The last step is to ensure the scroll range is updated appropriately.
    -- Calculate the total height of the scrollable region (using the model
    -- size), and the displayed height based on the number of shown buttons.

    local total_rows = self.displayedRows and #self.displayedRows or #self.displayData;

    local buttonHeight = self.ROW_HEIGHT;
    local totalHeight = (total_rows * buttonHeight) + self.ROW_HEIGHT;
    local shownHeight = self.MAX_ROWS * buttonHeight;

    HybridScrollFrame_Update(self.ListScrollFrame, totalHeight, shownHeight);
end

function ScrollTable:RefreshLayout()
    PDKP.Wago:IncrementCounter(self.name .. 'RefreshLayout');

    local offset = HybridScrollFrame_GetOffset(self.ListScrollFrame);

    self:GetDisplayRows();

    for i = 1, #self.displayedRows do
        local row = self.displayedRows[i];
        row:ClearAllPoints(); -- Remove it from view.
        if i >= offset + 1 and i <= offset + self.MAX_ROWS then
            row:Show();
            if i == offset + 1 then
                row:SetPoint("TOPLEFT", self.ListScrollFrame, 8, 0)
            else
                row:SetPoint("TOPLEFT", self.displayedRows[i - 1], "BOTTOMLEFT")
            end
            local isSelected, _ = Utils:tfind(self.selected, row.dataObj[row.selectOn])
            self:_HighlightRow(row, isSelected)
        else
            row:Hide();
        end
    end
    self:UpdateLabelTotals()
    self:RefreshTableSize();
end

function ScrollTable:UpdateLabelTotals()
    if self == nil or self.entryLabel == nil then
        return
    end

    local entry_label_text = #self.displayedRows .. " Players shown | " .. #self.selected .. " selected"

    self.entryLabel:SetText(entry_label_text)
end



----- FILTER FUNCTIONS -----

function ScrollTable:ApplyFilter(filterOn, checkedStatus)
    if filterOn == 'Class_All' then
        -- Reset all class filters if this gets checked.
        for _, class in pairs(MODULES.Constants.CLASSES) do
            local fClass = 'Class_' .. class;
            self.appliedFilters[fClass] = checkedStatus;
        end
    else
        self.appliedFilters[filterOn] = checkedStatus;
    end

    if filterOn == 'online' and checkedStatus then
        self.online = MODULES.GuildManager:GetOnlineNames() or {}
    elseif filterOn == 'raid' and checkedStatus then
        self.raid_members = MODULES.GroupManager:GetRaidMemberObjects() or {}
    end

    self.displayedRows = {};
    for i = 1, #self.displayData do
        local row = self.rows[i];
        if not row:ApplyFilters() then
            tinsert(self.displayedRows, row);
        end
    end

    if filterOn == 'Select_All' then
        if self.appliedFilters['Select_All'] then
            self:SelectAll()
        else
            self:ClearAll()
        end
    end

    self:RefreshTableSize();
    self:RefreshLayout();
end

function ScrollTable:SearchChanged(searchText)
    self.searchText = searchText
    local checkedStatus = searchText and searchText ~= '' and searchText ~= nil
    self:ApplyFilter('name', checkedStatus)
end

function ScrollTable:GetSelected()
    local selected = {}
    for i = 1, #self.selected do
        tinsert(selected, self.selected[i])
    end
    return selected;
end

----- INITIALIZATION FUNCTIONS -----

function ScrollTable:newHybrid(table_settings, col_settings, row_settings)
    local self = {};
    setmetatable(self, ScrollTable); -- Set the metatable so we use ScrollTable's __index

    -- Set all of the important settings or default if they were not provided.
    self.parent = self:SetParent(table_settings['parent'])
    self.name = self.parent and self.parent:GetName() .. '_' .. table_settings['name'] or table_settings['name']
    self.height = table_settings['height'] or 300
    self.width = table_settings['width'] or 300
    self.movable = table_settings['movable'] or false
    self.enableMouse = table_settings['enableMouse'] or false
    self.anchor = table_settings['anchor'] or {
        ['point'] = 'CENTER',
        ['rel_point_x'] = 0,
        ['rel_point_y'] = 0
    }

    maxProcessCount = MODULES.Options:displayProcessingChunkSize() or 16;

    self.RefreshDataFrame = CreateFrame("Frame");
    self.DataChangedFrame = CreateFrame("Frame");

    self.refreshPending = false;

    self.ROW_HEIGHT = row_settings['height'] or 20
    self.ROW_WIDTH = row_settings['width'] or 300
    self.ROW_MULTI_SELECT = row_settings['multiSelect'] or false
    self.ROW_SELECT_ON = row_settings['indexOn'] or nil
    self.retrieveDataFunc = table_settings['retrieveDataFunc']
    self.retrieveDisplayDataFunc = table_settings['retrieveDisplayDataFunc']
    self.onSelectChanged = table_settings['onSelectChanged'] or function()
    end

    self.MAX_ROWS = (self.height / self.ROW_HEIGHT);
    self.showHighlight = row_settings['showHighlight'] or false

    self.COL_HEIGHT = col_settings['height'] or 14
    self.COL_WIDTH = col_settings['width'] or 100
    self.HEADERS = col_settings['headers']

    self.displayData, self.displayedRows, self.appliedFilters, self.selected, self.online = {}, {}, {}, {}, {}
    self.raid_members, self.cols, self.data = {}, {}, {};
    self.searchText, self.entryLabel, self.lastSelect, self.sortBy, self.sortDir = nil, nil, nil, nil, nil;
    self.sortCol = nil;

    self.firstSort = col_settings['firstSort'] or nil;
    self.firstSortDir = col_settings['firstSortDir'] or 'ASC';

    self.firstSortRan, self.isDragging = false, false;

    self:RefreshData()

    -------------------------
    -- Setup the Frames
    -------------------------

    -- Create our base frame.
    self.frame = CreateFrame("Frame", self.name, self.parent, MODULES.Media.BackdropTemplate)
    self.frame:EnableMouse(self.enableMouse)
    self.frame:SetMovable(self.movable)
    self.frame:SetSize(self.width, self.height)
    self.frame:SetHeight(self.height + (self.COL_HEIGHT * 2));
    self.frame:SetWidth(self.width)
    self.frame:SetPoint(self.anchor['point'], self.parent, self.anchor['rel_point_x'], self.anchor['rel_point_y'])

    -- Give the frame a visible background and border:
    self.frame:SetBackdrop({
        tile = true, tileSize = 0,
        edgeFile = MODULES.Media.SCROLL_BORDER, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    self.frame.parent = self

    -----------------
    -- Create the ScrollFrame

    local listScrollFrame = CreateFrame("ScrollFrame", "ListScrollFrame", self.frame, 'HybridScrollFrameTemplate')

    listScrollFrame:SetPoint("TOPLEFT", 0, -(self.COL_HEIGHT * 2))
    listScrollFrame:SetPoint("BOTTOMRIGHT", -30, 8)

    ----------------
    -- Create the slider
    local scrollBar = CreateFrame("Slider", 'scrollBar', listScrollFrame, 'HybridScrollBarTemplate')
    scrollBar:SetPoint("TOPLEFT", listScrollFrame, "TOPRIGHT", 1, -16)
    scrollBar:SetPoint("BOTTOMLEFT", listScrollFrame, "BOTTOMRIGHT", 1, 12)

    self.ListScrollFrame = listScrollFrame
    self.scrollChild = listScrollFrame.scrollChild;

    ----------------
    -- Set the on_Load functions
    self:_OnLoad()

    self.ListScrollFrame.buttonHeight = self.ROW_HEIGHT;

    self.scrollChild:SetWidth(self.ListScrollFrame:GetWidth())

    listScrollFrame:SetVerticalScroll(0);
    listScrollFrame:UpdateScrollChildRect();

    self.ListScrollFrame.buttons = self.rows;

    scrollBar:SetMinMaxValues(1, (#self.data * self.ROW_HEIGHT))

    scrollBar.buttonHeight = self.ROW_HEIGHT;
    scrollBar:SetValueStep(self.ROW_HEIGHT);
    scrollBar:SetStepsPerPage(self.MAX_ROWS - 2);
    scrollBar:SetValue(1);

    self.scrollBar = scrollBar;

    self.scrollChild:SetPoint("TOPLEFT", self.ListScrollFrame, "TOPLEFT", -0, 0);

    self:RefreshLayout();

    self.frame:SetScript("OnShow", function()
        if not self.firstSortRan then
            if self.firstSortDir == 'DESC' then
                self.cols[self.firstSort]:Click()
                self.cols[self.firstSort]:Click()
            else
                self.cols[self.firstSort]:Click()
            end
            self.firstSortRan = true
        end
        if self.refreshPending then
            self:LagglessUpdate();
        end
    end)

    return self
end

function ScrollTable:_OnLoad()
    -- Create the item model that we'll be displaying.
    local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Button", nil, self.scrollChild)
        row:SetSize(self.ROW_WIDTH, self.ROW_HEIGHT)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp");
        row:RegisterForDrag("LeftButton")

        row.cols = {};
        row.index = i
        row.realIndex = nil;
        row.selectOn = self.ROW_SELECT_ON
        row.dataObj = self.displayData[i];
        row:SetID(i)
        row.isFiltered = false;

        if i == 1 then
            -- Anchor the first row relative to the frame.
            row:SetPoint("TOPLEFT", self.ListScrollFrame, 16, 0)
        else
            row:SetPoint("TOPLEFT", self.rows[i - 1], "BOTTOMLEFT")
        end

        if self.showHighlight then
            row:SetHighlightTexture(MODULES.Media.HIGHLIGHT_TEXTURE)
            row:SetPushedTexture(MODULES.Media.HIGHLIGHT_TEXTURE)
            row:SetScript("OnClick", function(r, clickType)
                self:_CheckSelect(r, clickType)
            end)
        end

        local sep = row:CreateTexture(nil, 'BACKGROUND')
        sep:SetTexture(MODULES.Media.ROW_SEP_TEXTURE)
        sep:SetHeight(3)
        sep:SetWidth(self.ROW_WIDTH)

        if i == 1 then
            sep:SetPoint("TOPLEFT", row, 0, 0, row, "TOPRIGHT")
        elseif i == 2 then
            sep:SetPoint("TOPLEFT", row, 0, 0, self.rows[i - 1], "TOPLEFT")
        else
            sep:SetPoint("TOPLEFT", row, 0, 0, self.rows[i - 1], "TOPLEFT")
        end

        row.super = self;

        function row:UpdateRowValues()
            for key, header in pairs(row.super['HEADERS']) do
                local label = header['label']
                local valFunc = header['getValueFunc']
                if valFunc ~= nil then
                    local val = (valFunc ~= nil and row.dataObj ~= nil) and valFunc(row.dataObj) or row.dataObj[label]
                    row.cols[key]:SetText(val)
                end
            end
        end

        function row:ApplyFilters()
            local dataObj = row.dataObj;
            row.isFiltered = false;
            local super = row.super;
            for filter, checkedStatus in pairs(super.appliedFilters or {}) do
                -- TODO: Refactor this mess...

                if row.isFiltered then
                    break
                end -- No need to waste time looping through the rest.

                -- It's one of the classes, not all.
                if substr(filter, 'Class_') and not substr(filter, '_All') and not checkedStatus then
                    local _, class = strsplit('_', filter);
                    if dataObj['class'] == class then
                        row.isFiltered = true
                        break ; -- We don't need to continue running checks, if it's filtered.
                    end
                elseif filter == 'Class_All' and not checkedStatus then
                    row.isFiltered = true;
                elseif checkedStatus then
                    if filter == 'online' then
                        if #super.online > 0 then
                            row.isFiltered = not tContains(super.online, dataObj['name'])
                        end
                    elseif filter == 'selected' then
                        row.isFiltered = not tContains(super.selected, dataObj['name'])
                    elseif filter == 'Select_All' then

                    elseif filter == 'raid' then
                        row.isFiltered = not tContains(super.raid_members, dataObj['name'])
                    elseif filter == 'name' then
                        row.isFiltered = not Utils:StringsMatch(dataObj['name'], super.searchText)
                    end
                end
            end

            return row.isFiltered;
        end

        for key, header in pairs(self.HEADERS) do
            local label = header['label']
            local col_name = '$parent' .. label
            local col = row:CreateFontString(col_name, 'OVERLAY', 'GameFontHighlightLeft')
            local getVal = header['getValueFunc']
            local val = (getVal ~= nil and row.dataObj ~= nil) and getVal(row.dataObj) or row.dataObj[label]

            col:SetJustifyH(header['point'])

            if label == 'class' then
                local _, colored_class = Utils:FormatTextByClass(val, val)
                val = colored_class
            end

            col:SetSize(self.COL_WIDTH, self.COL_HEIGHT)
            local col_point = header['point'] or 'LEFT'
            col:SetJustifyH(col_point)

            -- For excessively large numbers. Decrease the letter spacing.
            if type(val) == 'number' and val > 9999 then
                col:SetSpacing(0.5)
            end

            if key == 1 then
                col:SetPoint(col_point, row)
            else
                col:SetPoint("TOPLEFT", row.cols[key - 1], "TOPRIGHT", 0, 0)

                if key == #self.HEADERS and col_point == 'RIGHT' then
                    col:SetPoint("TOPLEFT", row.cols[key - 1], "TOPRIGHT", -10, 0)
                end
            end

            col:SetText(val)

            row.cols[key] = col;
        end

        rawset(t, i, row)
        return row
    end })
    local cols = setmetatable({}, { __index = function(t, i)
        local header = self.HEADERS[i] or {};
        local label = header['label'] or 'Test'
        local sortable = header['sortable'] or false
        local point = header['point'] or 'LEFT'
        local showSortDirection = header['showSortDirection'] or false
        local compare = header['compareFunc'];
        local font = header['font'] or "AchievementPointsFont"

        local col = CreateFrame("Button", "$parent_Col_" .. label, self.ListScrollFrame)

        local width = header['width'] or self.COL_WIDTH;

        col:SetHeight(self.COL_HEIGHT)
        col:SetWidth(width)

        if i == 1 then
            col:SetPoint("TOPLEFT", self.ListScrollFrame, -10, 20)
        else
            col:SetPoint("TOPLEFT", self.cols[i - 1], "TOPRIGHT", 20, 0)
        end

        local fs = col:CreateFontString(col, "OVERLAY", font)
        fs:SetText(strupper(label))
        fs:SetPoint("CENTER")

        local fsLength = fs:GetWidth()

        col.arrow = nil;
        col.dir = nil;
        col.label = label
        col.compare = compare
        col.fontString = fs

        function col:ToggleArrow(show)
            if col.arrow and show then
                col.arrow:Show()
            elseif col.arrow and not show then
                col.arrow:Hide()
            end
        end

        if showSortDirection then
            local arrow = col:CreateTexture(nil, 'BACKGROUND')
            arrow:SetTexture(MODULES.Media.ARROW_TEXTURE)
            arrow:SetPoint('RIGHT', col, 0, -3)
            col.arrow = arrow;

            col:ToggleArrow(false)

            arrow:SetRotation(rotate_down)
        end

        if sortable then
            col:SetScript("OnClick", function()
                if col:GetParent():IsVisible() then
                    for key, column in pairs(self.cols) do
                        if key ~= i then
                            column.dir = nil;
                            column:ToggleArrow(false)
                        else
                            column:ToggleArrow(true)
                            self.sortBy = column.label
                            self.sortCol = column
                        end
                    end

                    col.dir = (col.dir == nil or col.dir == 'ASC') and 'DESC' or 'ASC' -- Tenary

                    local deg = col.dir == 'DESC' and rotate_down or rotate_up
                    point = col.dir == 'DESC' and -1 or 2

                    -- Gives us uniform arrow spacing, based on label length.
                    -- Base is based off of length of "Name" and "Class" when they are uppercase.
                    local baseLength = 45
                    local arrow_x = floor((fsLength - baseLength) / 2 - 1)

                    if col.arrow ~= nil then
                        col.arrow:SetRotation(deg)
                        col.arrow:SetPoint('TOPRIGHT', col, 'TOPRIGHT', arrow_x, point)
                    end

                    self.sortDir = col.dir
                    tsort(self.rows, col.compare)
                    self:RefreshLayout();
                end
            end)
        end

        col:Show()

        rawset(t, i, col)
        return col
    end })

    self.rows = rows
    self.cols = cols

    for i = 1, #self.HEADERS do
        self.cols[i]:Show()
    end

    self.ListScrollFrame.buttons = self.rows;

    -- Bind the update field on the scrollframe to a function that'll update
    -- the displayed contents. This is called when the frame is scrolled.
    self.ListScrollFrame.update = function()
        self:RefreshLayout();
    end

    -- OPTIONAL: Keep the scrollbar visible even if there's nothing to scroll.
    HybridScrollFrame_SetDoNotHideScrollBar(self.ListScrollFrame, true);
end

pdkp_ScrollTableMixin = PDKP.ScrollTable;
