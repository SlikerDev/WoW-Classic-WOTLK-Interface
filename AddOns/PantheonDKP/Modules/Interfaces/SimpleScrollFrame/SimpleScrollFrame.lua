local _, PDKP = ...

PDKP.SimpleScrollFrame = {}

local SimpleScrollFrame = PDKP.SimpleScrollFrame;

SimpleScrollFrame.__index = SimpleScrollFrame; -- Set the __index parameter to reference

-- Lua APIs
local _, _, _ = pairs, assert, type
local min, max, floor = math.min, math.max, math.floor
local tinsert = table.insert

-- WoW APIs
local CreateFrame, _ = CreateFrame, UIParent

function SimpleScrollFrame:FixScrollOnUpdate()
    if self.updateLock then
        return
    end
    self.updateLock = true
    local status = self.status or self.localstatus
    local height, viewheight = self.scrollFrame:GetHeight(), self.content:GetHeight()
    local offset = status.offset or 0
    -- Give us a margin of error of 2 pixels to stop some conditions that i would blame on floating point inaccuracys
    -- No-one is going to miss 2 pixels at the bottom of the frame, anyhow!

    if viewheight < height + 2 then
        if self.scrollBarShown then
            self.scrollBarShown = nil
            self.scrollBar:Hide()
            self.scrollBar:SetValue(0)
            self.scrollFrame:SetPoint("BOTTOMRIGHT")
            if self.content.original_width then
                self.content.width = self.content.original_width
            end
        end
    else
        if not self.scrollBarShown then
            self.scrollBarShown = true
            self.scrollBar:Show()
            self.scrollFrame:SetPoint("BOTTOMRIGHT", -20, 0)
            if self.content.original_width then
                self.content.width = self.content.original_width - 20
            end
        end

        local value = (offset / (viewheight - height) * 1000)
        if value > 1000 then
            value = 1000
        end
        self.scrollBar:SetValue(value)
        self:SetScroll(value)
        if value < 1000 then
            self.content:ClearAllPoints()
            self.content:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT", 0, offset)
            self.content:SetPoint("TOPRIGHT", self.scrollFrame, "TOPRIGHT", 0, offset)
            status.offset = offset
        end
    end
    self.updateLock = nil
end

function SimpleScrollFrame:MoveScroll(value)
    local status = self.status or self.localstatus

    local height, viewheight = self.scrollFrame:GetHeight(), self.content:GetHeight()

    if self.scrollBar:IsVisible() then
        local diff = height - viewheight;
        local delta = 1
        if value < 0 then
            delta = -1
        end
        self.scrollBar:SetValue(min(max(status.scrollvalue + delta * (1000 / (diff / 45)), 0), 1000))
    end
end

function SimpleScrollFrame:SetScroll(value)
    local status = self.status or self.localstatus
    local viewheight = self.scrollFrame:GetHeight()
    local height = self.content:GetHeight()
    local offset

    if viewheight > height then
        offset = 0
    else
        offset = floor((height - viewheight) / 1000.0 * value)
    end
    self.content:ClearAllPoints()

    self.content:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT", 0, offset)
    self.content:SetPoint("TOPRIGHT", self.scrollFrame, "TOPRIGHT", 0, offset)
    status.offset = offset
    status.scrollvalue = value
    self.waiting_on_update = false;
    self.elapsed_update = 0
end

function PDKP_SimpleScroll_SetScroll(_, _)

end

