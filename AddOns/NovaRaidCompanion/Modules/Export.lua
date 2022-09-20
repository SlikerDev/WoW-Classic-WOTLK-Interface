------------------------------
---NovaRaidCompanion Talents--
------------------------------
local addonName, NRC = ...;
local L = LibStub("AceLocale-3.0"):GetLocale("NovaRaidCompanion");

local exportFrame;

local function loadExportFrame()
	if (not exportFrame) then
		exportFrame = NRC:createExportFrame("NRCExportFrame", 500, 300, 0, 100);
	end
end

local function generateFightClubLootExportString(logID)
	local data = NRC.db.global.instances[logID];
	if (not data) then
		return "Error generating export string, raid data not found.";
	end
	local mapToTrades = NRC.config.mapLootDisplayToTrades;
	local raidDate = date("%m/%d/%Y", data.enteredTime);
	local exportString = "";
	exportString = exportString .. "   Attendees:\n\n";
	for k, v in pairs(data.group) do
		exportString = exportString .. v.name .. ";";
	end
	exportString = exportString .. "\n\n   Loot:\n\n";
	--local tradeData = getTradeData(raidData.raidID)
	if (NRC.config.lootExportLegendary) then
		local loot, bossLoot, trashLoot, lootData = NRC:getLootData(logID, nil, 5, nil, nil, nil, not NRC.config.lootExportTradeskill, mapToTrades);
		for k, v in ipairs(lootData) do
			local name = v.name;
			if (v.override) then
				name = v.override;
			elseif (v.traded) then
				name = v.traded;
			end
			exportString = exportString .. raidDate .. ";" .. v.itemLink .. ";" .. name .. "\n";
	    end
    end
    if (NRC.config.lootExportEpic) then
		local loot, bossLoot, trashLoot, lootData = NRC:getLootData(logID, nil, 4, nil, nil, nil, not NRC.config.lootExportTradeskill, mapToTrades);
		for k, v in ipairs(lootData) do
			local name = v.name;
			if (v.override) then
				name = v.override;
			elseif (v.traded) then
				name = v.traded;
			end
			exportString = exportString .. raidDate .. ";" .. v.itemLink .. ";" .. name .. "\n";
	    end
    end
    if (NRC.config.lootExportRare) then
		local loot, bossLoot, trashLoot, lootData = NRC:getLootData(logID, nil, 3, nil, nil, nil, not NRC.config.lootExportTradeskill, mapToTrades);
		for k, v in ipairs(lootData) do
			local name = v.name;
			if (v.override) then
				name = v.override;
			elseif (v.traded) then
				name = v.traded;
			end
			exportString = exportString .. raidDate .. ";" .. v.itemLink .. ";" .. name .. "\n";
	    end
    end
    if (NRC.config.lootExportUncommon) then
		local loot, bossLoot, trashLoot, lootData = NRC:getLootData(logID, nil, 2, nil, nil, nil, not NRC.config.lootExportTradeskill, mapToTrades);
		for k, v in ipairs(lootData) do
			local name = v.name;
			if (v.override) then
				name = v.override;
			elseif (v.traded) then
				name = v.traded;
			end
			exportString = exportString .. raidDate .. ";" .. v.itemLink .. ";" .. name .. "\n";
	    end
    end
    exportString = string.gsub(exportString, "\n$", "");
    return exportString
end

