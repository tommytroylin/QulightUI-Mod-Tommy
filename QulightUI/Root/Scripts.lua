-----------------
-- Slash commands
-----------------
SlashCmdList["FRAME"] = function() print(GetMouseFocus():GetName()) end
SLASH_FRAME1 = "/gn"
SLASH_FRAME2 = "/frame"

SlashCmdList["GETPARENT"] = function() print(GetMouseFocus():GetParent():GetName()) end
SLASH_GETPARENT1 = "/gp"
SLASH_GETPARENT2 = "/parent"

SlashCmdList["RELOADUI"] = function() ReloadUI() end
SLASH_RELOADUI1 = "/rl"
SLASH_RELOADUI2 = "/reload"

SlashCmdList["RCSLASH"] = function() DoReadyCheck() end
SLASH_RCSLASH1 = "/rc"
SLASH_RCSLASH2 = "/readycheck"

SlashCmdList["TICKET"] = function() ToggleHelpFrame() end
SLASH_TICKET1 = "/ticket"
SLASH_TICKET2 = "/gm"


SLASH_FRAME1 = "/frame"
SlashCmdList["FRAME"] = function(arg)
	if arg ~= "" then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end
	if arg ~= nil and arg:GetName() ~= nil then
		local SetPoint, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
		ChatFrame1:AddMessage("|cffCC0000----------------------------")
		ChatFrame1:AddMessage("Name: |cffFFD100"..arg:GetName())
		if arg:GetParent() and arg:GetParent():GetName() then
			ChatFrame1:AddMessage("Parent: |cffFFD100"..arg:GetParent():GetName())
		end

		ChatFrame1:AddMessage("Width: |cffFFD100"..format("%.2f",arg:GetWidth()))
		ChatFrame1:AddMessage("Height: |cffFFD100"..format("%.2f",arg:GetHeight()))
		ChatFrame1:AddMessage("Strata: |cffFFD100"..arg:GetFrameStrata())
		ChatFrame1:AddMessage("Level: |cffFFD100"..arg:GetFrameLevel())

		if xOfs then
			ChatFrame1:AddMessage("X: |cffFFD100"..format("%.2f",xOfs))
		end
		if yOfs then
			ChatFrame1:AddMessage("Y: |cffFFD100"..format("%.2f",yOfs))
		end
		if relativeTo and relativeTo:GetName() then
			ChatFrame1:AddMessage("SetPoint: |cffFFD100"..SetPoint.."|r anchored to "..relativeTo:GetName().."'s |cffFFD100"..relativePoint)
		end
		ChatFrame1:AddMessage("|cffCC0000----------------------------")
	elseif arg == nil then
		ChatFrame1:AddMessage("Invalid frame name")
	else
		ChatFrame1:AddMessage("Could not find frame info")
	end
end
-----------------
-- Check Player's Role
-----------------
CheckRole = function()
	local role = ""
	local tree = GetSpecialization()

	if tree then
		role = select(6, GetSpecializationInfo(tree))
	end

	return role
end
-----------------
-- wait Frame
-----------------
local waitTable = {}
local waitFrame
function Delay(delay, func, ...)
	if(type(delay)~="number" or type(func)~="function") then
		return false
	end
	if(waitFrame == nil) then
		waitFrame = CreateFrame("Frame","WaitFrame", UIParent)
		waitFrame:SetScript("onUpdate",function (self,elapse)
			local count = #waitTable
			local i = 1
			while(i<=count) do
				local waitRecord = tremove(waitTable,i)
				local d = tremove(waitRecord,1)
				local f = tremove(waitRecord,1)
				local p = tremove(waitRecord,1)
				if(d>elapse) then
				  tinsert(waitTable,i,{d-elapse,f,p})
				  i = i + 1
				else
				  count = count - 1
				  f(unpack(p))
				end
			end
		end)
	end
	tinsert(waitTable,{delay,func,{...}})
	return true
end
----------------------------------------------------------------------------------------
--	Based on AchievementMover
----------------------------------------------------------------------------------------
local AchievementAnchor = CreateFrame("Frame", "AchievementAnchor", UIParent)
AchievementAnchor:SetWidth(DungeonCompletionAlertFrame1:GetWidth() - 36)
AchievementAnchor:SetHeight(DungeonCompletionAlertFrame1:GetHeight() - 4)
AchievementAnchor:SetPoint("CENTER", 0, 0)

