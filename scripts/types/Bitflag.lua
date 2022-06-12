local Enum            = require "system.utils.Enum"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local NixLib = require "NixLib.NixLib"

local EnumUtils = require "PowerSettings.EnumUtils"
local PSStorage = require "PowerSettings.PSStorage"

local module = {}

function module.format(value, presets)
  local hex = bit.tohex(value, 8)
  local n = EnumUtils.getName(presets, value)

  if n ~= nil then
    if SettingsStorage.get("config.showAdvanced") then return n .. " (0x" .. hex .. ")"
    else return n end
  end

  local split = NixLib.bitSplit(value)

  if #split == 0 then return L("No flags enabled", "formatNoFlags")
  elseif #split == 1 then return L.formatKey("1 flag (%s)", "formatOneFlag", "0x" .. hex)
  elseif #split == 2 then return L.formatKey("2 flags (%s)", "formatTwoFlags", "0x" .. hex)
  else return L.formatKey("%i flags (%s)", "formatManyFlags", #split, "0x" .. hex) end
  -- else return (#split) .. " flags (0x" .. hex .. ")" end
end

function module.getFlags(id)
  local flags = {}
  flags.names = {}
  local unnamedFlags = {}

  for k, v in pairs(flags) do
    local log2 = math.log(v) / math.log(2)
    if log2 == math.floor(log2) then
      flags[k] = v
      flags.names[v] = k
      unnamedFlags[v] = false
    else
      for i, v2 in ipairs(NixLib.bitSplit(v)) do
        if unnamedFlags[v] == nil then
          unnamedFlags[v] = true
        end
      end
    end
  end

  for k, v in pairs(unnamedFlags) do
    if v then
      local hex = bit.tohex(k, 8)
      hex = hex:sub(hex:find("[123456789abcdef]", 1, false), -1)
      flags[L.formatKey("Unnamed bit %s", "unnamedBitDetail", "0x" .. hex)] = k
      flags.names[k] = L("Unnamed bit", "unnamedBit")
    end
  end

  return flags
end

function module.nameFlags(flags)
  if EnumUtils.hasNames(flags) then return flags end

  local out = {}

  for k, v in pairs(flags) do
    out[k] = v
    out[v] = k
  end

  return out
end

function module.setting(mode, args)
  if args.presets == nil and args.flags == nil then
    error("Bitflag settings must specify flags or presets (preferably both).", 2)
  end
  args.editAsString = false -- forcibly false for bitflag settings, we'll edit as menu instead
  args.presets = args.presets or args.flags
  args.format = args.format or function(val) return module.format(val, args.presets) end
  args.flags = module.nameFlags(args.flags or module.getFlags(args.presets))
  PSStorage.add("bitflag", args)
  return Settings[mode].number(args)
end

function module.action(id)
  -- Opens the bitflag selectors
  Menu.open("PowerSettings_bitflag", id)
end

function module.leftAction(id)
  -- Sets the setting to the highest preset lower than its current value, or the highest preset altogether if no lower preset exists.
  local node = PSStorage.get(id, Settings.Layer.REMOTE_PENDING)
  local presets = node.data.presets
  local A = SettingsStorage.get(id, Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue(id)
  local B = nil

  for k, C in pairs(presets) do
    if B == nil or (B < A and C < A and C > B) or (B >= A and (C > B or C < A))
    then
      B = C
    end
  end

  SettingsStorage.set(id, B, Settings.Layer.REMOTE_PENDING)
end

function module.rightAction(id)
  -- Sets the setting to the lowest preset higher than its current value, or the lowest preset altogether if no higher preset exists.
  local node = PSStorage.get(id, Settings.Layer.REMOTE_PENDING)
  local presets = node.data.presets
  local A = SettingsStorage.get(id, Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue(id)
  local B = nil

  for k, C in pairs(presets) do
    if B == nil or (B > A and C > A and C < B) or (B <= A and (C < B or C > A))
    then
      B = C
    end
  end

  SettingsStorage.set(id, B, Settings.Layer.REMOTE_PENDING)
end

return module
