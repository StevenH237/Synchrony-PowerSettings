local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local Bitflag   = require "PowerSettings.types.Bitflag"
local EnumUtils = require "PowerSettings.EnumUtils"
local PSStorage = require "PowerSettings.PSStorage"

local function flipBit(node, ind)
  local value = SettingsStorage.get(node, Settings.Layer.REMOTE_PENDING) or SettingsStorage.get(node)
  SettingsStorage.set(node, bit.bxor(value, ind), Settings.Layer.REMOTE_PENDING)
end

local function labelBit(node, name, ind)
  local out = name .. ": "
  local value = SettingsStorage.get(node, Settings.Layer.REMOTE_PENDING) or SettingsStorage.get(node)

  if bit.band(value, ind) ~= 0 then
    out = out .. "\3*9e9On\3r"
  else
    out = out .. "\3*e99Off\3r"
  end

  return out
end

Event.menu.add("menuBitflag", "PowerSettings_bitflag", function(ev)
  ev.menu = {}
  local entries = {}
  local advanced = SettingsStorage.get("config.showAdvanced")

  local data = PSStorage.get(ev.arg).data
  ev.menu.label = data.name

  local flags = data.flags

  for i = 0, 31 do
    local v = bit.lshift(1, i)
    local k = EnumUtils.getName(flags, v)
    if not k then goto nextBit end
    if advanced then
      local hex = bit.tohex(v, 8)
      hex = hex:sub(hex:find("[123456789abcdef]", 1, false), -1)
      k = k .. " (0x" .. hex .. ")"
    end
    local action = function() flipBit(ev.arg, v) end
    local entry = {
      id = ev.arg .. ".bit" .. v,
      leftAction = action,
      rightAction = action,
      action = action,
      label = function() return labelBit(ev.arg, k, v) end
    }
    table.insert(entries, entry)
    ::nextBit::
  end

  table.insert(entries, {height=0})
  table.insert(entries, {
    action=Menu.close,
    id="_done",
    label="Done",
    sound="UIBack"
  })

  ev.menu.entries = entries
  ev.menu.escapeAction = Menu.close
end)