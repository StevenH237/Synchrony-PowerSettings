local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"
local Utilities       = require "system.utils.Utilities"

local PSComponent   = require "PowerSettings.types.Component"
local PSEntity      = require "PowerSettings.types.Entity"
local PSEntityEvent = require "PowerSettings.PSEntityEvent"
local PSStorage     = require "PowerSettings.PSStorage"

local module = {}

local function defaultListFormat(itemFormat, list)
  if #list == 0 then return L("Empty", "emptyList")
  elseif #list == 1 then return string.format("{%s}", itemFormat(list[1]))
  elseif #list == 2 then return L("2 items", "twoItemList")
  else return L.formatKey("%d items", "manyItemList", #list) end
end

function module.action(id)
  Menu.open("PowerSettings_list", {
    id = id,
    items = SettingsStorage.get(id, Settings.Layer.REMOTE_PENDING) or
        Utilities.fastCopy(SettingsStorage.getDefaultValue(id)),
    mode = module.Mode.MODIFY,
    node = PSStorage.get(id)
  })
end

function module.setting(mode, itemType, args)
  args.itemFormat = args.itemFormat or module[itemType].itemFormat
  args.itemDefault = args.itemDefault or module[itemType].itemDefault
  args.minimum = args.minimum or module[itemType].minimum
  args.maximum = args.maximum or module[itemType].maximum
  args.step = args.step or module[itemType].step
  args.visibility = args.visibility or Settings.Visibility.VISIBLE
  args.format = args.format or function(value) return defaultListFormat(args.itemFormat, value) end
  args.default = args.default or {}

  if itemType == "enum" then
    args.itemFormat = args.itemFormat or function(value) return args.enum.prettyNames[value] end
    args.itemDefault = args.itemDefault or ({ next(args.enum) })[2]
  elseif itemType == "entity" then
    args.itemFormat = args.itemFormat or PSEntity.format
    args.entities = PSEntity.getFilteredEntities(args.filter)
    PSEntityEvent.add(args)
  elseif itemType == "component" then
    args.itemFormat = args.itemFormat or PSComponent.format
    args.components = PSComponent.getFilteredComponents(args.filter)
    PSEntityEvent.addc(args)
  end

  PSStorage.add("list." .. itemType, args)
  return Settings[mode].string(args)
end

module.Mode = {
  MODIFY = 1,
  ORGANIZE = 2
}

local function numberEditAsString(arg, key)
  local value = arg.textEntry
  if not key then
    value = value:sub(1, -2)
  elseif key == "-" then
    -- there are two cases when it's allowed:
    -- • at the very start of a number, OR
    -- • immediately after an `e` in a non-hexadecimal number
    if value == "" or (value:sub(-1) == "e" and not value:find("x", 1, true)) then
      value = value .. "-"
    end
  elseif key == "." then
    -- a decimal point is only allowed when:
    -- • the number is not hexadecimal, AND
    -- • the number doesn't already have a decimal portion, AND
    -- • the number doesn't already have an exponential portion
    if not (string.find(value, ".", 1, true) or string.find(value, "e", 1, true) or string.find(value, "x", 1, true)) then
      value = value .. "."
    end
  elseif key == "0" or key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or
      key == "8" or key == "9" then
    -- numbers are always allowed
    value = value .. key
  elseif ({ ["a"] = true, ["b"] = true, ["c"] = true, ["d"] = true, ["f"] = true })[key:lower()] then
    -- "abcdf"
    -- allowed only in hexadecimal numbers
    if value:find("x", 1, true) then
      value = value .. key:lower()
    end
  elseif key == "E" or key == "e" then
    -- allowed under two conditions:
    -- • the number is hexadecimal, OR
    -- • the number doesn't contain an exponential portion
    if value:find("x", 1, true) or not value:find("e", 1, true) then
      value = value .. "e"
    end
  elseif key == "X" or key == "x" then
    -- "x"
    -- allowed only under two conditions:
    -- • the number is exactly "0", OR
    -- • the number is empty
    if value == "" or value == "0" then
      value = "0x"
    end
  end
  arg.textEntry = value
end

local function numberTextEntryToggle(arg, active, confirm)
  if active then
    arg.textEntry = tostring(arg.items[arg.selected])
  else
    if confirm then
      local out = tonumber(arg.textEntry) or 0
      local data = arg.node.data
      if data.maximum and out > data.maximum then
        out = data.maximum
      end
      if data.minimum and out < data.minimum then
        out = data.minimum
      end
      arg.items[arg.selected] = out
    end
    arg.textEntry = nil
  end
end

module.number = {
  itemFormat = tostring,
  itemDefault = 0,
  step = 1,
  editAsString = numberEditAsString,
  textEntryToggle = numberTextEntryToggle,
  leftAction = function(arg)
    local value = arg.items[arg.selected]
    local lower = value - (arg.node.data.step or 1)
    if arg.node.data.minimum and lower < arg.node.data.minimum then lower = arg.node.data.minimum end
    arg.items[arg.selected] = lower
  end,
  rightAction = function(arg)
    local value = arg.items[arg.selected]
    local higher = value + (arg.node.data.step or 1)
    if arg.node.data.maximum and higher > arg.node.data.maximum then higher = arg.node.data.maximum end
    arg.items[arg.selected] = higher
  end
}

module.percent = {
  itemFormat = Settings.Format.PERCENT,
  itemDefault = 1,
  step = 0.05,
  minimum = 0,
  maximum = 1,
  editAsString = numberEditAsString,
  textEntryToggle = numberTextEntryToggle,
  leftAction = module.number.leftAction,
  rightAction = module.number.rightAction
}

module.string = {
  itemFormat = tostring,
  itemDefault = "",
  textEntry = function(arg, key)
    if key then
      arg.textEntry = arg.textEntry .. string.char(key)
    else
      arg.textEntry = string.sub(arg.textEntry, 1, -2)
    end
  end,
  textEntryToggle = function(arg, active, confirm)
    if active then
      arg.textEntry = arg.items[arg.selected]
    else
      if confirm then
        arg.items[arg.selected] = arg.textEntry
      end
      arg.textEntry = nil
    end
  end
}

module.enum = {
  -- itemDefault is specified above
  leftAction = function(arg)
    local value = arg.items[arg.selected]
    local list = arg.node.data.enum.valueList
    local leftValue = nil

    for i, v in ipairs(list) do
      if v == value then
        if leftValue == nil then leftValue = list[#list] end
        break
      end
      leftValue = v
    end

    arg.items[arg.selected] = leftValue
  end,
  rightAction = function(arg)
    local value = arg.items[arg.selected]
    local list = arg.node.data.enum.valueList

    local useNext = nil

    for i, v in ipairs(list) do
      if useNext == true then useNext = v break end
      if v == value then useNext = true end
    end

    if useNext == nil or useNext == true then useNext = list[1] end

    arg.items[arg.selected] = useNext
  end
}

module.entity = {
  -- itemDefault is specified above
  leftAction = function(arg)
    local node = arg.node
    local list = node.data.entities
    local value = arg.items[arg.selected]
    local leftValue = nil

    for i, v in ipairs(list) do
      if v == value then
        if leftValue == nil then leftValue = list[#list] end
        break
      end
      leftValue = v
    end

    if leftValue == nil then leftValue = "" end

    arg.items[arg.selected] = leftValue
  end,
  rightAction = function(arg)
    local node = arg.node
    local list = node.data.entities
    local value = arg.items[arg.selected]
    local useNext = nil

    for i, v in ipairs(list) do
      if useNext == true then useNext = v break end
      if v == value then useNext = true end
    end

    if useNext == nil or useNext == true then useNext = list[1] end
    if useNext == nil then useNext = "" end

    arg.items[arg.selected] = useNext
  end,
  action = function(arg)
    Menu.open("PowerSettings_entitySearch", {
      callback = function(value) arg.items[arg.selected] = value end,
      label = L.formatKey("%s item", "listItemName", arg.node.data.name),
      list = arg.node.data.entities,
      node = arg.node.data,
      query = "",
      textEntry = false
    })
  end
}

module.component = {
  -- itemDefault is specified above
  leftAction = function(arg)
    local node = arg.node
    local list = node.data.components
    local value = arg.items[arg.selected]
    local leftValue = nil

    for i, v in ipairs(list) do
      if v == value then
        if leftValue == nil then leftValue = list[#list] end
        break
      end
      leftValue = v
    end

    if leftValue == nil then leftValue = "" end

    arg.items[arg.selected] = leftValue
  end,
  rightAction = function(arg)
    local node = arg.node
    local list = node.data.components
    local value = arg.items[arg.selected]
    local useNext = nil

    for i, v in ipairs(list) do
      if useNext == true then useNext = v break end
      if v == value then useNext = true end
    end

    if useNext == nil or useNext == true then useNext = list[1] end
    if useNext == nil then useNext = "" end

    arg.items[arg.selected] = useNext
  end,
  action = function(arg)
    Menu.open("PowerSettings_componentSearch", {
      callback = function(value) arg.items[arg.selected] = value end,
      label = L.formatKey("%s item", "listItemName", arg.node.data.name),
      list = arg.node.data.components,
      node = arg.node.data,
      query = "",
      textEntry = false
    })
  end
}

return module
