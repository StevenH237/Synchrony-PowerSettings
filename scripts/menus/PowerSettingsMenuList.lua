---@diagnostic disable: param-type-mismatch
local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"
local TextFormat      = require "necro.config.i18n.TextFormat"

local Text = require "PowerSettings.i18n.Text"

local PSList    = require "PowerSettings.types.List"
local PSStorage = require "PowerSettings.PSStorage"

local NLText = require "NixLib.i18n.Text"

--[[
  List arg parameters:
  id = (string) The ID of the setting
  mode = (int) Which mode the list is in
  node = (PSSettingsNode) The setting node
  selected = (int) The index of the selected item; or the words "add" or "done"
  start = (int|nil) The index at which the selected item started
  text = (string|nil) The text currently being edited
]]

local function finishMove(arg, i)
  local start = arg.moving
  arg.moving = nil

  if start ~= i then
    local value = table.remove(arg.items, start)
    table.insert(arg.items, i, value)
  end

  Menu.update()
end

local function cancelMove(arg)
  arg.moving = nil
  Menu.update()
end

local function addItem(arg, i)
  local def = PSStorage.get(arg.id).data.itemDefault
  if type(def) == "function" then
    def = def(arg.items)
  end

  table.insert(arg.items, i, def)
  Menu.update()
end

local function exitMenu(arg)
  arg.callback(arg.items)
  Menu.close()
end

local function closeDropdown(arg, i, val)
  if val == "insert" then
    addItem(arg, i)
  elseif val == "move" then
    arg.moving = i
    Menu.update()
  elseif val == "remove" then
    table.remove(arg.items, i)
    Menu.update()
  end
  -- "cancel" does nothing
end

local function openDropdown(arg, i)
  local node = PSStorage.get(arg.id).data

  local entries = {}

  if (not node.limit) or #arg.items < node.limit then
    table.insert(entries, {
      id = "insert",
      label = Text.List.InsertAbove,
      settingsValue = "insert"
    })
  end

  if #arg.items > 1 then
    table.insert(entries, {
      id = "move",
      label = Text.List.Move,
      settingsValue = "move"
    })
  end

  table.insert(entries, {
    id = "remove",
    label = Text.List.Remove,
    settingsValue = "remove"
  })

  table.insert(entries, {
    id = "cancel",
    label = NLText.Cancel,
    settingsValue = "cancel"
  })

  Menu.open("dropdown", {
    entries = entries,
    callback = function(val)
      closeDropdown(arg, i, val)
    end
  })
end

Event.menu.add("menuList", "PowerSettings_list", function(ev)
  --[[ev.arg format:
  {
    id = "mod.PowerSettings.setting.node",
    items = {
      "List",
      "of",
      "items"
    },
    moving = 1 or nil, -- index of item being moved, nil if nothing
    callback = function() end
  }
  ]]
  local menu = {}
  local entries = {}

  local items = ev.arg.items

  local node = PSStorage.get(ev.arg.id)
  local data = node.data
  local itemType = node.sType:sub(6, -1)

  for i = 1, #items do
    local entry
    if ev.arg.moving then
      entry = {
        id = i,
        label = function() return data.itemFormat(items[i]) end,
        action = function() finishMove(ev.arg, i) end,
        specialAction = function() cancelMove(ev.arg) end
      }

      if ev.arg.moving == i then
        entry.label = function() return TextFormat.color(data.itemFormat(items[i]), 0x422BB4) end
      end
    else
      entry = PSList[itemType].menuEntry(ev.arg, i)
      entry.specialAction = function() openDropdown(ev.arg, i) end
    end

    table.insert(entries, entry)
  end

  if #items == 0 then
    table.insert(entries, {
      id = 0,
      label = Text.ListIsEmpty
    })
  end

  table.insert(entries, { height = 0 })

  if (not data.limit) or #items < data.limit then
    local entry = {
      label = Text.AddListItem,
      id = "_add"
    }

    if not ev.arg.moving then
      entry.action = function() addItem(ev.arg, #ev.arg.items + 1) end
    end

    table.insert(entries, entry)
    table.insert(entries, { height = 0 })
  end

  if ev.arg.moving then
    table.insert(entries, {
      id = "_cancel",
      label = Text.CancelMove,
      action = function() cancelMove(ev.arg) end
    })

    menu.escapeAction = function() cancelMove(ev.arg) end
  else
    table.insert(entries, {
      id = "_exit",
      label = NLText.Done,
      action = function() exitMenu(ev.arg) end
    })

    menu.escapeAction = function() exitMenu(ev.arg) end
  end

  menu.entries = entries
  menu.label = node.data.name
  ev.menu = menu
end)
