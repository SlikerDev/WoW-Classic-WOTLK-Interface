local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils
local Utils = PDKP.Utils

local unpack, CreateFrame, UIParent, UISpecialFrames = unpack, CreateFrame, UIParent, UISpecialFrames
local tinsert = table.insert

local AuctionGUI = {}
AuctionGUI.itemLink = nil;

local AuctionManager;

function AuctionGUI:Initialize()
    AuctionManager = MODULES.AuctionManager;

    local title_str = Utils:FormatTextColor('PDKP Active Bids', MODULES.Constants.ADDON_HEX)

    local f = CreateFrame("Frame", "pdkp_auction_frame", UIParent, MODULES.Media.BackdropTemplate)
    f:SetFrameStrata('DIALOG')
    f:SetWidth(256)
    f:SetHeight(256)
    f:SetPoint("BOTTOMRIGHT", pdkp_frame, "BOTTOMLEFT", 0, 0)
    GUtils:setMovable(f)
    f:SetClampedToScreen(true);

    local stopBid, bid_box;

    f:SetScript("OnShow", function()
        f.dkp_title:SetText('Total DKP: ' .. MODULES.DKPManager:GetMyDKP())
        if not ( PDKP.canEdit or AuctionManager:CanChangeAuction() ) then
            stopBid:Hide();
            stopBid:SetEnabled(false);
            if PDKP.AuctionTimer.addTime ~= nil then
                PDKP.AuctionTimer.addTime:Hide();
            end
        elseif PDKP.canEdit and AuctionManager:IsAuctionInProgress() and AuctionManager:CanChangeAuction() then
            stopBid:SetEnabled(true)
            stopBid:Show()
            if PDKP.AuctionTimer.addTime ~= nil then
                PDKP.AuctionTimer.addTime:Show();
            end
        end
        f.maxBid:Show();
        f.reopenFrame:Hide()
    end)

    local sourceWidth, sourceHeight = 256, 512
    local startX, startY, width, height = 0, 0, 216, 277

    local texCoords = {
        startX / sourceWidth,
        (startX + width) / sourceWidth,
        startY / sourceHeight,
        (startY + height) / sourceHeight
    }

    local tex = f:CreateTexture(nil, 'BACKGROUND')
    tex:SetTexture(MODULES.Media.BID_FRAME)

    tex:SetTexCoord(unpack(texCoords))
    tex:SetAllPoints(f)

    local title = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    title:SetText(title_str)
    title:SetPoint("CENTER", f, "TOP", 25, -22)

    local dkp_title = f:CreateFontString(f, 'OVERLAY', 'GameFontNormal')
    dkp_title:SetPoint("TOP", title, "BOTTOM", -5, -25)

    local bid_counter_frame = CreateFrame('Frame', nil, f)
    bid_counter_frame:SetPoint('TOPLEFT', f, 'TOPLEFT', 5, 0)
    bid_counter_frame:SetSize(78, 64)

    local bid_counter = bid_counter_frame:CreateFontString(bid_counter_frame, 'OVERLAY', 'BossEmoteNormalHuge')
    bid_counter:SetText("0")
    bid_counter:SetPoint("CENTER", bid_counter_frame, "CENTER")
    bid_counter:SetPoint("TOP", bid_counter_frame, "CENTER", 0, 10)

    local close_btn = GUtils:createCloseButton(f, true)
    close_btn:SetSize(24, 22)
    close_btn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -10)

    local sb = CreateFrame("Button", "$parent_submit", f, "UIPanelButtonTemplate")
    sb:SetSize(80, 22) -- width, height
    sb:SetText("Submit Bid")
    sb:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 10)
    sb:SetScript("OnClick", function()
        local bid_amt = f.bid_box.getValue()
        f.current_bid:SetText(bid_amt)
        MODULES.CommsManager:SendCommsMessage('BidSubmit', bid_amt)
    end)
    sb:SetEnabled(false)

    local maxBid = CreateFrame("Button", "$parent_maxBid", f, "UIPanelButtonTemplate")
    maxBid:SetSize(80, 22) -- width, height
    maxBid:SetText("Max Bid")
    maxBid:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 33)
    maxBid:SetEnabled(true);
    maxBid:SetScript("OnClick", function()
        local leadership = MODULES.GroupManager.leadership;
        local sendTo = leadership.dkpOfficer;
        if sendTo == nil then
            sendTo = leadership.masterLoot;
        end
        if sendTo == nil then
            PDKP.CORE:Print("Could not find the DKP Officer to send the bid to");
            return;
        end
        GUI.Dialogs:Show('PDKP_BID_MAX_CONFIRM', nil, {
            ['sendTo'] = sendTo,
            ['frame'] = f,
        });
    end)
    maxBid:SetScript("OnShow", function()
        maxBid:SetEnabled(true);
        if f.current_bid.getValue() > 0 then
            f.submit_btn:SetText("Update Bid")
        else
            f.submit_btn:SetText("Submit Bid")
        end
    end)
    maxBid:SetScript("OnHide", function()
        maxBid:SetEnabled(false);
    end)

    local cb = CreateFrame("Button", "$parent_cancelBid", f, "UIPanelButtonTemplate")
    cb:SetSize(80, 22) -- width, height
    cb:SetText("Cancel Bid")
    cb:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 28, 10)
    cb:Hide()
    cb:SetEnabled(false)
    cb:SetScript("OnClick", function()
        f.current_bid:SetText("")
        f.cancel_btn:SetEnabled(false)
        f.cancel_btn:Hide()
        maxBid:Show();
        maxBid:SetEnabled(true);
        MODULES.CommsManager:SendCommsMessage('CancelBid', { ['cancelBid'] = true })
    end)
    cb:SetScript("OnShow", function()
        if f.current_bid.getValue() > 0 then
            f.submit_btn:SetText("Update Bid")
        else
            f.submit_btn:SetText("Submit Bid")
        end
    end)
    cb:SetScript("OnHide", function()
        f.submit_btn:SetText("Submit Bid")
    end)

    stopBid = CreateFrame("Button", "$parent_stop_btn", f, "UIPanelButtonTemplate")
    stopBid:SetSize(80, 22) -- width, height
    stopBid:SetText("Manually End Current Auction")
    stopBid:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 15, -22)
    stopBid:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 0)
    stopBid:SetScript("OnClick", function()
        MODULES.AuctionManager:HandleTimerFinished(true)
    end)
    stopBid:SetEnabled(false)
    stopBid:Hide()

    local item_icon = f:CreateTexture(nil, 'OVERLAY')
    item_icon:SetSize(46, 35)
    item_icon:SetPoint("LEFT", f, "LEFT", 32, 21)

    local item_link = GUtils:createItemLink(f)
    item_link:SetPoint("LEFT", item_icon, "RIGHT", 5, 0)
    item_link:SetWidth(150)
    item_link.icon = item_icon

    local bid_box_opts = {
        ['name'] = 'bid_input',
        ['parent'] = f,
        ['title'] = 'Bid Amount',
        ['multi_line'] = false,
        ['hide'] = false,
        ['max_chars'] = 5,
        ['textValidFunc'] = function(box)
            if box == nil then
                box = bid_box
            end
            local box_val = box.getValue()
            local curr_bid_val = f.current_bid.getValue()
            local myDKP = MODULES.DKPManager:GetMyDKP()
            local bidInProgress = MODULES.AuctionManager:IsAuctionInProgress()

            if box_val and box_val <= myDKP and box_val > 0 and box_val ~= curr_bid_val and bidInProgress then
                return sb:SetEnabled(true)
            end
            return sb:SetEnabled(false)
        end,
        ['numeric'] = true,
        ['small_title'] = false,
    }
    bid_box = GUtils:createEditBox(bid_box_opts)
    bid_box:SetWidth(80)
    bid_box:SetPoint("LEFT", f, "LEFT", 45, -35)
    bid_box:SetFrameLevel(f:GetFrameLevel() + 5)
    bid_box.frame:SetFrameLevel(bid_box:GetFrameLevel() - 2)
    bid_box:SetScript("OnTextSet", function()
        local val = bid_box.getValue()
        f.submit_btn.isEnabled = val > 0
        f.submit_btn:SetEnabled(f.submit_btn.isEnabled)
    end)

    local current_bid_opts = {
        ['name'] = 'display_bid',
        ['parent'] = f,
        ['title'] = 'Pending Bid',
        ['multi_line'] = false,
        ['max_chars'] = 5,
        ['textValidFunc'] = nil,
        ['numeric'] = true,
        ['small_title'] = false,
    }
    local current_bid = GUtils:createEditBox(current_bid_opts)
    current_bid:SetWidth(80)
    current_bid:SetPoint("LEFT", bid_box, "RIGHT", 15, 0)
    current_bid.frame:SetFrameLevel(current_bid:GetFrameLevel() - 2)
    current_bid:SetEnabled(false)
    current_bid.frame:SetBackdrop(nil)
    current_bid:SetScript("OnTextSet", function()
        local val = current_bid.getValue()
        f.cancel_btn.isEnabled = val > 0
        f.cancel_btn:SetEnabled(f.cancel_btn.isEnabled)
        f.bid_box:SetText(0)

        if f.cancel_btn.isEnabled then
            f.cancel_btn:Show()
        else
            f.cancel_btn:Hide()
        end
    end)

    local bids_open_btn = CreateFrame("Button", nil, f)
    bids_open_btn:SetSize(45, 25);
    bids_open_btn:SetNormalTexture(MODULES.Media.ARROW_RIGHT_TEXTURE)
    bids_open_btn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -45)

    bids_open_btn:SetScript("OnClick", function()
        if AuctionGUI.current_bidders_frame:IsVisible() then
            AuctionGUI.current_bidders_frame:Hide()
            bids_open_btn:SetNormalTexture(MODULES.Media.ARROW_RIGHT_TEXTURE)
        else
            AuctionGUI.current_bidders_frame:Show()
            bids_open_btn:SetNormalTexture(MODULES.Media.ARROW_LEFT_TEXTURE)
        end
    end)

    local reopenFrame = CreateFrame("Button", "$parent_reopen_btn", UIParent, "UIPanelButtonTemplate")
    reopenFrame:SetSize(150, 22) -- width, height
    reopenFrame:SetText("PDKP Bid Interface")
    reopenFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    reopenFrame:SetScript("OnClick", function()
        reopenFrame:Hide()
        if MODULES.AuctionManager:IsAuctionInProgress() then
            f:Show()
            PDKP.AuctionTimer.isBarLocked = false
            PDKP.AuctionTimer:Show()
        end
    end)
    reopenFrame:Hide()

    tinsert(UISpecialFrames, f:GetName())

    f.current_bid = current_bid
    f.bid_box = bid_box
    f.item_link = item_link
    f.submit_btn = sb
    f.cancel_btn = cb
    f.bid_counter = bid_counter
    f.dkp_title = dkp_title
    f.stopBid = stopBid
    f.bids_open_btn = bids_open_btn
    f.reopenFrame = reopenFrame
    f.maxBid = maxBid;

    AuctionGUI.frame = f

    -- Interface\CHATFRAME\UI-ChatInputBorder for the item-link

    local pushBarOpts = {
        ['name'] = 'AuctionTimer',
        ['type'] = 'timer',
        ['default'] = 30,
        ['min'] = 0,
        ['max'] = 30,
        ['func'] = function()
            MODULES.AuctionManager:HandleTimerFinished()
        end,
    }

    if PDKP.canEdit then
        pushBarOpts['addTime'] = true
    end

    PDKP.AuctionTimer = GUtils:createStatusBar(pushBarOpts)

    PDKP.AuctionTimer:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 10, 0)
    PDKP.AuctionTimer:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -5, 0)

    PDKP.AuctionTimer.bg:SetPoint("TOPLEFT", PDKP.AuctionTimer, "TOPLEFT")
    PDKP.AuctionTimer.bg:SetPoint("BOTTOMLEFT", PDKP.AuctionTimer, "BOTTOMLEFT")
    PDKP.AuctionTimer.bg:SetWidth(PDKP.AuctionTimer:GetWidth())

    PDKP.AuctionTimer.bgFrame:SetPoint("TOPLEFT", PDKP.AuctionTimer, "TOPLEFT", -33, 20)
    PDKP.AuctionTimer.bgFrame:SetPoint("BOTTOMRIGHT", PDKP.AuctionTimer, "BOTTOMRIGHT", 33, -20)

    if PDKP.AuctionTimer.addTime ~= nil and pushBarOpts['addTime'] == true then
        PDKP.AuctionTimer.addTime:SetScript("OnClick", function()
            if MODULES.AuctionManager:CanChangeAuction() then
                MODULES.CommsManager:SendCommsMessage('AddTime', {['addTime'] = true})
            end
        end)

        if not MODULES.AuctionManager:CanChangeAuction() then
            PDKP.AuctionTimer.addTime:Hide();
        end
    end

    f:SetScript("OnHide", function()
        if MODULES.AuctionManager:IsAuctionInProgress() then
            reopenFrame:Show()
            PDKP.AuctionTimer.isBarLocked = true
        else
            PDKP.AuctionTimer.reset()
        end
    end)

    self:CreateBiddersWindow()

    f:Hide()
