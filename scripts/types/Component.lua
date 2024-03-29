local Entities        = require "system.game.Entities"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local Text = require "PowerSettings.i18n.Text"

local PSEntityEvent = require "PowerSettings.PSEntityEvent"
local PSMain        = require "PowerSettings.PSMain"
local PSStorage     = require "PowerSettings.PSStorage"

local NixLib = require "NixLib.NixLib"

local module = {}

function module.format(value)
  local component = NixLib.getComponent(value)

  if component then
    return value
  else
    return Text.Format.NoSuchComponent(value)
  end
end

function module.getFilteredComponents(filter)
  local out = {}

  if type(filter) == "function" then
    for k, v in pairs(NixLib.getComponents()) do
      if filter(v) then
        out[#out + 1] = v.name
      end
    end
  elseif type(filter) == "table" then
    for i, v in ipairs(filter) do
      if NixLib.getComponent(v) then
        out[#out + 1] = v.name
      end
    end
  elseif type(filter) == "string" then
    for k, v in pairs(NixLib.getComponents()) do
      if v.name:sub(1, filter:len()) == filter then
        out[#out + 1] = v.name
      end
    end
  else
    for k, v in pairs(NixLib.getComponents()) do
      out[#out + 1] = v.name
    end
  end

  return out
end

function module.action(id, layer)
  local node = PSStorage.get(id).data

  Menu.open("PowerSettings_componentSearch", {
    callback = function(value)
      SettingsStorage.set(id, value, layer)
      if node.refreshOnChange then
        Menu.update()
      end
    end,
    label = node.name,
    list = node.components,
    node = node,
    query = "",
    textEntry = false
  })
end

function module.leftAction(id, layer)
  local node = PSStorage.get(id)
  local list = node.data.components
  local value = SettingsStorage.get(id, Settings.Layer.REMOTE_PENDING) or SettingsStorage.get(id)
  local leftValue = nil

  for i, v in ipairs(list) do
    if v == value then
      if leftValue == nil then leftValue = list[#list] end
      break
    end
    leftValue = v
  end

  if leftValue == nil then leftValue = "" end

  SettingsStorage.set(id, leftValue, layer)
end

function module.rightAction(id, layer)
  local node = PSStorage.get(id)
  local list = node.data.components
  local value = SettingsStorage.get(id, Settings.Layer.REMOTE_PENDING) or SettingsStorage.get(id)
  local useNext = nil

  for i, v in ipairs(list) do
    if useNext == true then useNext = v break end
    if v == value then useNext = true end
  end

  if useNext == nil or useNext == true then useNext = list[1] end
  if useNext == nil then useNext = "" end

  SettingsStorage.set(id, useNext, layer)
end

function module.setting(mode, args)
  args.editAsString = false -- forcibly false, we'll use a menu instead
  args.format = args.format or module.format
  args.components = module.getFilteredComponents(args.filter)
  PSEntityEvent.addc(args)

  if not args.id then
    if args.autoRegister then
      local id = Settings[mode].string(args)
      PSStorage.add("component", args, id)
      return id
    else
      error(Text.Errors.SettingID)
    end
  else
    PSStorage.add("component", args, PSMain.getModSettingPrefix() .. args.id)
    return Settings[mode].string(args)
  end
end

return module
