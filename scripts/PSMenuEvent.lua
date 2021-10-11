local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local PSStorage = require "PowerSettings.PSStorage"

Event.menu.override("settings", 1, function(func, ev)
  func(ev)

  if ev.arg.prefix:sub(1,4) == "mod." then
    for i, v in ipairs(ev.menu.entries) do
      -- print(v.id)
      local node = PSStorage.get(v.id)
      
      if not node then return end
      
      local data = node.data

      -- Code for basic settings
      if not SettingsStorage.get("config.showAdvanced") then
        -- print("Basic settings shown")
        if data.ps_basicName then
          v.label = function() return data.ps_basicName .. ": " .. SettingsStorage.getFormattedValue(v.id, SettingsStorage.get(v.id, Settings.Layer.REMOTE_PENDING)) end
        end
      end
    end
  end
end)