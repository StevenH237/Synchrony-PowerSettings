local Settings = require "necro.config.Settings"

local PSStorage = require "PowerSettings.PSStorage"

local module = {}

function module.setting(mode, args)
  args.action = function() end
  args.leftAction = nil
  args.rightAction = nil
  if args.name:sub(1, 2) ~= "\3*" then
    args.name = "\3*cc5" .. args.name .. "\3r"
  end
  args.visibility = args.visibility or Settings.Visibility.VISIBLE
  PSStorage.add("header", args)
  return Settings.shared.action(args)
end

return module
