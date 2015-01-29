local addon, ns = ...
local config = CreateFrame("Frame")

config.width = 338		--长度
config.height = 7		--宽度
config.position = {"CENTER", UIParent, "CENTER", 0, -210}		--锚点
config.fade = false 		--脱离战斗渐隐
config.tex = "Interface\\Buttons\\WHITE8x8"		--材质

ns.config = config
