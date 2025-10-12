--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local PlayerStates = require(ReplicatedStorage.ECS.EntityData.PlayerCharacter.PlayerStates)

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local PlayerStateComponent = CharacterComponents.List.PlayerState

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local PhysicsColliders = CharacterQueries.PhysicsColliders

--Variables
local DownVector = -Vector3.yAxis

local FloatHeight = 1
local Epsilon = 0.1

FloatHeight += Epsilon
DownVector *= FloatHeight

local function MakeParams(Collider : MeshPart) : RaycastParams
     local Params = RaycastParams.new()
     
     Params.FilterType = Enum.RaycastFilterType.Exclude
     Params.FilterDescendantsInstances = {Collider}
     Params.RespectCanCollide = true
     Params.CollisionGroup = "Game"
     
     return Params
end

local function ProcessCollider(EntityID : number, Collider : MeshPart)
     local ColliderPos = Collider:GetPivot().Position
     local ColliderSize = Collider.Size
     
     local ColliderBottom = ColliderPos.Y - (ColliderSize.Y / 2)
     local RaycastPos = Vector3.new(ColliderPos.X, ColliderBottom, ColliderPos.Z)

     local Collision : RaycastResult? = workspace:Raycast(
          RaycastPos,
          DownVector,
          MakeParams(Collider)
     )
     
     if not Collision then
          Characters:set(EntityID, PlayerStateComponent,
               PlayerStates.Falling
          )
     end
end

local function GetColliders()
     for EntityID : number, Collider : MeshPart in PhysicsColliders do
          local PlayerState = Characters:get(EntityID, PlayerStateComponent)
          if PlayerState == PlayerStates.Falling then continue end

          ProcessCollider(EntityID, Collider)
     end
end

return {
     name = "Apply Gravity Check",
     system = GetColliders,
     runConditions = table.freeze({
       
     })
}