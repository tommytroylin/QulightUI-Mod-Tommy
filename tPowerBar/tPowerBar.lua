local _G =_G

local addon, ns = ...
local config = ns.config
local powercolor = {}
local MyClass = select(2, UnitClass("player"))
local MyClassColor = RAID_CLASS_COLORS[MyClass]
for power, color in next, PowerBarColor do
	if (type(power) == "string") then
		if power == "MANA" then
			powercolor[power] = {0, 0.76, 1}
		elseif power ==  "FUEL" then
			powercolor[power] = {0, 0.55, 0.5}
		elseif  power ==  "FOCUS" then
			powercolor[power] = {.7,.45,.25}
		elseif  power ==  "RAGE" then
			powercolor[power] = {.7,.3,.3}
		else
			powercolor[power] = {color.r, color.g, color.b}
		end
	end
end
--TODO to change the W to k
local function ShortValue(v)
	if v >= 1e8 then
		return ("%.2fy"):format(v / 1e8):gsub("%.?0+([km])$", "%1")
	elseif v >= 1e4 or v <= -1e4 then
		return ("%.2fw"):format(v / 1e4):gsub("%.?0+([km])$", "%1")
	else
		return v
	end
end
function tPowerBar:PriestShadow()
	if MyClass ~= "PRIEST" then return end
	local ShadowOrbs = CreateFrame("Frame", nil, UIParent)
	ShadowOrbs:SetSize(config.width, config.height)
	ShadowOrbs:SetPoint(unpack(config.position))
	local maxShadowOrbs = UnitPowerMax('player', SPELL_POWER_SHADOW_ORBS)

	for i = 1,maxShadowOrbs do
		ShadowOrbs[i] = CreateFrame("StatusBar", nil, ShadowOrbs)
		ShadowOrbs[i]:SetSize((config.width-2*(maxShadowOrbs-1))/maxShadowOrbs, config.height)
		ShadowOrbs[i]:SetStatusBarTexture(config.tex)
		ShadowOrbs[i]:SetStatusBarColor(.86,.22,1)
		local s = ShadowOrbs[i]:GetStatusBarTexture()
		tPowerBar:CreateTop(s, .86,.22,1)
		tPowerBar:CreateShadow(ShadowOrbs[i])
		ShadowOrbs[i]:Hide()
		if (i == 1) then
			ShadowOrbs[i]:SetPoint("LEFT", ShadowOrbs, "LEFT")
		else
			ShadowOrbs[i]:SetPoint("LEFT", ShadowOrbs[i-1], "RIGHT", 2, 0)
		end
	end
	ShadowOrbs:RegisterEvent("PLAYER_ENTERING_WORLD")
	ShadowOrbs:RegisterEvent("UNIT_POWER")
	ShadowOrbs:RegisterEvent("UNIT_DISPLAYPOWER")
	ShadowOrbs:RegisterEvent("PLAYER_REGEN_ENABLED")
	ShadowOrbs:RegisterEvent("PLAYER_REGEN_DISABLED")
	ShadowOrbs:SetScript("OnEvent",function(self, event, unit)
		local numShadowOrbs = UnitPower('player', SPELL_POWER_SHADOW_ORBS)
		if unit == "player" then
			for i = 1,maxShadowOrbs do
				if i <= numShadowOrbs then
					ShadowOrbs[i]:Show()
				else
					ShadowOrbs[i]:Hide()
				end
			end
		end
		if config.fade then
			if event == "PLAYER_REGEN_DISABLED" then
				UIFrameFadeIn(ShadowOrbs, 1, ShadowOrbs:GetAlpha(), 1)
			end
			if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" then
				UIFrameFadeOut(ShadowOrbs, 1, ShadowOrbs:GetAlpha(), 0)
			end
		end
	end)
end

--Monk harmony bar

