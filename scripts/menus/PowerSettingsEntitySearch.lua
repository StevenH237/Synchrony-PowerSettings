local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local SettingsStorage = require "necro.config.SettingsStorage"

local function searchLabel(value)
  if value ~= "" then return value
  else return "(Search...)" end
end

local function searchSpecialAction(arg)
  arg.query = ""
  Menu.update()
end

local function searchKeystroke(arg, key)
  if key == nil then
    arg.query = string.sub(arg.query, 1, -2)
  else
    arg.query = arg.query .. key
  end
  Menu.update()
end

local function resultAction(value, callback)
  Menu.close()
  callback(value)
end

Event.menu.add("menuEntitySearch", "PowerSettings_entitySearch", function(ev)
  local menu = {}
  local entries = {}

  local entities = ev.arg.list

  for i, v in ipairs(entities) do
    table.insert(entries, {
      id = "result." .. v,
      label = v,
      action = function() resultAction(v, ev.arg.callback) end
    })
  end

  if ev.searchText == nil then
    table.insert(entries, 1, {
      label = "Press Ctrl+F to search!",
      font = {
        fillColor = -1,
        font = "gfx/necro/font/necrosans-6.png;",
        shadowColor = -16777216,
        size = 6
      }
    })

    table.insert(entries, 2, {
      height = 0
    })

    entries[#entries + 1] = {
      height = 0
    }

    entries[#entries + 1] = {
      id = "cancel",
      label = "Cancel",
      action = Menu.close
    }
  end

  menu.entries = entries
  menu.searchable = true

  menu.label = "Select entity"

  ev.menu = menu

  print(ev)
end)
