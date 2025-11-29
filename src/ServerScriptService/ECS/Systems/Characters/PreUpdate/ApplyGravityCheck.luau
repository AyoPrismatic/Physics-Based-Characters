--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--ECS
local CharacterGlobals = require(ReplicatedStorage.ECS.Globals.Character)
local Properties = CharacterGlobals.CharacterProperties
local PlayerStates = CharacterGlobals.PlayerStates

local Serdes = require(ReplicatedStorage.ECS.Components.Character.Serdes)

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local PlayerStateComponent = CharacterComponents.List.PlayerState

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local PositionUpdates = CharacterQueries.PositionUpdates

--Variables
local CollisionEpsilon = Properties.CollisionEpsilon
local CollisionParams = Properties.CollisionParams
local CharacterRadius = Properties.CharacterRadius
local FloatHeight = Properties.FloatHeight

local DownVector = -Vector3.yAxis * (FloatHeight + CollisionEpsilon)

local function ProcessCollider(EntityID : number, Position : Vector3)
     local Collision = workspace:Raycast(
          Vector3.new(Position.X, Position.Y - CharacterRadius, Position.Z), -- <- (Position.Y - Radius) = Bottom of Collider
          DownVector * 1.4,
          CollisionParams
     )
     
     if not Collision or Collision.Distance > (FloatHeight - CollisionEpsilon) then
          Serdes.SerializeAndSet(EntityID, PlayerStateComponent,
               PlayerStates.Falling
          )
     end
end

local function GetColliders()
     for EntityID : number, PositionObject : Vector3Value in PositionUpdates do
          if Serdes.GetDeserialized(EntityID, PlayerStateComponent) ~= PlayerStates.Falling then
               ProcessCollider(EntityID, PositionObject.Value)
          end
     end
end

return {
     name = "Apply Gravity Check",
     system = GetColliders,
     runConditions = table.freeze({
       
     })
}