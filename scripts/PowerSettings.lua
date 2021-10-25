local Settings = require "necro.config.Settings"

local NixLib = require "NixLib.NixLib"

local PSStorage  = require "PowerSettings.PSStorage"
local PSTBitflag = require "PowerSettings.types.Bitflag"
local PSTEntity  = require "PowerSettings.types.Entity"
local PSTList    = require "PowerSettings.types.List"
local PSTNumber  = require "PowerSettings.types.Number"

local module = {}

local function defaultSetting(mode, sType, args)
  PSStorage.add(sType, args)
  return Settings[mode][sType](args)
end

for _, v in ipairs({"shared", "entitySchema"}) do
  module[v] = {}
  for _, t in ipairs({"enum", "string", "table", "choice", "action"}) do
    module[v][t] = function(args) return defaultSetting(v, t, args) end
  end

  module[v].bitflag = function(args) return PSTBitflag.setting(v, args) end
  module[v].entity = function(args) return PSTEntity.setting(v, args) end
  module[v].number = function(args) return PSTNumber.setting(v, "number", args) end
  module[v].percent = function(args) return PSTNumber.setting(v, "percent", args) end
  module[v].time = function(args) return PSTNumber.setting(v, "time", args) end
  module[v].list = {}

  for _, t in ipairs({"string", "number", "enum"}) do
    module[v].list[t] = function(args) return PSTList.setting(v, t, args) end
  end
end

function module.group(args)
  return Settings.group(args)
end

return module