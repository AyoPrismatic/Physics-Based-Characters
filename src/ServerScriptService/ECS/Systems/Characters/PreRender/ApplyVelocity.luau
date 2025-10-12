--!optimize 2
--!native

--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Vector3U = require(ReplicatedStorage.Utils.Vector)[3]

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)

local PhysicsColliderComponent = CharacterComponents.List.PhysicsCollider
local PlayerStateComponent = CharacterComponents.List.PlayerState

--Systems
local UpdateTravelledVelocitySystem = require(ServerScriptService.ECS.Systems.Characters.Update.UpdateTravelledVelocity)

--Types
type EntityID = number
type Velocity = Vector3
type PlayerVelocities = {[EntityID] : Velocity}

--Variables
local PlayerStates = require(ReplicatedStorage.ECS.EntityData.PlayerCharacter.PlayerStates)
local PlayerVelocities : {[EntityID] : {Velocity}} = {}

local MaxSlopeAngle = math.rad(55) -- Vector3.Angle returns an angle in radians, so radians is used here
local AddedRayLength = 1
local SkinWidth = 0.02
local MaxBounces = 3

local CollisionParams = RaycastParams.new()
CollisionParams.FilterType = Enum.RaycastFilterType.Include
CollisionParams.FilterDescendantsInstances = {workspace}
CollisionParams.RespectCanCollide = true
CollisionParams.CollisionGroup = "Game"

local function GetCollider(EntityID : number) : MeshPart
     return Characters:get(EntityID, PhysicsColliderComponent)
end

local function MovePlayer(EntityID : number, PhysicsCollider : MeshPart, MoveVector : Vector3)
     local CurrentCFrame : CFrame = PhysicsCollider:GetPivot()
     local NewCFrame = CurrentCFrame + MoveVector

     UpdateTravelledVelocitySystem.UpdateVelocityData(EntityID, MoveVector)
     
     PhysicsCollider:PivotTo(NewCFrame)
end

local function ProjectVelocity(LeftoverVelocity : Vector3, SurfaceNormal : Vector3) : Vector3
     local LeftOverVector : Vector3 = Vector3U.ProjectOnPlane(LeftoverVelocity, SurfaceNormal).Unit

     return LeftOverVector * LeftoverVelocity.Magnitude
end

local function CollideAndSlide(EntityID : number, PhysicsCollider : MeshPart, Velocity : Vector3, HorizontalDirection : Vector3, Depth : number) -- Depth == Recursions
     if Depth >= MaxBounces then return end

     local VelocityDirection = Velocity.Unit
     local RayVector = VelocityDirection * (Velocity.Magnitude + SkinWidth + AddedRayLength)

     local Collision : RaycastResult? = workspace:Shapecast(
          PhysicsCollider,
          RayVector,
          CollisionParams
     )
     
     if Collision then
          local DistanceToSurface = Collision.Distance - AddedRayLength + SkinWidth
          local CollisionNormal = Collision.Normal
          local VectorToSurface = Vector3.zero

          if DistanceToSurface > AddedRayLength then
               VectorToSurface = VelocityDirection * DistanceToSurface
          end

          local RemainingVelocity = Velocity - VectorToSurface
          local Angle = Vector3.yAxis:Angle(CollisionNormal)

          local ProjectedVector = ProjectVelocity(
               RemainingVelocity, -- Remaining velocity from collision
               CollisionNormal
          )
          
          if Angle >= MaxSlopeAngle then
               --Makes the player move slower the more perpendicular their move direction is
               local Normal = Vector3.new(Collision.Normal.X, 0, Collision.Normal.Z)
               local Scale = math.min(1, 1.2 - (Normal.Unit):Dot(HorizontalDirection))
               
               local PlayerState = Characters:get(EntityID, PlayerStateComponent)

               if PlayerState == PlayerStates.Grounded then
                    ProjectedVector = ProjectVelocity(
                         Vector3.new(RemainingVelocity.X, 0, RemainingVelocity.Z), -- Remaining velocity from collision
                         Normal
                    )

                    ProjectedVector = ProjectedVector.Unit * ProjectedVector.Magnitude
               end

               ProjectedVector *= Scale
          end

          MovePlayer(EntityID, PhysicsCollider, VectorToSurface)
          CollideAndSlide(EntityID, PhysicsCollider, ProjectedVector, HorizontalDirection, Depth + 1)
     else
          MovePlayer(EntityID, PhysicsCollider, Velocity)
     end
end

local function UpdateEntities()
     for EntityID, Velocities in PlayerVelocities do
          for _, Velocity in Velocities do
               if Velocity == Vector3.zero then continue end

               local HorizontalDirection = Vector3.new(Velocity.X, 0, Velocity.Z).Unit * -1
               
               CollideAndSlide(EntityID, GetCollider(EntityID), Velocity, HorizontalDirection, 1)
          end

          PlayerVelocities[EntityID] = nil
     end
end

return {
     UpdateVelocityData = function(EntityID, Velocity)
          local VelocityData = PlayerVelocities[EntityID]

          if not VelocityData then
               PlayerVelocities[EntityID] = {Velocity}
               return
          end
          
          table.insert(VelocityData, Velocity)
     end,

     SystemData = {
          name = "Velocity Application",
          system = UpdateEntities,
          runConditions = table.freeze({
               
          })
     }
}