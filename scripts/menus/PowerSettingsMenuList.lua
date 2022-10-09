---@diagnostic disable: param-type-mismatch
local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

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

local function getDefault(arg)
  local default = arg.node.data.itemDefault
  if type(default) == "function" then
    default = default(arg.items)
  end
  return default
end

local modify = {
  upAction = function(arg)
    if arg.selected == 1 then
      arg.selected = "done"
    elseif arg.selected == "done" then
      if #arg.items == arg.node.data.limit then
        arg.selected = #arg.items
      else
        arg.selected = "add"
      end
    elseif arg.selected == "add" and #arg.items >= 1 then
      arg.selected = #arg.items
    elseif arg.selected == "add" then
      arg.selected = "done"
    else
      arg.selected = arg.selected - 1
    end
    Menu.update()
    Menu.selectByID(arg.id .. "." .. arg.selected)
  end,
  downAction = function(arg)
    if arg.selected == #arg.items then
      if #arg.items == arg.node.data.limit then
        arg.selected = "done"
      else
        arg.selected = "add"
      end
    elseif arg.selected == "add" then
      arg.selected = "done"
    elseif arg.selected == "done" and #arg.items >= 1 then
      arg.selected = 1
    elseif arg.selected == "done" then
      arg.selected = "add"
    else
      arg.selected = arg.selected + 1
    end
    Menu.update()
    Menu.selectByID(arg.id .. "." .. arg.selected)
  end,
  specialAction = function(arg)
    if Menu.isTextEntryActive() then return end
    arg.mode = PSList.Mode.ORGANIZE
    arg.start = arg.selected
    Menu.update()
  end,
  textEntry = function(arg, key, itemType)
    if PSList[itemType].textEntry then
      PSList[itemType].textEntry(arg, key)
    else
      PSList[itemType].editAsString(arg, key)
    end
  end,
  textEntryToggle = function(arg, active, confirm, itemType)
    PSList[itemType].textEntryToggle(arg, active, confirm)
  end,
  exitAction = function(arg)
    SettingsStorage.set(arg.id, arg.items, Settings.Layer.REMOTE_PENDING)
    Menu.close()
    if arg.node.refreshOnChange then
      Menu.update()
    end
  end
}

local organize = {
  leftAction = function(arg)
    table.remove(arg.items, arg.selected)
    if #arg.items == 0 then
      arg.selected = "add"
    elseif arg.selected ~= 1 then
      arg.selected = arg.selected - 1
    end
    arg.mode = PSList.Mode.MODIFY
    Menu.update()
    Menu.selectByID(arg.id .. "." .. arg.selected)
  end,
  upAction = function(arg)
    if arg.selected ~= 1 then
      local items = arg.items
      local sel = arg.selected
      items[sel], items[sel - 1] = items[sel - 1], items[sel]
      arg.selected = sel - 1
      Menu.update()
      Menu.selectByID(arg.id .. "." .. arg.selected)
    end
  end,
  downAction = function(arg)
    if arg.selected ~= #arg.items then
      local items = arg.items
      local sel = arg.selected
      items[sel], items[sel + 1] = items[sel + 1], items[sel]
      arg.selected = sel + 1
      Menu.update()
      Menu.selectByID(arg.id .. "." .. arg.selected)
    end
  end,
  rightAction = function(arg)
    table.insert(arg.items, arg.selected, getDefault(arg))
    arg.mode = PSList.Mode.MODIFY
    Menu.update()
  end,
  escapeAction = function(arg)
    local pos = arg.selected
    local start = arg.start
    if pos ~= start then
      local item = table.remove(arg.items, pos)
      table.insert(arg.items, start, item)
    end
    arg.selected = arg.start
    arg.mode = PSList.Mode.MODIFY
    Menu.update()
    Menu.selectByID(arg.id .. "." .. arg.selected)
  end,
  confirmAction = function(arg)
    arg.mode = PSList.Mode.MODIFY
    Menu.update()
  end
}

local function addItem(arg, select)
  arg.items[#arg.items + 1] = getDefault(arg)
  if select or #arg.items == arg.node.data.limit then
    arg.selected = #arg.items
    Menu.update()
    Menu.selectByID(arg.id .. "." .. arg.selected)
  else
    Menu.update()
  end
end

Event.menu.add("menuList", "PowerSettings_list", function(ev)
  local menu = {}
  local entries = {}

  local arg = ev.arg

  local items = arg.items

  if not arg.selected then
    if #items > 0 then
      arg.selected = 1
    else
      arg.selected = "add"
    end
  end

  local node = arg.node
  local itemType = node.sType:sub(6, -1)

  for i = 1, #items do
    local entry = {
      id = arg.id .. "." .. i,
      label = function() return node.data.itemFormat(items[i]) end,
    }

    entries[#entries + 1] = entry

    if arg.mode == PSList.Mode.MODIFY then
      if PSList[itemType].leftAction then entry.leftAction = function() PSList[itemType].leftAction(arg) end end
      if PSList[itemType].rightAction then entry.rightAction = function() PSList[itemType].rightAction(arg) end end
      entry.specialAction = function() modify.specialAction(arg) end
      entry.upAction = function() modify.upAction(arg) end
      entry.downAction = function() modify.downAction(arg) end
      if PSList[itemType].textEntry or (PSList[itemType].editAsString and node.data.editAsString) then
        entry.textEntry = function(key) modify.textEntry(arg, key, itemType) end
        entry.textEntryToggle = function(active, confirm) modify.textEntryToggle(arg, active, confirm, itemType) end
        if i == arg.selected then
          entry.label = function() if arg.textEntry then return arg.textEntry else return node.data.itemFormat(items[i]) end end
        end
      elseif PSList[itemType].action then
        entry.action = function() PSList[itemType].action(arg) end
      elseif PSList[itemType].rightAction then
        entry.action = function() PSList[itemType].rightAction(arg) end
      end
    else
      entry.leftAction = function() organize.leftAction(arg) end
      if #arg.items ~= arg.node.data.limit then
        entry.rightAction = function() organize.rightAction(arg) end
      end
      entry.upAction = function() organize.upAction(arg) end
      entry.downAction = function() organize.downAction(arg) end
      entry.action = function() organize.confirmAction(arg) end
      entry.specialAction = function() organize.confirmAction(arg) end
      if i == arg.selected then entry.label = function() return "\3*d22" .. node.data.itemFormat(items[i]) .. "\3r" end end
    end
  end

  if #items > 0 then
    entries[#entries + 1] = { height = 0 }
  end

  if #items ~= node.data.limit then
    -- "Add item" entry
    entries[#entries + 1] = {
      label = Text.AddListItem,
      action = function() addItem(arg, true) end,
      specialAction = function() addItem(arg, false) end,
      id = arg.id .. ".add",
      downAction = function() modify.downAction(arg) end,
      upAction = function() modify.upAction(arg) end
    }

    entries[#entries + 1] = { height = 0 }
  end

  entries[#entries + 1] = {
    label = NLText.Done,
    action = function() modify.exitAction(arg) end,
    id = arg.id .. ".done",
    downAction = function() modify.downAction(arg) end,
    upAction = function() modify.upAction(arg) end
  }

  if arg.mode == PSList.Mode.MODIFY then
    menu.escapeAction = function() modify.exitAction(arg) end
  else
    menu.escapeAction = function() organize.escapeAction(arg) end
  end

  menu.entries = entries
  menu.label = node.data.name
  ev.menu = menu
end)
