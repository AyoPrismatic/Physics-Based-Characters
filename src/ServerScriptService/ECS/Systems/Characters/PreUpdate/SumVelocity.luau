--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)
local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)

local MovementAppliedEntities = CharacterQueries.MovementAppliedEntities
local GravityAppliedEntities = CharacterQueries.GravityAppliedEntities
local ForceAppliedEntities = CharacterQueries.ForceAppliedEntities

--Types
type EntityID = number
type Velocity = Vector3

--Variables
local ApplyVelocitySystem = require(ServerScriptService.ECS.Systems.Characters.Update.ApplyVelocity)
local PlayerVelocities : {[EntityID] : Velocity} = {}

local function UpdateVelocity(EntityID : number, AddedForce : Vector3)
     PlayerVelocities[EntityID] += AddedForce
end

local function CalculateEntities()
     for EntityID, MoveVelocity in MovementAppliedEntities do
          PlayerVelocities[EntityID] = MoveVelocity
     end

     for EntityID, ForceVelocity in ForceAppliedEntities do
          UpdateVelocity(EntityID, ForceVelocity)
     end

     ApplyVelocitySystem.UpdateVelocityData(PlayerVelocities)
end

return {
     name = "Velocity Summation",
     system = CalculateEntities,
     runConditions = table.freeze({
          
     })
}