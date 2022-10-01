local E, L, V, P, G = unpack(ElvUI)
local mPlugin = "mMediaTag"
local mMT = E:GetModule(mPlugin)
local NP = E:GetModule("NamePlates")
local UF = E:GetModule("UnitFrames")
local addon, ns = ...

local mInsert = table.insert
local GetSpecializationInfo = GetSpecializationInfo
local GetActiveSpecGroup = GetActiveSpecGroup
local GetSpellCooldown = GetSpellCooldown
local interruptSpellId = nil

_G.mMediaTag_interruptOnCD = false
_G.mMediaTag_interruptinTime = false

local interruptOnCD = _G.mMediaTag_interruptOnCD
local interruptinTime = _G.mMediaTag_interruptinTime

local interruptSpellList = {
	-- warrior
	[71] = 6552,
	[72] = 6552,
	[73] = 6552,
	-- paladin
	[65] = nil,
	[66] = 96231,
	[70] = 96231,
	--HUNTER
	[253] = 147362,
	[254] = 147362,
	[255] = 187707,
	--ROGUE"
	[259] = 1766,
	[260] = 1766,
	[261] = 1766,
	--PRIEST
	[256] = nil,
	[257] = nil,
	[258] = 15487,
	--DEATHKNIGHT
	[250] = 47528,
	[251] = 47528,
	[252] = 47528,
	--SHAMAN
	[262] = 57994,
	[263] = 57994,
	[264] = 57994,
	--MAGE
	[62] = 2139,
	[63] = 2139,
	[64] = 2139,
	--"WARLOCK
	[265] = 119910,
	[266] = 119914,
	[267] = 119910,
	--MONK
	[268] = 116705,
	[270] = nil,
	[269] = 116705,
	--DRUID
	[102] = 78675,
	[103] = 106839,
	[104] = 106839,
	[105] = nil,
	--DEMONHUNTER
	[577] = 183752,
	[581] = 183752,
}

function mMT:mUpdateKick()
	interruptSpellId = interruptSpellList[select(1, GetSpecializationInfo(GetSpecialization()))]
end

function mMT:mSetupCastbar()
	interruptSpellId = interruptSpellList[select(1, GetSpecializationInfo(GetSpecialization()))]
	local colorKickonCD = E.db[mPlugin].mCastbar.kickcd
	local colorKickinTime = E.db[mPlugin].mCastbar.kickintime

	if interruptSpellId then
		hooksecurefunc(NP, "Castbar_CheckInterrupt", function(unit)
			if unit.unit == "vehicle" or unit.unit == "player" then
				return
			end

			local interruptCD = nil
			local interruptReadyInTime = false

			if interruptSpellId then
				local cdStart, cdDur = GetSpellCooldown(interruptSpellId)
				local _, statusMax = unit:GetMinMaxValues()
				local value = unit:GetValue()
				interruptCD = (cdStart > 0 and cdDur - (GetTime() - cdStart)) or 0

				if unit.channeling then
					interruptReadyInTime = (interruptCD + 0.5) < value
				else
					interruptReadyInTime = (interruptCD + 0.5) < (statusMax - value)
				end

				if not unit.notInterruptible then
					if interruptCD > 0 and interruptReadyInTime then
						if E.db[mPlugin].mCastbar.gardient then
							unit:GetStatusBarTexture():SetGradient("HORIZONTAL", colorKickinTime.r, colorKickinTime.g, colorKickinTime.b, colorKickinTime.r2, colorKickinTime.g2, colorKickinTime.b2)
						else
							unit:SetStatusBarColor(colorKickinTime.r, colorKickinTime.g, colorKickinTime.b)
						end
						--unit:SetStatusBarColor(colorKickinTime.r, colorKickinTime.g, colorKickinTime.b)
					elseif interruptCD > 0 then
						if E.db[mPlugin].mCastbar.gardient then
							unit:GetStatusBarTexture():SetGradient("HORIZONTAL", colorKickonCD.r, colorKickonCD.g, colorKickonCD.b, colorKickonCD.r2, colorKickonCD.g2, colorKickonCD.b2)
						else
							unit:SetStatusBarColor(colorKickonCD.r, colorKickonCD.g, colorKickonCD.b)
						end
						--unit:SetStatusBarColor(colorKickonCD.r, colorKickonCD.g, colorKickonCD.b)
						--else
						--	unit:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)
					end


				end
			end
		end)

		hooksecurefunc(UF, "PostCastStart", function(unit)
			if unit.unit == "vehicle" or unit.unit == "player" then
				return
			end

			local db = unit:GetParent().db
			if not db or not db.castbar then
				return
			end

			local interruptCD = 0
			local interruptReadyInTime = false

			if interruptSpellId then
				local cdStart, cdDur = GetSpellCooldown(interruptSpellId)
				local _, statusMax = unit:GetMinMaxValues()
				local value = unit:GetValue()
				interruptCD = (cdStart > 0 and cdDur - (GetTime() - cdStart)) or 0

				if unit.channeling then
					interruptReadyInTime = (interruptCD + 0.5) < value
				else
					interruptReadyInTime = (interruptCD + 0.5) < (statusMax - value)
				end

				if not unit.notInterruptible then
					if interruptCD > 0 and interruptReadyInTime then
						if E.db[mPlugin].mCastbar.gardient then
							unit:GetStatusBarTexture():SetGradient("HORIZONTAL", colorKickinTime.r, colorKickinTime.g, colorKickinTime.b, colorKickinTime.r2, colorKickinTime.g2, colorKickinTime.b2)
						else
							unit:SetStatusBarColor(colorKickinTime.r, colorKickinTime.g, colorKickinTime.b)
						end
						--unit:SetStatusBarColor(colorKickinTime.r, colorKickinTime.g, colorKickinTime.b)
						interruptOnCD = true
					elseif interruptCD > 0 then
						if E.db[mPlugin].mCastbar.gardient then
							unit:GetStatusBarTexture():SetGradient("HORIZONTAL", colorKickonCD.r, colorKickonCD.g, colorKickonCD.b, colorKickonCD.r2, colorKickonCD.g2, colorKickonCD.b2)
						else
							unit:SetStatusBarColor(colorKickonCD.r, colorKickonCD.g, colorKickonCD.b)
						end
						--unit:SetStatusBarColor(colorKickonCD.r, colorKickonCD.g, colorKickonCD.b)
						interruptinTime = true
						--else
						--	unit:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b)
					else
						interruptinTime = false
						interruptOnCD = false
					end
				end
			end
		end)
	end
