local Entities        = require "system.game.Entities"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local Text = require "PowerSettings.i18n.Text"

local PSEntityEvent = require "PowerSettings.PSEntityEvent"
local PSMain        = require "PowerSettings.PSMain"
local PSStorage     = require "PowerSettings.PSStorage"

local module = {}

function module.format(value)
  local entity = Entities.getEntityPrototype(value)

  if entity then
    if entity.friendlyName then
      if SettingsStorage.get("config.showAdvanced") then
        return Text.Format.Entity(entity.friendlyName.name, value)
      else
        return entity.friendlyName.name
      end
    else
      return value
    end
  else
    return Text.Format.NoSuchEntity(value)
  end
end

function module.getFilteredEntities(filter)
  local out = {}

  if type(filter) == "function" then
    for i2, v2 in Entities.prototypesWithComponents({}) do
      if filter(v2) then
        out[#out + 1] = v2.name
      end
    end
  elseif type(filter) == "table" then
    out = Entities.getEntityTypesWithComponents(filter)
  elseif type(filter) == "string" then
    out = Entities.getEntityTypesWithComponents({ filter })
  else
    out = Entities.getEntityTypesWithComponents({})
  end

  return out
end

function module.action(id, layer)
  local node = PSStorage.get(id).data

  Menu.open("PowerSettings_entitySearch", {
    callback = function(value)
      SettingsStorage.set(id, value, layer)
      if node.refreshOnChange then
        Menu.update()
      end
    end,
    label = node.name,
    list = node.entities,
    node = node,
    query = "",
    textEntry = false
  })
end

function module.leftAction(id, layer)
  local node = PSStorage.get(id)
  local list = node.data.entities
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
  local list = node.data.entities
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
  args.entities = module.getFilteredEntities(args.filter)
  PSEntityEvent.add(args)

  if not args.id then
    if args.autoRegister then
      local id = Settings[mode].string(args)
      PSStorage.add("entity", args, id)
      return id
    else
      error(Text.Errors.SettingID)
    end
  else
    PSStorage.add("entity", args, PSMain.getModSettingPrefix() .. args.id)
    return Settings[mode].string(args)
  end
end

return module