local POSITION, ANCHOR_POINT, YOFFSET = "BOTTOM", "TOP", -9

local function fixAnchors()
	local point = select(1, AchievementAnchor:GetPoint())

	if string.find(point, "TOP") or point == "CENTER" or point == "LEFT" or point == "RIGHT" then
		POSITION = "TOP"
		ANCHOR_POINT = "BOTTOM"
		YOFFSET = 9
	else
		POSITION = "BOTTOM"
		ANCHOR_POINT = "TOP"
		YOFFSET = -9
	end

	AlertFrame:ClearAllPoints()
	AlertFrame:SetPoint(POSITION, AchievementAnchor, POSITION, 2, YOFFSET)

	GroupLootContainer:ClearAllPoints()
	GroupLootContainer:SetPoint(POSITION, AlertFrame, ANCHOR_POINT, -100, YOFFSET)
end
hooksecurefunc("AlertFrame_FixAnchors", fixAnchors)

local function AlertFrame_SetLootAnchors(alertAnchor)
	if MissingLootFrame:IsShown() then
		MissingLootFrame:ClearAllPoints()
		MissingLootFrame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
		if GroupLootContainer:IsShown() then
			GroupLootContainer:ClearAllPoints()
			GroupLootContainer:SetPoint(POSITION, MissingLootFrame, ANCHOR_POINT, 0, YOFFSET)
		end
	elseif GroupLootContainer:IsShown() then
		GroupLootContainer:ClearAllPoints()
		GroupLootContainer:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end
hooksecurefunc("AlertFrame_SetLootAnchors", AlertFrame_SetLootAnchors)

local function AlertFrame_SetLootWonAnchors(alertAnchor)
	for i = 1, #LOOT_WON_ALERT_FRAMES do
		local frame = LOOT_WON_ALERT_FRAMES[i]
		if frame:IsShown() then
			frame:ClearAllPoints()
			frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
			alertAnchor = frame
		end
	end
end
hooksecurefunc("AlertFrame_SetLootWonAnchors", AlertFrame_SetLootWonAnchors)

local function AlertFrame_SetMoneyWonAnchors(alertAnchor)
	for i = 1, #MONEY_WON_ALERT_FRAMES do
		local frame = MONEY_WON_ALERT_FRAMES[i]
		if frame:IsShown() then
			frame:ClearAllPoints()
			frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
			alertAnchor = frame
		end
	end
end
hooksecurefunc("AlertFrame_SetMoneyWonAnchors", AlertFrame_SetMoneyWonAnchors)

local function AlertFrame_SetAchievementAnchors(alertAnchor)
	if AchievementAlertFrame1 then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame"..i]
			if frame and frame:IsShown() then
				frame:ClearAllPoints()
				frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
				alertAnchor = frame
			end
		end
	end
end
hooksecurefunc("AlertFrame_SetAchievementAnchors", AlertFrame_SetAchievementAnchors)

local function AlertFrame_SetCriteriaAnchors(alertAnchor)
	if CriteriaAlertFrame1 then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["CriteriaAlertFrame"..i]
			if frame and frame:IsShown() then
				frame:ClearAllPoints()
				frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
				alertAnchor = frame
			end
		end
	end
end
hooksecurefunc("AlertFrame_SetCriteriaAnchors", AlertFrame_SetCriteriaAnchors)

local function AlertFrame_SetChallengeModeAnchors(alertAnchor)
	local frame = ChallengeModeAlertFrame1
	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end
hooksecurefunc("AlertFrame_SetChallengeModeAnchors", AlertFrame_SetChallengeModeAnchors)

local function AlertFrame_SetDungeonCompletionAnchors(alertAnchor)
	local frame = DungeonCompletionAlertFrame1
	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end
hooksecurefunc("AlertFrame_SetDungeonCompletionAnchors", AlertFrame_SetDungeonCompletionAnchors)

local function AlertFrame_SetScenarioAnchors(alertAnchor)
	local frame = ScenarioAlertFrame1
	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end
hooksecurefunc("AlertFrame_SetScenarioAnchors", AlertFrame_SetScenarioAnchors)

local function AlertFrame_SetGuildChallengeAnchors(alertAnchor)
	local frame = GuildChallengeAlertFrame
	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end
