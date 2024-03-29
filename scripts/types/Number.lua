local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local Text = require "PowerSettings.i18n.Text"

local PSMain    = require "PowerSettings.PSMain"
local PSStorage = require "PowerSettings.PSStorage"

local module = {}

function module.validateBounds(id, layer)
  local this = PSStorage.get(id).data
  local value = SettingsStorage.get(id, Settings.Layer.REMOTE_PENDING) or SettingsStorage.get(id)
  local newValue = nil
  local lowerBound = this.lowerBound
  local lowerValue = nil
  local upperBound = this.upperBound
  local upperValue = nil

  -- Let's validate the lower bound first
  if type(lowerBound) == "string" then
    -- Strings are treated as a setting ID.
    lowerValue = SettingsStorage.get(lowerBound)
  elseif type(lowerBound) == "function" then
    -- Functions are called parameterlessly.
    lowerValue = lowerBound()
  elseif type(lowerBound) == "number" then
    -- Just in case.
    lowerValue = lowerBound
  end

  if lowerValue and value < lowerValue then
    value = lowerValue
    newValue = lowerValue
  end

  -- Let's validate the upper bound second
  if type(upperBound) == "string" then
    -- Strings are treated as a setting ID.
    upperValue = SettingsStorage.get(upperBound)
  elseif type(upperBound) == "function" then
    -- Functions are called parameterlessly.
    upperValue = upperBound()
  elseif type(upperBound) == "number" then
    -- Just in case.
    upperValue = upperBound
  end

  if upperValue and value > upperValue then
    value = upperValue
    newValue = upperValue
  end

  -- If we're changing the value, then change it
  if newValue then
    SettingsStorage.set(id, newValue, layer)
  end
end

function module.setting(scope, sType, args)
  if type(args.lowerBound) == "string" and args.lowerBound:sub(1, 4) ~= "mod." then
    args.lowerBound = "mod." .. PSMain.getCallingMod() .. "." .. args.lowerBound
  end
  if type(args.upperBound) == "string" and args.upperBound:sub(1, 4) ~= "mod." then
    args.upperBound = "mod." .. PSMain.getCallingMod() .. "." .. args.upperBound
  end

  if not args.id then
    if args.autoRegister then
      local id = Settings[scope][sType](args)
      PSStorage.add(sType, args, id)
      return id
    else
      error(Text.Errors.SettingID)
    end
  else
    PSStorage.add(sType, args, PSMain.getModSettingPrefix() .. args.id)
    return Settings[scope][sType](args)
  end
end

return module
