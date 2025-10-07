--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)

local GravityUpdates = CharacterQueries.GravityUpdates

local PlayerStateComponent = CharacterComponents.List.PlayerState
local AirTimeComponent = CharacterComponents.List.AirTime
local GravityComponent = CharacterComponents.List.Gravity

--Variables
local PlayerStates = require(ReplicatedStorage.ECS.EntityData.PlayerCharacter.PlayerStates)

--Constants
local GRAVITYRATE = 196.2

local function IsFalling(EntityID : number) : boolean
     return Characters:get(EntityID, PlayerStateComponent) == PlayerStates.Falling
end

local function UpdateGravity(DT : number, EntityID : number, AirTime : number)
     AirTime += DT
     
     Characters:set(EntityID, AirTimeComponent, AirTime)
     Characters:set(EntityID, GravityComponent, GRAVITYRATE * AirTime)
end

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID, AirTime in GravityUpdates do
          if IsFalling(EntityID) then
               UpdateGravity(DT, EntityID, AirTime)
          end
     end
end

return {
     name = "Gravity Updates",
     system = UpdateEntities,
     runConditions = table.freeze({
          
     })
}