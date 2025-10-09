--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local ForceVelocityComponent = CharacterComponents.List.ForceVelocity

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local ForceAppliedEntities = CharacterQueries.ForceAppliedEntities

local Epsilon = 3
local AirDrag = 5

local function DecayVelocity(DT : number, EntityID : number, ForceVelocity : Vector3)
     ForceVelocity *= math.exp(-AirDrag * DT)

     if ForceVelocity.Magnitude < Epsilon then
          ForceVelocity = Vector3.zero
     end

     Characters:set(EntityID, ForceVelocityComponent,
          ForceVelocity
     )
end

local function UpdateForceVelocity()
     local DT = Scheduler:getDeltaTime()

     for EntityID, ForceVelocity in ForceAppliedEntities do
          if ForceVelocity == Vector3.zero then continue end

          DecayVelocity(DT, EntityID, ForceVelocity)
     end
end

return {
     name = "Force Velocity Updates",
     system = UpdateForceVelocity,
     runConditions = table.freeze({
          
     })
}