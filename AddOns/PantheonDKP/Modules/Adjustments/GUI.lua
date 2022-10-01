local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
local Utils = PDKP.Utils;

local tinsert, _, pairs, next = table.insert, tContains, pairs, next;

local Adjust = {}
local tabName = 'view_adjust_button';

Adjust.dropdowns = {}
Adjust.editBoxes = {}

function Adjust:Initialize()
    if not PDKP.canEdit then
        return
    end

    local tabNames = GUI.TabController.tab_names

    -- To prevent tab controller not being ready yet.
    if tabNames == nil and self.entry_preview == nil and self.entry_details == nil then
        return C_Timer.After(0.1, function()
            Adjust:Initialize()
        end)
    end

    local tf = tabNames[tabName].frame;

    --- Entry Preview Section
    self.entry_preview = self:_CreateEntryPreview(tf)

    --- Entry Details section
    local entry_details = GUtils:createBackdropFrame('entry_details', tf, 'Entry Details');
    entry_details:SetPoint("TOPLEFT", self.entry_preview, "BOTTOMLEFT", 0, 0)
    entry_details:SetPoint("BOTTOMRIGHT", tf, "BOTTOMRIGHT", 0, 0);

    local mainDD, raidDD, amount_box, other_box, item_box;

    --- Reason Section
    local reason_opts = {
        ['name'] = 'reason',
        ['parent'] = entry_details.content,
        ['title'] = 'Reason',
        ['items'] = { 'Boss Kill', 'Item Win', 'Other', 'Decay'},
        ['defaultVal'] = 'Boss Kill',
        ['changeFunc'] = self.DropdownChanged
    }

    if not MODULES.Database:HasPhaseStarted() then
        table.insert(reason_opts['items'], 'Phase');
    end

    mainDD = GUtils:createDropdown(reason_opts)
    mainDD:SetPoint("TOPLEFT", entry_details, "TOPLEFT", -3, -50)
    tinsert(self.dropdowns, mainDD)
    tinsert(entry_details.children, mainDD)

    local raid_items = {}
    local sortedPairs = {
        "Gruul's Lair", "Magtheridon's Lair", "Serpentshrine Cavern", "Tempest Keep", "Battle for Mount Hyjal",
        "Black Temple", "Sunwell Plateau"
    };

    for raid_name, raid_table in pairs(MODULES.Constants.RAID_BOSSES) do
        raid_items[raid_name] = raid_table['boss_names']
    end

    --- Raid Section
    local raid_opts = {
        ['name'] = 'raid_boss',
        ['parent'] = mainDD,
        ['title'] = 'Raid Boss',
        ['hide'] = true,
        ['dropdownTable'] = mainDD,
        ['showOnValue'] = 'Boss Kill',
        ['changeFunc'] = self.DropdownChanged,
        ['items'] = raid_items,
        ['sortedPairs'] = sortedPairs,
    }

    raidDD = GUtils:createNestedDropdown(raid_opts)
    raidDD:SetPoint("LEFT", mainDD, "RIGHT", -20, 0)
    tinsert(self.dropdowns, raidDD)
    tinsert(entry_details.children, raidDD)

    --- Amount section
    local amount_opts = {
        ['name'] = 'amount',
        ['parent'] = mainDD,
        ['title'] = 'Amount',
        ['multi'] = false,
        ['max_chars'] = 7,
        ['numeric'] = false,
        ['dropdownTable'] = mainDD,
        ['showOnValue'] = 'Always',
        ['textValidFunc'] = self.DropdownChanged
    }
    amount_box = GUtils:createEditBox(amount_opts)
    amount_box.frame:SetWidth(75)
    amount_box:SetWidth(60)
    amount_box:SetPoint("TOPLEFT", mainDD, "BOTTOMLEFT", 25, -20)
    tinsert(self.editBoxes, amount_box)
    tinsert(entry_details.children, amount_box)

    --- Item Name Box Section
    local item_opts = {
        ['name'] = 'item',
        ['parent'] = mainDD,
        ['title'] = 'Item Name',
        ['multi'] = false,
        ['numeric'] = false,
        ['dropdownTable'] = mainDD,
        ['showOnValue'] = 'Item Win',
        ['textValidFunc'] = self.DropdownChanged
    }
    item_box = GUtils:createEditBox(item_opts)
    item_box:SetPoint("LEFT", mainDD, "RIGHT", 20, 0)
    item_box:Hide()
    tinsert(self.editBoxes, item_box)
    tinsert(entry_details.children, item_box)

    --- Other Edit Box Section
    local other_opts = {
        ['name'] = 'other',
        ['parent'] = mainDD,
        ['title'] = 'Other',
        ['multi'] = true,
        ['numeric'] = false,
        ['dropdownTable'] = mainDD,
        ['showOnValue'] = 'Other',
        ['textValidFunc'] = self.DropdownChanged
    }
    other_box = GUtils:createEditBox(other_opts)
    other_box:SetPoint("LEFT", mainDD, "RIGHT", 20, 0)
    other_box:Hide()
    tinsert(self.editBoxes, other_box)
    tinsert(entry_details.children, other_box)

    --- Submit Section
    local sb = CreateFrame("Button", "$parent_submit", tf, "UIPanelButtonTemplate")
    sb:SetSize(80, 22) -- width, height
    sb:SetText("Submit")
    sb:SetPoint("BOTTOMRIGHT", tf, "BOTTOMRIGHT", 4, -22)
    sb:SetScript("OnClick", function()
        if not Utils:tEmpty(MODULES.Adjustment.entry) then
            MODULES.Adjustment.entry:Save(true)
        end
        raidDD.resetVals()
        wipe(MODULES.Adjustment.entry)
    end)
    sb:Disable()

    entry_details.submit_btn = sb

    self.entry_details = entry_details;
