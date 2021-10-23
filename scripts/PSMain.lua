local module = {}

function module.getCallingMod()
  local modName = script.loader
  return modName:sub(1, modName:find(".", 1, true) - 1)
end

return module