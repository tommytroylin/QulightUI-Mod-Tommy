local csf = CreateFrame("Frame")
csf:SetScript("OnEvent", function()
SetCVar("cameraDistanceMax", 50)
SetCVar("cameraDistanceMaxFactor", 3.4)
SetCVar("consolidateBuffs", 0)
SetCVar("ShowClassColorInNameplate", 1)
SetCVar("consolidateBuffs",0) 
SetCVar("buffDurations",1)

end)
csf:RegisterEvent("PLAYER_LOGIN")

----------------------------------------------------------------------------------------
-- Launcher
----------------------------------------------------------------------------------------
local function positionsetup()
	QulightDataPerChar = {}
end

local QulightOnLogon = CreateFrame("Frame")
QulightOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
QulightOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	
	if (QulightData == nil) then QulightData = {} end
	if (QulightDataPerChar == nil) then QulightDataPerChar = {} end
	
		SetCVar("useUiScale", 1)
		if Qulight["general"].MultisampleProtect == true then
		end
		if Qulight["general"].UiScale > 1 then Qulight["general"].UiScale = 1 end
		if Qulight["general"].UiScale < 0.64 then Qulight["general"].UiScale = 0.64 end
		SetCVar("uiScale", Qulight["general"].UiScale)

	print(" ")
	print("Welcome to |cFF00A2FFQulight UI|r")
	print(" ")
	print("|cFF00A2FFhttp://QulightUI.org |r - Site UI;")
	print(" ")
	print("|cFF00A2FF/config |r - Config Qulight UI;")
	print("|cFF00A2FF/ui |r - Command for change all UI positions.")
	print("|cFF00A2FF/ui reset |r - Set default UI postions.")
end)
