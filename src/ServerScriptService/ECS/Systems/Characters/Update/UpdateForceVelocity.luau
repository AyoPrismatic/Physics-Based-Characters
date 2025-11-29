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
local CharacterGlobals = require(ReplicatedStorage.ECS.Globals.Character)
local Properties = CharacterGlobals.CharacterProperties

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local ForceAppliedEntities = CharacterQueries.ForceAppliedEntities

--Types
type DecayRate = number
type Velocity = Vector3

type ForceVelocities = {[number | string?] : {DecayRate | Velocity}}

--Variables
local MinForceVelocity = Properties.MinForceVelocity

local function DecayVelocity(DT : number, VelocityIndex : number | string?, ForceVelocities : ForceVelocities, DecayRate : number, ForceVelocity : Vector3)
     if DecayRate ~= 0 then
          ForceVelocity *= math.exp(-DecayRate * DT)
     end

     if ForceVelocity.Magnitude >= MinForceVelocity then
          ForceVelocities[VelocityIndex][2] = ForceVelocity
     else
          ForceVelocities[VelocityIndex] = nil
     end
end

local function UpdateForceVelocity()
     local DT = Scheduler:getDeltaTime()

     for EntityID, ForceVelocitiesBuf in ForceAppliedEntities do
          local ForceVelocities = ForceVelocityManager.GetVelocities(ForceVelocitiesBuf)

          for Index, VelocityData in ForceVelocities do
               DecayVelocity(DT, Index, ForceVelocities, VelocityData[1], VelocityData[2])
          end
          
          ForceVelocityManager.UpdateVelocities(ForceVelocities, EntityID)
     end
end

return {
     name = "Force Velocity Updates",
     system = UpdateForceVelocity,
     runConditions = table.freeze({
          
     })
}