end

function Adjust:_CreateEntryPreview(tf)
    if not PDKP.canEdit then
        return
    end

    local f = GUtils:createBackdropFrame('entry_preview', tf, 'Entry Preview');
    f:SetPoint("TOPLEFT", tf, "TOPLEFT", 10, -20)
    f:SetPoint("TOPRIGHT", tf, "TOPRIGHT", -10, -20)
    f:SetSize(340, 250);

    local PREVIEW_HEADERS = { 'Officer', 'Reason', 'Amount', 'Members' }
    local padding = 20

    for i = 1, #PREVIEW_HEADERS do
        local head = PREVIEW_HEADERS[i]
        local label = f.content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')

        label.setVal = function(_, value)
            if value == nil or value == '' then
                return label:resetVal()
            end

            local combinedText = head .. ': ' .. value;
            local maxLines = label:GetMaxLines();

            -- Helps prevent lag when selecting everyone in the guild. Due to only around 50 people being displayed anyway.
            if (head == 'Members') then

                local combinedWidth = string.len(combinedText)
                local labelWidth = label:GetWidth();

                if (maxLines > 2) then
                    labelWidth = labelWidth * maxLines -2;
                end

                if (combinedWidth > labelWidth) then
                    local oneThird = math.ceil(string.len(combinedText)/3);
                    combinedText = string.sub(combinedText, 0, oneThird);
                end

                return label:SetText(combinedText)
            end
            label:SetText(combinedText)
        end
        label.resetVal = function()
            label:SetText(head .. ': ' .. 'None')
        end
        label.setDefault = function()
            label:SetText(head .. ': ')
        end

        if i == 1 then
            label:SetPoint("TOPLEFT", f.content, "TOPLEFT", 5, -5)
        else
            label:SetPoint("TOPLEFT", f.children[i - 1], "BOTTOMLEFT", 0, -2)
        end

        label:setDefault()

        if head == 'Members' then
            label:SetMaxLines(12)
        end

        label:SetWidth(f.content:GetWidth() - padding)

        label:resetVal()

        table.insert(f.children, label)
    end

    f.invalidText = Utils:FormatTextColor("Entry is invalid", MODULES.Constants.WARNING);
    f.validText = Utils:FormatTextColor('Entry is ready for submission', MODULES.Constants.SUCCESS)
    f.desc:SetText(f.invalidText);

    return f;
