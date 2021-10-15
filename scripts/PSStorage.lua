local module = {}

local storedSettings = {}

function module.add(sType, data)
  local modName = script.loader
  modName = modName:sub(1, modName:find(".", 1, true) - 1)
  storedSettings["mod." .. modName .. "." .. data.id] = {sType=sType, data=data}
end

function module.contains(id)
  if storedSettings[id] then return true else return false end
end

function module.get(id)
  return storedSettings[id]
end

return module