end

local function mCastbarOptions()
	E.Options.args.mMediaTag.args.cosmetic.args.castbar.args = {
		cosmetics = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			desc = L["Enable Interrupt on CD colors for Castbars"],
			get = function(info)
				return E.db[mPlugin].mCastbar.enable
			end,
			set = function(info, value)
				E.db[mPlugin].mCastbar.enable = value
				E:StaticPopup_Show("CONFIG_RL")
			end,
		},
		spacer = {
			order = 2,
			type = "description",
			name = "\n\n",
		},
		description = {
			order = 3,
			type = "description",
			name = L["Here you can set the color of the castbar when the own kick is on CD."],
		},
		spacer2 = {
			order = 4,
			type = "description",
			name = "\n\n",
		},
		gardient = {
			order = 1,
			type = "toggle",
			name = L["Enable gardient mode"],
			desc = L["Enable gardient mode"],
			get = function(info)
				return E.db[mPlugin].mCastbar.gardient
			end,
			set = function(info, value)
				E.db[mPlugin].mCastbar.gardient = value
			end,
		},
		colorkickcd = {
			type = "color",
			order = 11,
			name = L["Kick on CD"],
			hasAlpha = false,
			get = function(info)
				local t = E.db[mPlugin].mCastbar.kickcd
				return t.r, t.g, t.b
			end,
			set = function(info, r, g, b)
				local t = E.db[mPlugin].mCastbar.kickcd
				t.r, t.g, t.b = r, g, b
			end,
		},
		colorkickcd2 = {
			type = "color",
			order = 12,
			name = L["Kick on CD"],
			hasAlpha = false,
			disabled = function()
				return not E.db[mPlugin].mCastbar.gardient
			end,
			get = function(info)
				local t = E.db[mPlugin].mCastbar.kickcd
				return t.r2, t.g2, t.b2
			end,
			set = function(info, r, g, b)
				local t = E.db[mPlugin].mCastbar.kickcd
				t.r2, t.g2, t.b2 = r, g, b
			end,
		},
		spacer3 = {
			order = 13,
			type = "description",
			name = "\n\n",
		},
		colorkickintime = {
			type = "color",
			order = 14,
			name = L["Kick ready in Time"],
			hasAlpha = false,
			get = function(info)
				local t = E.db[mPlugin].mCastbar.kickintime
				return t.r, t.g, t.b
			end,
			set = function(info, r, g, b)
				local t = E.db[mPlugin].mCastbar.kickintime
				t.r, t.g, t.b = r, g, b
			end,
		},
		colorkickintime2 = {
			type = "color",
			order = 15,
			name = L["Kick ready in Time"],
			hasAlpha = false,
			disabled = function()
				return not E.db[mPlugin].mCastbar.gardient
			end,
			get = function(info)
				local t = E.db[mPlugin].mCastbar.kickintime
				return t.r2, t.g2, t.b2
			end,
			set = function(info, r, g, b)
				local t = E.db[mPlugin].mCastbar.kickintime
				t.r2, t.g2, t.b2 = r, g, b
			end,
		},
	}
end

mInsert(ns.Config, mCastbarOptions)
