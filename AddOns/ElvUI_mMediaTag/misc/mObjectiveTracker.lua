local E, L, V, P, G = unpack(ElvUI)
local mPlugin = "mMediaTag"
local mMT = E:GetModule(mPlugin)
local addon, ns = ...
local LSM = E.Libs.LSM

-- Lib Globals
local unpack = unpack
local format = format

-- WoW Globals
local _G = _G
local ObjectiveTrackerFrame = _G.ObjectiveTrackerFrame
local ObjectiveTrackerBlocksFrame = _G.ObjectiveTrackerBlocksFrame
--local WORLD_QUEST_TRACKER_MODULE = _G.WORLD_QUEST_TRACKER_MODULE
--local BONUS_OBJECTIVE_TRACKER_MODULE = _G.BONUS_OBJECTIVE_TRACKER_MODULE
local maxNumQuestsCanAccept = C_QuestLog.GetMaxNumQuestsCanAccept()
local HeaderTitel = ObjectiveTrackerBlocksFrame.QuestHeader.Text:GetText()
local width = _G.ObjectiveTrackerFrame:GetWidth()
--local hight = _G.ObjectiveTrackerFrame:GetHight()

-- Variables
local _, unitClass = UnitClass("PLAYER")
local mClassColor = ElvUF.colors.class[unitClass]
local mFontFlags = {
	NONE = L["NONE"],
	OUTLINE = "Outline",
	THICKOUTLINE = "Thick",
	MONOCHROME = "|cffaaaaaaMono|r",
	MONOCHROMEOUTLINE = "|cffaaaaaaMono|r Outline",
	MONOCHROMETHICKOUTLINE = "|cffaaaaaaMono|r Thick",
}
local positionValues = {
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	CENTER = "CENTER",
	TOP = "TOP",
	TOPLEFT = "TOPLEFT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOM = "BOTTOM",
	BOTTOMLEFT = "BOTTOMLEFT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
}

local TextureList, mIconsList = nil, nil

local function mTGAtoIcon(file, i)
	return format("|T%s:16:16:0:0.8:64:64|t %s - %s", file, L["Icon"], i)
end

local function mGetTexturePath(file)
	return format("Interface\\AddOns\\ElvUI_mMediaTag\\media\\misc\\dot%s.tga", file)
end

local function SetupDotIconList()
	if not mIconsList then
		local tmpIcon = {}
		for i = 1, 16, 1 do
			local path = mGetTexturePath(i)
			tmpIcon[i] = { ["file"] = path, ["icon"] = mTGAtoIcon(path, i) }
		end
		mIconsList = tmpIcon
	end
end

local function mTextureList()
	if not TextureList then
		SetupDotIconList()
		local tmpTexture = {}
		local i = 0
		for i in pairs(mIconsList) do
			tmpTexture[i] = mIconsList[i].icon
		end
		TextureList = tmpTexture
	end
	return TextureList
end

local function mDashIcon(icon)
	return format("|T%s:8:8:-1:-3.8:64:64|t", icon)
end

local mOTFont = nil
local mOTFontFlag = nil
local c = { r = 1, g = 1, b = 1 }

local function mGetFont()
	mOTFont = LSM:Fetch("font", E.db[mPlugin].mObjectiveTracker.font)
	mOTFontFlag = E.db[mPlugin].mObjectiveTracker.fontflag
end

local function mcg(color)
	local shift = 0.5
	local colorA = { color[1] - 0.3, color[2] - 0.3, color[3] - 0.3 }
	if color[1] > color[2] and color[1] > color[3] then
		colorA = { 1, color[2] - 0.3, color[3] - 0.3 }
	elseif color[2] > color[1] and color[2] > color[3] then
		colorA = { color[1] - 0.3, 1, color[3] - 0.3 }
	elseif color[3] > color[1] and color[3] > color[2] then
		colorA = { color[1] - 0.3, color[2] - 0.3, 1 }
	end

	local colorB = color
	local gardientColor = {}
	gardientColor[1] = colorA[1] + shift * (colorB[1] - colorA[1])
	gardientColor[2] = colorA[2] + shift * (colorB[2] - colorA[2])
	gardientColor[3] = colorA[3] + shift * (colorB[3] - colorA[3])

	return gardientColor
end

local function mSetGradient(obj, revers, orientation, minR, minG, minB, maxR, maxG, maxB)
	if obj then
		local c = mcg({ minR, minG, minB })
		if revers then
			obj:GetStatusBarTexture():SetGradient(orientation, c[1], c[2], c[3], minR, minG, minB)
		else
			obj:GetStatusBarTexture():SetGradient(orientation, minR, minG, minB, c[1], c[2], c[3])
		end
	end
end

local function mGardientProgressBars(self, value)
	if not (self.Bar and self.isSkinned and value) then
		return
	end
	local current = (not 100 and value) or (value and 100 and 100 ~= 0 and value / 100)
	if not current then
		return
	end
	local r, g, b = E:ColorGradient(current, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)
	self.Bar.backdrop:SetBackdropColor(
		E.db.general.backdropfadecolor.r,
		E.db.general.backdropfadecolor.g,
		E.db.general.backdropfadecolor.b,
		E.db.general.backdropfadecolor.a
	)
	mSetGradient(
		self.Bar,
		E.db[mPlugin].mObjectiveTracker.text.reverse,
		"HORIZONTAL",
		r,
		g,
		b,
		r - 0.4,
		g - 0.4,
		b - 0.4
	)
