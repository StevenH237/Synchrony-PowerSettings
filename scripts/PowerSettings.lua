local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local NixLib = require "NixLib.NixLib"

local Text = require "PowerSettings.i18n.Text"

local PSMain        = require "PowerSettings.PSMain"
local PSStorage     = require "PowerSettings.PSStorage"
local PSTBitflag    = require "PowerSettings.types.Bitflag"
local PSTComponent  = require "PowerSettings.types.Component"
local PSTEntity     = require "PowerSettings.types.Entity"
local PSTHeader     = require "PowerSettings.types.Header"
local PSTLabel      = require "PowerSettings.types.Label"
local PSTList       = require "PowerSettings.types.List"
local PSTMultiLabel = require "PowerSettings.types.MultiLabel"
local PSTNumber     = require "PowerSettings.types.Number"
local PSTPreset     = require "PowerSettings.types.Preset"

local module = {}

local function autoRegister(args)
  if PSMain.isAutoRegister() and args.autoRegister == nil then
    args.autoRegister = true
  end
end

local function defaultSetting(mode, sType, args)
  if sType == "action" and args.action == nil then
    args.action = function() end
  end

  if not args.id then
    if args.autoRegister then
      local id = Settings[mode][sType](args)
      PSStorage.add(sType, args, id)
      return id
    else
      error(Text.Errors.SettingID)
    end
  else
    PSStorage.add(sType, args, PSMain.getModSettingPrefix() .. args.id)
    return Settings[mode][sType](args)
  end
end

for _, v in ipairs({ "shared", "entitySchema", "user", "overridable" }) do
  module[v] = {}
  for _, t in ipairs({ "bool", "enum", "string", "table", "choice", "action" }) do
    module[v][t] = function(args) autoRegister(args) return defaultSetting(v, t, args) end
  end

  module[v].bitflag = function(args) autoRegister(args) return PSTBitflag.setting(v, args) end
  module[v].component = function(args) autoRegister(args) return PSTComponent.setting(v, args) end
  module[v].entity = function(args) autoRegister(args) return PSTEntity.setting(v, args) end
  module[v].number = function(args) autoRegister(args) return PSTNumber.setting(v, "number", args) end
  module[v].percent = function(args) autoRegister(args) return PSTNumber.setting(v, "percent", args) end
  module[v].time = function(args) autoRegister(args) return PSTNumber.setting(v, "time", args) end
  module[v].label = function(args) autoRegister(args) return PSTLabel.setting(v, args) end
  module[v].multiLabel = function(args) autoRegister(args) return PSTMultiLabel.setting(v, args) end
  module[v].preset = function(args) autoRegister(args) return PSTPreset.setting(v, args) end
  module[v].header = function(args) autoRegister(args) return PSTHeader.setting(v, args) end
  module[v].list = {}

  for _, t in ipairs({ "string", "number", "enum", "entity", "component" }) do
    module[v].list[t] = function(args) autoRegister(args) return PSTList.setting(v, t, args) end
  end
end

function module.group(args)
  autoRegister(args)

  if not args.id then
    if args.autoRegister then
      local id = Settings.group(args)
      PSStorage.add("group", args, id)
      return id
    else
      error(Text.Errors.SettingID)
    end
  else
    PSStorage.add("group", args, PSMain.getModSettingPrefix() .. args.id)
    return Settings.group(args)
  end
end

function module.reset(prefix, layer)
  local layerIn = layer or Settings.Layer.REMOTE_OVERRIDE
  local layerOut = layerIn

  if layerIn == Settings.Layer.REMOTE_OVERRIDE then
    layerOut = Settings.Layer.REMOTE_PENDING
  end

  local keys = SettingsStorage.listKeys(prefix, layerIn)
  for _, key in ipairs(keys) do
    SettingsStorage.set(key, nil, layerOut)
  end
end

function module.getIgnored(data)
  if data.ignoredIsNil then
    return nil
  elseif data.ignoredValue ~= nil then
    return data.ignoredValue
  else
    return data.default
  end
end

local function getRawSetting(id)
  local n = PSStorage.get(id)
  if n then
    local node = n.data -- This is the settings definition table, the same one actually passed to Settings.*.*
    for i, v in ipairs(node.layers) do
      if v == Settings.Layer.REMOTE_OVERRIDE then
        local val = SettingsStorage.get(id, Settings.Layer.REMOTE_PENDING)
        if val ~= nil then return val end
      end
      local val = SettingsStorage.get(id, v)
      if val ~= nil then return val end
    end
  else
    return SettingsStorage.get(id) -- Fallback if the setting wasn't actually defined in PowerSettings
  end
end

function module.get(setting, layers)
  local node = PSStorage.get()

  -- Do we have an ignore condition?
  if node then
    local ignoredIf = node.data.ignoredIf
    -- If it exists and is true, return the default value.
    if type(ignoredIf) == "function" then
      if ignoredIf() then
        return module.getIgnored(node.data)
      end
    end
  end

  if type(layers) == nil then
    return getRawSetting(setting)
  end

  if type(layers) ~= "table" then
    layers = { layers }
  end

  -- Try grabbing it by the layers.
  for i, layer in ipairs(layers) do
    local try = SettingsStorage.get(setting, layer)
    if try ~= nil then return try end
  end

  return SettingsStorage.get(setting)
end

function module.getRaw(setting, layers)
  local node = PSStorage.get()

  if type(layers) == nil then
    return getRawSetting(setting)
  end

  if type(layers) ~= "table" then
    layers = { layers }
  end

  -- Try grabbing it by the layers.
  for i, layer in ipairs(layers) do
    local try = SettingsStorage.get(setting, layer)
    if try ~= nil then return try end
  end

  return SettingsStorage.get(setting)
end

function module.autoRegister()
  PSMain.setAutoRegister(true)
end

-- Backwards compatibility with vanilla Settings
module.shared.group = module.group
module.entitySchema.group = module.group

for _, v in ipairs({ "Scope", "Type", "Visibility", "Tag", "Layer", "Format" }) do
  module[v] = Settings[v]
end

-- And explain the intentional lack of backwards compatibility:
local moduleMeta = {}

function moduleMeta.index(table, key)
  if key == "overridable" then
    error(L("PowerSettings does not support overridable settings (yet!). You'll need to use regular Settings for those."
      , "overridableError"))
  elseif key == "user" then
    error(L("PowerSettings does not support user settings (yet!). You'll need to use regular Settings for those.",
      "userError"))
  end
end

setmetatable(module, moduleMeta)

return module