function tPowerBar:Monk()
	if MyClass ~= "MONK" then return end
	local chibar = CreateFrame("Frame",nil,UIParent)
	chibar:SetSize(config.width, config.height)
	chibar:SetPoint(unpack(config.position))
	for i=1,5 do
		chibar[i] = CreateFrame("StatusBar",nil,chibar)
		chibar[i]:SetSize((config.width-8)/5, config.height)
		chibar[i]:SetStatusBarTexture(config.tex)
		chibar[i]:SetStatusBarColor(0.0, 1.00 , 0.59)
		local s = chibar[i]:GetStatusBarTexture()
		tPowerBar:CreateTop(s, 0.0, 1.00 , 0.59)
		tPowerBar:CreateShadow(chibar[i])
		if i==1 then
			chibar[i]:SetPoint("LEFT", chibar, "LEFT")
		else
			chibar[i]:SetPoint("LEFT", chibar[i-1], "RIGHT", 2, 0)
		end
		chibar[i]:Hide()
	end
	chibar:RegisterEvent("PLAYER_ENTERING_WORLD")
	chibar:RegisterEvent("UNIT_POWER")
	chibar:RegisterEvent("UNIT_DISPLAYPOWER")
	chibar:RegisterEvent("PLAYER_REGEN_DISABLED")
	chibar:RegisterEvent("PLAYER_REGEN_ENABLED")
	chibar:SetScript("OnEvent",function(self, event, unit)
		local chinum = UnitPower("player",SPELL_POWER_CHI)
		local chimax = UnitPowerMax("player",SPELL_POWER_CHI)
		if unit == "player" then
			if chinum ~= chimax then
				if chimax == 4 then
					chibar[5]:Hide()
					for i = 1,4 do
						chibar[i]:SetWidth((config.width-6)/4)
					end
				elseif chimax == 5 then
					chibar[5]:Show()
					for i = 1,5 do
						chibar[i]:SetWidth((config.width-8)/5)
					end
				end
			end
			for i = 1,chimax do
				if i <= chinum then
					chibar[i]:Show()
				else
					chibar[i]:Hide()
				end
			end
		end
		if config.fade then
			if event == "PLAYER_REGEN_DISABLED" then
				UIFrameFadeIn(chibar, 1, chibar:GetAlpha(), 1)
			end
			if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" then
				UIFrameFadeOut(chibar, 1, chibar:GetAlpha(), 0)
			end
		end
	end)
end
--DK and PAL
local runes = {
	{1, 0, 0},   -- blood
	{0, .5, 0},  -- unholy
	{0, 1, 1},   -- frost
	{.9, .1, 1}, -- death
}
local runemap = { 1, 2, 5, 6, 3, 4 }
local OnUpdate = function(self, elapsed)
	local duration = self.duration + elapsed
	if(duration >= self.max) then
		return self:SetScript("OnUpdate", nil)
	else
		self.duration = duration
		return self:SetValue(duration)
	end
end
local UpdateType = function(self, rid, alt)
	local rune = self[runemap[rid]]
	local colors = runes[GetRuneType(rid) or alt]
	local r, g, b = colors[1], colors[2], colors[3]
	rune:SetStatusBarColor(r, g, b)
	local s = rune:GetStatusBarTexture()
	tPowerBar:CreateTop(s, r, g, b)
end
local function OnEvent(self, event, unit)
	if event == "RUNE_POWER_UPDATE" or "PLAYER_ENTERING_WORLD" then
		for i=1, 6 do
			local rune = self[runemap[i]]
			if(rune) then
				local start, duration, runeReady = GetRuneCooldown(i)
				if(runeReady) then
					rune:SetMinMaxValues(0, 1)
					rune:SetValue(1)
					rune:SetScript("OnUpdate", nil)
				else
					rune.duration = GetTime() - start
					rune.max = duration
					rune:SetMinMaxValues(1, duration)
					rune:SetScript("OnUpdate", OnUpdate)
				end
			end
		end
	end
	if event == "RUNE_TYPE_UPDATE" then
		for i=1, 6 do
			UpdateType(self, i, math.floor((runemap[i]+1)/2))
		end
	end
	if config.fade then
		if event == "PLAYER_REGEN_DISABLED" then
			UIFrameFadeIn(self, 1, self:GetAlpha(), 1)
		end
		if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" then
			UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
		end
	end
