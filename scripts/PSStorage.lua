local PSMain = require "PowerSettings.PSMain"

local module = {}

local storedSettings = {}

function module.add(sType, data)
  storedSettings["mod." .. PSMain.getCallingMod() .. "." .. data.id] = {sType=sType, data=data}
end

function module.contains(id)
  if storedSettings[id] then return true else return false end
end

function module.get(id)
  return storedSettings[id]
end

return module