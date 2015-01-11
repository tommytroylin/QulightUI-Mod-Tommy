local addon, ns = ...
local config = ns.config
tPowerBar = CreateFrame("Frame", nil, UIParent)

local filename, fontHeight, _ = GameFontNormal:GetFont()
-- just for creating text
function tPowerBar:MakeFontString(parent, size, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(filename, size or fontHeight, fontStyle or "OUTLINE")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(1.25, -1.25)
	return fs
end

local function CreateBorder(f, r, g, b, a)
 	f:SetBackdrop({
		edgeFile = "interface\\Addons\\tPowerBar\\media\\solid",
		edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	f:SetBackdropBorderColor(r or 0, g or 0, b or 0, a or 1)
end
function tPowerBar:CreateShadow(f, t, offset, thickness, texture)
	if f.shadow then return end

	local borderr, borderg, borderb, bordera = 0, 0, 0, 1
	local backdropr, backdropg, backdropb, backdropa =  .05, .05, .05, .9
	local frameLevel = f:GetFrameLevel() > 1 and f:GetFrameLevel() or 1
	if t == "Background" then
		backdropa = 0.6
	elseif t == "UnitFrame" then
		backdropa = 0.3
	else
		backdropa = 0
	end

	local border = CreateFrame("Frame", nil, f)
	border:SetFrameLevel(frameLevel)
	border:SetPoint("TOPLEFT", -1, 1)
	border:SetPoint("TOPRIGHT", 1, 1)
	border:SetPoint("BOTTOMRIGHT", 1, -1)
	border:SetPoint("BOTTOMLEFT", -1, -1)
	CreateBorder(border)
	f.border = border

	local shadow = CreateFrame("Frame", nil, border)
	shadow:SetFrameLevel(frameLevel - 1)
	shadow:SetPoint("TOPLEFT", -3, 3)
	shadow:SetPoint("TOPRIGHT", 3, 3)
	shadow:SetPoint("BOTTOMRIGHT", 3, -3)
	shadow:SetPoint("BOTTOMLEFT", -3, -3)
	shadow:SetBackdrop( {
		edgeFile = "interface\\Addons\\tPowerBar\\media\\glowTex",
		bgFile ="interface\\Addons\\tPowerBar\\media\\solid",
		edgeSize = 4,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	})
	shadow:SetBackdropColor( backdropr, backdropg, backdropb, backdropa )
	shadow:SetBackdropBorderColor( borderr, borderg, borderb, bordera )
	f.shadow = shadow
end

function tPowerBar:CreateBack(f, r1,g1,b1,a1,r2,g2,b2,a2)
	local gradient = f:CreateTexture(nil, "BACKGROUND")
	gradient:SetPoint("TOPLEFT")
	gradient:SetPoint("BOTTOMRIGHT")
	gradient:SetTexture(config.tex)
	if a1 and a2 then
		gradient:SetGradientAlpha("VERTICAL", r1 or 0, g1 or  0, b1 or  0, a1, r2 or  .35, g2 or  .35, b2 or  .35, a2)
	else
		gradient:SetGradientAlpha("VERTICAL", r1 or 0, g1 or  0, b1 or  0, 0.3, r2 or  .35, g2 or  .35, b2 or  .35, .35)
	end
end
function tPowerBar:CreateTop(f, r, g, b)
	f:SetGradientAlpha("VERTICAL", r, g, b, 1, r/2, g/2, b/2, 1)
end