end
function tPowerBar:PaladinDeathKnight()
	if  MyClass ~= "PALADIN" and MyClass ~= "DEATHKNIGHT" then return end
    local count
	if MyClass == "DEATHKNIGHT" then
		count = 6
		RuneFrame.Show = RuneFrame.Hide
		RuneFrame:Hide()
	elseif MyClass == "PALADIN" then
		count = UnitPowerMax('player', SPELL_POWER_HOLY_POWER)
	end
	local bars = CreateFrame("Frame", nil, UIParent)
	bars:SetSize(config.width, config.height)
	bars:SetPoint(unpack(config.position))
	for i = 1, count do
		bars[i] =CreateFrame("StatusBar", nil, bars)
		bars[i]:SetStatusBarTexture(config.tex)
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		bars[i]:SetSize((config.width-2*(count-1))/count, config.height)
		if (i == 1) then
			bars[i]:SetPoint("LEFT", bars, "LEFT")
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", 2, 0)
		end
        if MyClass == "PALADIN" then
            bars[i]:SetStatusBarColor(0.9, 0.9, 0)
			local s = bars[i]:GetStatusBarTexture()
			tPowerBar:CreateTop(s, 0.9, 0.9, 0)
			bars[i]:Hide()
		end
		tPowerBar:CreateShadow(bars[i])
	end
	if MyClass == "DEATHKNIGHT" then
		for i=1,6 do
			UpdateType(bars, i, math.floor((runemap[i]+1)/2))
		end
	end
	if MyClass == "DEATHKNIGHT" then
		bars:RegisterEvent("RUNE_POWER_UPDATE")
		bars:RegisterEvent("RUNE_TYPE_UPDATE")
		bars:RegisterEvent("PLAYER_ENTERING_WORLD")
		bars:RegisterEvent("PLAYER_REGEN_ENABLED")
		bars:RegisterEvent("PLAYER_REGEN_DISABLED")
		bars:SetScript("OnEvent", OnEvent)
	elseif MyClass == "PALADIN" then
		bars:RegisterEvent("PLAYER_ENTERING_WORLD")
		bars:RegisterEvent("UNIT_POWER")
		bars:RegisterEvent("UNIT_DISPLAYPOWER")
		bars:RegisterEvent("PLAYER_REGEN_ENABLED")
		bars:RegisterEvent("PLAYER_REGEN_DISABLED")
		bars:SetScript("OnEvent",function(self, event, unit)
			if unit == "player" then
				local num = UnitPower('player', SPELL_POWER_HOLY_POWER)
				for i = 1,count do
					if i <= num then
						bars[i]:Show()
					else
						bars[i]:Hide()
					end
				end
			end
			if config.fade then
				if event == "PLAYER_REGEN_DISABLED" then
					UIFrameFadeIn(bars, 1, bars:GetAlpha(), 1)
				end
				if event == "PLAYER_REGEN_ENABLED" then
					UIFrameFadeOut(bars, 1, bars:GetAlpha(), 0)
				end
			end
		end)
	end
