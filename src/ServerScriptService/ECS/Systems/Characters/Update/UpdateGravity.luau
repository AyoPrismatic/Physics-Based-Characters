--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)

--ECS
local Serdes = require(ReplicatedStorage.ECS.Components.Character.Serdes)

local CharacterGlobals = require(ReplicatedStorage.ECS.Globals.Character)
local ComponentLimits = CharacterGlobals.ComponentLimits
local Properties = CharacterGlobals.CharacterProperties
local PlayerStates = CharacterGlobals.PlayerStates

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local GravityUpdates = CharacterQueries.GravityUpdates

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local PlayerStateComponent = Components.PlayerState
local AirTimeComponent = Components.AirTime
local GravityComponent = Components.Gravity

--Constants
local RateOfGravity = Properties.RateOfGravity
local MaxGravity = ComponentLimits.Gravity

local function IsFalling(EntityID : number) : boolean
     return Serdes.GetDeserialized(EntityID, PlayerStateComponent) == PlayerStates.Falling
end

local function UpdateGravity(DT : number, EntityID : number, AirTime : number)
     AirTime += DT
     
     Serdes.SerializeAndSet(EntityID, GravityComponent, math.min(MaxGravity, RateOfGravity * AirTime))
     Serdes.SerializeAndSet(EntityID, AirTimeComponent, AirTime)
end

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID, AirTime : buffer in GravityUpdates do
          if IsFalling(EntityID) then
               UpdateGravity(DT, EntityID, Serdes.Deserialize(AirTimeComponent, AirTime))
          end
     end
end

return {
     name = "Gravity Updates",
     system = UpdateEntities,
     runConditions = table.freeze({
          
     })
}