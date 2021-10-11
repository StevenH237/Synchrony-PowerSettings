local module = {}

local storedSettings = {}

function module.add(type, data)
  local modName = script.loader
  modName = modName:sub(1, modName:find(".", 1, true) - 1)
  -- print("Storing mod." .. modName .. "." .. data.id)
  storedSettings["mod." .. modName .. "." .. data.id] = {type=type, data=data}
end

function module.contains(id)
  if storedSettings[id] then return true else return false end
end

function module.get(id)
  return storedSettings[id]
end

return module