end
function tPowerBar:CombatPoint()
	if MyClass ~= "ROGUE" and MyClass ~= "DRUID" then return end

	local CombatPointBar = CreateFrame("Frame", nil, UIParent)
	CombatPointBar:SetSize(config.width, config.height)
	CombatPointBar:SetPoint(unpack(config.position))

	for i = 1, 5 do
		CombatPointBar[i] =CreateFrame("StatusBar", nil, CombatPointBar)
		CombatPointBar[i]:SetStatusBarTexture(config.tex)
		CombatPointBar[i]:GetStatusBarTexture():SetHorizTile(false)
		CombatPointBar[i]:SetSize((config.width-2*4)/5, config.height)
		if (i == 1) then
			CombatPointBar[i]:SetPoint("LEFT", CombatPointBar, "LEFT")
		else
			CombatPointBar[i]:SetPoint("LEFT", CombatPointBar[i-1], "RIGHT", 2, 0)
		end
		local s = CombatPointBar[i]:GetStatusBarTexture()
		if i ~= 5 then
			CombatPointBar[i]:SetStatusBarColor(0.9, 0.9, 0)
			tPowerBar:CreateTop(s,1.00,0.96,0.41)
		else

			CombatPointBar[i]:SetStatusBarColor(1, 0.2, 0.2)
			tPowerBar:CreateTop(s,0.99,0.12,0.23)

		end
		tPowerBar:CreateShadow(CombatPointBar[i])
		CombatPointBar[i]:Hide()
	end
	CombatPointBar:RegisterEvent("PLAYER_ENTERING_WORLD")
	CombatPointBar:RegisterEvent("UNIT_COMBO_POINTS")
	CombatPointBar:RegisterEvent("PLAYER_TARGET_CHANGED")
	CombatPointBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	CombatPointBar:RegisterEvent("PLAYER_TALENT_UPDATE")
	CombatPointBar:RegisterEvent("PLAYER_REGEN_DISABLED")
	CombatPointBar:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_TALENT_UPDATE" or event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_ENTERING_WORLD" or event == "UNIT_COMBO_POINTS" then
			if MyClass == "DRUID" then
				local form = GetShapeshiftFormID()
				if(not form) then
					self:Hide()
				elseif(form ~= CAT_FORM) then
					self:Hide()
				else
					self:Show()
				end
			end
		end
		if event == "UNIT_COMBO_POINTS" or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
			cp = GetComboPoints('player', 'target')
			for i=1, MAX_COMBO_POINTS do
				if(i <= cp) then
					self[i]:Show()
				else
					self[i]:Hide()
				end
			end
		end
	end)
end

