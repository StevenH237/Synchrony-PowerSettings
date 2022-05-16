local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"
local Utilities       = require "system.utils.Utilities"

local PowerSettings = require "PowerSettings.PowerSettings"
local PSBitflag     = require "PowerSettings.types.Bitflag"
local PSEntity      = require "PowerSettings.types.Entity"
local PSComponent   = require "PowerSettings.types.Component"
local PSList        = require "PowerSettings.types.List"
local PSNumber      = require "PowerSettings.types.Number"
local PSStorage     = require "PowerSettings.PSStorage"

Event.menu.override("settings", 1, function(func, ev)
  func(ev)

  if ev.arg.prefix:sub(1, 4) == "mod." then
    local entries = ev.menu.entries
    local i = 1

    while i <= #entries do
      local v = entries[i]

      if not v.id then
        i = i + 1
        goto notNode
      end

      local node = PSStorage.get(v.id)

      -- If it's not a PowerSettings node
      if not node then
        i = i + 1
        goto notNode
      end

      local data = node.data

      -- If it's an invisible node
      local visibility = data.visibleIf
      if type(visibility) == "function" then
        if not visibility() then
          table.remove(entries, i)
          goto notNode
        end
      end

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

        -- Setting type "component"
      elseif node.sType == "component" then
        v.action = function() PSComponent.action(v.id) end
        v.leftAction = function() PSComponent.leftAction(v.id) end
        v.rightAction = function() PSComponent.rightAction(v.id) end

        -- Setting type "list.*"
      elseif node.sType:sub(1, 5) == "list." then
        v.action = function() PSList.action(v.id) end
        v.textEntry = nil
        v.textEntryToggle = nil

      elseif node.sType == "label" then
        v.action = nil
        v.textEntry = nil
        v.textEntryToggle = nil
        v.leftAction = nil
        v.rightAction = nil
        v.specialAction = nil
        if not node.data.large then
          v.font = {
            fillColor = -1,
            font = "gfx/necro/font/necrosans-6.png;",
            shadowColor = -16777216,
            size = 6
          }
        end

        -- Numeric setting types
      elseif node.sType == "number" or node.sType == "time" or node.sType == "percent" then
        -- greaterThan/lessThan parameters
        if data.lowerBound or data.upperBound then
          if v.action then
            local cAction = v.action
            v.action = function() cAction() PSNumber.validateBounds(v.id) end
          end

          if v.leftAction then
            local cLeftAction = v.leftAction
            v.leftAction = function() cLeftAction() PSNumber.validateBounds(v.id) end
          end

          if v.rightAction then
            local cRightAction = v.rightAction
            v.rightAction = function() cRightAction() PSNumber.validateBounds(v.id) end
          end

          if v.specialAction then
            local cSpecialAction = v.specialAction
            v.specialAction = function() cSpecialAction() PSNumber.validateBounds(v.id) end
          end

          if v.textEntryToggle then
            local cTextEntryToggle = v.textEntryToggle
            v.textEntryToggle = function(active, confirm) cTextEntryToggle(active, confirm) PSNumber.validateBounds(v.id) end
          end
        end

      elseif node.sType == "action" then
        -- side and special actions
        if data.leftAction then v.leftAction = data.leftAction end
        if data.rightAction then v.rightAction = data.rightAction end
        if data.specialAction then v.specialAction = data.specialAction end
      end

      -- Code for basic settings
      if not SettingsStorage.get("config.showAdvanced") then
        if data.basicName then
          v.label = function() return data.basicName .. ": " .. SettingsStorage.getFormattedValue(v.id, SettingsStorage.get(v.id, Settings.Layer.REMOTE_PENDING)) end
        end
      end

      i = i + 1
      ::notNode::
    end
  end
end)
