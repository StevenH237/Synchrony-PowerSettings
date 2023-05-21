local Event  = require "necro.event.Event"
local FileIO = require "system.game.FileIO"
local JSON   = require "system.utils.serial.JSON"

local PSMain = require "PowerSettings.PSMain"

local module = {}

local exporting = {}

function module.add()
  -- Get the calling mod and its version
  local modName = PSMain.getCallingMod()
  local modVer = JSON.decode(FileIO.readFileToString(("mods/%s/mod.json"):format(modName))).version

  -- Add that to the table to export
  exporting[modName] = modVer
end

Event.settingsPresetSave.add("addVersionNumbers", { order = "editor", sequence = 10 }, function(ev)
  local stgs = ev.settings

  -- Add all the version to the exporting table
  -- These are PowerSettings-namespaced so that they shouldn't conflict with any mods
  for k, v in pairs(exporting) do
    stgs["mod.PowerSettings.version." .. k] = v
  end
end)

return module