--balance druid
function tPowerBar:Eclipse()
	if MyClass ~= "DRUID" then return end
	local ECLIPSE_BAR_SOLAR_BUFF_ID = ECLIPSE_BAR_SOLAR_BUFF_ID
	local ECLIPSE_BAR_LUNAR_BUFF_ID = ECLIPSE_BAR_LUNAR_BUFF_ID
	local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE
	local MOONKIN_FORM = MOONKIN_FORM
	local showBar = false
	local eb = CreateFrame('Frame', nil, UIParent)
	eb:SetSize(config.width, config.height)
	eb:SetPoint(unpack(config.position))
	tPowerBar:CreateShadow(eb)
	local lb = CreateFrame('StatusBar', nil, eb)
	lb:SetPoint('LEFT', eb, 'LEFT')
	lb:SetSize(config.width, config.height)
	lb:SetStatusBarTexture(config.tex)
	lb:SetStatusBarColor(0.27, 0.47, 0.74)
	local s = lb:GetStatusBarTexture()
	tPowerBar:CreateTop(s, 0.27, 0.47, 0.74)
	eb.LunarBar = lb
	local sb = CreateFrame('StatusBar', nil, eb)
	sb:SetPoint('LEFT', lb:GetStatusBarTexture(), 'RIGHT', 0, 0)
	sb:SetSize(config.width, config.height)
	sb:SetStatusBarTexture(config.tex)
	sb:SetStatusBarColor(0.9, 0.6, 0.3)
	local s = sb:GetStatusBarTexture()
	tPowerBar:CreateTop(s, 0.9, 0.6, 0.3)
	eb.SolarBar = sb
	local h = CreateFrame("Frame", nil, eb)
	h:SetFrameLevel(eb:GetFrameLevel()+1)
	h:SetAllPoints(eb)
	local ebInd = tPowerBar:MakeFontString(h, 10, "THINOUTLINE")
	ebInd:SetPoint('CENTER', h, 'CENTER', 0, 0)

	eb:RegisterEvent("ECLIPSE_DIRECTION_CHANGE")
	eb:RegisterEvent("PLAYER_TALENT_UPDATE")
	eb:RegisterEvent("UNIT_POWER")
	eb:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	eb:RegisterEvent("PLAYER_ENTERING_WORLD")
	eb:RegisterEvent("PLAYER_REGEN_DISABLED")
	eb:RegisterEvent("PLAYER_REGEN_ENABLED")
	eb:SetScript("OnEvent", function(self, event, unit, powerType)
		if event == "ECLIPSE_DIRECTION_CHANGE" or event == "PLAYER_ENTERING_WORLD" then
			local dir = GetEclipseDirection()
			if dir=="sun" then
				ebInd:SetText("|cff4478BC>>>|r")
			elseif dir=="moon" then
				ebInd:SetText("|cffE5994C<<<|r")
			end
		end
		if event == "PLAYER_TALENT_UPDATE" or event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_REGEN_DISABLED" then
			local form = GetShapeshiftFormID()
			if(not form) then
				showBar = false
			elseif(form == MOONKIN_FORM) then
				showBar = true
			end

			if(showBar) then
				eb:Show()
				if eb:GetAlpha() < 1 then
					UIFrameFadeIn(eb, 1, eb:GetAlpha(), 1)
				end
			else
				eb:Hide()
				if eb:GetAlpha() > 1 then
					UIFrameFadeOut(eb, 1, eb:GetAlpha(), 0)
				end
			end
		end
		if event == "UNIT_POWER" then
			if(unit ~= "player" or (event == 'UNIT_POWER' and powerType ~= 'ECLIPSE')) then return end

			local power = UnitPower('player', SPELL_POWER_ECLIPSE)
			local maxPower = UnitPowerMax('player', SPELL_POWER_ECLIPSE)

			if(self.LunarBar) then
				self.LunarBar:SetMinMaxValues(-maxPower, maxPower)
				self.LunarBar:SetValue(power)
			end

			if(self.SolarBar) then
				self.SolarBar:SetMinMaxValues(-maxPower, maxPower)
				self.SolarBar:SetValue(power * -1)
			end
		end
		if event == "PLAYER_ENTERING_WORLD" then
			local power = UnitPower('player', SPELL_POWER_ECLIPSE)
			local maxPower = UnitPowerMax('player', SPELL_POWER_ECLIPSE)

			if(self.LunarBar) then
				self.LunarBar:SetMinMaxValues(-maxPower, maxPower)
				self.LunarBar:SetValue(power)
			end

			if(self.SolarBar) then
				self.SolarBar:SetMinMaxValues(-maxPower, maxPower)
				self.SolarBar:SetValue(power * -1)
			end
		end
		if config.fade then
			if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" then
					UIFrameFadeOut(eb, 1, eb:GetAlpha(), 0)
			end
		end
	end)
end
--Warlock power bar

