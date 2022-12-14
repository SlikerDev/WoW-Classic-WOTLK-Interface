local E, L, V, P, G = unpack(ElvUI)
local mPlugin = "mMediaTag"
local mMT = E:GetModule(mPlugin)
local DT = E:GetModule("DataTexts")
local addon, ns = ...

--Lua functions
local format = format
local strjoin = strjoin

--WoW API / Variables
local _G = _G
local C_CurrencyInfo = C_CurrencyInfo

--Variables
local displayString, lastPanel = "", nil
local mText = format("mMediaTag %s", L["Stygian Ember"])
local mTextName = "mStygianEmber"
local mCurrencyID = 1977
local hideCurrency = false

local function OnEnter(self)
	if not hideCurrency then
		DT:SetupTooltip(self)
		DT.tooltip:SetHyperlink(mMT:mCurrencyLink(mCurrencyID))
		DT.tooltip:Show()
	end
end

local function OnEvent(self, event, ...)
	local info = C_CurrencyInfo.GetCurrencyInfo(mCurrencyID)
	local TextJustify = self.text:GetJustifyH()
	if info then
		local name = ""
		local CurrencValue = info.quantity

		if E.db[mPlugin].mStygianEmber.hide and CurrencValue == 0 then
			hideCurrency = true
		else
			hideCurrency = false
		end

		if not hideCurrency then
			if E.db[mPlugin].mStygianEmber.name then
				if TextJustify == "RIGHT" then
					name = " " .. info.name
				else
					name = info.name .. " "
				end
			end

			if E.db[mPlugin].mStygianEmber.icon then
				if TextJustify == "RIGHT" then
					name = format("%s %s", name, mMT:mIcon(info.iconFileID))
				else
					name = format("%s %s", mMT:mIcon(info.iconFileID), name)
				end
			end

			if E.db[mPlugin].mStygianEmber.short then
				CurrencValue = E:ShortValue(info.quantity, 2)
			end

			local CurrencyTextSring = displayString

			if E.db[mPlugin].mStygianEmber.style == "color" then
				if TextJustify == "RIGHT" then
					CurrencyTextSring = "|CFFAC0BFC%s|r%s"
				else
					CurrencyTextSring = "%s|CFFAC0BFC%s|r"
				end
			elseif E.db[mPlugin].mStygianEmber.style == "white" then
				CurrencyTextSring = "|CFFFFFFFF%s%s|r"
			end

			if TextJustify == "RIGHT" then
				self.text:SetFormattedText(CurrencyTextSring, CurrencValue, name ~= "" and name)
			else
				self.text:SetFormattedText(CurrencyTextSring, name ~= "" and name, CurrencValue)
			end
		end
	else
		self.text:SetText("|CFFE74C3CERROR!|r")
	end

	lastPanel = self
end

local function OnLeave(self)
	DT.tooltip:Hide()
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s", hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel, "ELVUI_COLOR_UPDATE")
	end
end

E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext(
	mTextName,
	_G.CURRENCY,
	{ "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE" },
	OnEvent,
	nil,
	nil,
	OnEnter,
	OnLeave,
	mText,
	ValueColorUpdate
)