end

local function mSetupHeaderFont(headdertext)
	if headdertext then
		local QuestCount = E.db[mPlugin].mObjectiveTracker.header.questcount
		mGetFont()

		if E.db[mPlugin].mObjectiveTracker.header.fontcolorstyle == "class" then
			c = { r = mClassColor[1], g = mClassColor[2], b = mClassColor[3] }
		else
			c = E.db[mPlugin].mObjectiveTracker.header.fontcolor
		end

		if QuestCount ~= "none" then
			local _, numQuests = C_QuestLog.GetNumQuestLogEntries()
			local QuestCountText = format("%s/%s", numQuests, maxNumQuestsCanAccept)

			if (QuestCount == "colorleft") or (QuestCount == "colorright") then
				local cg = E.db[mPlugin].mObjectiveTracker.text.progresscolorgood
				local ct = E.db[mPlugin].mObjectiveTracker.text.progresscolortransit
				local cb = E.db[mPlugin].mObjectiveTracker.text.progresscolorbad
				local tmpPercent = mMT:round((tonumber(numQuests) / tonumber(maxNumQuestsCanAccept)) * 100 or 0)
				local r, g, b = E:ColorGradient(tmpPercent * 0.01, cg.r, cg.g, cg.b, ct.r, ct.g, ct.b, cb.r, cb.g, cb.b)
				local CountColorString = E:RGBToHex(r, g, b)

				if QuestCount == "colorleft" then
					ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(
						format("[%s%s|r] %s", CountColorString, QuestCountText, HeaderTitel)
					)
				elseif QuestCount == "colorright" then
					ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(
						format("%s [%s%s|r]", HeaderTitel, CountColorString, QuestCountText)
					)
				end
			elseif QuestCount == "left" then
				ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(format("[%s] %s", QuestCountText, HeaderTitel))
			elseif QuestCount == "right" then
				ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(format("%s [%s]", HeaderTitel, QuestCountText))
			end
		end

		headdertext:SetFont(mOTFont, E.db[mPlugin].mObjectiveTracker.header.fontsize, mOTFontFlag)
		headdertext:SetTextColor(c.r, c.g, c.b)

		if E.db[mPlugin].mObjectiveTracker.header.textshadow then
			headdertext:SetShadowColor(0, 0, 0, 1)
			headdertext:SetShadowOffset(1, -1)
		else
			headdertext:SetShadowColor(0, 0, 0, 0)
			headdertext.SetShadowColor = function() end
		end

		headdertext:SetWordWrap(headdertext)

		local TextHight = headdertext:GetStringHeight()
		if headdertext:GetHeight() ~= TextHight then
			headdertext:SetHeight(TextHight)
		end
	end
end

local function mSetupTitleFont(titletext)
	if titletext then
		mGetFont()
		if E.db[mPlugin].mObjectiveTracker.title.fontcolorstyle == "class" then
			c = { r = mClassColor[1], g = mClassColor[2], b = mClassColor[3] }
		else
			c = E.db[mPlugin].mObjectiveTracker.title.fontcolor
		end
		titletext:SetFont(mOTFont, E.db[mPlugin].mObjectiveTracker.title.fontsize, mOTFontFlag)
		titletext:SetTextColor(c.r, c.g, c.b)

		if E.db[mPlugin].mObjectiveTracker.title.textshadow then
			titletext:SetShadowColor(0, 0, 0, 1)
			titletext:SetShadowOffset(1, -1)
		else
			titletext:SetShadowColor(0, 0, 0, 0)
			titletext.SetShadowColor = function() end
		end

		titletext:SetWordWrap(titletext)

		local TextHight = titletext:GetStringHeight()
		if titletext:GetHeight() ~= TextHight then
			titletext:SetHeight(TextHight)
		end
	end
end

local function mSetupQuestFont(linetext, state)
	if linetext then
		mGetFont()
		if E.db[mPlugin].mObjectiveTracker.text.fontcolorstyle == "class" then
			c = { r = mClassColor[1], g = mClassColor[2], b = mClassColor[3] }
		elseif state == "COMPLETED" then
			c = E.db[mPlugin].mObjectiveTracker.text.completecolor
		else
			c = E.db[mPlugin].mObjectiveTracker.text.fontcolor
		end
		linetext:SetFont(mOTFont, E.db[mPlugin].mObjectiveTracker.text.fontsize, mOTFontFlag)

		linetext:SetTextColor(c.r, c.g, c.b)

		if E.db[mPlugin].mObjectiveTracker.text.textshadow then
			linetext:SetShadowColor(0, 0, 0, 1)
			linetext:SetShadowOffset(1, -1)
		else
			linetext:SetShadowColor(0, 0, 0, 0)
			linetext.SetShadowColor = function() end
		end

		linetext:SetWordWrap(linetext)
		local TextHight = linetext:GetStringHeight()
		if linetext:GetHeight() ~= TextHight then
			linetext:SetHeight(TextHight)
		end
	end