function tPowerBar:Warlock()
	if MyClass ~= "WARLOCK" then return end
	local MAX_POWER_PER_EMBER = 10
	local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY
	local SPELL_POWER_BURNING_EMBERS = SPELL_POWER_BURNING_EMBERS
	local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS
	local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
	local SPEC_WARLOCK_DESTRUCTION_GLYPH_EMBERS = 63304
	local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION
	local SPEC_WARLOCK_AFFLICTION_GLYPH_SHARDS = 63302
	local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY
	local LATEST_SPEC = 0

	local Colors = {
		[1] = {148/255, 130/255, 201/255, 1},
		[2] = {95/255, 222/255,  95/255, 1},
		[3] = {222/255, 95/255,  95/255, 1},
	}
	local bars = CreateFrame('Frame', nil, UIParent)
	bars:SetSize(config.width, config.height)
	bars:SetPoint(unpack(config.position))
	for i = 1, 4 do
		bars[i] = CreateFrame("StatusBar", nil, bars)
		bars[i]:SetSize((config.width-2*(4-1))/4, config.height)
		bars[i]:SetStatusBarTexture(config.tex)
		tPowerBar:CreateBack(bars[i])
		tPowerBar:CreateShadow(bars[i])
		if i == 1 then
			bars[i]:SetPoint("LEFT", bars)
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", 2, 0)
		end
	end
	bars:RegisterEvent("UNIT_POWER")
	bars:RegisterEvent("UNIT_DISPLAYPOWER")
	bars:RegisterEvent("PLAYER_ENTERING_WORLD")
	bars:RegisterEvent("PLAYER_TALENT_UPDATE")
	bars:RegisterEvent("PLAYER_REGEN_DISABLED")
	bars:RegisterEvent("PLAYER_REGEN_ENABLED")
	bars:SetScript("OnEvent", function(self,event,unit, powerType)
		if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TALENT_UPDATE" then
			local wsb = self
			local spacing = select(4, wsb[4]:GetPoint())
			local w = wsb:GetWidth()
			local s = 0

			local spec = GetSpecialization()
			if spec then
				if not wsb:IsShown() then
					wsb:Show()
				end

				if LATEST_SPEC ~= spec then
					for i = 1, 4 do
						local max = select(2, wsb[i]:GetMinMaxValues())
						if spec == SPEC_WARLOCK_AFFLICTION then
							wsb[i]:SetValue(max)
						else
							wsb[i]:SetValue(0)
						end
						wsb[i]:Show()
					end
				end

				if spec == SPEC_WARLOCK_DESTRUCTION then
					local maxembers = 4

					for i = 1, maxembers do
						if i ~= maxembers then
							wsb[i]:SetWidth(w / maxembers - spacing)
							s = s + (w / maxembers)
						else
							wsb[i]:SetWidth(w - s)
						end
						wsb[i]:SetStatusBarColor(unpack(Colors[SPEC_WARLOCK_DESTRUCTION]))
						local s = wsb[i]:GetStatusBarTexture()
						tPowerBar:CreateTop(s, Colors[SPEC_WARLOCK_DESTRUCTION][1], Colors[SPEC_WARLOCK_DESTRUCTION][2], Colors[SPEC_WARLOCK_DESTRUCTION][3])
					end
				elseif spec == SPEC_WARLOCK_AFFLICTION then
					local maxshards = 4

					for i = 1, maxshards do
						if i ~= maxshards then
							wsb[i]:SetWidth(w / maxshards - spacing)
							s = s + (w / maxshards)
						else
							wsb[i]:SetWidth(w - s)
						end
						wsb[i]:SetStatusBarColor(unpack(Colors[SPEC_WARLOCK_AFFLICTION]))
						local s = wsb[i]:GetStatusBarTexture()
						tPowerBar:CreateTop(s, Colors[SPEC_WARLOCK_AFFLICTION][1], Colors[SPEC_WARLOCK_AFFLICTION][2], Colors[SPEC_WARLOCK_AFFLICTION][3])
					end
				elseif spec == SPEC_WARLOCK_DEMONOLOGY then
					wsb[2]:Hide()
					wsb[3]:Hide()
					wsb[4]:Hide()
					wsb[1]:SetWidth(wsb:GetWidth())
					wsb[1]:SetStatusBarColor(unpack(Colors[SPEC_WARLOCK_DEMONOLOGY]))
					local s = wsb[1]:GetStatusBarTexture()
					tPowerBar:CreateTop(s, Colors[SPEC_WARLOCK_DEMONOLOGY][1], Colors[SPEC_WARLOCK_DEMONOLOGY][2], Colors[SPEC_WARLOCK_DEMONOLOGY][3])
				end
			else
				if wsb:IsShown() then
					wsb:Hide()
				end
			end
		end
--update power TODO  UnitAffectingCombat("player")
		if (event == "UNIT_POWER" or event == "UNIT_DISPLAYPOWER") then
			if(unit ~= "player" or (powerType ~= "BURNING_EMBERS" and powerType ~= "SOUL_SHARDS" and powerType ~= "DEMONIC_FURY")) then return end
			local wsb = self
			local spec = GetSpecialization()

			if spec then
				if (spec == SPEC_WARLOCK_DESTRUCTION) then
					local maxPower = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
					local power = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
					local numEmbers = power / MAX_POWER_PER_EMBER
					local numBars = floor(maxPower / MAX_POWER_PER_EMBER)

					for i = 1, numBars do
						wsb[i]:SetMinMaxValues((MAX_POWER_PER_EMBER * i) - MAX_POWER_PER_EMBER, MAX_POWER_PER_EMBER * i)
						wsb[i]:SetValue(power)
					end
				elseif ( spec == SPEC_WARLOCK_AFFLICTION ) then
					local numShards = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
					local maxShards = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS)

					for i = 1, maxShards do
						if i <= numShards then
							wsb[i]:SetAlpha(1)
						else
							wsb[i]:SetAlpha(0)
						end
					end
				elseif spec == SPEC_WARLOCK_DEMONOLOGY then
					local power = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
					local maxPower = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
					wsb[1]:SetAlpha(1)
					wsb[1]:SetMinMaxValues(0, maxPower)
					wsb[1]:SetValue(power)
				end
			end
		end
		if config.fade then
			if event == "PLAYER_REGEN_DISABLED" then
				UIFrameFadeIn(self, 1, self:GetAlpha(), 1)
			end
			if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TALENT_UPDATE" then
				UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
			end
		end
	end)
