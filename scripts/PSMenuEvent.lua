local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local PSBitflag = require "PowerSettings.types.Bitflag"
local PSStorage = require "PowerSettings.PSStorage"

Event.menu.override("settings", 1, function(func, ev)
  func(ev)

  if ev.arg.prefix:sub(1,4) == "mod." then
    for i, v in ipairs(ev.menu.entries) do
      local node = PSStorage.get(v.id)

      if not node then goto notNode end

      local data = node.data

      -- Setting type "bitflag"
      if node.sType == "bitflag" then
        v.action = function() PSBitflag.action(v.id) end
        v.leftAction = function() PSBitflag.leftAction(v.id) end
        v.rightAction = function() PSBitflag.rightAction(v.id) end
      end

      -- Code for basic settings
      if not SettingsStorage.get("config.showAdvanced") then
        if data.ps_basicName then
          v.label = function() return data.ps_basicName .. ": " .. SettingsStorage.getFormattedValue(v.id, SettingsStorage.get(v.id, Settings.Layer.REMOTE_PENDING)) end
        end
      end

      ::notNode::
    end
  end
end)