local module = {}

local autoRegisters = {}

function module.getCallingMod()
  local modName = script.loader
  return modName:sub(1, modName:find(".", 1, true) - 1)
end

function module.getModSettingPrefix()
  return "mod." .. module.getCallingMod() .. "."
end

function module.setAutoRegister(mode)
  local modName = module.getCallingMod()
  autoRegisters[modName] = mode
end

function module.isAutoRegister()
  local modName = module.getCallingMod()
  return not not autoRegisters[modName]
end

return module
