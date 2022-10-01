local E, L, V, P, G = unpack(ElvUI)
local mPlugin = "mMediaTag"
local mMT = E:GetModule(mPlugin)
local DT = E:GetModule("DataTexts")
local addon, ns = ...

--Lua functions
local format = format

--Variables
local mText = format("Dock %s", QUESTLOG_BUTTON)
local mTextName = "mQuest"

local function mDockCheckFrame()
	return (WorldMapFrame and WorldMapFrame:IsShown())
end

function mMT:CheckFrameQuest(self)
	self.mIcon.isClicked = mDockCheckFrame()
	mMT:DockTimer(self)
end

local function OnEnter(self)
	if E.db[mPlugin].mDock.tip.enable then
		DT.tooltip:AddLine(QUESTLOG_BUTTON)
		DT.tooltip:Show()
	end
	self.mIcon.isClicked = mDockCheckFrame()
	mMT:mOnEnter(self, "CheckFrameQuest")
end

local function OnEvent(self, event, ...)
	self.mSettings = {
		Name = mTextName,
		IconTexture = E.db[mPlugin].mDock.quest.path,
		Notifications = false,
		Text = false,
		Spezial = false,
	}

	mMT:DockInitialisation(self)
end

local function OnLeave(self)
	if E.db[mPlugin].mDock.tip.enable then
		DT.tooltip:Hide()
	end

	self.mIcon.isClicked = mDockCheckFrame()
	mMT:mOnLeave(self)
end

local function OnClick(self)
	if mMT:CheckCombatLockdown() then
		mMT:mOnClick(self, "CheckFrameQuest")
		ToggleQuestLog()
	end
end

DT:RegisterDatatext(mTextName, "mDock", nil, OnEvent, nil, OnClick, OnEnter, OnLeave, mText, nil, nil)
