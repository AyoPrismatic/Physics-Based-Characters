--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local Vector3U = require(ReplicatedStorage.Utils.Vector)[3]

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)

local PhysicsColliderComponent = CharacterComponents.List.PhysicsCollider

--Types
type EntityID = number
type Velocity = Vector3
type PlayerVelocities = {[EntityID] : Velocity}

--Variables
local PlayerStates = require(ReplicatedStorage.ECS.EntityData.PlayerCharacter.PlayerStates)
local PlayerVelocities : {[EntityID] : Velocity} = {}

local MaxBounces = 5
local AddedWidth = 0.02 -- Prevents wonky clipping

local CharacterCollisionParams = RaycastParams.new()
--CharacterCollisionParams.FilterType = Enum.RaycastFilterType.Include
--CharacterCollisionParams.FilterDescendantsInstances = workspace
CharacterCollisionParams.RespectCanCollide = true
CharacterCollisionParams.CollisionGroup = "Game"


local function MovePlayer(PhysicsCollider : Instance, MoveVector : Vector3)
     local CurrentCFrame : CFrame = PhysicsCollider:GetPivot()
     
     PhysicsCollider:PivotTo(CurrentCFrame + MoveVector)
end

local function ProjectVelocity(LeftoverVelocity : Vector3, SurfaceNormal : Vector3) : Vector3
     local LeftOverVector : Vector3 = Vector3U.ProjectOnPlane(LeftoverVelocity, SurfaceNormal).Unit
     local LeftOverDistance : Vector3 = LeftoverVelocity.Magnitude

     return LeftOverVector * LeftOverDistance
end

local function CollideAndSlide(EntityID : number, PhysicsCollider : BasePart, Velocity : Vector3, Depth : number) -- Depth == Recursions
     if Depth >= MaxBounces then return Vector3.zero else
          if not PhysicsCollider then
               PhysicsCollider = Characters:get(EntityID, PhysicsColliderComponent)
          end
     end

     local Collision : RaycastResult? = workspace:Shapecast(
          PhysicsCollider,
          Velocity + Vector3.new(AddedWidth),
          CharacterCollisionParams
     )

     if Collision then
          local VectorToSurface = Velocity.Unit * (Collision.Distance - AddedWidth)
          if VectorToSurface.Magnitude <= AddedWidth then
               VectorToSurface = Vector3.zero
          end

          local ProjectedVector = ProjectVelocity(
               Velocity - VectorToSurface, -- Remaining velocity from collision
               Collision.Normal
          )

          MovePlayer(PhysicsCollider, VectorToSurface)
          CollideAndSlide(EntityID, PhysicsCollider, ProjectedVector, Depth + 1)
     else
          MovePlayer(PhysicsCollider, Velocity)
     end
end

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID, Velocity in PlayerVelocities do
          CollideAndSlide(EntityID, nil, Velocity * DT, 1)
     end
end

return {
     UpdateVelocityData = function(VelocityTable : PlayerVelocities)
          PlayerVelocities = VelocityTable
     end,

     SystemData = {
          name = "Velocity Application",
          system = UpdateEntities,
          runConditions = table.freeze({
               
          })
     }
}