end

local function mCreatBar(modul)
	local BarStyle, BarColorStyle, BarColor, BarShadow, BarGardient, BarGardientReverse, mEltreumUI =
		"none", "class", { r = 1, g = 1, b = 1 }, true, true, false, false
	BarStyle = E.db[mPlugin].mObjectiveTracker.header.barstyle
	BarColor = E.db[mPlugin].mObjectiveTracker.header.barcolor
	BarColorStyle = E.db[mPlugin].mObjectiveTracker.header.barcolorstyle
	BarShadow = E.db[mPlugin].mObjectiveTracker.header.barshadow
	BarGardient = E.db[mPlugin].mObjectiveTracker.header.gradient
	BarGardientReverse = E.db[mPlugin].mObjectiveTracker.header.reverse

	if (BarStyle == "one") or (BarStyle == "two") or (BarStyle == "onebig") or (BarStyle == "twobig") then
		if BarColorStyle == "class" then
			BarColor = { r = mClassColor[1], g = mClassColor[2], b = mClassColor[3] }
		end
		local BarTexture = LSM:Fetch("statusbar", E.db[mPlugin].mObjectiveTracker.header.texture)

		local mBarOne = CreateFrame("StatusBar", nil, modul)
		mBarOne:SetFrameStrata("BACKGROUND")
		if (BarStyle == "onebig") or (BarStyle == "twobig") then
			mBarOne:SetSize(width, 5)
		else
			mBarOne:SetSize(width, 1)
		end
		mBarOne:SetPoint("BOTTOM", 0, 0)
		mBarOne:SetStatusBarTexture(BarTexture)
		mBarOne:SetStatusBarColor(BarColor.r, BarColor.g, BarColor.b)
		mBarOne:CreateBackdrop()

		if BarGardient then
			mSetGradient(
				mBarOne,
				BarGardientReverse,
				"HORIZONTAL",
				BarColor.r,
				BarColor.g,
				BarColor.b,
				BarColor.r,
				BarColor.g,
				BarColor.b
			)
		end

		if BarShadow then
			mBarOne:CreateShadow()
		end

		if (BarStyle == "two") or (BarStyle == "twobig") then
			local mBarTwo = CreateFrame("StatusBar", nil, modul)
			mBarTwo:SetFrameStrata("BACKGROUND")
			if BarStyle == "twobig" then
				mBarTwo:SetSize(width, 5)
			else
				mBarTwo:SetSize(width, 1)
			end
			mBarTwo:SetPoint("TOP", 0, 0)
			mBarTwo:SetStatusBarTexture(BarTexture)
			mBarTwo:SetStatusBarColor(BarColor.r, BarColor.g, BarColor.b)
			mBarTwo:CreateBackdrop()

			if BarGardient then
				mSetGradient(
					mBarTwo,
					BarGardientReverse,
					"HORIZONTAL",
					BarColor.r,
					BarColor.g,
					BarColor.b,
					BarColor.r,
					BarColor.g,
					BarColor.b
				)
			end

			if BarShadow then
				mBarTwo:CreateShadow()
			end
		end
	end
end

