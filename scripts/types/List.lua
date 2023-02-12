local DropdownMenu    = require "necro.menu.generic.DropdownMenu"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"
local TextPrompt      = require "necro.render.ui.TextPrompt"
local Utilities       = require "system.utils.Utilities"

local Text = require "PowerSettings.i18n.Text"

local NixLib = require "NixLib.NixLib"

local PSComponent   = require "PowerSettings.types.Component"
local PSEntity      = require "PowerSettings.types.Entity"
local PSEntityEvent = require "PowerSettings.PSEntityEvent"
local PSMain        = require "PowerSettings.PSMain"
local PSStorage     = require "PowerSettings.PSStorage"

local module = {}

local function defaultListFormat(itemFormat, list)
  if #list == 0 then return Text.Format.List0
  elseif #list == 1 then return string.format("{%s}", itemFormat(list[1]))
  elseif #list == 2 then return Text.Format.List2
  else return Text.Format.ListPlus(#list) end
end

function module.action(id)
  Menu.open("PowerSettings_list", {
    id = id,
    items = SettingsStorage.get(id, Settings.Layer.REMOTE_PENDING) or
        Utilities.fastCopy(SettingsStorage.getDefaultValue(id)),
    mode = module.Mode.MODIFY,
    callback = function(items)
      SettingsStorage.set(id, items, Settings.Layer.REMOTE_PENDING)
    end
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
  args.editAsString = nil -- No longer supported

  if itemType == "enum" then
    -- this itemFormat reassignment stays because it's based on the args
    args.itemFormat = args.itemFormat or function(value) return args.enum.prettyNames[value] end
    args.itemDefault = args.itemDefault or ({ next(args.enum) })[2]
  elseif itemType == "entity" then
    args.entities = PSEntity.getFilteredEntities(args.filter)
    PSEntityEvent.add(args)
  elseif itemType == "component" then
    args.components = PSComponent.getFilteredComponents(args.filter)
    PSEntityEvent.addc(args)
  end

  if not args.id then
    if args.autoRegister then
      local id = Settings[mode].table(args)
      PSStorage.add("list." .. itemType, args, id)
      return id
    else
      error(Text.Errors.SettingID)
    end
  else
    PSStorage.add("list." .. itemType, args, PSMain.getModSettingPrefix() .. args.id)
    return Settings[mode].table(args)
  end
end

module.Mode = {
  MODIFY = 1,
  ORGANIZE = 2
}

module.number = {
  itemFormat = tostring,
  itemDefault = 0,
  step = 1,
  menuEntry = function(arg, ind)
    local node = PSStorage.get(arg.id).data
    local items = arg.items

    local entry = TextPrompt.menuEntry {
      id = ind,
      get = function() return tostring(items[ind]) end,
      set = function(value) items[ind] = tonumber(value) or node.itemDefault end,
      view = node.itemFormat,
      autoSelect = true
    }

    entry.leftAction = function()
      local value = items[ind]
      local lower = value - (node.step or 1)
      if node.minimum and lower < node.minimum then lower = node.minimum end
      items[ind] = lower
    end
    entry.rightAction = function()
      local value = items[ind]
      local higher = value + (node.step or 1)
      if node.maximum and higher > node.maximum then higher = node.maximum end
      items[ind] = higher
    end

    return entry
  end
}

module.percent = {
  itemFormat = Settings.Format.PERCENT,
  itemDefault = 1,
  step = 0.05,
  minimum = 0,
  maximum = 1,
  menuEntry = module.number.menuEntry
}

module.string = {
  itemFormat = tostring,
  itemDefault = "",
  menuEntry = function(arg, ind)
    local node = PSStorage.get(arg.id).data
    local items = arg.items

    local entry = TextPrompt.menuEntry {
      id = ind,
      get = function() return items[ind] end,
      set = function(value) items[ind] = value end,
      view = node.itemFormat,
      autoSelect = true
    }

    return entry
  end
}

module.enum = {
  -- itemDefault is specified above
  menuEntry = function(arg, ind)
    local node = PSStorage.get(arg.id).data
    local items = arg.items

    local entries = {}
    for k, v in pairs(node.enum) do
      table.insert(entries, {
        id = v,
        label = node.itemFormat(v),
        settingsValue = v
      })
    end

    NixLib.sortBy(entries, "settingsValue")

    local entry = DropdownMenu.createEntry {
      id = ind,
      get = function() return items[ind] end,
      set = function(value) items[ind] = value end,
      view = node.itemFormat,
      entries = entries
    }

    return entry
  end
  --[[ leftAction = function(arg)
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
      if useNext == true then
        useNext = v
        break
      end
      if v == value then useNext = true end
    end

    if useNext == nil or useNext == true then useNext = list[1] end

    arg.items[arg.selected] = useNext
  end ]]
}

module.entity = {
  -- itemDefault is specified above
  itemFormat = PSEntity.format,
  menuEntry = function(arg, ind)
    local node = PSStorage.get(arg.id).data
    local items = arg.items

    return {
      id = ind,
      label = function() return node.itemFormat(items[ind]) end,
      leftAction = function()
        local list = node.entities
        local value = items[ind]
        local leftValue = nil

        for i, v in ipairs(list) do
          if v == value then
            if leftValue == nil then leftValue = list[#list] end
            break
          end
          leftValue = v
        end

        if leftValue == nil then leftValue = "" end

        items[ind] = leftValue
      end,
      rightAction = function()
        local list = node.entities
        local value = items[ind]
        local useNext = nil

        for i, v in ipairs(list) do
          if useNext == true then
            useNext = v
            break
          end
          if v == value then useNext = true end
        end

        if useNext == nil or useNext == true then useNext = list[1] end
        if useNext == nil then useNext = "" end

        items[ind] = useNext
      end,
      action = function()
        Menu.open("PowerSettings_entitySearch", {
          callback = function(value) items[ind] = value end,
          label = Text.ListItemName(node.name),
          list = node.entities,
          node = node,
          query = "",
          textEntry = false
        })
      end
    }
  end
}

module.component = {
  -- itemDefault is specified above
  itemFormat = PSComponent.format,
  menuEntry = function(arg, ind)
    local node = PSStorage.get(arg.id).data
    local items = arg.items

    return {
      id = ind,
      label = function() return node.itemFormat(items[ind]) end,
      leftAction = function()
        local list = node.components
        local value = items[ind]
        local leftValue = nil

        for i, v in ipairs(list) do
          if v == value then
            if leftValue == nil then leftValue = list[#list] end
            break
          end
          leftValue = v
        end

        if leftValue == nil then leftValue = "" end

        items[ind] = leftValue
      end,
      rightAction = function()
        local list = node.components
        local value = items[ind]
        local useNext = nil

        for i, v in ipairs(list) do
          if useNext == true then
            useNext = v
            break
          end
          if v == value then useNext = true end
        end

        if useNext == nil or useNext == true then useNext = list[1] end
        if useNext == nil then useNext = "" end

        items[ind] = useNext
      end,
      action = function()
        Menu.open("PowerSettings_componentSearch", {
          callback = function(value) items[ind] = value end,
          label = Text.ListItemName(node.name),
          list = node.components,
          node = node,
          query = "",
          textEntry = false
        })
      end
    }
  end
}

return module