end

function Adjust:UpdatePreview()
    if not PDKP.canEdit then
        return
    end

    local entry = MODULES.Adjustment.entry
    local isValid = entry:IsValid()

    local officerPreview = self.entry_preview.children[1]
    local reasonPreview = self.entry_preview.children[2]
    local amountPreview = self.entry_preview.children[3]
    local memberPreview = self.entry_preview.children[4]

    officerPreview:setVal(entry.formattedOfficer)
    amountPreview:setVal(entry.change_text)
    memberPreview:setVal(entry.formattedNames)
    reasonPreview:setVal(entry.historyText)

    if isValid then
        self.entry_preview.desc:SetText(self.entry_preview.validText)
    else
        self.entry_preview.desc:SetText(self.entry_preview.invalidText)
    end

    self.entry_details.submit_btn:SetEnabled(isValid)
end

-- Just helps break up everything, gathering all of the data into one place before shipping it off.
function Adjust:DropdownChanged()
    if not PDKP.canEdit then
        return
    end

    if Adjust.entry_details == nil then
        return
    end

    --- There will always be either 2 or 3 valid adjustments.
    local valid_adjustments = {}
    local children = Adjust.entry_details.children

    local mainDD = children[1]
    local raidDD = children[2]
    local amount_box = children[3]

    local amt = tonumber(amount_box:getValue())

    -- TODO: Sunwell boss DKP, raidDD hass boss_names in it.

    if (mainDD.selectedValue == 'Boss Kill') then
        amount_box:SetEnabled(false)
        local isSunwellBoss = MODULES.Constants.BOSS_TO_RAID[raidDD.selectedValue] == "Sunwell Plateau"
        if isSunwellBoss and amt ~= 20 then
            amount_box:SetText(20);
        elseif not isSunwellBoss and amt ~= 10 then
            amount_box:SetText(10)
        end
    else
        amount_box:SetEnabled(true)
    end

    if (mainDD.selectedValue == 'Decay' or mainDD.selectedValue == 'Phase') and amount_box:IsVisible() then
        amount_box:SetText(0)
        amount_box:Hide()
        return Adjust:DropdownChanged();
    else
        amount_box:Show();
    end

    if mainDD.selectedValue == 'Item Win' and amt == 0 then
        amount_box:SetText(1);
    end

    -- In case someone accidentally puts other characters in the edit box that makes it invalid.
    if amt == nil then
        local num = Utils:RemoveAllNonNumerics(amount_box:getValue())
        amount_box:SetText(num)
    end

    if mainDD.selectedValue == 'Item Win' and amt ~= nil and amt > 0 then
        amount_box:SetText(amt * -1)
    end

    local tbl_len = 0
    for _, dd in pairs(children) do
        if dd.dropdownTable ~= nil and dd.showOnValue ~= "Always" then
            local ddParent = dd.dropdownTable;
            if ddParent.selectedValue == dd.showOnValue and ddParent:IsVisible() then
                dd:Show()
            else
                dd:Hide()
            end
        end
        if dd.isValid() then
            valid_adjustments[dd.uniqueID] = dd.selectedValue
            tbl_len = tbl_len + 1
        end
    end

    if (mainDD.selectedValue == 'Decay' or mainDD.selectedValue == 'Phase') and amount_box:IsVisible() then
        amount_box:Hide();
    end

    if next(valid_adjustments) ~= nil and tbl_len >= 2 then
        MODULES.Adjustment:Update(valid_adjustments)
    end
end

function Adjust:InsertItemLink(itemLink)
    for i = 1, #self.editBoxes do
        local eb = self.editBoxes[i]
        if eb.uniqueID == 'item' then
            eb:SetText("");
            eb:SetText(itemLink);
            return
        end
    end
end

GUI.Adjustment = Adjust