end
function tPowerBar:Mage()
	if MyClass ~= "MAGE" then return end

	local bars = CreateFrame("Frame", nil, UIParent)
	bars:SetSize(config.width, config.height)
	bars:SetPoint(unpack(config.position))

	for i = 1,6 do
		bars[i] = CreateFrame("StatusBar", nil, f)
		bars[i]:SetSize((config.width-2*(6-1))/6, config.height)
		bars[i]:SetStatusBarTexture(config.tex)
		bars[i]:SetStatusBarColor(MyClassColor.r, MyClassColor.g, MyClassColor.b)
		local s = bars[i]:GetStatusBarTexture()
		tPowerBar:CreateTop(s, MyClassColor.r, MyClassColor.g, MyClassColor.b)
		tPowerBar:CreateShadow(bars[i])
		bars[i]:Hide()
		if (i == 1) then
			bars[i]:SetPoint("LEFT", bars)
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", 2, 0)
		end
	end
	bars:RegisterEvent("PLAYER_ENTERING_WORLD")
	bars:RegisterEvent("UNIT_AURA")

	bars:SetScript("OnEvent",function(self,event,unit)
		local num = select(4, UnitDebuff("player", GetSpellInfo(36032)))
		if num == nil then num = 0 end
		if unit ~= "player" then return end
		for i = 1,6 do
			if i <= num then
				self[i]:Show()
			else
				self[i]:Hide()
			end
		end
	end)
end
local function Smooth(self, value)
	if value == self:GetValue() then
        self.smoothing = nil
    else
        self.smoothing = value
    end
end
local function UpdateHealthSmooth(self)
	if self.smoothing == nil then return end
	local val = self.smoothing
	local limit = 30/GetFramerate()
    local cur = self:GetValue()
    local new = cur + min((val-cur)/3, max(val-cur, limit))

    if new ~= new then
        new = val
    end

    self:SetValue_(new)
    if cur == val or abs(new - val) < 2 then
        self:SetValue_(val)
        self.smoothing = nil
    end
end

