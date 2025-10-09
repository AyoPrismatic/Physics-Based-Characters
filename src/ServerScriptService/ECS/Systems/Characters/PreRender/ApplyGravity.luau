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

local DownVector = Vector3.new(0, -1, 0)
local MaxSlopeAngle = math.rad(55) -- Vector3.Angle returns an angle in radians, so radians is used here
local AddedLength = 5 -- Prevents wonky clipping
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

local function CollideAndSlide(DT : number, EntityID : number, PhysicsCollider : MeshPart, Velocity : Vector3, HorizontalDirection : Vector3, Depth : number) -- Depth == Recursions
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
          Characters:set(EntityID, GroundNormalComponent, Collision.Normal)
          
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
          local Angle = Vector3.yAxis:Angle(Collision.Normal)
          
          -- Slope isn't as steep as we want it for it to slide
          if Angle <= MaxSlopeAngle then
               MovePlayer(PhysicsCollider, VectorToGoal)
               return
          end
          
          local ProjectedVector = ProjectVelocity(
               Velocity - VectorToGoal, -- Remaining velocity from collision
               Collision.Normal
          )

          DT += (Angle - MaxSlopeAngle) * (1 - (MaxSlopeAngle/Angle))

          CollideAndSlide(DT, EntityID, PhysicsCollider, ProjectedVector * DT, HorizontalDirection, Depth + 1)
     else
          MovePlayer(PhysicsCollider, Velocity)
          Characters:set(EntityID, GroundNormalComponent, Vector3.yAxis)
     end
end

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID, PhysicsCollider, Gravity in GravityAppliedEntities do
          CollideAndSlide(DT, EntityID, PhysicsCollider, DownVector * (Gravity * DT), Vector3.new(0,0,0), 1)
     end
end

return {
     name = "Gravity Application",
     system = UpdateEntities,
     runConditions = table.freeze({
          
     })
}
