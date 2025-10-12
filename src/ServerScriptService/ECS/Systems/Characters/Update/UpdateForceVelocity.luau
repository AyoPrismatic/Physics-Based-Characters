--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
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

local function DecayVelocity(DT : number, EntityID : number, VelocityIndex : number | string?, ForceVelocities : ForceVelocities, DecayRate : number, ForceVelocity : Vector3)
     ForceVelocity *= math.exp(-DecayRate * DT)

     if ForceVelocity.Magnitude < Epsilon then
          ForceVelocities[VelocityIndex] = nil
          return
     end

     ForceVelocities[VelocityIndex][2] = ForceVelocity
end

local function UpdateForceVelocity()
     local DT = Scheduler:getDeltaTime()

     for EntityID, ForceVelocities in ForceAppliedEntities do
          if next(ForceVelocities) == nil then continue end -- There is no Applied Force Velocity

          for Index, VelocityData in ForceVelocities do
               DecayVelocity(DT, EntityID, Index, ForceVelocities, VelocityData[1], VelocityData[2])
          end
     end
end

return {
     name = "Force Velocity Updates",
     system = UpdateForceVelocity,
     runConditions = table.freeze({
          
     })
}