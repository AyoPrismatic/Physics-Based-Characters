--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)

--ECS
local Global = require(ReplicatedStorage.ECS.Globals.Character)
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local GravityUpdates = CharacterQueries.GravityUpdates

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local PlayerStateComponent = Components.PlayerState
local AirTimeComponent = Components.AirTime
local GravityComponent = Components.Gravity

--Constants
local GRAVITYRATE = 196.2

local function IsFalling(EntityID : number) : boolean
     return Characters:get(EntityID, PlayerStateComponent) == Global.PlayerStates.Falling
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