--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--ECS
local Global = require(ReplicatedStorage.ECS.Globals.Character)

local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local PlayerStateComponent = CharacterComponents.List.PlayerState

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local PositionUpdates = CharacterQueries.PositionUpdates

--Variables
local DownVector = -Vector3.yAxis

local Radius = Global.PlayerCharacterRadius
local FloatHeight = 1.35
local Epsilon = 0.2

DownVector *= FloatHeight + Epsilon

local Params = RaycastParams.new()

Params.FilterType = Enum.RaycastFilterType.Include
Params.FilterDescendantsInstances = {workspace}
Params.RespectCanCollide = true
Params.CollisionGroup = "Game"

local function ProcessCollider(EntityID : number, Position : Vector3)
     local RaycastPos = Vector3.new(Position.X, Position.Y - Radius, Position.Z) -- (Position.Y - Radius) = Bottom of Collider

     local Collision : RaycastResult? = workspace:Raycast(
          RaycastPos,
          DownVector,
          Params
     )
     
     if Collision == nil or Collision.Distance < (FloatHeight - Epsilon) then
          Characters:set(EntityID, PlayerStateComponent,
               Global.PlayerStates.Falling
          )
     end
end

local function GetColliders()
     for EntityID : number, Position : Vector3Value in PositionUpdates do
          local PlayerState = Characters:get(EntityID, PlayerStateComponent)
          if PlayerState == Global.PlayerStates.Falling then continue end

          ProcessCollider(EntityID, Position.Value)
     end
end

return {
     name = "Apply Gravity Check",
     system = GetColliders,
     runConditions = table.freeze({
       
     })
}