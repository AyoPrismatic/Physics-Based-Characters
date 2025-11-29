--!optimize 2
--!native
--!strict

--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)

--ECS
local Serdes = require(ReplicatedStorage.ECS.Components.Character.Serdes)

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local MovementAppliedEntities = CharacterQueries.MovementAppliedEntities
local ForceAppliedEntities = CharacterQueries.ForceAppliedEntities

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local MoveVelocityComponent = Components.MoveVelocity

--Variables
local GetVelocities = require(ServerScriptService.ECS.Modules.Characters.ForceVelocityManager).GetVelocities
local ApplyVelocitySystem = require(ServerScriptService.ECS.Systems.Characters.PostUpdate.ApplyVelocity)

local function CalculateVelocities()
     local DT = Scheduler:getDeltaTime()
     
     for EntityID : number, MoveVelocityBuf : buffer in MovementAppliedEntities do
          ApplyVelocitySystem.UpdateVelocityData(EntityID,
               Serdes.Deserialize(MoveVelocityComponent, MoveVelocityBuf) * DT
          )
     end

     for EntityID : number, ForceVelocitiesBuf : buffer in ForceAppliedEntities do
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
