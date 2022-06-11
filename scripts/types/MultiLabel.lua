local Settings        = require "necro.config.Settings"
local StringUtilities = require "system.utils.StringUtilities"
local Utilities       = require "system.utils.Utilities"

local PSTLabel = require "PowerSettings.types.Label"

local module = {}

function module.setting(mode, args)
  args.action = function() end
  args.visibility = args.visibility or Settings.Visibility.VISIBLE
  args.autoRegister = true -- forcibly required for multi-labels

  -- Note: This doesn't define a PSStorage-stored node because it defines several sub-settings.
  local texts = args.texts or StringUtilities.split(args.name, "\n")

  local output = {}

  for i, v in ipairs(texts) do
    local subArgs = Utilities.deepCopy(args)
    subArgs.texts = nil
    subArgs.name = v
    subArgs.id = subArgs.id .. tostring(i)
    subArgs.order = subArgs.order + ((i - 1) / #texts)
    output[i] = PSTLabel.setting(mode, subArgs)
  end

  return output
end

return module