end

function AuctionGUI:AddTimeToAuction(sender)
    PDKP.CORE:Print(sender, "extended the auction timer");
    PDKP.AuctionTimer.setAmount(PDKP.AuctionTimer:GetValue() + 10)
end

function AuctionGUI:CreateBiddersWindow()
    local f = GUtils:createBackdropFrame('pdkp_bidders_frame', self.frame, 'Bidders')
    f:SetPoint("TOPLEFT", self.frame, "TOPRIGHT", 0, -30)
    f:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMRIGHT", 0, 0)
    f:SetSize(200, 150)

    f.border:SetBackdropColor(unpack({ 0, 0, 0, 0.85 }))

    local scroll = PDKP.SimpleScrollFrame:new(f.content)
    local scrollFrame = scroll.scrollFrame
    local scrollContent = scrollFrame.content;

    f.scrollContent = scrollContent;
    f.scrollContent:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT");
    f.scroll = scroll;
    f.scrollFrame = scrollFrame;

    f:Hide()

    self.current_bidders_frame = f;
end

function AuctionGUI:ResetAuctionInterface()
    self.frame.stopBid:Hide()
    self.frame.bid_box:SetText(0)
    self.frame.current_bid:SetText(0)
    self.frame.stopBid:Hide()

    self.frame:Show()

    local numBidders = #MODULES.AuctionManager.CURRENT_BIDDERS

    if not self.current_bidders_frame:IsVisible() and numBidders >= 1 then
        self.frame.bids_open_btn:Click()
    end

    self:_ShowBidAmounts()

    self.frame.reopenFrame:Hide()
