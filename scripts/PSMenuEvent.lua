local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local PSBitflag = require "PowerSettings.types.Bitflag"
local PSEntity  = require "PowerSettings.types.Entity"
local PSNumber  = require "PowerSettings.types.Number"
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
        v.action = function()
          if SettingsStorage.get("config.showAdvanced") then
            PSBitflag.action(v.id)
          else
            PSBitflag.rightAction(v.id)
          end
        end
        v.leftAction = function() PSBitflag.leftAction(v.id) end
        v.rightAction = function() PSBitflag.rightAction(v.id) end

      -- Setting type "entity"
      elseif node.sType == "entity" then
        v.action = function() PSEntity.action(v.id) end
        v.leftAction = function() PSEntity.leftAction(v.id) end
        v.rightAction = function() PSEntity.rightAction(v.id) end

      -- Numeric setting types with greaterThan/lessThan parameters
      elseif node.sType == "number" or node.sType == "time" or node.sType == "percent" then
        if data.lowerBound or data.upperBound then
          local cAction = v.action
          local cLeftAction = v.leftAction
          local cRightAction = v.rightAction
          local cSpecialAction = v.specialAction

          v.action = function() cAction() PSNumber.validateBounds(v.id) end
          v.leftAction = function() cLeftAction() PSNumber.validateBounds(v.id) end
          v.rightAction = function() cRightAction() PSNumber.validateBounds(v.id) end
          v.specialAction = function() cSpecialAction() PSNumber.validateBounds(v.id) end
        end
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