local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
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
    arg.query = arg.query .. string.char(key)
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
  local advanced = SettingsStorage.get("config.showAdvanced")

  local entities = ev.arg.list
  local query = ev.arg.query

  local filtered = {}

  for i, v in ipairs(entities) do
    local vl = v:lower()
    local n = query:lower()
    local iStart, iEnd = vl:find(n, 1, true)

    if iStart then
      table.insert(filtered, {v, iStart, iEnd})
    end
  end

  menu.label = ev.arg.label

  entries[1] = {
    id="searchbox",
    label=function() return searchLabel(query) end,
    textEntry=function(key) searchKeystroke(ev.arg, key) end,
    textEntryToggle=function(active, confirm) end,
    specialAction=function() searchSpecialAction(ev.arg) end
  }

  entries[2] = {
    height=1
  }

  if #filtered > 0 then
    for i, v in ipairs(filtered) do
      local entry = {}
      entry.id = "result." .. v[1]
      entry.label = string.sub(v[1], 1, v[2]-1)
        .. "\3*cc5" .. string.sub(v[1], v[2], v[3])
        .. "\3r" .. string.sub(v[1], v[3]+1, -1)
      entry.action = function() resultAction(v[1], ev.arg.callback) end
      entry.specialAction = function() Menu.selectByID("searchbox") end
      entries[2+i] = entry
    end

    entries[#entries+1] = {
      height=1
    }
  end

  entries[#entries+1] = {
    id="cancel",
    label="Cancel",
    action=Menu.close
  }

  menu.entries = entries
  ev.menu = menu
end)