end

--- Bid info:
---
---Name, Bid Amount, Total DKP
function AuctionGUI:CreateNewBidder(bid_info)
    local bidders = MODULES.AuctionManager.CURRENT_BIDDERS
    local bidFound, bidIndex = false, nil

    for i = 1, #bidders do
        local bidder = bidders[i]
        if bidder.name == bid_info['name'] then
            MODULES.AuctionManager.CURRENT_BIDDERS[i].bid = bid_info['bid']
            bidFound = true
            bidIndex = i
        end
    end

    if not bidFound then
        table.insert(MODULES.AuctionManager.CURRENT_BIDDERS, bid_info)
    elseif bidFound and bidIndex ~= nil then
        MODULES.AuctionManager.CURRENT_BIDDERS[bidIndex] = bid_info
    end

    self:RefreshBidders()
end

function AuctionGUI:RefreshBidders()
    local bidders_frame = self.current_bidders_frame;
    local scrollContent = bidders_frame.scrollContent;
    local bidders = MODULES.AuctionManager.CURRENT_BIDDERS

    scrollContent:WipeChildren() -- Wipe previous shrouding children frames.

    local createProspectFrame = function()
        local f = CreateFrame("Frame", nil, scrollContent, nil)
        f:SetSize(scrollContent:GetWidth(), 18)
        f.name = f:CreateFontString(f, "OVERLAY", "GameFontHighlightLeft")
        f.bid = f:CreateFontString(f, 'OVERLAY', 'GameFontNormalRight')
        f.name:SetHeight(18)
        f.bid:SetHeight(18)
        f.name:SetPoint("LEFT")
        f.bid:SetPoint("RIGHT")
        return f
    end

    for i = 1, #bidders do
        local prospect_frame = createProspectFrame()
        local prospect_info = bidders[i]

        if prospect_info ~= nil then
            prospect_frame.name:SetText(prospect_info['name'])

            prospect_frame.bid:Hide()

            if PDKP:IsDev() and PDKP.showBidAmounts then
                prospect_frame.bid:Show()
            end

            prospect_frame.bid:SetText(prospect_info['bid'])

            scrollContent:AddChild(prospect_frame)
        end
    end
