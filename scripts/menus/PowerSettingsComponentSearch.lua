local Controls = require "necro.config.Controls"
local Event    = require "necro.event.Event"
local Menu     = require "necro.menu.Menu"

local Text = require "PowerSettings.i18n.Text"

local NLText = require "NixLib.i18n.Text"

local function resultAction(value, callback)
  Menu.close()
  callback(value)
end

Event.menu.add("menuComponentSearch", "PowerSettings_componentSearch", function(ev)
  local menu = {}
  local entries = {}

  local components = ev.arg.list

  for i, v in ipairs(components) do
    table.insert(entries, {
      id = "result." .. v,
      label = v,
      action = function() resultAction(v, ev.arg.callback) end
    })
  end

  if ev.searchText == nil then
    table.insert(entries, 1, {
      label = Text.SearchHint(Controls.getFriendlyMiscKeyBind(Controls.Misc.SEARCH)),
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
      label = NLText.Cancel,
      action = Menu.close
    }
  end

  menu.label = Text.SelectComponent

  menu.entries = entries
  menu.searchable = true
  ev.menu = menu
end)