hooksecurefunc("AlertFrame_SetGuildChallengeAnchors", AlertFrame_SetGuildChallengeAnchors)

hooksecurefunc(GroupLootContainer, "SetPoint", function(self, point, anchorTo, attachPoint, xOffset, yOffset)
	if _G[anchorTo] == UIParent or _G[anchorTo] == AchievementAnchor then
		fixAnchors()
	end
end)
hooksecurefunc("AlertFrame_SetGarrisonFollowerAlertFrameAnchors", AlertFrame_SetGarrisonFollowerAlertFrameAnchors)

function AlertFrame_SetGarrisonBuildingAlertFrameAnchors(alertAnchor)
	local frame = GarrisonBuildingAlertFrame
	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end
hooksecurefunc("AlertFrame_SetGarrisonBuildingAlertFrameAnchors", AlertFrame_SetGarrisonBuildingAlertFrameAnchors)

function AlertFrame_SetGarrisonBuildingAlertFrameAnchors(alertAnchor)
	local frame = GarrisonBuildingAlertFrame
	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end
hooksecurefunc("AlertFrame_SetGarrisonMissionAlertFrameAnchors", AlertFrame_SetGarrisonMissionAlertFrameAnchors)

function AlertFrame_SetGarrisonBuildingAlertFrameAnchors(alertAnchor)
	local frame = GarrisonMissionAlertFrame
	if frame:IsShown() then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
	end
end

if Qulight["general"].autoinvite then

	local CheckFriend = function(name)
		for i = 1, GetNumFriends() do
			if GetFriendInfo(i) == name then
				return true
			end
		end
		for i = 1, select(2, BNGetNumFriends()) do
			local presenceID, _, _, _, _, _, client, isOnline = BNGetFriendInfo(i)
			if client == "WoW" and isOnline then
				local _, toonName, _, realmName = BNGetToonInfo(presenceID)
				if name == toonName or name == toonName.."-"..realmName then
					return true
				end
			end
		end
		if IsInGuild() then
			for i = 1, GetNumGuildMembers() do
				if GetGuildRosterInfo(i) == name then
					return true
				end
			end
		end
	end

	local ai = CreateFrame("Frame")
	ai:RegisterEvent("PARTY_INVITE_REQUEST")
	ai:SetScript("OnEvent", function(self, event, name)
		if QueueStatusMinimapButton:IsShown() or GetNumGroupMembers() > 0 then return end
		if CheckFriend(name) then
			RaidNotice_AddMessage(RaidWarningFrame, "Accepted invite from: "..name, {r = 0.41, g = 0.8, b = 0.94}, 3)
			print(format("|cffffff00".."Accepted invite from: "..name.."."))
			AcceptGroup()
			for i = 1, STATICPOPUP_NUMDIALOGS do
				local frame = _G["StaticPopup"..i]
				if frame:IsVisible() and frame.which == "PARTY_INVITE" then
					frame.inviteAccepted = 1
					StaticPopup_Hide("PARTY_INVITE")
					return
				elseif frame:IsVisible() and frame.which == "PARTY_INVITE_XREALM" then
					frame.inviteAccepted = 1
					StaticPopup_Hide("PARTY_INVITE_XREALM")
					return
				end
			end
		else
			SendWho(name)
		end
end)
end

local function ForceTaintPopupHide()
 if GetBuildInfo == "5.4.1" then
  hooksecurefunc("StaticPopup_Show", function(which)
   if (which == "ADDON_ACTION_FORBIDDEN") then
    StaticPopup_Hide(which)
   end
  end)
 end
end

local Fixes = CreateFrame("Frame")
Fixes:RegisterEvent("PLAYER_ENTERING_WORLD")
Fixes:SetScript("OnEvent", function(self, event, ...)
 if event == "PLAYER_ENTERING_WORLD" then
  ForceTaintPopupHide()
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
 end
end)

----------------------------------------------------------------------------------------
--	Creating Coordinate
----------------------------------------------------------------------------------------

local coords = CreateFrame("Frame", "CoordsFrame", WorldMapFrame)
coords:SetFrameLevel(90)
coords.PlayerText = coords:CreateFontString(nil, "ARTWORK", "GameFontNormal")
coords.PlayerText:SetPoint("BOTTOMLEFT", WorldMapFrame.UIElementsFrame, "BOTTOMLEFT", 5, 5)
coords.PlayerText:SetJustifyH("LEFT")
coords.PlayerText:SetText(UnitName("player")..": 0,0")
coords.PlayerText:SetTextColor(1, 1, 1)
coords.PlayerText:SetFontObject(SystemFont_Med1)

