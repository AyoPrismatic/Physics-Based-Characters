--!optimize 2
--!native
--!strict

--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)

--ECS
local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)

local MovementAppliedEntities = CharacterQueries.MovementAppliedEntities
local ForceAppliedEntities = CharacterQueries.ForceAppliedEntities

--Types
type EntityID = number

type DecayRate = number
type Velocity = Vector3

--Variables
local ApplyVelocitySystem = require(ServerScriptService.ECS.Systems.Characters.PreRender.ApplyVelocity)

local function CalculateVelocities()
     local DT = Scheduler:getDeltaTime()
     
     for EntityID, MoveVelocity in MovementAppliedEntities do
          ApplyVelocitySystem.UpdateVelocityData(EntityID, MoveVelocity * DT)
     end

     for EntityID, ForceVelocities : {[string?] : {DecayRate | Velocity}} in ForceAppliedEntities do
          for _, VelocityData in ForceVelocities do
               ApplyVelocitySystem.UpdateVelocityData(EntityID, VelocityData[2] * DT)
          end
     end
end

return {
     name = "Velocity Updates",
     system = CalculateVelocities,
     runConditions = table.freeze({
          
     })
}
