local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local PSMain    = require "PowerSettings.PSMain"
local PSStorage = require "PowerSettings.PSStorage"

local module = {}

function module.validateBounds(id)
  local this = PSStorage.get(id)
  local value = SettingsStorage.get(id, Settings.Layer.REMOTE_PENDING) or SettingsStorage.get(id)
  local newValue = nil
  local lowerBound = this.data.lowerBound
  local lowerValue = nil
  local upperBound = this.data.upperBound
  local upperValue = nil

  -- Let's validate the lower bound first
  if type(lowerBound) == "string" then
    -- Strings are treated as a setting ID.
    lowerValue = SettingsStorage.get(lowerBound, Settings.Layer.REMOTE_PENDING) or SettingsStorage.get(lowerBound)
  elseif type(lowerBound) == "function" then
    -- Functions are called parameterlessly.
    lowerValue = lowerBound()
  end

  if lowerValue and value < lowerValue then
    value = lowerValue
    newValue = lowerValue
  end

  -- Let's validate the upper bound second
  if type(upperBound) == "string" then
    -- Strings are treated as a setting ID.
    upperValue = SettingsStorage.get(upperBound, Settings.Layer.REMOTE_PENDING) or SettingsStorage.get(upperBound)
  elseif type(upperBound) == "function" then
    -- Functions are called parameterlessly.
    upperValue = upperBound()
  end

  if upperValue and value > upperValue then
    value = upperValue
    newValue = upperValue
  end

  -- If we're changing the value, then change it
  if newValue then
    SettingsStorage.set(id, newValue, Settings.Layer.REMOTE_PENDING)
  end
end

function module.setting(scope, sType, args)
  if type(args.lowerBound) == "string" and args.lowerBound:sub(1, 4) ~= "mod." then
    args.lowerBound = "mod." .. PSMain.getCallingMod() .. "." .. args.lowerBound
  end
  if type(args.upperBound) == "string" and args.upperBound:sub(1, 4) ~= "mod." then
    args.upperBound = "mod." .. PSMain.getCallingMod() .. "." .. args.upperBound
  end
  PSStorage.add(sType, args)
  return Settings[scope][sType](args)
end

return module