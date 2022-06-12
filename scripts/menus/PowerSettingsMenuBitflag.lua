local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"
local TextFormat      = require "necro.config.i18n.TextFormat"

local EnumUtils = require "PowerSettings.EnumUtils"
local PSStorage = require "PowerSettings.PSStorage"

local NKeyBank = require "NixLib.i18n.KeyBank"

local function flipBit(node, ind)
  local value = SettingsStorage.get(node, Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue(node)
  SettingsStorage.set(node, bit.bxor(value, ind), Settings.Layer.REMOTE_PENDING)
end

local function labelBit(node, name, ind)
  local out = name .. " "
  local value = SettingsStorage.get(node, Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue(node)

  if bit.band(value, ind) ~= 0 then
    out = out .. TextFormat.Symbol.CHECKBOX_ON
  else
    out = out .. TextFormat.Symbol.CHECKBOX_OFF
  end

  return out
end

local function finish(refresh)
  Menu.close()
  if refresh then
    Menu.update()
  end
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

  table.insert(entries, { height = 0 })
  table.insert(entries, {
    action = function() finish(data.refreshOnChange) end,
    id = "_done",
    label = NKeyBank.Done,
    sound = "UIBack"
  })

  ev.menu.entries = entries
  ev.menu.escapeAction = function() finish(data.refreshOnChange) end
end)