local function SkinQuestText(text)
	local QuestCount = E.db[mPlugin].mObjectiveTracker.header.questcount
	if QuestCount ~= "none" then
		local _, numQuests = C_QuestLog.GetNumQuestLogEntries()
		local QuestCountText = format("%s/%s", numQuests, maxNumQuestsCanAccept)

		if (QuestCount == "colorleft") or (QuestCount == "colorright") then
			local cg = E.db[mPlugin].mObjectiveTracker.text.progresscolorgood
			local ct = E.db[mPlugin].mObjectiveTracker.text.progresscolortransit
			local cb = E.db[mPlugin].mObjectiveTracker.text.progresscolorbad
			local tmpPercent = mMT:round((tonumber(numQuests) / tonumber(maxNumQuestsCanAccept)) * 100 or 0)
			local r, g, b = E:ColorGradient(tmpPercent * 0.01, cg.r, cg.g, cg.b, ct.r, ct.g, ct.b, cb.r, cb.g, cb.b)
			local CountColorString = E:RGBToHex(r, g, b)

			if QuestCount == "colorleft" then
				ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(
					format("[%s%s|r] %s", CountColorString, QuestCountText, HeaderTitel)
				)
			elseif QuestCount == "colorright" then
				ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(
					format("%s [%s%s|r]", HeaderTitel, CountColorString, QuestCountText)
				)
			end
		elseif QuestCount == "left" then
			ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(format("[%s] %s", QuestCountText, HeaderTitel))
		elseif QuestCount == "right" then
			ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(format("%s [%s]", HeaderTitel, QuestCountText))
		end
	end

	local current, required, details = strmatch(text, "^(%d-)/(%d-) (.+)")
	if (current == nil) or (required == nil) or (details == nil) then
		details, current, required = strmatch(text, "(.+): (%d-)/(%d-)$")
	end

	if (current == nil) or (required == nil) or (details == nil) then
		return
	end

	if (current ~= nil) or (required ~= nil) or (details ~= nil) then
		local tmpPercent = mMT:round((tonumber(current) / tonumber(required)) * 100 or 0)

		if E.db[mPlugin].mObjectiveTracker.text.progresscolor then
			local cg = E.db[mPlugin].mObjectiveTracker.text.progresscolorgood
			local ct = E.db[mPlugin].mObjectiveTracker.text.progresscolortransit
			local cb = E.db[mPlugin].mObjectiveTracker.text.progresscolorbad
			local r, g, b = E:ColorGradient(tmpPercent * 0.01, cb.r, cb.g, cb.b, ct.r, ct.g, ct.b, cg.r, cg.g, cg.b)
			local ColorString = E:RGBToHex(r, g, b)

			if
				E.db[mPlugin].mObjectiveTracker.text.progresscolor
				and E.db[mPlugin].mObjectiveTracker.text.progrespercent
				and (tonumber(required) >= 2)
			then
				if E.db[mPlugin].mObjectiveTracker.text.cleantext then
					return format(
						"%s%s/%s|r - %s%s|r %s",
						ColorString,
						current,
						required,
						ColorString,
						tmpPercent .. "%",
						details
					)
				else
					return format(
						"%s%s/%s|r - %s%s|r %s",
						ColorString,
						current,
						required,
						ColorString,
						tmpPercent .. "%",
						details
					)
				end
			else
				if E.db[mPlugin].mObjectiveTracker.text.cleantext then
					return format("%s%s/%s|r %s", ColorString, current, required, details)
				else
					return format("[%s%s/%s|r] %s", ColorString, current, required, details)
				end
			end
		else
			if E.db[mPlugin].mObjectiveTracker.text.progrespercent and (tonumber(required) >= 2) then
				if E.db[mPlugin].mObjectiveTracker.text.cleantext then
					return format("%s/%s - %s %s", current, required, tmpPercent .. "%", details)
				else
					return format("[%s/%s] - %s %s", current, required, tmpPercent .. "%", details)
				end
			else
				if E.db[mPlugin].mObjectiveTracker.text.cleantext then
					return format("%s/%s %s", current, required, details)
				else
					return format("[%s/%s] %s", current, required, details)
				end
			end
		end
	else
		return text
	end
end

local function SkinOBTScenario(numCriteria, objectiveBlock)
	if _G.ScenarioObjectiveBlock then
		local childs = { _G.ScenarioObjectiveBlock:GetChildren() }
		for _, child in pairs(childs) do
			if child.Text then
				mSetupQuestFont(child.Text)
			end
		end
	end
end

local function SkinOBTText(_, line)
	if line then
		if line.HeaderText then
			mSetupTitleFont(line.HeaderText)
		end

		if line.currentLine then
			if line.currentLine.objectiveKey == 0 then
				mSetupTitleFont(line.currentLine.Text)
			else
				local DashStyle = E.db[mPlugin].mObjectiveTracker.dash.style
				if line.currentLine.Dash then
					if DashStyle ~= "blizzard" then
						if DashStyle == "custom" then
							line.currentLine.Dash:SetText(E.db[mPlugin].mObjectiveTracker.dash.customstring)
						elseif DashStyle == "icon" then
							line.currentLine.Dash:SetText(
								mDashIcon(mIconsList[E.db[mPlugin].mObjectiveTracker.dash.texture].file)
							)
						else
							line.currentLine.Dash:Hide()
							line.currentLine.Text:ClearAllPoints()
							line.currentLine.Text:Point("TOPLEFT", line.currentLine.Dash, "TOPLEFT", 0, 0)
						end
					end
				end

				local CheckTexture = "Interface\\AddOns\\ElvUI_mMediaTag\\media\\misc\\check.tga"
				local CheckColor = E.db[mPlugin].mObjectiveTracker.text.completecolor

				if line.currentLine.Check then
					if DashStyle == "none" then
						line.currentLine.Check:ClearAllPoints()
						line.currentLine.Check:Point("TOPRIGHT", line.currentLine.Dash, "TOPLEFT", 0, 0)
					end
					line.currentLine.Check:SetTexture(CheckTexture)
					line.currentLine.Check:SetVertexColor(CheckColor.r, CheckColor.g, CheckColor.b, 1)
				end

				if line.currentLine.Text then
					local LineText = line.currentLine.Text:GetText()

					if LineText ~= nil then
						LineText = SkinQuestText(LineText)
						if LineText ~= nil then
							line.currentLine.Text:SetText(LineText)
						end
					end
					mSetupQuestFont(line.currentLine.Text, line.currentLine.state)
				end
			end
		end
	end
end

local function SkinOBT()
	local Frame = ObjectiveTrackerFrame.MODULES
	if Frame then
		for i = 1, #Frame do
			local Modules = Frame[i]
			if Modules then
				mSetupHeaderFont(Modules.Header.Text)
				if not Modules.IsSkinned then
					if E.db[mPlugin].mObjectiveTracker.header.barstyle ~= "none" then
						mCreatBar(Modules.Header)
					end
					hooksecurefunc(Modules, "AddObjective", SkinOBTText)
					Modules.IsSkinned = true
				end
			end
		end
	end