coords.MouseText = coords:CreateFontString(nil, "ARTWORK", "GameFontNormal")
coords.MouseText:SetJustifyH("LEFT")
coords.MouseText:SetPoint("BOTTOMLEFT", coords.PlayerText, "TOPLEFT", 0, 5)
coords.MouseText:SetText("Mouse:   0, 0")
coords.MouseText:SetTextColor(1, 1, 1)
coords.MouseText:SetFontObject(SystemFont_Med1)

local int = 0
WorldMapFrame:HookScript("OnUpdate", function(self, elapsed)
	int = int + 1
	if int >= 3 then
		local inInstance, _ = IsInInstance()
		local x,y = GetPlayerMapPosition("player")
			x = math.floor(100 * x)
			y = math.floor(100 * y)
		if x ~= 0 and y ~= 0 then
			coords.PlayerText:SetText(UnitName("player")..":   "..x..", "..y)
		else
			coords.PlayerText:SetText(" ")
		end

		local scale = WorldMapDetailFrame:GetEffectiveScale()
		local width = WorldMapDetailFrame:GetWidth()
		local height = WorldMapDetailFrame:GetHeight()
		local centerX, centerY = WorldMapDetailFrame:GetCenter()
		local x, y = GetCursorPosition()
		local adjustedX = (x / scale - (centerX - (width/2))) / width
		local adjustedY = (centerY + (height/2) - y / scale) / height

		if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
			adjustedX = math.floor(100 * adjustedX)
			adjustedY = math.floor(100 * adjustedY)
			coords.MouseText:SetText(MOUSE_LABEL..":   "..adjustedX..", "..adjustedY)
		else
			coords.MouseText:SetText(" ")
		end
		int = 0
	end
end)
-- add downhere

----------------------------------------------------------------------------------------
--	Speedy Focus
----------------------------------------------------------------------------------------
local modifier = "alt" -- shift, alt or ctrl
local mouseButton = "1" -- 1 = left, 2 = right, 3 = middle, 4 and 5 = thumb buttons if there are any

local function SetFocusHotkey(frame)
	frame:SetAttribute(modifier.."-type"..mouseButton,"focus")
end

local function CreateFrame_Hook(type, name, parent, template)
	if template == "SecureUnitButtonTemplate" then
			SetFocusHotkey(_G[name])
	end
end

hooksecurefunc("CreateFrame", CreateFrame_Hook)

-- Keybinding override so that models can be shift/alt/ctrl+clicked
local f = CreateFrame("CheckButton", "FocuserButton", UIParent, "SecureActionButtonTemplate")
f:SetAttribute("type1","macro")
f:SetAttribute("macrotext","/focus mouseover")
SetOverrideBindingClick(FocuserButton,true,modifier.."-BUTTON"..mouseButton,"FocuserButton")

-- Set the keybindings on the default unit frames since we won't get any CreateFrame notification about them
local duf = {
	PlayerFrame,
	PetFrame,
	PartyMemberFrame1,
	PartyMemberFrame2,
	PartyMemberFrame3,
	PartyMemberFrame4,
	PartyMemberFrame1PetFrame,
	PartyMemberFrame2PetFrame,
	PartyMemberFrame3PetFrame,
	PartyMemberFrame4PetFrame,
	TargetFrame,
	TargetofTargetFrame,
}

for i,frame in pairs(duf) do
	SetFocusHotkey(frame)
end

----------------------------------------------------------------------------------------
--	low health
----------------------------------------------------------------------------------------

local LowHealthFrame = CreateFrame("Frame", "NephHealthFrame", UIParent)
LowHealthFrame:SetAllPoints() 
LowHealthFrame:SetFrameStrata("BACKGROUND")
LowHealthFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
LowHealthFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)

local warningTexture = LowHealthFrame:CreateTexture(nil, "BACKGROUND")
warningTexture:SetTexture("Interface\\FullScreenTextures\\LowHealth")
warningTexture:SetAllPoints(LowHealthFrame)
warningTexture:SetBlendMode("ADD")
LowHealthFrame.texture = warningTexture

