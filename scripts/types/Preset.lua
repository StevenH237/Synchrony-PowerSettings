local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local PSStorage = require "PowerSettings.PSStorage"

local module = {}

function module.action(set, unset)
  for k, v in pairs(set) do
    if type(v) == "function" then v = v() end
    SettingsStorage.set(k, v, Settings.Layer.REMOTE_PENDING)
  end

  for i, v in ipairs(set) do
    SettingsStorage.set(v, nil, Settings.Layer.REMOTE_PENDING)
  end
end

function module.setting(sType, args)
  args.action = module.action(args.values, args.removeValues)
  PSStorage.add("preset", args)
  return Settings[sType].action(args)
end