function NRC:loadLootExportFrame(logID, refresh)
	loadExportFrame();
	local type = NRC.config.exportType;
	exportFrame.EditBox:SetText("");
	if (not refresh) then
		exportFrame.topFrame.fs:SetText("|cFFFFFF00Loot Export");
		
		exportFrame.checkbox1.Text:SetText("|cFFff8000" .. L["Legendary"]);
		exportFrame.checkbox1:ClearAllPoints();
		exportFrame.checkbox1:SetPoint("TOPLEFT", exportFrame.topFrame, 5, -2);
		exportFrame.checkbox1:SetChecked(NRC.config.lootExportLegendary);
		exportFrame.checkbox1:SetScript("OnClick", function()
			local value = exportFrame.checkbox1:GetChecked();
			NRC.config.lootExportLegendary = value;
			NRC:loadLootExportFrame(logID)
		end)
		exportFrame.checkbox1:Show();
		
		exportFrame.checkbox2.Text:SetText("|cFFa335ee" .. L["Epic"]);
		exportFrame.checkbox2:ClearAllPoints();
		exportFrame.checkbox2:SetPoint("TOPLEFT", exportFrame.topFrame, 5, -20);
		exportFrame.checkbox2:SetChecked(NRC.config.lootExportEpic);
		exportFrame.checkbox2:SetScript("OnClick", function()
			local value = exportFrame.checkbox2:GetChecked();
			NRC.config.lootExportEpic = value;
			NRC:loadLootExportFrame(logID)
		end)
		exportFrame.checkbox2:Show();
		
		exportFrame.checkbox3.Text:SetText("|cFF0070dd" .. L["Rare"]);
		exportFrame.checkbox3:ClearAllPoints();
		exportFrame.checkbox3:SetPoint("TOPLEFT", exportFrame.topFrame, 5, -38);
		exportFrame.checkbox3:SetChecked(NRC.config.lootExportRare);
		exportFrame.checkbox3:SetScript("OnClick", function()
			local value = exportFrame.checkbox3:GetChecked();
			NRC.config.lootExportRare = value;
			NRC:loadLootExportFrame(logID)
		end)
		exportFrame.checkbox3:Show();
		
		exportFrame.checkbox4.Text:SetText("|cFF1eff00" .. L["Uncommon"]);
		exportFrame.checkbox4:ClearAllPoints();
		exportFrame.checkbox4:SetPoint("TOPLEFT", exportFrame.topFrame, 5, -56);
		exportFrame.checkbox4:SetChecked(NRC.config.lootExportUncommon);
		exportFrame.checkbox4:SetScript("OnClick", function()
			local value = exportFrame.checkbox4:GetChecked();
			NRC.config.lootExportUncommon = value;
			NRC:loadLootExportFrame(logID)
		end)
		exportFrame.checkbox4:Show();
		
		exportFrame.checkbox5.Text:SetText("|cFFDEDE42" .. L["Tradeskill"] .. "/Gems");
		exportFrame.checkbox5:ClearAllPoints();
		exportFrame.checkbox5:SetPoint("TOPLEFT", exportFrame.topFrame, 100, -56);
		exportFrame.checkbox5.tooltip2.fs:SetText("Gems, Sunmotes, other tradeskill items.");
		exportFrame.checkbox5:SetChecked(NRC.config.lootExportTradeskill);
		exportFrame.checkbox5:SetScript("OnClick", function()
			local value = exportFrame.checkbox5:GetChecked();
			NRC.config.lootExportTradeskill = value;
			NRC:loadLootExportFrame(logID)
		end)
		exportFrame.checkbox5:Show();
		
		exportFrame.dropdownMenu1:SetPoint("TOPRIGHT", exportFrame.topFrame, "TOPRIGHT", -20, -3);
		exportFrame.dropdownMenu1.tooltip.fs:SetText("|Cffffd000" .. L["exportTypeTooltip"]);
		exportFrame.dropdownMenu1.tooltip:SetWidth(exportFrame.dropdownMenu1.tooltip.fs:GetStringWidth() + 18);
		exportFrame.dropdownMenu1.tooltip:SetHeight(exportFrame.dropdownMenu1.tooltip.fs:GetStringHeight() + 12);
		exportFrame.dropdownMenu1.tooltip:ClearAllPoints();
		exportFrame.dropdownMenu1.tooltip:SetPoint("BOTTOM", exportFrame.dropdownMenu1, "TOP", 0, 5);
		NRC.DDM:UIDropDownMenu_SetWidth(exportFrame.dropdownMenu1, 135);
		exportFrame.dropdownMenu1.initialize = function(dropdown)
			local info = NRC.DDM:UIDropDownMenu_CreateInfo()
			info.text = "|cFF9CD6DE" .. L["Google Spreadsheet"];
			info.checked = false;
			info.value = "google";
			info.func = function(self)
				NRC.DDM:UIDropDownMenu_SetSelectedValue(dropdown, self.value)
				NRC.config.exportType = info.value;
				NRC:loadLootExportFrame(logID, true);
			end
			NRC.DDM:UIDropDownMenu_AddButton(info);
			local info = NRC.DDM:UIDropDownMenu_CreateInfo()
			info.text = "|cFF9CD6DE" .. L["DFT Fight Club "];
			info.checked = false;
			info.value = "fightclub";
			info.func = function(self)
				NRC.DDM:UIDropDownMenu_SetSelectedValue(dropdown, self.value)
				NRC.config.exportType = info.value;
				NRC:loadLootExportFrame(logID, true);
			end
			NRC.DDM:UIDropDownMenu_AddButton(info);
			--NRC.DDM:UIDropDownMenu_AddSeparator();
			if (not NRC.DDM:UIDropDownMenu_GetSelectedValue(exportFrame.dropdownMenu1)) then
				--If no value set then it's first load, set saved db value.
				NRC.DDM:UIDropDownMenu_SetSelectedValue(exportFrame.dropdownMenu1, NRC.config.exportType);
			end
		end
		NRC.DDM:UIDropDownMenu_Initialize(exportFrame.dropdownMenu1, exportFrame.dropdownMenu1.initialize);
		--exportFrame.dropdownMenu1:HookScript("OnShow", function() NRC.DDM:UIDropDownMenu_Initialize(exportFrame.dropdownMenu1) end);
		--If we reopen then reset the dropdowns.
		--if (resetDropdowns) then
		--	NRC.DDM:UIDropDownMenu_SetSelectedValue(exportFrame.dropdownMenu1, NRC.config.exportType);
		--end
		exportFrame.dropdownMenu1:Show();
	end
	local text = "Error, export type not found.";
	if (type == "google") then
		text = "Google export feature unfinished, if you would like a format added that your guild uses please ask on my discord https://discord.gg/RTKMfTmkdj";
	elseif (type == "fightclub") then
		text = generateFightClubLootExportString(logID);
	end
	exportFrame.EditBox:Insert(text);
	exportFrame.EditBox:HighlightText();
	exportFrame.EditBox:SetFocus();
	exportFrame:Show();
end