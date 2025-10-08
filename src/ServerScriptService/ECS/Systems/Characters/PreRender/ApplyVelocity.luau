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

local MaxSlopeAngle = math.rad(55) -- Vector3.Angle returns an angle in radians, so radians is used here
local AddedLength = 0.05 -- Prevents wonky clipping
local MaxBounces = 3

local CharacterCollisionParams = RaycastParams.new()
CharacterCollisionParams.FilterType = Enum.RaycastFilterType.Include
CharacterCollisionParams.FilterDescendantsInstances = {workspace}
CharacterCollisionParams.RespectCanCollide = true
CharacterCollisionParams.CollisionGroup = "Game"

local function GetCollider(EntityID : number) : MeshPart
     return Characters:get(EntityID, PhysicsColliderComponent)
end

local function MovePlayer(PhysicsCollider : Instance, MoveVector : Vector3)
     local CurrentCFrame : CFrame = PhysicsCollider:GetPivot()
     
     PhysicsCollider:PivotTo(CurrentCFrame + MoveVector)
end

local function ProjectVelocity(LeftoverVelocity : Vector3, SurfaceNormal : Vector3) : Vector3
     local LeftOverVector : Vector3 = Vector3U.ProjectOnPlane(LeftoverVelocity, SurfaceNormal).Unit

     return LeftOverVector * LeftoverVelocity.Magnitude
end

local function CollideAndSlide(EntityID : number, PhysicsCollider : MeshPart?, Velocity : Vector3, HorizontalDirection : Vector3, Depth : number) -- Depth == Recursions
     if Depth >= MaxBounces then return end

     local VelocityDirection = Velocity.Unit
     local RayVector = VelocityDirection * (Velocity.Magnitude + AddedLength)

     local Collision : RaycastResult? = workspace:Shapecast(
          PhysicsCollider,
          RayVector,
          CharacterCollisionParams
     )
     
     if Collision then
          local DistanceToSurface = Collision.Distance - AddedLength
          local VectorToSurface = Vector3.zero

          if DistanceToSurface > AddedLength then
               VectorToSurface = VelocityDirection * DistanceToSurface
          end

          local ProjectedVector = ProjectVelocity(
               Velocity - VectorToSurface, -- Remaining velocity from collision
               Collision.Normal
          )
          
          local Angle = Vector3.yAxis:Angle(Collision.Normal)
          --print(math.deg(Angle))
          if Angle >= MaxSlopeAngle then
               --Makes the player move slower the more perpendicular their move direction is
               local Normal = Vector3.new(Collision.Normal.X, 0, Collision.Normal.Z).Unit
               local Scale = math.min(1, 1.2 - Normal:Dot(HorizontalDirection))

               ProjectedVector *= Scale
          end

          MovePlayer(PhysicsCollider, VectorToSurface)
          CollideAndSlide(EntityID, PhysicsCollider, ProjectedVector, HorizontalDirection, Depth + 1)
     else
          MovePlayer(PhysicsCollider, Velocity)
     end
end

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID, Velocity in PlayerVelocities do
          if Velocity == Vector3.zero then continue end
          Velocity *= DT

          local HorizontalDirection = Vector3.new(Velocity.X, 0, Velocity.Z).Unit * -1
          
          CollideAndSlide(EntityID, GetCollider(EntityID), Velocity, HorizontalDirection, 1)
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