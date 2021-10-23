local Entities = require "system.game.Entities"
local Event    = require "necro.event.Event"

local Entity = require "PowerSettings.types.Entity"

local entitySettings = {}

local module = {}

function module.add(args)
  entitySettings[#entitySettings+1] = args
end

Event.ecsSchemaReloaded.add("entitySettings", {order="updateECS", sequence=1}, function(ev)
  for i, v in ipairs(entitySettings) do
    v.entities = Entity.getFilteredEntities(v.filter)
  end
end)

return module