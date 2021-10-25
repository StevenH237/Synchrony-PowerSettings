local Controls        = require "necro.config.Controls"
local Event           = require "necro.event.Event"
local GFX             = require "system.gfx.GFX"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"
local UI              = require "necro.render.UI"

local PSList = require "PowerSettings.types.List"

Event.renderUI.add("renderSettingsMenuOverlay", "menuOverlay", function ()
  if not Menu.getCurrent() or Menu.getCurrent().name ~= "PowerSettings_list" then
    return
  end

  local arg = Menu.getCurrent().arg
  if not arg then
    return
  end

  if arg.selected == "done" then return end

  local text
  if arg.selected == "add" then
    text = ("Press '%s' to add without selecting the item"):format(Controls.getFriendlyMiscKeyBind(Controls.Misc.SELECT_2))
  elseif arg.mode == PSList.Mode.MODIFY then
    text = ("Press '%s' for additional options"):format(Controls.getFriendlyMiscKeyBind(Controls.Misc.SELECT_2))
  else
    if #arg.items == arg.node.data.limit then
      text = ("'%s': End move | '%s': Delete | '%s'/'%s': Move"):format(
        Controls.getFriendlyMiscKeyBind(Controls.Misc.SELECT_2),
        Controls.getFriendlyMiscKeyBind(Controls.Misc.MENU_LEFT),
        Controls.getFriendlyMiscKeyBind(Controls.Misc.MENU_UP),
        Controls.getFriendlyMiscKeyBind(Controls.Misc.MENU_DOWN))
    else
      text = ("'%s': End move | '%s': Delete | '%s'/'%s': Move | '%s': Insert above"):format(
        Controls.getFriendlyMiscKeyBind(Controls.Misc.SELECT_2),
        Controls.getFriendlyMiscKeyBind(Controls.Misc.MENU_LEFT),
        Controls.getFriendlyMiscKeyBind(Controls.Misc.MENU_UP),
        Controls.getFriendlyMiscKeyBind(Controls.Misc.MENU_DOWN),
        Controls.getFriendlyMiscKeyBind(Controls.Misc.MENU_RIGHT))
    end
  end

  UI.drawText {
    font = UI.Font.SMALL,
    text = text,
    size = UI.Font.SMALL.size * 2,
    alignX = 0.5,
    alignY = 1,
    x = GFX.getWidth() / 2,
    y = GFX.getHeight() - 12,
  }
end)
