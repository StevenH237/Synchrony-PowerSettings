local Settings  = require "necro.config.Settings"
local PSStorage = require "PowerSettings.PSStorage"

local module = {}

local function defaultSetting(mode, type, args)
  PSStorage.add(type, args)
  return Settings[mode][type](args)
end

for _, v in ipairs({"shared", "entitySchema"}) do
  module[v] = {}
  for _, t in ipairs({"enum", "number", "string", "time", "percent", "table", "choice", "action"}) do
    module[v][t] = function(args) return defaultSetting(v, t, args) end
  end
end

function module.group(args)
  return Settings.group(args)
end

return module