function SimpleScrollFrame:new(parent)
    local self = {}
    setmetatable(self, SimpleScrollFrame); -- Set the metatable so we use SimpleScrollFrame's __index

    local sf = CreateFrame("ScrollFrame", '$parent_scrollFrame', parent)
    sf:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    sf:SetHeight(parent:GetHeight())
    sf:SetWidth(parent:GetWidth())

    sf:EnableMouseWheel(1)

    local sb = CreateFrame("Slider", '$parent_scrollBar', sf, "UIPanelScrollBarTemplate", BackdropTemplateMixin and "BackdropTemplate")
    sb:SetPoint("TOPLEFT", sf, "TOPRIGHT", 2, -20)
    sb:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", -2, 18)
    sb:SetMinMaxValues(0, 1000)
    sb:SetValueStep(1)
    sb:SetValue(0)
    sb:SetWidth(16)
    sb:Hide()

    self.waiting_on_update = false;
    self.elapsed_update = 0

    --- The next 3 functions handle changing the positioning of the scroll child, and the slider bar respectively.

    -- Handles mouse wheel events on the frame. Moving the content up or down depending on the direction.
    sf:SetScript("OnMouseWheel", function(_, value)
        self.waiting_on_update = false;
        self.elapsed_update = 0;
        self:MoveScroll(value)
    end)

    -- Handles dragging the scroll bar to change what content is being shown currently.
    -- Only allows content updates every 0.05 seconds to prevent tearing while manually dragging the scroll bar.
    sb:SetScript("OnValueChanged", function(_, value)
        if not self.waiting_on_update then
            self:SetScroll(value)
            self.waiting_on_update = true
        elseif self.elapsed_update >= 0.05 then
            self:SetScroll(value)
            self.waiting_on_update = false
            self.elapsed_update = 0;
        end
    end)

    -- Creates an internal "timer" of sorts, that only updates the frame every 0.05 seconds.
    -- This is necessary, because otherwise the content gets updated every time the slider
    sb:SetScript("OnUpdate", function(_, elapsed)
        if self.waiting_on_update then
            self.elapsed_update = self.elapsed_update + elapsed
        end
    end)

    sf.scrollBar = sb

    local sbg = sb:CreateTexture(nil, "BACKGROUND")
    sbg:SetAllPoints(sb)
    sbg:SetColorTexture(0, 0, 0, 0.4)

    sf.scrollBar.bg = sbg

    local sc = CreateFrame("Frame", '$parent_scrollContent', sf)
    sc:SetPoint("TOPLEFT", sf, "TOPLEFT", 0, 0)
    sc:SetPoint("TOPRIGHT", sf, "TOPRIGHT", 0, 0)
    sc:SetWidth(parent:GetWidth() - 20)

    sc:Show()
    sc.children = {}

    self.simpleWipeFrame = CreateFrame("Frame");
    self.simpleAddFrame = CreateFrame("Frame");
    self.simpleResizeFrame = CreateFrame("Frame");

    self.childWipeInProgress = false;

    sc.AddChild = function(content, frame)
        local childCount = #content.children;
        if childCount == 0 then
            frame:SetPoint("TOPLEFT", 10, 0)
            frame:SetPoint("TOPRIGHT", -10, 0)
        else
            local previous_frame = content.children[childCount]
            frame:SetPoint("TOPLEFT", previous_frame, "BOTTOMLEFT", 0, 0)
            frame:SetPoint("TOPRIGHT", previous_frame, "BOTTOMRIGHT", 0, 0)
        end
        sc:SetHeight(sc:GetHeight() + frame:GetHeight())
        table.insert(content.children, frame)
    end

    sc.WipeChildren = function(content)
        if (content == nil) then return end

        content:Hide();

        self.childWipeInProgress = true;
        local children_height = 0
        local childCount = #content.children;
        for i = 1, childCount do
            local child = content.children[i]
            child:Hide()
            children_height = children_height + child:GetHeight()
            child = nil;
        end
        self.simpleWipeFrame:SetScript("OnUpdate", nil);
        sc:SetHeight(sc:GetHeight() - children_height)
        content.children = {} -- wipe the children.
        self.childWipeInProgress = false;
        content:Show();
    end

    sc.AddBulkChildren = function(content, frames)
        content:Hide();

        content:WipeChildren(content) -- Wipe the children first, before doing a mass add.
        local children_height = 0

        for i = 1, #frames do
            local child = frames[i]
            local childCount = #content.children;
            if childCount == 0 then
                child:SetPoint("TOPLEFT", 0, 0)
                child:SetPoint("TOPRIGHT", 0, 0)
            else
                local previous_frame = content.children[i - 1]
                child:SetPoint("TOPLEFT", previous_frame, "BOTTOMLEFT", 0, 0)
                child:SetPoint("TOPRIGHT", previous_frame, "BOTTOMRIGHT", 0, 0)
            end
            child:Show()
            children_height = children_height + child:GetHeight()
            tinsert(content.children, child)
        end

        sc:SetHeight(sc:GetHeight() + children_height)
        content:Show();
    end

    sc:SetScript("OnSizeChanged", function(_, value)
        sc:SetScript("OnUpdate", function()
            sc:SetScript("OnUpdate", nil)
            self:FixScrollOnUpdate(value)
        end)
    end)

    sc.ResizeByChild = function(_)
        sc:SetHeight(0)
        local new_height = 0
        for i = 1, #sc.children do
            local child = sc.children[i]
            new_height = child:GetHeight() + new_height;
        end
        sc:SetHeight(new_height)
    end

    sc.Resize = function(_, offsetX1, offsetX2)
        sc:SetHeight(0)

        offsetX1 = offsetX1 or 2
        offsetX2 = offsetX2 or -15

        local temp_children = {}

        for i = 1, #sc.children do
            local child_frame = sc.children[i]
            if child_frame:IsVisible() then
                table.insert(temp_children, child_frame)
            end
        end

        for i = 1, #temp_children do
            local child_frame = temp_children[i]
            child_frame:ClearAllPoints()
            if i == 1 then
                child_frame:SetPoint("TOPLEFT", offsetX1, 0)
                child_frame:SetPoint("TOPRIGHT", offsetX2, 0)
            else
                child_frame:SetPoint("TOPLEFT", temp_children[i - 1], "BOTTOMLEFT", 0, 0)
                child_frame:SetPoint("TOPRIGHT", temp_children[i - 1], "BOTTOMRIGHT", 0, 0)
            end
            sc:SetHeight(sc:GetHeight() + child_frame:GetHeight())
        end
        sc.children = temp_children;
    end

    sf.content = sc
    sf.scrollBar = sb

    sf:SetScrollChild(sc)

    self.localstatus = { ['scrollvalue'] = 0 }

    self.scrollFrame = sf
    self.scrollBar = sb
    self.scrollBarBG = sbg
    self.content = sc

    self.scrollFrame.obj, self.scrollBar.obj = self, self

    return self
end

pdkp_SimpleScrollFrameMixin = PDKP.SimpleScrollFrame;
