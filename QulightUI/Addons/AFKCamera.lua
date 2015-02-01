local PName = select(1, UnitName("player"))
local PLevel = UnitLevel("player")
local PClass = select(2, UnitClass("player"))
local PRace = select(2, UnitRace("player"))
local PFaction = UnitFactionGroup("player")
local color = RAID_CLASS_COLORS[PClass]
local blank = Qulight["media"].blank
local normTex = [[Interface\AddOns\Qulight\Root\media\normTex.tga]] 
local font = Qulight["media"].combatfont

local PGuild
if IsInGuild() then
	PGuild = select(1, GetGuildInfo("player"))
else
	PGuild = " "
end

local function UpdateColor(t)
	if t == template then return end

	if t == "Transparent" then
		local balpha = 1
		if t == "Transparent" then balpha = 0.7 end
		borderr, borderg, borderb = { .125, .125, .125 }
		backdropr, backdropg, backdropb = { .05, .05, .05 }
		backdropa = balpha
	end
	
	template = t
end

local function SetTemplate(f, t, tex)
	if tex then 
		texture = normTex
	else 
		texture = blank
	end
	
	UpdateColor(t)
		
	f:SetBackdrop({
	  bgFile = texture, 
	  edgeFile = blank, 
	  tile = false, tileSize = 0, edgeSize = 1,
	})
	
	if not noinset and not f.isInsetDone then
		f.insettop = f:CreateTexture(nil, "BORDER")
		f.insettop:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 1)
		f.insettop:SetPoint("TOPRIGHT", f, "TOPRIGHT", 1, -1)
		f.insettop:SetHeight(1)
		f.insettop:SetTexture(0, 0, 0)	
		f.insettop:SetDrawLayer("BORDER", -7)
		
		f.insetbottom = f:CreateTexture(nil, "BORDER")
		f.insetbottom:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", -1, -1)
		f.insetbottom:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
		f.insetbottom:SetHeight(1)
		f.insetbottom:SetTexture(0, 0, 0)	
		f.insetbottom:SetDrawLayer("BORDER", -7)
		
		f.insetleft = f:CreateTexture(nil, "BORDER")
		f.insetleft:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 1)
		f.insetleft:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, -1)
		f.insetleft:SetWidth(1)
		f.insetleft:SetTexture(0, 0, 0)
		f.insetleft:SetDrawLayer("BORDER", -7)
		
		f.insetright = f:CreateTexture(nil, "BORDER")
		f.insetright:SetPoint("TOPRIGHT", f, "TOPRIGHT", 1, 1)
		f.insetright:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, -1)
		f.insetright:SetWidth(1)
		f.insetright:SetTexture(0, 0, 0)	
		f.insetright:SetDrawLayer("BORDER", -7)

		f.insetinsidetop = f:CreateTexture(nil, "BORDER")
		f.insetinsidetop:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
		f.insetinsidetop:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, 1)
		f.insetinsidetop:SetHeight(1)
		f.insetinsidetop:SetTexture(0, 0, 0)	
		f.insetinsidetop:SetDrawLayer("BORDER", -7)
		
		f.insetinsidebottom = f:CreateTexture(nil, "BORDER")
		f.insetinsidebottom:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, 1)
		f.insetinsidebottom:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
		f.insetinsidebottom:SetHeight(1)
		f.insetinsidebottom:SetTexture(0, 0, 0)	
		f.insetinsidebottom:SetDrawLayer("BORDER", -7)
		
		f.insetinsideleft = f:CreateTexture(nil, "BORDER")
		f.insetinsideleft:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
		f.insetinsideleft:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", -1, 1)
		f.insetinsideleft:SetWidth(1)
		f.insetinsideleft:SetTexture(0, 0, 0)
		f.insetinsideleft:SetDrawLayer("BORDER", -7)
		
		f.insetinsideright = f:CreateTexture(nil, "BORDER")
		f.insetinsideright:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -1)
		f.insetinsideright:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, 1)
		f.insetinsideright:SetWidth(1)
		f.insetinsideright:SetTexture(0, 0, 0)	
		f.insetinsideright:SetDrawLayer("BORDER", -7)

		f.isInsetDone = true
	end
		
	f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	f:SetBackdropBorderColor(borderr, borderg, borderb)
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end

local AFKPanel = CreateFrame( "Frame", "AFKPanel", nil )
AFKPanel:SetPoint( "BOTTOMLEFT", UIParent, "BOTTOMLEFT", -2, -2 )
AFKPanel:SetPoint( "TOPRIGHT", UIParent, "BOTTOMRIGHT", 2, 150 )
AFKPanel:SetTemplate("Transparent")
AFKPanel:Hide()