end

function AuctionGUI:_ShowBidAmounts()
    local bidders_frame = self.current_bidders_frame;
    local scrollContent = bidders_frame.scrollContent;

    table.sort(MODULES.AuctionManager.CURRENT_BIDDERS, function(a, b) return tonumber(a['bid']) > tonumber(b['bid']) end)

    self:RefreshBidders()

    for _, child in pairs(scrollContent.children) do
        child.bid:Show()
    end
end

function AuctionGUI:CancelBidder(bidder)
    local bidders = MODULES.AuctionManager.CURRENT_BIDDERS
    for i = 1, #bidders do
        local b = bidders[i]
        if b.name == bidder then
            MODULES.AuctionManager.CURRENT_BIDDERS[i] = nil
            break ;
        end
    end
    self:RefreshBidders()
end

function AuctionGUI:StartAuction(itemLink, itemName, itemTexture, startedBy)
    self.frame.item_link.SetItemLink(itemLink, itemName, itemTexture)
    self.frame.dkp_title:SetText('Total DKP: ' .. MODULES.DKPManager:GetMyDKP())

    self:RefreshBidders()

    if self.frame:IsVisible() then
        self.frame:Hide()
    end

    self.frame:Show()
    MODULES.AuctionManager.CurrentAuctionInfo = { ['itemName'] = itemName, ['itemLink'] = itemLink, ['itemTexture'] = itemTexture, ['startedBy'] = startedBy }
end

GUI.AuctionGUI = AuctionGUI
