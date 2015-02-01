----------------------------------
-- 屏幕两侧显示血量百分比
---------------------------------
local hideHealth = Qulight["hide"].health
local hidePower = Qulight["hide"].power
if hideHealth and hidePower then return end
Anchorplayerpercent = CreateFrame("Frame","Move_playerpercent",UIParent)
Anchorplayerpercent:SetPoint("TOPRIGHT", UIParent, "BOTTOM", -213-110, 365)
CreateAnchor(Anchorplayerpercent, "Move player percent", 110, 60)

Anchortargetpercent = CreateFrame("Frame","Move_targetpercent",UIParent)
Anchortargetpercent:SetPoint("TOPLEFT", UIParent, "BOTTOM", 213+110, 365)
CreateAnchor(Anchortargetpercent, "Move target percent", 110, 60)

PowerBarColor[0] = {r=0.16, g=0.41, b=0.80}
local SetFontString = function(parent, fontSize, justify) 
   local fs = parent:CreateFontString(nil, "OVERLAY") 
   fs:SetFont(Qulight["media"].combatfont, fontSize, "outline") 
   fs:SetJustifyH(justify) 
   return fs 
end 
local SVal = function(val) 
   if val then 
      if (val >= 1e8) then 
         return format("%.2fy", val / 1e8) 
      elseif (val >= 1e4) then 
         return format("%.2fw", val / 1e4) 
      else 
         return format("%d",val) 
      end 
   end 
end 

local PlayerPanel = CreateFrame("Frame", nil, UIParent) 
PlayerPanel:SetPoint("LEFT",Anchorplayerpercent,0,0) 
PlayerPanel:SetSize(1,1) 
local TargetPanel = CreateFrame("Frame", nil, UIParent) 
TargetPanel:SetPoint("RIGHT",Anchortargetpercent,0,0) 
TargetPanel:SetSize(1,1) 
local PHString, THString
if not hideHealth then
   if hidePower then
      PHString = SetFontString(PlayerPanel,50,"LEFT") 
      PHString:SetPoint("LEFT",PlayerPanel,"RIGHT",0,-20) 
      THString = SetFontString(TargetPanel,50,"RIGHT") 
      THString:SetPoint("RIGHT",TargetPanel,"LEFT",3,-20) 
   else
      PHString = SetFontString(PlayerPanel,50,"LEFT") 
      PHString:SetPoint("LEFT",PlayerPanel,"RIGHT",0,0) 
      THString = SetFontString(TargetPanel,50,"RIGHT") 
      THString:SetPoint("RIGHT",TargetPanel,"LEFT",3,0)
   end
end
local PPString, TPString
if not hidePower then
   PPString = SetFontString(PlayerPanel,14,"LEFT") 
   PPString:SetPoint("TOPLEFT",PlayerPanel,"BOTTOM",0,-18) 
   TPString = SetFontString(TargetPanel,14,"LEFT") 
   TPString:SetPoint("TOPRIGHT",TargetPanel,"BOTTOM",3,-18) 
end

TargetPanel:RegisterEvent("PLAYER_ENTERING_WORLD") 
TargetPanel:RegisterEvent("PLAYER_TARGET_CHANGED") 
TargetPanel:RegisterEvent("UNIT_HEALTH") 
TargetPanel:RegisterEvent("UNIT_MAXHEALTH") 
TargetPanel:SetScript("OnEvent",function() 
   local Pclasscolor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2,UnitClass('player'))] 
   local Tclasscolor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2,UnitClass('target'))] 
   local Ppowercolor = PowerBarColor[UnitPowerType("player")] 
   local Tpowercolor = PowerBarColor[UnitPowerType("target")] 
   if not hideHealth then
      PHString:SetTextColor(Pclasscolor.r,Pclasscolor.g,Pclasscolor.b) 
   end
   if not hidePower then
      PPString:SetTextColor(Ppowercolor.r,Ppowercolor.g,Ppowercolor.b)
   end
   if Tclasscolor then 
      if not hideHealth then
         THString:SetTextColor(Tclasscolor.r,Tclasscolor.g,Tclasscolor.b) 
      end
   end 
   if Tpowercolor then 
      if not hidePower then
         TPString:SetTextColor(Tpowercolor.r,Tpowercolor.g,Tpowercolor.b)
      end
   end 
    if not UnitExists("target")then 
         TargetPanel:SetAlpha(0) 
      else 
         TargetPanel:SetAlpha(1) 
      end 
   
end) 
TargetPanel:SetScript("OnUpdate",function() 
   if not hideHealth then
      if UnitHealthMax("player")>0 then PHString:SetText(format("%d",UnitHealth("player")/UnitHealthMax("player")*100)) end 
      if UnitHealthMax("target")>0 then THString:SetText(format("%d",UnitHealth("target")/UnitHealthMax("target")*100)) end   
   end
   if not hidePower then
      PPString:SetText(SVal(UnitPower("player")).."/"..SVal(UnitPowerMax("player"))) 
      TPString:SetText(SVal(UnitPower("target")).."/"..SVal(UnitPowerMax("target"))) 
   end
end)

