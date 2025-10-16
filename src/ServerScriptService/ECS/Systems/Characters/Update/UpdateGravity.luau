--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)

--Packages
local Squash = require(ReplicatedStorage.Packages.Squash)

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
local ComponentLimits = Global.ComponentLimits
local MaxGravity = ComponentLimits.Gravity
local RateOfGravity = Global.RateOfGravity

local NewBuffer = Squash.tobuffer
local NewCursor = Squash.cursor
local Uint = Squash.uint

local function IsFalling(EntityID : number) : boolean
     return Characters:get(EntityID, PlayerStateComponent) == Global.PlayerStates.Falling
end

local function UpdateGravity(DT : number, EntityID : number, AirTime : number)
     local Cursor = NewCursor(24) -- <- A Squash "Cursor" with 24 slots for bits (3 bytes of storage)

     AirTime += DT

     Uint(3).ser(
          Cursor,
          --Max Gravity is 1000. Using a 3 byte uint we can store gravity and 4 of it's decimal places
          math.min(MaxGravity, RateOfGravity * AirTime) * 10000 -- <- Multiplied by 10k to keep the 1st 4 decimals
     )

     Characters:set(EntityID, AirTimeComponent, AirTime)
     Characters:set(EntityID, GravityComponent,
          NewBuffer(Cursor)
     )
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