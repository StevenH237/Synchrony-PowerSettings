local Controls = require "necro.config.Controls"

local module = {
  AddListItem = L("+ Add", "addListItem"),
  BitflagUnnamedDetail = function(...) return L.formatKey("Unnamed bit %s", "bitflagUnnamedDetail") end,
  BitflagUnnamed = L("Unnamed bit", "bitflagUnnamed"),
  Errors = {
    BitflagOmission = L("Bitflag settings must specify flags or presets (preferably both).", "errors.bitflagOmission"),
    SettingID = L("Settings defined through PowerSettings must have an id (recommended) or autoRegister.",
      "errors.settingID")
  },
  Format = {
    Bitflag0 = L("No flags", "format.bitflag0"),
    Bitflag1 = function(...) return L.formatKey("1 flag (%s)", "format.bitflag1", ...) end,
    Bitflag2 = function(...) return L.formatKey("2 flags (%s)", "format.bitflag2", ...) end,
    BitflagPlus = function(...) return L.formatKey("%i flags (%s)", "format.bitflagPlus", ...) end,
    Entity = function(...) return L.formatKey("%s (%s)", "format.entity", ...) end, -- so RTL languages can display correctly
    List0 = L("Empty", "format.list0"),
    List1 = L("1 item", "format.list1"), -- futureproofing
    List2 = L("2 items", "format.list2"),
    ListPlus = function(...) return L.formatKey("%d items", "format.listPlus", ...) end,
    NoSuchComponent = function(...) return L.formatKey("(No such component: %s)", "format.noSuchComponent", ...) end,
    NoSuchEntity = function(...) return L.formatKey("(No such entity: %s)", "format.noSuchEntity", ...) end
  },
  ListItemName = function(...) return L.formatKey("%s item", "listItemName", ...) end,
  Render = {
    Add = function(...) return L.formatKey("Press '%s' to add without selecting the item.", "render.add", ...) end,
    Insert = function(...)
      return L.formatKey("'%s': End move | '%s': Delete | '%s'/'%s': Move | '%s': Insert above", "render.insert", ...)
    end,
    Modify = function(...) return L.formatKey("Press '%s' for additional options.", "render.modify", ...) end,
    NoInsert = function(...) return L.formatKey("'%s': End move | '%s': Delete | '%s'/'%s': Move", "render.noInsert", ...) end,
  },
  SearchHint = function(...) return L.formatKey("Use '%s' to search!", "searchHint", ...) end,
  SelectComponent = L("Select component", "selectComponent"),
  SelectEntity = L("Select entity", "selectEntity")
}

return module
