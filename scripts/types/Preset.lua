local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local Text = require "PowerSettings.i18n.Text"

local PSMain    = require "PowerSettings.PSMain"
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

function module.setting(mode, args)
  args.action = module.action(args.values, args.removeValues)

  if not args.id then
    if args.autoRegister then
      local id = Settings[mode].action(args)
      PSStorage.add("preset", args, id)
      return id
    else
      error(Text.Errors.SettingID)
    end
  else
    PSStorage.add("preset", args, PSMain.getModSettingPrefix() .. args.id)
    return Settings[mode].action(args)
  end
end
