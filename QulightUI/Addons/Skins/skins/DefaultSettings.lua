---------
--Skada Settings
---------
local SetSkada = function()
  if IsAddOnLoaded("Skada") then
      if(SkadaDB) then table.wipe(SkadaDB) end
      SkadaDB = {
        ["hasUpgraded"] = true,
        ["profiles"] = {
          ["Default"] = {
            ["windows"] = {
              {
                ["barslocked"] = true,
                ["background"] = {
                  ["height"] = 135,
                },
                ["y"] = 23,
                ["x"] = -5,
                ["barwidth"] = 436,
                ["point"] = "BOTTOMRIGHT",
                ["modeincombat"] = "Damage",
              }, -- [1]
            },
            ["icon"] = {
              ["minimapPos"] = 206.0,
              ["hide"] = true,
            },
          },
        },
      }
  end
end
---------
--DBM Settings
---------

local SetDBM = function()
  if IsAddOnLoaded("DBM-Core") then
    DBM_SavedOptions = {
      ["ShowMinimapButton"] = false,


      ["RaidWarningPosition"] = {
      ["Y"] = -220,
      ["X"] = 0,
      ["Point"] = "TOP",
    },

      --SpecialWarning
      ["ShowSpecialWarnings"] = true,
      ["SpecialWarningPoint"] = "TOP",
      ["SpecialWarningX"] = 0,
      ["SpecialWarningY"] = -255.0,
      ["SpecialWarningFont"] = "Fonts\\Font.ttf",
      ["SpecialWarningFontSize"] = 50,

      --InfoFrame
      ["DontShowInfoFrame"] = false,
      ["InfoFramePoint"] = "CENTER",
      ["InfoFrameX"] = -370,
      ["InfoFrameY"] = -445,


      --RangeFrame
      ["DontShowRangeFrame"] = false,
      ["RangeFramePoint"] = "CENTER",
      ["RangeFrameFrames"] = "radar",
      ["RangeFrameRadarPoint"] = "CENTER",
      ["RangeFrameRadarX"] = 370,
      ["RangeFrameRadarY"] = -450,
      ["RangeFrameLocked"] = false,
      ["RangeFrameUpdates"] = "Average",
    }

    DBT_PersistentOptions = {
      ["DBM"] = {
        ["StartColorR"] = 0.58,
        ["StartColorB"] = 0.51,
        ["StartColorG"] = 0.79,
        ["EndColorR"] = 1,
        ["EndColorG"] = 0,
        ["EndColorB"] = 0,
        ["EnlargeBarsPercent"] = 0.125,
        ["EnlargeBarsTime"] = 8,
        ["FontSize"] = 12,
        ["IconLeft"] = true,
        ["FillUpBars"] = true,
        ["ExpandUpwards"] = true,
        ["Texture"] = Qulight["media"].texture,
        --Timer
        ["Scale"] = 1,
        ["TimerPoint"] = "CENTER",
        ["TimerX"] = -420.0,
        ["TimerY"] = 140.0,
        ["Width"] = 190,
        ["Height"] = 20,
        ["BarXOffset"] = 0,
        ["BarYOffset"] = 5,

        --HugeTimer
        ["HugeScale"] = 1,
        ["HugeWidth"] = 190,
        ["HugeHeight"] = 20,
        ["HugeTimerPoint"] = "CENTER",
        ["HugeTimerX"] = 0.0,
        ["HugeTimerY"] = 	30.0,
        ["HugeBarXOffset"] = 0,
        ["HugeBarYOffset"] = 7,
      },
    }
  end
end


---------
--Settings Loader
---------

StaticPopupDialogs["LoadDefaultSettings"] = {
  text = "Load the Default settings for DBM and Skada?",
  button1 = YES,
  button2 = NO,
  OnAccept = function()
      SetSkada();
      SetDBM();
      ReloadUI();
  end,
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1
}

SLASH_CONFIG1 = "/loadDefault"
SlashCmdList["CONFIG"] = function() StaticPopup_Show("LoadDefaultSettings") end