local showWarning = false
LowHealthFrame:Hide()

function NephHealthFrame:UNIT_HEALTH(_, arg1)
	if UnitIsDeadOrGhost("player") then
		if showWarning then
			showWarning = false
			LowHealthFrame:Hide()
		end
	else
		local lowHealth = (UnitHealth("player") / UnitHealthMax("player") < 0.3)
		if lowHealth and not showWarning then
			showWarning = true
			LowHealthFrame:Show()
			PlaySoundFile("Sound\\interface\\RaidWarning.wav") --TODO
		elseif not lowHealth and showWarning then
			showWarning = false
			LowHealthFrame:Hide()
		end
	end
end
----------------------------------------------------------------------------------------
--	Bulkie
----------------------------------------------------------------------------------------
local THROTTLE = 0.33 
local TITLE = 'Queue To Max'
if GetLocale() == 'zhCN' then 
   TITLE = '一键全部下单'
elseif GetLocale() == 'zhTW' then 
   TITLE = '一鍵全部訂單'
end 

local BulkieDisplayFrame = CreateFrame('Frame', 'BulkieFrame', UIParent) 
BulkieDisplayFrame:SetFrameStrata('DIALOG') 
BulkieDisplayFrame:SetToplevel(true) 
BulkieDisplayFrame:EnableMouse(true) 
BulkieDisplayFrame:SetClampedToScreen(true) 
BulkieDisplayFrame:SetWidth(340) 
BulkieDisplayFrame:SetHeight(50) 
BulkieDisplayFrame:SetPoint('TOPLEFT', 13, -470) 
BulkieDisplayFrame:Hide() 

-- create title 
local title = BulkieDisplayFrame:CreateFontString (nil, "ARTWORK", "GameFontNormalLarge") 
title:SetPoint("TOPLEFT", 16, -16) 
title:SetText("") 
BulkieDisplayFrame.Title = title 

-- create button 
local button = CreateFrame('Button', 'BulkieBulkButton', BulkieDisplayFrame) 
button:SetPoint("TOPRIGHT", -5, -21) 
button:SetWidth(160) 
button:SetHeight(22)
local buttonbgtexture = button:CreateTexture("BulkieBulkButtonBG", "OVERLAY")
CreateStyle(button,2)
button:Show() 

local buttonString = button:CreateFontString("BulkieButton", "OVERLAY")
	buttonString:SetFont(Qulight["media"].font, 10, "OUTLINE")
	buttonString:SetText(TITLE)
	buttonString:SetPoint("CENTER")

-- register events 
BulkieDisplayFrame:RegisterEvent("SHIPMENT_CRAFTER_OPENED") 
BulkieDisplayFrame:RegisterEvent("SHIPMENT_CRAFTER_CLOSED") 
BulkieDisplayFrame:RegisterEvent("SHIPMENT_CRAFTER_INFO") 

function BulkieDisplayFrame:SHIPMENT_CRAFTER_OPENED (containerID) 
  BulkieDisplayFrame:Show() 
  self:SetScript("OnUpdate", nil) 
end 

function BulkieDisplayFrame:SHIPMENT_CRAFTER_CLOSED () 
  BulkieDisplayFrame:Hide() 
  self:SetScript("OnUpdate", nil) 
end 

function BulkieDisplayFrame:SHIPMENT_CRAFTER_INFO (success, _, maxShipments, plotID) 
  self.maxShipments = maxShipments 
  if self.maxShipments == C_Garrison.GetNumPendingShipments() then 
    button:Disable() 
  else 
    button:Enable() 
  end 
end 

-- set the click handler 
button:SetScript('OnClick', function(self) 
  BulkieDisplayFrame.elapsed = 0 
  BulkieDisplayFrame:SetScript("OnUpdate", function (self, elapsed) 
    self.elapsed = self.elapsed + elapsed 
    if self.elapsed > THROTTLE then 
      self.elapsed = 0 
      C_Garrison.RequestShipmentCreation() 
      if self.maxShipments == C_Garrison.GetNumPendingShipments() then 
        self:SetScript("OnUpdate", nil) 
        button:Disable() 
      end 
    end 
  end) 
end) 

-- set handlers for frame events 
BulkieDisplayFrame:SetScript ("OnEvent", function (self, event, ...) 
  if self[event] then 
    self[event] (self, ...) 
  end 
end)

