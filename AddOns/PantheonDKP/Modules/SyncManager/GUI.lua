local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local GUtils = PDKP.GUtils;
--local Utils = PDKP.Utils;

local UIParent, CreateFrame = UIParent, CreateFrame;

local SyncGUI = {};

function SyncGUI:Initialize()
    if not PDKP.canEdit then return end;

    self.checkButtons = {};

    local f = CreateFrame("Frame", 'pdkp_sync_frame', UIParent, 'BasicFrameTemplateWithInset')
    f:SetSize(285, 250)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f.title = f:CreateFontString(nil, "OVERLAY")
    f.title:SetFontObject("GameFontHighlight")
    f.title:SetPoint("CENTER", f.TitleBg, "CENTER", 11, 0)
    f.title:SetText("PDKP Officer Sync")
    f:SetFrameStrata("HIGH")
    f:SetFrameLevel(1)
    f:SetToplevel(true)

    f.content = CreateFrame("Frame", '$parent_content', f)
    f.content:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -28)
    f.content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)
    f.content:SetSize(f:GetWidth(), f:GetHeight());

    f:Hide();

    GUtils:setMovable(f);
    GUtils:addToSpecialFrames(f);

    ----- SimpleScrollFrame
    local scroll = PDKP.SimpleScrollFrame:new(f.content)
    local scrollFrame = scroll.scrollFrame
    local scrollContent = scrollFrame.content;

    scrollContent:SetWidth(scrollFrame:GetWidth());

    -- Create all of the Backdrop groups.
    local GROUP_OPTS = {
        { ['name'] = 'sync_type_group', ['title'] = 'Type', ['height'] = 75,
          ['description'] = "Type of sync to send.", ['setting'] = 'type',
          ['checkChildren'] = {
              {
                  ['group'] = 'sync_type_group',
                  ['siblings'] = { 'PDKP_OfficerSyncOverwrite' },
                  ['name'] = 'Merge',
              },
              {
                  ['group'] = 'sync_type_group',
                  ['siblings'] = { 'PDKP_OfficerSyncMerge' },
                  ['name'] = 'Overwrite',
              },
          },
        },
        { ['name'] = 'sync_group_group', ['title'] = 'Channel', ['height'] = 75,
          ['description'] = "Who do you want to receive the sync.", ['setting'] = 'group',
          ['checkChildren'] = {
              {
                  ['group'] = 'sync_group_group',
                  ['siblings'] = { 'PDKP_OfficerSyncRaid', },
                  ['name'] = 'Guild',
              },
          },
        },
    }

    for i = 1, #GROUP_OPTS do
        local opts = GROUP_OPTS[i]
        local frame = GUtils:createBackdropFrame(nil, scrollContent, opts['title'])
        frame.named_children = {};
        frame:SetHeight(opts['height'])
        if opts['description'] then
            frame.desc:SetText(opts['description'])
        end
        scrollContent:AddChild(frame)
        frame.syncSetting = opts['setting']

        for _, checkOpts in pairs(opts['checkChildren']) do
            local checkGroup = frame
            local checkSiblings = checkOpts['siblings']
            local btnOpts = {
                ['uniqueName'] = 'PDKP_OfficerSync' .. checkOpts['name'],
                ['center'] = true,
                ['frame'] = checkGroup.content,
                ['text'] = checkOpts['name'],
                ['enabled'] = true,
                ['parent'] = checkGroup.content,
            };
            local cb = GUtils:createCheckButton(btnOpts);
            cb.uniqueValue = checkOpts['name']
            cb:ClearAllPoints();
            cb:SetChecked(false);
            if #checkGroup.children > 0 then
                local prevCb = checkGroup.children[#checkGroup.children];
                cb:SetPoint("LEFT", prevCb.text, "RIGHT", 5, 0);
            else
                cb:SetPoint("LEFT", checkGroup.content, "LEFT", 0, 10);
            end
            cb:SetScript("OnClick", function()
                for _, bName in pairs(checkSiblings) do
                    local b = _G['pdkp_filter_' .. bName];
                    if (b ~= nil) then
                        b:SetChecked(false);
                    end
                end
                cb:SetChecked(true);
                MODULES.SyncManager:AdjustSettings(frame.syncSetting, cb.uniqueValue);
                self:ToggleSubmit();
            end)
            cb:SetHitRectInsets(0, cb.text:GetWidth() * -1, 0, 0)
            table.insert(checkGroup.children, cb);
            table.insert(self.checkButtons, cb);
        end
    end

    local sb = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
    sb:SetPoint("BOTTOMRIGHT", f.content, "BOTTOMRIGHT", 0, -4);
    sb:SetText("Send Sync");
    sb:SetSize(80, 22);
    sb:SetEnabled(false);
    sb:SetScript("OnClick", function()
        MODULES.SyncManager:SendSync();
    end)
    f.submit = sb;

    f:SetScript("OnHide", function()
        MODULES.SyncManager:Reset();
    end)

    PDKP.OfficerSyncFrame = f;
end

function SyncGUI:ToggleSubmit()
    PDKP.OfficerSyncFrame.submit:SetEnabled(MODULES.SyncManager:IsSyncReady())
end

function SyncGUI:ClearChecked()
    for _, b in pairs(self.checkButtons) do
        b:SetChecked(false);
    end
    PDKP.OfficerSyncFrame:Hide();
end

GUI.SyncGUI = SyncGUI;
