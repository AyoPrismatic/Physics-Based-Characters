--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local Entities = CharacterQueries.Entities

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local TravelledVelocityComponent = CharacterComponents.List.TravelledVelocity

--Types
type EntityID = number
type Velocity = Vector3

--Variables
local PlayerVelocities : {[EntityID] : Velocity} = {}

local function UpdateEntities()
     for EntityID : number in Entities do
          local TravelledVelocity = PlayerVelocities[EntityID] or Vector3.zero
          Characters:set(EntityID, TravelledVelocityComponent,
               TravelledVelocity
          )

          PlayerVelocities[EntityID] = nil
     end

     table.clear(PlayerVelocities)
end

return {
     UpdateVelocityData = function(EntityID : number, Velocity : Vector3)
          local CurrentVelocity : Vector3 = PlayerVelocities[EntityID] or Vector3.zero

          PlayerVelocities[EntityID] = CurrentVelocity + Velocity
     end,

     SystemData = {
          name = "Velocity Application",
          system = UpdateEntities,
          runConditions = table.freeze({
               
          })
     }
}