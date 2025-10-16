--!optimize 2
--!native
--!strict

--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local ForceVelocityManager = require(ServerScriptService.ECS.Modules.Characters.ForceVelocityManager)
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)

--ECS
local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local ForceAppliedEntities = CharacterQueries.ForceAppliedEntities

--Types
type DecayRate = number
type Velocity = Vector3

type ForceVelocities = {[number | string?] : {DecayRate | Velocity}}

--Variables
local Epsilon = 5

local function DecayVelocity(DT : number, VelocityIndex : number | string?, ForceVelocities : ForceVelocities, DecayRate : number, ForceVelocity : Vector3)
     if DecayRate ~= 0 then
          ForceVelocity *= math.exp(-DecayRate * DT)
     else
          return 0
     end

     if ForceVelocity.Magnitude >= Epsilon then
          ForceVelocities[VelocityIndex][2] = ForceVelocity
     else
          ForceVelocities[VelocityIndex] = nil
     end

     return 1
end

local function UpdateForceVelocity()
     local DT = Scheduler:getDeltaTime()

     for EntityID, ForceVelocitiesBuf in ForceAppliedEntities do
          local ForceVelocities = ForceVelocityManager.GetVelocities(ForceVelocitiesBuf)
          local Updates = 0

          for Index, VelocityData in ForceVelocities do
               Updates += DecayVelocity(DT, Index, ForceVelocities, VelocityData[1], VelocityData[2])
          end
          
          if Updates > 0 then
               ForceVelocityManager.UpdateVelocities(ForceVelocities, EntityID)
          end
     end
end

return {
     name = "Force Velocity Updates",
     system = UpdateForceVelocity,
     runConditions = table.freeze({
          
     })
}