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

--Variables
local GetVelocities = require(ServerScriptService.ECS.Modules.Characters.ForceVelocityManager).GetVelocities
local ApplyVelocitySystem = require(ServerScriptService.ECS.Systems.Characters.PostUpdate.ApplyVelocity)

local function CalculateVelocities()
     local DT = Scheduler:getDeltaTime()
     
     for EntityID, MoveVelocity in MovementAppliedEntities do
          ApplyVelocitySystem.UpdateVelocityData(EntityID, MoveVelocity * DT)
     end

     for EntityID, ForceVelocitiesBuf : buffer in ForceAppliedEntities do
          for _, VelocityData in GetVelocities(ForceVelocitiesBuf) do
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