end

local function mOBTFontColors()
	local mQuestFontColor = E.db[mPlugin].mObjectiveTracker.text.fontcolor
	local mQuestCompleteFontColor = E.db[mPlugin].mObjectiveTracker.text.completecolor
	local mQuestFailedFontColor = E.db[mPlugin].mObjectiveTracker.text.failedcolor
	local mTitelFontColor = E.db[mPlugin].mObjectiveTracker.title.fontcolor

	if E.db[mPlugin].mObjectiveTracker.text.fontcolorstyle == "class" then
		mQuestFontColor = { r = mClassColor[1], g = mClassColor[2], b = mClassColor[3] }
	end

	if E.db[mPlugin].mObjectiveTracker.title.fontcolorstyle == "class" then
		mTitelFontColor = { r = mClassColor[1], g = mClassColor[2], b = mClassColor[3] }
	end

	OBJECTIVE_TRACKER_COLOR = {
		["Normal"] = { r = mQuestFontColor.r, g = mQuestFontColor.g, b = mQuestFontColor.b },
		["NormalHighlight"] = { r = mQuestFontColor.r + 0.2, g = mQuestFontColor.g + 0.2, b = mQuestFontColor.b + 0.2 },
		["Failed"] = { r = mQuestFailedFontColor.r, g = mQuestFailedFontColor.g, b = mQuestFailedFontColor.b },
		["FailedHighlight"] = {
			r = mQuestFailedFontColor.r + 0.2,
			g = mQuestFailedFontColor.g + 0.2,
			b = mQuestFailedFontColor.b + 0.2,
		},
		["Header"] = { r = mTitelFontColor.r, g = mTitelFontColor.g, b = mTitelFontColor.b },
		["HeaderHighlight"] = { r = mTitelFontColor.r + 0.2, g = mTitelFontColor.g + 0.2, b = mTitelFontColor.b + 0.2 },
		["Complete"] = { r = mQuestCompleteFontColor.r, g = mQuestCompleteFontColor.g, b = mQuestCompleteFontColor.b },
		["TimeLeft"] = { r = DIM_RED_FONT_COLOR.r, g = DIM_RED_FONT_COLOR.g, b = DIM_RED_FONT_COLOR.b },
		["TimeLeftHighlight"] = { r = RED_FONT_COLOR.r, g = RED_FONT_COLOR.g, b = RED_FONT_COLOR.b },
	}
	OBJECTIVE_TRACKER_COLOR["Normal"].reverse = OBJECTIVE_TRACKER_COLOR["NormalHighlight"]
	OBJECTIVE_TRACKER_COLOR["NormalHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["Normal"]
	OBJECTIVE_TRACKER_COLOR["Failed"].reverse = OBJECTIVE_TRACKER_COLOR["FailedHighlight"]
	OBJECTIVE_TRACKER_COLOR["FailedHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["Failed"]
	OBJECTIVE_TRACKER_COLOR["Header"].reverse = OBJECTIVE_TRACKER_COLOR["HeaderHighlight"]
	OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["Header"]
	OBJECTIVE_TRACKER_COLOR["TimeLeft"].reverse = OBJECTIVE_TRACKER_COLOR["TimeLeftHighlight"]
	OBJECTIVE_TRACKER_COLOR["TimeLeftHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["TimeLeft"]
	OBJECTIVE_TRACKER_COLOR["Complete"] = OBJECTIVE_TRACKER_COLOR["Complete"]
	OBJECTIVE_TRACKER_COLOR["CompleteHighlight"] = OBJECTIVE_TRACKER_COLOR["Complete"]
end

local function mObjectiveTrackerOptions()
	E.Options.args.mMediaTag.args.cosmetic.args.objectivetracker.args = {
		objectivetrackerenable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			desc = L["Enable ObjectiveTracker (Questwatch) Skin."],
			get = function(info)
				return E.db[mPlugin].mObjectiveTracker.enable
			end,
			set = function(info, value)
				E.db[mPlugin].mObjectiveTracker.enable = value
				if value == true and E.private.skins.blizzard.objectiveTracker == false then
					E.private.skins.blizzard.objectiveTracker = true
				end
				E:StaticPopup_Show("CONFIG_RL")
			end,
		},

		generalgroup = {
			order = 10,
			type = "group",
			name = L["Font"],
			disabled = function()
				return not E.db[mPlugin].mObjectiveTracker.enable
			end,
			args = {
				generalfont = {
					type = "select",
					dialogControl = "LSM30_Font",
					order = 1,
					name = L["Default Font"],
					values = LSM:HashTable("font"),
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.font
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.font = value
					end,
				},
				generalfontflag = {
					type = "select",
					order = 2,
					name = L["Font contour"],
					values = mFontFlags,
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.fontflag
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.fontflag = value
					end,
				},
			},
		},

		headergroup = {
			order = 20,
			type = "group",
			name = L["Header"],
			disabled = function()
				return not E.db[mPlugin].mObjectiveTracker.enable
			end,
			args = {
				headerfontsize = {
					order = 1,
					name = L["Font Size"],
					type = "range",
					min = 6,
					max = 64,
					step = 1,
					softMin = 8,
					softMax = 32,
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.header.fontsize
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.header.fontsize = value
					end,
				},
				headerfontcolorstyle = {
					order = 2,
					type = "select",
					name = L["Fontcolor Style"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.header.fontcolorstyle
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.header.fontcolorstyle = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						class = L["Class"],
						custom = L["Custom"],
					},
				},
				headerfontcolor = {
					type = "color",
					order = 3,
					name = L["Fontcolor"],
					hasAlpha = false,
					disabled = function()
						return (E.db[mPlugin].mObjectiveTracker.header.fontcolorstyle == "class")
					end,
					get = function(info)
						local t = E.db[mPlugin].mObjectiveTracker.header.fontcolor
						return t.r, t.g, t.b
					end,
					set = function(info, r, g, b)
						local t = E.db[mPlugin].mObjectiveTracker.header.fontcolor
						t.r, t.g, t.b = r, g, b
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				headerfontshadow = {
					order = 4,
					type = "toggle",
					name = L["Font shadow"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.header.textshadow
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.header.textshadow = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				headerheader1 = {
					order = 5,
					type = "header",
					name = L[""],
				},
				headerbarstyle = {
					order = 6,
					type = "select",
					name = L["Bar Style"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.header.barstyle
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.header.barstyle = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						one = L["One"],
						two = L["Two"],
						onebig = L["One big"],
						twobig = L["Two big"],
						none = L["None"],
					},
				},
				headerbarcolorstyle = {
					order = 7,
					type = "select",
					name = L["Barcolor Style"],
					disabled = function()
						return (E.db[mPlugin].mObjectiveTracker.header.barstyle == "none")
					end,
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.header.barcolorstyle
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.header.barcolorstyle = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						class = L["Class"],
						custom = L["Custom"],
					},
				},
				headerbarcolor = {
					type = "color",
					order = 8,
					name = L["Barcolor"],
					hasAlpha = false,
					disabled = function()
						return (E.db[mPlugin].mObjectiveTracker.header.barcolorstyle == "class")
					end,
					get = function(info)
						local t = E.db[mPlugin].mObjectiveTracker.header.barcolor
						return t.r, t.g, t.b
					end,
					set = function(info, r, g, b)
						local t = E.db[mPlugin].mObjectiveTracker.header.barcolor
						t.r, t.g, t.b = r, g, b
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				headerbarshadow = {
					order = 9,
					type = "toggle",
					name = L["Bar Shadow"],
					disabled = function()
						return (E.db[mPlugin].mObjectiveTracker.header.barstyle == "none")
					end,
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.header.barshadow
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.header.barshadow = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				headerbargardient = {
					order = 10,
					type = "toggle",
					name = L["Bar Gardient"],
					disabled = function()
						return (E.db[mPlugin].mObjectiveTracker.header.barstyle == "none")
					end,
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.header.gradient
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.header.gradient = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				headerbargardientreverse = {
					order = 11,
					type = "toggle",
					name = L["Bar Gardient reverse"],
					disabled = function()
						return (E.db[mPlugin].mObjectiveTracker.header.barstyle == "none")
					end,
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.header.reverse
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.header.reverse = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				headerbartexture = {
					order = 12,
					type = "select",
					dialogControl = "LSM30_Statusbar",
					name = L["Bar Texture"],
					values = LSM:HashTable("statusbar"),
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.header.texture
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.header.texture = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				headerheader2 = {
					order = 14,
					type = "header",
					name = L[""],
				},
				headerquestamount = {
					order = 15,
					type = "select",
					name = L["Show Quest Amount"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.header.questcount
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.header.questcount = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						none = L["None"],
						left = L["left"],
						right = L["right"],
						colorleft = L["Colorful left"],
						colorright = L["Colorful right"],
					},
				},
			},
		},

		titlegroup = {
			order = 30,
			type = "group",
			name = L["Title"],
			disabled = function()
				return not E.db[mPlugin].mObjectiveTracker.enable
			end,
			args = {
				titlefontsize = {
					order = 1,
					name = L["Font Size"],
					type = "range",
					min = 6,
					max = 64,
					step = 1,
					softMin = 8,
					softMax = 32,
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.title.fontsize
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.title.fontsize = value
					end,
				},
				titlefontcolorstyle = {
					order = 2,
					type = "select",
					name = L["Fontcolor Style"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.title.fontcolorstyle
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.title.fontcolorstyle = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						class = L["Class"],
						custom = L["Custom"],
					},
				},
				titlefontcolor = {
					type = "color",
					order = 3,
					name = L["Fontcolor"],
					hasAlpha = false,
					disabled = function()
						return not E.db[mPlugin].mObjectiveTracker.title.fontcolorstyle == "class"
					end,
					get = function(info)
						local t = E.db[mPlugin].mObjectiveTracker.title.fontcolor
						return t.r, t.g, t.b
					end,
					set = function(info, r, g, b)
						local t = E.db[mPlugin].mObjectiveTracker.title.fontcolor
						t.r, t.g, t.b = r, g, b
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				titlefontshadow = {
					order = 4,
					type = "toggle",
					name = L["Font shadow"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.title.textshadow
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.title.textshadow = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
			},
		},

		textgroup = {
			order = 40,
			type = "group",
			name = L["Quest Text"],
			disabled = function()
				return not E.db[mPlugin].mObjectiveTracker.enable
			end,
			args = {
				textfontsize = {
					order = 1,
					name = L["Font Size"],
					type = "range",
					min = 6,
					max = 64,
					step = 1,
					softMin = 8,
					softMax = 32,
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.text.fontsize
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.text.fontsize = value
					end,
				},
				textfontcolorstyle = {
					order = 2,
					type = "select",
					name = L["Fontcolor Style"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.text.fontcolorstyle
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.text.fontcolorstyle = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						class = L["Class"],
						custom = L["Custom"],
					},
				},
				textfontcolor = {
					type = "color",
					order = 3,
					name = L["Fontcolor"],
					hasAlpha = false,
					disabled = function()
						return not E.db[mPlugin].mObjectiveTracker.text.fontcolorstyle == "class"
					end,
					get = function(info)
						local t = E.db[mPlugin].mObjectiveTracker.text.fontcolor
						return t.r, t.g, t.b
					end,
					set = function(info, r, g, b)
						local t = E.db[mPlugin].mObjectiveTracker.text.fontcolor
						t.r, t.g, t.b = r, g, b
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textfontshadow = {
					order = 4,
					type = "toggle",
					name = L["Font shadow"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.text.textshadow
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.text.textshadow = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textheader1 = {
					order = 5,
					type = "header",
					name = L[""],
				},
				textfontcolorcomplete = {
					type = "color",
					order = 6,
					name = L["Complete Fontcolor"],
					hasAlpha = false,
					get = function(info)
						local t = E.db[mPlugin].mObjectiveTracker.text.completecolor
						return t.r, t.g, t.b
					end,
					set = function(info, r, g, b)
						local t = E.db[mPlugin].mObjectiveTracker.text.completecolor
						t.r, t.g, t.b = r, g, b
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textfontcolorfailed = {
					type = "color",
					order = 7,
					name = L["Failed Fontcolor"],
					hasAlpha = false,
					get = function(info)
						local t = E.db[mPlugin].mObjectiveTracker.text.failedcolor
						return t.r, t.g, t.b
					end,
					set = function(info, r, g, b)
						local t = E.db[mPlugin].mObjectiveTracker.text.failedcolor
						t.r, t.g, t.b = r, g, b
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textprogresscolorgood = {
					type = "color",
					order = 8,
					name = L["God color"],
					hasAlpha = false,
					disabled = function()
						return not E.db[mPlugin].mObjectiveTracker.text.progresscolor
					end,
					get = function(info)
						local t = E.db[mPlugin].mObjectiveTracker.text.progresscolorgood
						return t.r, t.g, t.b
					end,
					set = function(info, r, g, b)
						local t = E.db[mPlugin].mObjectiveTracker.text.progresscolorgood
						t.r, t.g, t.b = r, g, b
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textprogresscolortransit = {
					type = "color",
					order = 9,
					name = L["Transit color"],
					hasAlpha = false,
					disabled = function()
						return not E.db[mPlugin].mObjectiveTracker.text.progresscolor
					end,
					get = function(info)
						local t = E.db[mPlugin].mObjectiveTracker.text.progresscolortransit
						return t.r, t.g, t.b
					end,
					set = function(info, r, g, b)
						local t = E.db[mPlugin].mObjectiveTracker.text.progresscolortransit
						t.r, t.g, t.b = r, g, b
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textprogresscolorbad = {
					type = "color",
					order = 10,
					name = L["Bad color"],
					hasAlpha = false,
					disabled = function()
						return not E.db[mPlugin].mObjectiveTracker.text.progresscolor
					end,
					get = function(info)
						local t = E.db[mPlugin].mObjectiveTracker.text.progresscolorbad
						return t.r, t.g, t.b
					end,
					set = function(info, r, g, b)
						local t = E.db[mPlugin].mObjectiveTracker.text.progresscolorbad
						t.r, t.g, t.b = r, g, b
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textheader2 = {
					order = 11,
					type = "header",
					name = L[""],
				},
				textprogresspercent = {
					order = 12,
					type = "toggle",
					name = L["Progress in percent"],
					desc = L["Show Progress in percent"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.text.progrespercent
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.text.progrespercent = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textprogresscolor = {
					order = 13,
					type = "toggle",
					name = L["Colorful Progress"],
					desc = L["Colorful Progress"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.text.progresscolor
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.text.progresscolor = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textonlyprogresstext = {
					order = 14,
					type = "toggle",
					name = L["Clean Text"],
					desc = L["Shows the Text without []"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.text.cleantext
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.text.cleantext = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textbargardient = {
					order = 15,
					type = "toggle",
					name = L["Bar Gardient"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.text.gradient
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.text.gradient = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
				textbargardientreverse = {
					order = 16,
					type = "toggle",
					name = L["Bar Gardient reverse"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.text.reverse
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.text.reverse = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
			},
		},

		dashgroup = {
			order = 50,
			type = "group",
			name = L["Dash"],
			disabled = function()
				return not E.db[mPlugin].mObjectiveTracker.enable
			end,
			args = {
				dashstyle = {
					order = 1,
					type = "select",
					name = L["Dash Style"],
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.dash.style
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.dash.style = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						blizzard = L["Blizzard"],
						icon = L["Icon"],
						custom = L["Custom"],
						none = L["None"],
					},
				},
				dashtexture = {
					order = 2,
					type = "select",
					name = L["Icon"],
					disabled = function()
						return not (E.db[mPlugin].mObjectiveTracker.dash.style == "icon")
					end,
					get = function(info)
						return E.db[mPlugin].mObjectiveTracker.dash.texture
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.dash.texture = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = mTextureList(),
				},
				dashcustom = {
					order = 3,
					name = L["Custom Dash Symbol"],
					desc = L["Custom Dash Symbol, enter any character you want."],
					type = "input",
					width = "smal",
					disabled = function()
						return not (E.db[mPlugin].mObjectiveTracker.dash.style == "custom")
					end,
					get = function()
						return E.db[mPlugin].mObjectiveTracker.dash.customstring
					end,
					set = function(info, value)
						E.db[mPlugin].mObjectiveTracker.dash.customstring = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
				},
			},
		},
	}
end

function mMT:InitializemOBT()
	if E.db[mPlugin].mObjectiveTracker.enable == true then
		mOBTFontColors()

		hooksecurefunc(_G.QUEST_TRACKER_MODULE, "SetBlockHeader", SkinOBT)
		hooksecurefunc("ObjectiveTracker_Update", SkinOBT)
		hooksecurefunc(_G.SCENARIO_CONTENT_TRACKER_MODULE, "UpdateCriteria", SkinOBTScenario)

		-- hooksecurefunc('ObjectiveTracker_Expand',TrackerStateChanged)
		-- hooksecurefunc('ObjectiveTracker_Collapse',TrackerStateChanged)
		-- hooksecurefunc('QuestObjectiveSetupBlockButton_Item', HandleItemButton)
		-- hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE, "AddObjective", HandleItemButton)
		-- hooksecurefunc('BonusObjectiveTrackerProgressBar_SetValue',ColorProgressBars)			--[Color]: Bonus Objective Progress Bar
		-- hooksecurefunc('ObjectiveTrackerProgressBar_SetValue',ColorProgressBars)				--[Color]: Quest Progress Bar
		-- hooksecurefunc('ScenarioTrackerProgressBar_SetValue',ColorProgressBars)					--[Color]: Scenario Progress Bar
		-- hooksecurefunc('QuestObjectiveSetupBlockButton_AddRightButton',PositionFindGroupButton)	--[Move]: The eye & quest item to the left of the eye
		-- hooksecurefunc('ObjectiveTracker_CheckAndHideHeader',SkinOjectiveTrackerHeaders)		--[Skin]: Module Headers
		-- hooksecurefunc('QuestObjectiveSetupBlockButton_FindGroup',SkinFindGroupButton)			--[Skin]: The eye
		-- hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE,'AddProgressBar',SkinProgressBars)		--[Skin]: Bonus Objective Progress Bar
		-- hooksecurefunc(_G.WORLD_QUEST_TRACKER_MODULE,'AddProgressBar',SkinProgressBars)			--[Skin]: World Quest Progress Bar
		-- hooksecurefunc(_G.DEFAULT_OBJECTIVE_TRACKER_MODULE,'AddProgressBar',SkinProgressBars)	--[Skin]: Quest Progress Bar
		-- hooksecurefunc(_G.SCENARIO_TRACKER_MODULE,'AddProgressBar',SkinProgressBars)			--[Skin]: Scenario Progress Bar
		-- hooksecurefunc(_G.CAMPAIGN_QUEST_TRACKER_MODULE,'AddProgressBar',SkinProgressBars)		--[Skin]: Campaign Progress Bar
		-- hooksecurefunc(_G.QUEST_TRACKER_MODULE,'AddProgressBar',SkinProgressBars)				--[Skin]: Quest Progress Bar
		-- hooksecurefunc(_G.QUEST_TRACKER_MODULE,'AddTimerBar',SkinTimerBars)						--[Skin]: Quest Timer Bar
		-- hooksecurefunc(_G.SCENARIO_TRACKER_MODULE,'AddTimerBar',SkinTimerBars)					--[Skin]: Scenario Timer Bar
		-- hooksecurefunc(_G.ACHIEVEMENT_TRACKER_MODULE,'AddTimerBar',SkinTimerBars)				--[Skin]: Achievement Timer Bar
		if E.db[mPlugin].mObjectiveTracker.text.gradient then
			hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue", mGardientProgressBars) --[Color]: Bonus Objective Progress Bar
			hooksecurefunc("ObjectiveTrackerProgressBar_SetValue", mGardientProgressBars) --[Color]: Quest Progress Bar
			hooksecurefunc("ScenarioTrackerProgressBar_SetValue", mGardientProgressBars)
		end
	end
end

table.insert(ns.Config, mObjectiveTrackerOptions)
