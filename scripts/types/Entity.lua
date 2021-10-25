local Entities        = require "system.game.Entities"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local PSStorage     = require "PowerSettings.PSStorage"
local PSEntityEvent = require "PowerSettings.PSEntityEvent"

local module = {}

function module.format(value)
  local entity = Entities.getEntityPrototype(value)

  if entity then
    if entity.friendlyName then
      if SettingsStorage.get("config.showAdvanced") then
        return entity.friendlyName.name .. " (" .. value .. ")"
      else
        return entity.friendlyName.name
      end
    else
      return value
    end
  else
    return "(No such entity: " .. value .. ")"
  end
end

function module.getFilteredEntities(filter)
  local out = {}

  if type(filter) == "function" then
    for i2, v2 in Entities.typesWithComponents({}) do
      if filter(v2) then
        out[#out+1] = v2.name
      end
    end
  elseif type(filter) == "table" then
    out = Entities.getEntityTypesWithComponents(filter)
  elseif type(filter) == "string" then
    out = Entities.getEntityTypesWithComponents({filter})
  else
    out = Entities.getEntityTypesWithComponents({})
  end

  return out
end

function module.action(id)
  local node = PSStorage.get(id).data

  Menu.open("PowerSettings_entitySearch", {
    id=id,
    label=node.name,
    list=node.entities,
    node=node,
    query="",
    textEntry=false
  })
end

function module.leftAction(id)
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

  SettingsStorage.set(id, leftValue, Settings.Layer.REMOTE_PENDING)
end

function module.rightAction(id)
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

  SettingsStorage.set(id, useNext, Settings.Layer.REMOTE_PENDING)
end

function module.setting(mode, args)
  args.editAsString = false -- forcibly false, we'll use a menu instead
  args.format = args.format or module.format
  args.entities = module.getFilteredEntities(args.filter)
  PSStorage.add("entity", args)
  PSEntityEvent.add(args)
  return Settings[mode].string(args)
end

return module