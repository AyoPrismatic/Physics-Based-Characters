--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local Interpolator = require(ReplicatedStorage.Utils.Interpolator)
local UVector3 = require(ReplicatedStorage.Utils.Vector)[3]

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)

local GravityAppliedEntities = CharacterQueries.GravityAppliedEntities

local SpringVelocityComponent = CharacterComponents.List.GravitySpringVelocity
local GroundNormalComponent = CharacterComponents.List.GroundNormal
local PlayerStateComponent = CharacterComponents.List.PlayerState
local AbsoluteYComponent = CharacterComponents.List.AbsoluteY
local GravityComponent = CharacterComponents.List.Gravity
local AirTimeComponent = CharacterComponents.List.AirTime

--Variables
local CharacterStates = require(ReplicatedStorage.ECS.EntityData.PlayerCharacter.PlayerStates)

local Frequency, Damping, Responsiveness = Interpolator.GenerateParameters(1.5, 0.8, 1.75)

local DownVector = Vector3.new(0, -1, 0)
local MaxSlopeAngle = math.rad(55) -- Vector3.Angle returns an angle in radians, so radians is used here
local AddedLength = 3 -- Prevents wonky clipping
local FloatHeight = 1
local MaxBounces = 3

local Epsilon = 0.12

local CharacterCollisionParams = RaycastParams.new()
CharacterCollisionParams.FilterType = Enum.RaycastFilterType.Include
CharacterCollisionParams.FilterDescendantsInstances = {workspace}
CharacterCollisionParams.RespectCanCollide = true
CharacterCollisionParams.CollisionGroup = "Game"

local function CharacterFalling(EntityID : Instance)
     Characters:set(EntityID, PlayerStateComponent, CharacterStates.Falling)
end

local function CharacterLanded(EntityID : Instance)
     Characters:set(EntityID, PlayerStateComponent, CharacterStates.Grounded)
     Characters:set(EntityID, GravityComponent, 0)
     Characters:set(EntityID, AirTimeComponent, 0)
end

local function MovePlayer(PhysicsCollider : Instance, MoveVector : Vector3)
     local CurrentCFrame : CFrame = PhysicsCollider:GetPivot()
     
     PhysicsCollider:PivotTo(CurrentCFrame + MoveVector)
end

local function ProjectVelocity(LeftoverVelocity : Vector3, SurfaceNormal : Vector3) : Vector3
     local LeftOverVector : Vector3 = UVector3.ProjectOnPlane(LeftoverVelocity, SurfaceNormal).Unit

     return LeftOverVector * LeftoverVelocity.Magnitude
end

local function GetAngle(SurfaceNormal : Vector3) : number
     return Vector3.yAxis:Angle(SurfaceNormal)
end

local function Round(Number) : number
     return math.round(Number * 1000) / 1000
end

local function CollideAndSlide(EntityID : number, PhysicsCollider : MeshPart, Velocity : Vector3, HorizontalDirection : Vector3, Depth : number) -- Depth == Recursions
     if Depth >= MaxBounces then return end

     local ColliderSize = PhysicsCollider.Size
     local ColliderPos = PhysicsCollider:GetPivot().Position

     local VelocityDirection = if Depth == 1 then DownVector else Velocity.Unit
     local RayVector = VelocityDirection * (Velocity.Magnitude + AddedLength)
     
     local Collision : RaycastResult? = workspace:Shapecast(
          PhysicsCollider,
          RayVector,
          CharacterCollisionParams
     )

     CharacterFalling(EntityID)
     
     if Collision then
          --The distance from the bottom of the collider to the collision point (Y)
          local DistanceToSurface = ColliderPos.Y - Collision.Position.Y - (ColliderSize.Y / 2)
          
          local DistanceToFloatPoint = DistanceToSurface - FloatHeight

          if (DistanceToSurface >= FloatHeight - Epsilon) and (DistanceToSurface <= FloatHeight + Epsilon) then
               CharacterLanded(EntityID)
          end
          
          --Due to added length, the distance can be farther than the gravity magnitude
          if DistanceToFloatPoint >= Velocity.Magnitude then
               MovePlayer(PhysicsCollider, Velocity)
               return
          end

          local VectorToGoal = VelocityDirection * DistanceToFloatPoint
          MovePlayer(PhysicsCollider, VectorToGoal)
          
          -- Slope isn't as steep as we want it for it to slide
          if GetAngle(Collision.Normal) <= MaxSlopeAngle then return end

          local ProjectedVector = ProjectVelocity(
               Velocity - VectorToGoal, -- Remaining velocity from collision
               Collision.Normal
          )

          CollideAndSlide(EntityID, PhysicsCollider, ProjectedVector, HorizontalDirection, Depth + 1)
     else
          MovePlayer(PhysicsCollider, Velocity)
     end
end

--[[
local function ApplyGravity(DT : number, EntityID : number, PhysicsCollider : MeshPart, AbsoluteY : number, Gravity : number)
     local ColliderSize = PhysicsCollider.Size
     local ColliderPivot = PhysicsCollider:GetPivot()
     local ColliderPos = ColliderPivot.Position
     local ColliderRadius = (ColliderSize.X + ColliderSize.Z) / 4 -- Averages side lengths and divides by 2

     local RaycastPos = Vector3.new(ColliderPos.X, AbsoluteY, ColliderPos.Z)
     local GravityMagnitude = Gravity + ColliderSize.Y + FloatHeight
     local GroundNormal = Vector3.yAxis

     local Collision : RaycastResult? = workspace:Spherecast(
          RaycastPos,
          ColliderRadius,
          DownVector * GravityMagnitude,
          MakeParams(PhysicsCollider)
     )

     AbsoluteY = AbsoluteY or GetAbsoluteY(EntityID, AbsoluteY, ColliderPos, ColliderSize, ColliderRadius)
     
     if Collision then
          -- The distance from the bottom of the Collider to the collision point (Y axis)
          local DistanceToCollision = ColliderPosition.Y + (ColliderRadius * 0.125) - Collision.Position.Y
          Gravity = 0

          if DistanceToCollision ~= FloatHeight then
               Gravity = DistanceToCollision - FloatHeight
          else
               CharacterLanded(EntityID)
          end

          GroundNormal = Collision.Normal
     else
          CharacterFalling(EntityID)
     end

     AbsoluteY -= Gravity

     local AbsolutePosition = Vector3.new(ColliderPos.X, AbsoluteY, ColliderPos.Z)

     PhysicsCollider:PivotTo(CFrame.new(AbsolutePosition) * ColliderPivot.Rotation)

     Characters:set(EntityID, GroundNormalComponent, GroundNormal)
     Characters:set(EntityID, AbsoluteYComponent, AbsoluteY)
end
--]]

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID, PhysicsCollider, Gravity in GravityAppliedEntities do
          CollideAndSlide(EntityID, PhysicsCollider, DownVector * (Gravity * DT), Vector3.new(0,0,0), 1)
     end
end

return {
     name = "Gravity Application",
     system = UpdateEntities,
     runConditions = table.freeze({
          
     })
}