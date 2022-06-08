local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local NixLib = require "NixLib.NixLib"

local PSStorage    = require "PowerSettings.PSStorage"
local PSTBitflag   = require "PowerSettings.types.Bitflag"
local PSTComponent = require "PowerSettings.types.Component"
local PSTEntity    = require "PowerSettings.types.Entity"
local PSTHeader    = require "PowerSettings.types.Header"
local PSTLabel     = require "PowerSettings.types.Label"
local PSTList      = require "PowerSettings.types.List"
local PSTNumber    = require "PowerSettings.types.Number"
local PSTPreset    = require "PowerSettings.types.Preset"

local module = {}

local function defaultSetting(mode, sType, args)
  if sType == "action" and args.action == nil then
    args.action = function() end
  end
  PSStorage.add(sType, args)
  return Settings[mode][sType](args)
end

for _, v in ipairs({ "shared", "entitySchema" }) do
  module[v] = {}
  for _, t in ipairs({ "bool", "enum", "string", "table", "choice", "action" }) do
    module[v][t] = function(args) return defaultSetting(v, t, args) end
  end

  module[v].bitflag = function(args) return PSTBitflag.setting(v, args) end
  module[v].component = function(args) return PSTComponent.setting(v, args) end
  module[v].entity = function(args) return PSTEntity.setting(v, args) end
  module[v].number = function(args) return PSTNumber.setting(v, "number", args) end
  module[v].percent = function(args) return PSTNumber.setting(v, "percent", args) end
  module[v].time = function(args) return PSTNumber.setting(v, "time", args) end
  module[v].label = function(args) return PSTLabel.setting(v, args) end
  module[v].preset = function(args) return PSTPreset.setting(v, args) end
  module[v].header = function(args) return PSTHeader.setting(v, args) end
  module[v].list = {}

  for _, t in ipairs({ "string", "number", "enum", "entity", "component" }) do
    module[v].list[t] = function(args) return PSTList.setting(v, t, args) end
  end
end

function module.group(args)
  PSStorage.add("group", args)
  return Settings.group(args)
end

function module.reset(prefix)
  local keys = SettingsStorage.listKeys(prefix, Settings.Layer.REMOTE_OVERRIDE)
  for _, key in ipairs(keys) do
    SettingsStorage.set(key, nil, Settings.Layer.REMOTE_PENDING)
  end
end

function module.getIgnored(data)
  if data.ignoredIsNil then
    return nil
  elseif data.ignored ~= nil then
    return data.ignoredValue
  else
    return data.default
  end
end

function module.get(setting, layers)
  layers = layers or { Settings.Layer.REMOTE_PENDING, Settings.Layer.REMOTE_OVERRIDE, Settings.Layer.DEFAULT }

  -- Do we have an ignore condition?
  local node = PSStorage.get(setting)
  if node then
    local ignoredIf = node.data.ignoredIf
    local visibleIf = node.data.visibleIf
    -- If it exists and is true, return the default value.
    if type(ignoredIf) == "function" then
      if ignoredIf() then
        return module.getIgnored(node.data)
      end
    elseif type(ignoredIf) == "bool" then
      -- This mostly exists to allow "ignoredIf=false" so that an invisible setting still affects the gameplay.
      if ignoredIf then
        return module.getIgnored(node.data)
      end
    elseif type(visibleIf) == "function" then
      -- Do we have a visibility condition?
      -- If so and it's *false*, return the default value.
      if not visibleIf() then
        return module.getIgnored(node.data)
      end
    end
  end

  -- Otherwise try grabbing it by the layers.
  for i, layer in ipairs(layers) do
    local try = SettingsStorage.get(setting, layer)
    if try ~= nil then return try end
  end

  return SettingsStorage.get(setting, Settings.Layer.DEFAULT)
end

function module.getRaw(setting, layers)
  layers = layers or { Settings.Layer.REMOTE_PENDING, Settings.Layer.REMOTE_OVERRIDE, Settings.Layer.DEFAULT }

  -- Try grabbing it by the layers.
  for i, layer in ipairs(layers) do
    local try = SettingsStorage.get(setting, layer)
    if try ~= nil then return try end
  end

  return SettingsStorage.get(setting, Settings.Layer.DEFAULT)
end

return module