function tPowerBar:HealthPowerBar()
	local bars = CreateFrame("Statusbar", nil, UIParent)
	bars:SetSize(config.width, config.height+2)
	bars:SetPoint(unpack(config.position))
	bars:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
	bars:SetMinMaxValues(0, UnitHealthMax("player"))
	bars:SetValue(UnitHealth("player"))
	bars:SetBackdrop({
		edgeFile = "interface\\Addons\\tPowerBar\\media\\solid",
		edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	bars:SetStatusBarColor(0.1, 0.8, 0.1, 0)
	bars:SetBackdropBorderColor(0, 0, 0, 1)
	tPowerBar:CreateShadow(bars)

	local spark =  bars:CreateTexture(nil, "OVERLAY")
	spark:SetTexture("Interface\\Addons\\tPowerBar\\Media\\ArrowT")
	spark:SetVertexColor(1, 0, 0, 1)
	spark:SetSize(16, 16)
	spark:SetPoint("BOTTOM", bars:GetStatusBarTexture(), "RIGHT", 0, 3)
	local healthtext = tPowerBar:MakeFontString(bars, select(2, GameFontNormalSmall:GetFont()))
	healthtext:SetPoint("BOTTOM", spark, "TOP", 0, -4)
	healthtext:SetTextColor(1, 0.22, 0.52)

	bars.SetValue_ = bars.SetValue
	bars.SetValue = Smooth

	local power = CreateFrame("Statusbar", nil, bars)
	power:SetSize(config.width, config.height+2)
	power:SetStatusBarTexture(config.tex)
	power:SetPoint("TOP", bars, "BOTTOM", 0, -2)
	power:SetStatusBarColor(MyClassColor.r, MyClassColor.g, MyClassColor.b, 1)
	power:SetMinMaxValues(0, UnitPowerMax("player"))
  power:SetBackdrop({
		edgeFile = "interface\\Addons\\tPowerBar\\media\\solid",
		edgeSize = 1,
		insets = { left = -1, right = -1, top = -1 , bottom = -1 }
	})
	power:SetBackdropBorderColor(0, 0, 0, 1)
  tPowerBar:CreateShadow(power)
  local s = power:GetStatusBarTexture()
	tPowerBar:CreateTop(s,MyClassColor.r, MyClassColor.g, MyClassColor.b)
	local powerspar =  power:CreateTexture(nil, "OVERLAY")
	powerspar:SetTexture("Interface\\Addons\\tPowerBar\\Media\\Arrow")
	--powerspar:SetBlendMode("ADD")
	powerspar:SetVertexColor(.3,.45,.65, 1)
	powerspar:SetSize(16, 16)
	powerspar:SetPoint("TOP", power:GetStatusBarTexture(), "RIGHT", 0, -3)
	local powertext = tPowerBar:MakeFontString(bars, select(2, GameFontNormalSmall:GetFont()))
	powertext:SetPoint("TOP", powerspar, "BOTTOM", 0, 4)

	power.SetValue_ = power.SetValue
	power.SetValue = Smooth

	bars:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed < .2 then
			local healthnum = UnitHealth("player")
			local powernum = UnitPower("player")
			local maxhealth = UnitHealthMax("player")
			local maxpower = UnitPowerMax("player")
			self:SetMinMaxValues(0, maxhealth)
			power:SetMinMaxValues(0, maxpower)
			self:SetValue(healthnum)
			power:SetValue(powernum)
			healthtext:SetText(ShortValue(healthnum))
			powertext:SetText(ShortValue(powernum))
			UpdateHealthSmooth(bars)
			UpdateHealthSmooth(power)
		return end
		self.elapsed = 0
	end)
	bars:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	bars:RegisterEvent("PLAYER_ENTERING_WORLD")
	bars:RegisterEvent("PLAYER_REGEN_ENABLED")
	bars:RegisterEvent("PLAYER_REGEN_DISABLED")
	bars:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	bars:SetScript("OnEvent", function(self, event)
		if config.fade then
			if event == "PLAYER_REGEN_DISABLED" then
				UIFrameFadeIn(self, 1, self:GetAlpha(), 1)
			end
			if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" then
				UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
			end
		end
		if event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_ENTERING_WORLD" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
			power:SetMinMaxValues(0, UnitPowerMax("player"))
			local _, powerclass = UnitPowerType("player")
			powertext:SetTextColor(unpack(powercolor[powerclass]))
		end
	end)
end
local launcher = CreateFrame("Frame", nil, UIParent)
launcher:RegisterEvent("PLAYER_LOGIN")
launcher:SetScript("OnEvent", function()
	tPowerBar:PriestShadow()
	tPowerBar:Monk()
	tPowerBar:PaladinDeathKnight()
	tPowerBar:CombatPoint()
	tPowerBar:Eclipse()
	tPowerBar:Warlock()
	tPowerBar:Mage()
	tPowerBar:HealthPowerBar()
end)
