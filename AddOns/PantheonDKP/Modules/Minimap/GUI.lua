local _, PDKP = ...

local MODULES = PDKP.MODULES
local GUI = PDKP.GUI
local Utils = PDKP.Utils;
local CONSTANTS = MODULES.Constants;

local map = {}

local LibStub = LibStub
local IsControlKeyDown, IsShiftKeyDown, IsAltKeyDown = IsControlKeyDown, IsShiftKeyDown, IsAltKeyDown
local unpack, tinsert = unpack, table.insert

local info = CONSTANTS.INFO;
local clickText = Utils:FormatTextColor('Click', info) .. ' to open PDKP. '
local shiftRightClickText = Utils:FormatTextColor('Shift-Right-Click', info) .. ' to open Officer push'
local rightClickText = Utils:FormatTextColor('Right-Click', info) .. ' to open settings'
local resetDatabaseText = Utils:FormatTextColor('Ctrl-Alt-Shift-Right-Click', info) .. ' to purge database'

function map:Initialize()
    local settingsDB = MODULES.Database:Settings();
    local miniDB = settingsDB['minimap'];

    self.LDB = LibStub("LibDataBroker-1.1")
    self.broker = self.LDB:NewDataObject('PantheonDKP', {
        type = "launcher",
        text = 'PantheonDKP',
        icon = MODULES.Media.PDKP_ADDON_ICON,
        OnTooltipShow = function(tooltip)
            local texts = map:_GetToolTipTexts()
            for i = 1, #texts do
                tooltip:AddLine(unpack(texts[i]))
            end
            tooltip:Show()
        end,
        OnClick = function(_, button)
            map:HandleIconClicks(button)
        end
    });

    self.icon = LibStub("LibDBIcon-1.0")
    self.icon:Register('PantheonDKP', self.broker, miniDB)

    if miniDB['hide'] then
        self:Hide();
    else
        self:Show()
    end
end

function map:Show()
    self.icon:Show("PantheonDKP")
    self.icon:Show("PantheonDKP")
end

function map:Hide()
    self.icon:Hide("PantheonDKP")
    self.icon:Hide("PantheonDKP")
end

function map:_GetToolTipTexts()
    local title = { "PantheonDKP " .. MODULES.Constants.COLORED_ADDON_VERSION }
    local lineBreak = { " ", 1, 1, 1, 1 }
    local leftClick = { clickText, 1, 1, 1 }
    local rightClick = { rightClickText, 1, 1, 1 }
    local shiftRightClick = { shiftRightClickText, 1, 1, 1 }
    local databaseResetClick = { resetDatabaseText, 1, 1, 1 }

    local texts = { title, lineBreak, leftClick, rightClick }

    if PDKP.canEdit then
        tinsert(texts, lineBreak)
        tinsert(texts, shiftRightClick)
    end

    tinsert(texts, lineBreak)
    tinsert(texts, databaseResetClick)

    tinsert(texts, lineBreak)

    local guildCapPercent = MODULES.DKPManager:GetMaxBid();

    local dkpCap = "[90% Bid Cap]: " .. tostring(guildCapPercent) .. " DKP";

    tinsert(texts, { dkpCap, 1, 1, 1 })

    return texts
end

function map:HandleIconClicks(buttonType)
    local hasCtrl, hasShift, hasAlt = IsControlKeyDown(), IsShiftKeyDown(), IsAltKeyDown()
    local clickTypes = {
        ['LeftButton'] = {
            [hasShift and hasAlt and hasCtrl] = function()
            end,
            [hasShift and hasAlt and not hasCtrl] = function()
            end,
            [hasShift and not hasAlt and not hasCtrl] = function()
            end,
            [hasAlt and not hasShift and not hasCtrl] = function()

            end,
            ['default'] = function()
                if pdkp_frame:IsVisible() then
                    pdkp_frame:Hide()
                else
                    pdkp_frame:Show()
                end
            end,
        },
        ['RightButton'] = {
            [hasShift and PDKP.canEdit and not hasAlt and not hasCtrl] = function()
                if PDKP.OfficerSyncFrame ~= nil then
                    PDKP.OfficerSyncFrame:Show();
                end
            end,
            [hasShift and hasAlt and hasCtrl] = function()
                MODULES.Database:ResetAllDatabases()
                ReloadUI()
            end,
            ['default'] = function()
                InterfaceOptionsFrame_Show()
                InterfaceOptionsFrame_OpenToCategory("PantheonDKP")
            end,
        }
    }

    local clickFunc = clickTypes[buttonType][true] or clickTypes[buttonType]['default']
    clickFunc()
end

GUI.Minimap = map
