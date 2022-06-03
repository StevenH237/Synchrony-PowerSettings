local Entities = require "system.game.Entities"
local Event    = require "necro.event.Event"

local PSComponent = require "PowerSettings.types.Component"
local PSEntity    = require "PowerSettings.types.Entity"

local entitySettings = {}
local componentSettings = {}

local module = {}

function module.add(args)
  entitySettings[#entitySettings + 1] = args
end

function module.addc(args)
  componentSettings[#componentSettings + 1] = args
end

Event.ecsSchemaReloaded.add("entitySettings", { order = "updateECS", sequence = 1000 }, function(ev)
  for i, v in ipairs(entitySettings) do
    v.entities = PSEntity.getFilteredEntities(v.filter)
  end

  for i, v in ipairs(componentSettings) do
    v.components = PSComponent.getFilteredComponents(v.filter)
  end
end)

return module
