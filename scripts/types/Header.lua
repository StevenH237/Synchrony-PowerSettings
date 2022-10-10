local Settings = require "necro.config.Settings"

local Text = require "PowerSettings.i18n.Text"

local PSMain    = require "PowerSettings.PSMain"
local PSStorage = require "PowerSettings.PSStorage"

local module = {}

-- mode parameter is intentionally unused, it exists for consistency
-- however, header settings are always non-entitySchema
function module.setting(mode, args)
  args.action = function() end
  args.leftAction = nil
  args.rightAction = nil
  args.visibility = args.visibility or Settings.Visibility.VISIBLE

  if not args.id then
    if args.autoRegister then
      local id = Settings.shared.action(args)
      PSStorage.add("header", args, id)
      return id
    else
      error(Text.Errors.SettingID)
    end
  else
    PSStorage.add("header", args, PSMain.getModSettingPrefix() .. args.id)
    return Settings.shared.action(args)
  end
end

return module
