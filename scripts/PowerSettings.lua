local Settings = require "necro.config.Settings"

local NixLib = require "NixLib.NixLib"

local Bitflag   = require "PowerSettings.types.Bitflag"
local EntityStg = require "PowerSettings.types.Entity"
local PSStorage = require "PowerSettings.PSStorage"

local module = {}

local function defaultSetting(mode, sType, args)
  PSStorage.add(sType, args)
  return Settings[mode][sType](args)
end

for _, v in ipairs({"shared", "entitySchema"}) do
  module[v] = {}
  for _, t in ipairs({"enum", "number", "string", "time", "percent", "table", "choice", "action"}) do
    module[v][t] = function(args) return defaultSetting(v, t, args) end
  end

  module[v].bitflag = function(args) return Bitflag.setting(v, args) end
  module[v].entity = function(args) return EntityStg.setting(v, args) end
end

function module.group(args)
  return Settings.group(args)
end

return module