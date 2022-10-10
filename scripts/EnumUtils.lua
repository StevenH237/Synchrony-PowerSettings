local module = {}

function module.getName(table, value)
  local hasData, data = pcall(function(e) return e.data end, table)
  if hasData and data and data[value] ~= nil and data[value].name ~= nil then return data[value].name end

  local hasPrettyNames, prettyNames = pcall(function(e) return e.prettyNames end, table)
  if hasPrettyNames and prettyNames and prettyNames[value] ~= nil then return prettyNames[value] end

  local hasNames, names = pcall(function(e) return e.names end, table)
  if hasNames and names and names[value] ~= nil then return names[value] end

  for k, v in pairs(table) do
    if v == value then return k end
  end

  return nil
end

function module.hasNames(table)
  local hasData, data = pcall(function(e) return e.data end, table)
  if hasData and data then
    for i, v in ipairs(data) do
      if data.name then return true end
    end
  end

  local hasNames, names = pcall(function(e) return e.names end, table)

  if hasNames == false then return nil end
  if names == nil then return false end
  return true
end

return module
