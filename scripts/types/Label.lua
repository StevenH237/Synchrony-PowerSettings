local Settings = require "necro.config.Settings"

local PSStorage = require "PowerSettings.PSStorage"

local module = {}

function module.setting(mode, args)
  args.action = function() end
  args.visibility = args.visibility or Settings.Visibility.VISIBLE
  PSStorage.add("label", args)
  return Settings.shared.action(args)
end

return module