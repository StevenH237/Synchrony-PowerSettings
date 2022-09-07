local Settings = require "necro.config.Settings"

local PSKeyBank = require "PowerSettings.i18n.KeyBank"
local PSMain    = require "PowerSettings.PSMain"
local PSStorage = require "PowerSettings.PSStorage"

local module = {}

-- mode parameter is intentionally unused, it exists for consistency
-- however, header settings are always non-entitySchema
function module.setting(mode, args)
  args.action = function() end
  args.leftAction = nil
  args.rightAction = nil
  if args.name:sub(1, 2) ~= "\3*" then
    args.name = "\3*cc5" .. args.name .. "\3r"
  end
  args.visibility = args.visibility or Settings.Visibility.VISIBLE

  if not args.id then
    if args.autoRegister then
      local id = Settings.shared.action(args)
      PSStorage.add("header", args, id)
      return id
    else
      error(PSKeyBank.SettingIDError)
    end
  else
    PSStorage.add("header", args, PSMain.getModSettingPrefix() .. args.id)
    return Settings.shared.action(args)
  end
end

return module
