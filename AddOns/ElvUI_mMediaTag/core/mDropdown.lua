local E, L, V, P, G = unpack(ElvUI)
local mPlugin = "mMediaTag"
local mMT = E:GetModule(mPlugin)
local LSM = E.Libs.LSM
local addon, ns = ...

--Lua functions
local tinsert = tinsert
local format = format

--WoW API / Variables
local _G = _G
local GetCursorPosition = GetCursorPosition
local InCombatLockdown = InCombatLockdown
local UnitClass = UnitClass

-- ElvUI
local ElvUF = ElvUF

--Variables
local autoHideDelay = 2
local PADDING = 10
local BUTTON_HEIGHT = 16
local mFrame = {}

function mMT:DropdownTimer()
	mFrame:Hide()
end

local function OnClick(btn)
	btn.func()
	btn:GetParent():Hide()
	mMT:CancelAllTimers(mFrame.mTimer)
end

local function OnEnter(btn)
	btn.hoverTex:Show()
	mMT:CancelAllTimers(mFrame.mTimer)
end

local function OnLeave(btn)
	btn.hoverTex:Hide()
	mFrame.mTimer = mMT:ScheduleTimer("DropdownTimer", autoHideDelay)
end

function mMT:mDropDown(list, frame, self, ButtonWidth, HideDelay)
	if HideDelay ~= nil then
		autoHideDelay = HideDelay
	end

	mMT:CancelAllTimers(mFrame.mTimer)

	if not frame.buttons then
		frame.buttons = {}
		frame:SetFrameStrata("DIALOG")
		frame:SetClampedToScreen(true)
		tinsert(_G.UISpecialFrames, frame:GetName())
		frame:Hide()
	end

	for i = 1, #frame.buttons do
		frame.buttons[i]:Hide()
	end

	for i = 1, #list do
		if not frame.buttons[i] then
			frame.buttons[i] = CreateFrame("Button", nil, frame)
			local texture = LSM:Fetch("statusbar", E.db[mPlugin].mHoverTexture)
			if texture == nil then
				texture = [[Interface\QuestFrame\UI-QuestTitleHighlight]]
			end

			if list[i].isTitle == true then
				frame.buttons[i].hoverTex = frame.buttons[i]:CreateTexture(nil, "OVERLAY")
				frame.buttons[i].hoverTex:SetAllPoints()
				frame.buttons[i].hoverTex:SetTexture(nil)
				frame.buttons[i].hoverTex:SetBlendMode("ADD")
				frame.buttons[i].hoverTex:Hide()
			else
				frame.buttons[i].hoverTex = frame.buttons[i]:CreateTexture(nil, "OVERLAY")
				frame.buttons[i].hoverTex:SetAllPoints()
				frame.buttons[i].hoverTex:SetTexture(texture)

				if E.db[mPlugin].mClassColorHover then
					local _, unitClass = UnitClass("player")
					local class = ElvUF.colors.class[unitClass]
					frame.buttons[i].hoverTex:SetGradientAlpha(
						"HORIZONTAL",
						class[1],
						class[2],
						class[3],
						class[1] - 0.4,
						class[2] - 0.4,
						class[3] - 0.4,
						0.5
					)
				else
					frame.buttons[i].hoverTex:SetGradientAlpha("HORIZONTAL", 0.94, 0.76, 0.05, 0.54, 0.36, 0, 0.5)
				end
				frame.buttons[i].hoverTex:SetBlendMode("ADD")
				frame.buttons[i].hoverTex:Hide()
			end

			frame.buttons[i].LeftText = frame.buttons[i]:CreateFontString(nil, "BORDER")
			frame.buttons[i].LeftText:SetAllPoints()
			frame.buttons[i].LeftText:FontTemplate(nil, nil, "")
			frame.buttons[i].LeftText:SetJustifyH("LEFT")

			frame.buttons[i].RightText = frame.buttons[i]:CreateFontString(nil, "BORDER")
			frame.buttons[i].RightText:SetAllPoints()
			frame.buttons[i].RightText:FontTemplate(nil, nil, "")
			frame.buttons[i].RightText:SetJustifyH("RIGHT")

			frame.buttons[i]:SetScript("OnEnter", OnEnter)
			frame.buttons[i]:SetScript("OnLeave", OnLeave)
		end

		frame.buttons[i]:Show()
		frame.buttons[i]:Height(BUTTON_HEIGHT)
		frame.buttons[i]:Width(ButtonWidth)

		frame.buttons[i].LeftText:SetText(list[i].lefttext or "")
		frame.buttons[i].RightText:SetText(list[i].righttext or "")

		frame.buttons[i].func = list[i].func
		frame.buttons[i]:SetScript("OnClick", OnClick)

		if i == 1 then
			frame.buttons[i]:Point("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING)
		else
			frame.buttons[i]:Point("TOPLEFT", frame.buttons[i - 1], "BOTTOMLEFT")
		end
	end

	frame:Height((#list * BUTTON_HEIGHT) + PADDING * 2)
	frame:Width(ButtonWidth + PADDING * 2)

	frame:ClearAllPoints()

	local point = E:GetScreenQuadrant(self)
	local bottom = point and strfind(point, "BOTTOM")
	local left = point and strfind(point, "LEFT")

	local anchor1 = (bottom and left and "BOTTOMLEFT")
		or (bottom and "BOTTOMRIGHT")
		or (left and "TOPLEFT")
		or "TOPRIGHT"
	local anchor2 = (bottom and left and "TOPLEFT")
		or (bottom and "TOPRIGHT")
		or (left and "BOTTOMLEFT")
		or "BOTTOMRIGHT"

	frame:Point(anchor1, self, anchor2)

	mFrame = frame

	if InCombatLockdown() then
		_G.UIErrorsFrame:AddMessage(format("%s%s|r", ns.mColor5, _G.ERR_NOT_IN_COMBAT))
		print(format("%s%s|r", ns.mColor5, _G.ERR_NOT_IN_COMBAT))
	else
		mFrame.mTimer = mMT:ScheduleTimer("DropdownTimer", autoHideDelay)
		ToggleFrame(frame)
	end
end
