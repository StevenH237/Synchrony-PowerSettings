local Settings = require "necro.config.Settings"

local PSKeyBank = require "PowerSettings.i18n.KeyBank"
local PSMain    = require "PowerSettings.PSMain"
local PSStorage = require "PowerSettings.PSStorage"

local module = {}

function module.setting(mode, args)
  args.action = function() end
  args.visibility = args.visibility or Settings.Visibility.VISIBLE

  if not args.id then
    if args.autoRegister then
      local id = Settings[mode].action(args)
      PSStorage.add("label", args, id)
      return id
    else
      error(PSKeyBank.SettingIDError)
    end
  else
    PSStorage.add("label", args, PSMain.getModSettingPrefix() .. args.id)
    return Settings[mode].action(args)
  end
end

return module