---------------------------------------------------------------------------------------
--	任务栏自动收起/副本任务不收
---------------------------------------------------------------------------------------
local autocollapse = CreateFrame("Frame") 
autocollapse:RegisterEvent("ZONE_CHANGED_NEW_AREA") 
autocollapse:RegisterEvent("PLAYER_ENTERING_WORLD") 
autocollapse:SetScript("OnEvent", function(self) 
if IsInInstance() then 
ObjectiveTrackerFrame.userCollapsed = true 
ObjectiveTracker_Collapse() 
elseif IsInInstance() and not ScenarioBlocksFrame:IsVisible() then 
ObjectiveTrackerFrame.userCollapsed = nil 
ObjectiveTracker_Expand()
else
ObjectiveTrackerFrame.userCollapsed = nil 
ObjectiveTracker_Expand() 
end 
end)

---------------------------------------------------------------------------------------
--	单刷坐骑副本提示
---------------------------------------------------------------------------------------
local instList = { 
   [556] = 2,      -- 塞塔克大厅，乌鸦 
   [575] = 2,      -- 乌特加德之巅，蓝龙 
   [585] = 2,      -- 魔导师平台，白鸡 
   [603] = 4,      -- 奥杜尔，飞机头 
   [631] = 6,      -- 冰冠堡垒，无敌 
} 

local f = CreateFrame("Frame") 
f:RegisterEvent("ZONE_CHANGED_NEW_AREA") 
f:RegisterEvent("PLAYER_DIFFICULTY_CHANGED") 
f:RegisterEvent("PLAYER_ENTERING_WORLD") 
f:SetScript("OnEvent", function() 
   local name, _, instType, diffname, _, _, _, id = GetInstanceInfo() 
   if IsInInstance() then 
      if instList[id] and instList[id] ~= instType then 
         UIErrorsFrame:AddMessage(name.."-"..diffname.." 你确定选对难度了？", 1, .1, .1) 
      end 
   end 
end)


------------------------
--auto choose the dearest things
------------------------
local frame = CreateFrame("FRAME", "GreedyQuester", UIParent)
frame:RegisterEvent("QUEST_COMPLETE")
frame:SetScript("OnEvent", function() 
  local max, max_index = 0, 0
  for x=1,GetNumQuestChoices() do 
    local item = GetQuestItemLink("choice", x)
    if item then
      local price = select(11, GetItemInfo(item))
      if price > max then
        max, max_index = price, x
      end
    end
  end
  local button = _G["QuestInfoItem"..max_index]
  if button then button:Click() end
end)

---------------------------------------------------------------------------------------
--	谁在点击小地图
---------------------------------------------------------------------------------------
local addon = CreateFrame('ScrollingMessageFrame', false, Minimap) 
addon:SetHeight(10) 
addon:SetWidth(100) 
addon:SetPoint('TOP', Minimap, 0, -15) 

addon:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE') 
addon:SetJustifyH'CENTER' 
addon:SetJustifyV'CENTER' 
addon:SetMaxLines(1) 
addon:SetFading(true) 
addon:SetFadeDuration(3) 
addon:SetTimeVisible(5) 

addon:RegisterEvent'MINIMAP_PING' 
addon:SetScript('OnEvent', function(self, event, u) 
   local c = RAID_CLASS_COLORS[select(2,UnitClass(u))] 
   local name = UnitName(u) 
   addon:AddMessage(name, c.r, c.g, c.b) 
end)

--------------------------------------------
-- 不再显示XX制作
--------------------------------------------
ITEM_CREATED_BY=""

--------------------------------------------
-- 打开银行自动存材料
--------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("BANKFRAME_OPENED")
frame:SetScript("OnEvent", function(self, event, ...)
	if not BankFrameItemButton_Update_OLD then
		BankFrameItemButton_Update_OLD = BankFrameItemButton_Update
		
		BankFrameItemButton_Update = function(button)
			if BankFrameItemButton_Update_PASS == false then
				BankFrameItemButton_Update_OLD(button)
			else
				BankFrameItemButton_Update_PASS = false
			end
		end
	end
	
	BankFrameItemButton_Update_PASS = true
	DepositReagentBank()
	--print("Reagents deposited into Reagent Bank.")
end)