local AFKPanelTop = CreateFrame( "Frame", "AFKPanelTop", nil )
AFKPanelTop:SetPoint( "TOPLEFT", UIParent, "TOPLEFT",-2, 2 )
AFKPanelTop:SetPoint( "BOTTOMRIGHT", UIParent, "TOPRIGHT", 2, -80 )
AFKPanelTop:SetTemplate("Transparent")
AFKPanelTop:SetFrameStrata("FULLSCREEN")
AFKPanelTop:Hide()

AFKPanelTop.Text = AFKPanelTop:CreateFontString( nil, "OVERLAY" )
AFKPanelTop.Text:SetPoint( "CENTER", AFKPanelTop, "CENTER", 0, 0 )
AFKPanelTop.Text:SetFont( font, 40, "OUTLINE" )
AFKPanelTop.Text:SetText( "|cffc41f3bAFK|r" )

AFKPanelTop.DateText = AFKPanelTop:CreateFontString( nil, "OVERLAY" )
AFKPanelTop.DateText:SetPoint( "BOTTOMLEFT", AFKPanelTop, "BOTTOMRIGHT", -100, 44 )
AFKPanelTop.DateText:SetFont( font, 15, "OUTLINE" )

AFKPanelTop.ClockText = AFKPanelTop:CreateFontString( nil, "OVERLAY" )
AFKPanelTop.ClockText:SetPoint( "BOTTOMLEFT", AFKPanelTop, "BOTTOMRIGHT", -100, 20 )
AFKPanelTop.ClockText:SetFont( font, 20, "OUTLINE" )

AFKPanelTop.PlayerNameText = AFKPanelTop:CreateFontString( nil, "OVERLAY" )
AFKPanelTop.PlayerNameText:SetPoint( "LEFT", AFKPanelTop, "LEFT", 25, 15 )
AFKPanelTop.PlayerNameText:SetFont( font, 28, "OUTLINE" )
AFKPanelTop.PlayerNameText:SetText( PName )
AFKPanelTop.PlayerNameText:SetTextColor( color.r, color.g, color.b )

AFKPanelTop.GuildText = AFKPanelTop:CreateFontString( nil, "OVERLAY" )
AFKPanelTop.GuildText:SetPoint( "LEFT", AFKPanelTop, "LEFT", 25, -3 )
AFKPanelTop.GuildText:SetFont( font, 15, "OUTLINE" )
AFKPanelTop.GuildText:SetText( "|cffc41f3b" .. PGuild .. "|r" )

AFKPanelTop.PlayerInfoText = AFKPanelTop:CreateFontString( nil, "OVERLAY" )
AFKPanelTop.PlayerInfoText:SetPoint( "LEFT", AFKPanelTop, "LEFT", 25, -20 )
AFKPanelTop.PlayerInfoText:SetFont( font, 15, "OUTLINE" )
AFKPanelTop.PlayerInfoText:SetText( LEVEL .. " " .. PLevel .. " " .. PFaction .. " " .. PClass )

local interval = 0
AFKPanelTop:SetScript( "OnUpdate", function( self, elapsed )
	interval = interval - elapsed
	if( interval <= 0 ) then
		AFKPanelTop.ClockText:SetText( format("%s", date( "%H|cffc41f3b:|r%M|cffc41f3b:|r%S" ) ) )
		AFKPanelTop.DateText:SetText( format("%s", date( "|cffc41f3b%a|r %b/%d" ) ) )
		interval = 0.5
	end
end )

local OnEvent = function(self, event, unit)
	if event == "PLAYER_FLAGS_CHANGED" then
		if unit == "player" then
			if UnitIsAFK(unit) and not UnitIsDead(unit) then
				SpinStart()
				AFKPanel:Show()
				AFKPanelTop:Show()
				Minimap:Hide()
			else
				SpinStop()
				AFKPanel:Hide()
				AFKPanelTop:Hide()
				Minimap:Show()
			end
		end
	elseif event == "PLAYER_LEAVING_WORLD" then
		SpinStop()
	elseif event == "PLAYER_DEAD" then
		if UnitIsAFK("player") then
			SpinStop()
			AFKPanel:Hide()
			AFKPanelTop:Hide()
			Minimap:Show()
		end
	end
end

AFKPanel:RegisterEvent( "PLAYER_ENTERING_WORLD" )
AFKPanel:RegisterEvent( "PLAYER_LEAVING_WORLD" )
AFKPanel:RegisterEvent( "PLAYER_FLAGS_CHANGED" )
AFKPanel:SetScript( "OnEvent", OnEvent )

AFKPanel:SetScript( "OnShow", function( self )
	UIFrameFadeIn( UIParent, 0.5, 1, 0 )
end )

AFKPanel:SetScript( "OnHide", function( self )
	UIFrameFadeOut( UIParent, 0.5, 0, 1 )
end )

function SpinStart()
	spinning = true
	MoveViewRightStart( 0.1 )
end

function SpinStop()
	if( not spinning ) then return end
	spinning = nil
	MoveViewRightStop()
end