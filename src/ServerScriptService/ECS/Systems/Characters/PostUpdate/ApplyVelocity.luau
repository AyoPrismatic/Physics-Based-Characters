--!optimize 2
--!native

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local UVector3 = require(ReplicatedStorage.Utils.Vector)[3]

--ECS
local Global = require(ReplicatedStorage.ECS.Globals.Character)

local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local PlayerStateComponent = Components.PlayerState
local PositionComponent = Components.Position

--Types
type EntityID = number
type Velocity = Vector3
type PlayerVelocities = {[EntityID] : Velocity}

--Variables
local PlayerVelocities : {[EntityID] : {Velocity}} = {}

local MaxVelocityMagnitude = Global.ComponentLimits.VelocityMagnitude
local MaxSlopeAngle = math.rad(55) -- Vector3.Angle returns an angle in radians, so radians is used here
local Radius = Global.PlayerCharacterRadius
local AddedRayLength = 5
local SkinWidth = 0.25
local MaxDepth = 3

local Epsilon = 0.05

local CollisionParams = RaycastParams.new()
CollisionParams.FilterType = Enum.RaycastFilterType.Include
CollisionParams.FilterDescendantsInstances = {workspace}
CollisionParams.RespectCanCollide = true
CollisionParams.CollisionGroup = "Game"

local function ProjectVelocity(LeftoverVelocity : Vector3, SurfaceNormal : Vector3) : Vector3
     local ProjectedVector = UVector3.ProjectOnPlane(
          LeftoverVelocity,
          SurfaceNormal
     )

     return LeftoverVelocity.Magnitude * ProjectedVector.Unit
end

local function HorizontalDir(Velocity : Vector3) : Vector3
     if Velocity ~= Velocity or Velocity == Vector3.zero then return end -- Components are NaN / Zero
     if Velocity.X == 0 and Velocity.Z == 0 then return Vector3.zero end-- Can't normalize

     return Vector3.new(Velocity.X, 0, Velocity.Z).Unit * -1
end

--Returns the Vector travelledc
local function CollideAndSlide(DT : number, EntityID : number, Position : Vector3, Velocity : Vector3, Direction : Vector3, HorizontalDirection : Vector3, Recursions : number) : Vector3
     if Velocity ~= Velocity or Velocity == Vector3.zero then return Vector3.zero end -- Components are NaN
     if Recursions >= MaxDepth then return Vector3.zero end
     
     local RayVector = Direction * (Velocity.Magnitude + SkinWidth + AddedRayLength)
     
     local Collision : RaycastResult? = workspace:Spherecast(
          Position,
          Radius,
          RayVector,
          CollisionParams
     )
     
     if Collision then
          local DistanceToSurface = Collision.Distance
          local DistanceToGoal = DistanceToSurface - SkinWidth

          local VectorToGoal

          if DistanceToGoal >= Velocity.Magnitude then
               VectorToGoal = Velocity -- Distance is greater than the travelling velocity
          elseif (DistanceToGoal >= SkinWidth - Epsilon) and (DistanceToGoal <= SkinWidth + Epsilon) then
               VectorToGoal = Vector3.zero -- At the desired range
          else
               VectorToGoal = Direction * DistanceToGoal
          end

          local RemainingVelocity = Velocity - VectorToGoal
          local Angle = Vector3.yAxis:Angle(Collision.Normal)

          local ProjectedVector = ProjectVelocity(
               RemainingVelocity, -- Remaining velocity from collision
               Collision.Normal
          )
          
          if Angle >= MaxSlopeAngle then
               --Makes the player move slower the more perpendicular their move direction is
               local Normal = Vector3.new(Collision.Normal.X, 0, Collision.Normal.Z)
               local Scale = math.min(1, 1.2 - (Normal.Unit):Dot(HorizontalDirection))
               
               local PlayerState = Characters:get(EntityID, PlayerStateComponent)

               if PlayerState == Global.PlayerStates.Grounded then
                    ProjectedVector = ProjectVelocity(
                         Vector3.new(RemainingVelocity.X, 0, RemainingVelocity.Z), -- Remaining velocity from collision
                         Normal
                    )

                    ProjectedVector = ProjectedVector.Unit * ProjectedVector.Magnitude
               end

               ProjectedVector *= Scale
          end

          local NewPosition = Position + VectorToGoal
          
          return VectorToGoal + CollideAndSlide(DT, EntityID, NewPosition, ProjectedVector, ProjectedVector.Unit, HorizontalDirection, Recursions + 1)
     else
          return Velocity
     end
end

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID, Velocities in PlayerVelocities do
          local Position : Vector3Value = Characters:get(EntityID, PositionComponent)

          local TransformationVector = Vector3.zero

          for _, Velocity in Velocities do
               if Velocity == Vector3.zero then continue end

               local HorizontalDirection = HorizontalDir(Velocity)
               local RayPosition = Position.Value + TransformationVector
               
               TransformationVector += CollideAndSlide(DT, EntityID, RayPosition, Velocity, Velocity.Unit, HorizontalDirection, 1)
          end

          Position.Value += TransformationVector

          PlayerVelocities[EntityID] = nil
     end
end

return {
     UpdateVelocityData = function(EntityID : number, Velocity : Vector3)
          local VelocityData = PlayerVelocities[EntityID]

          if Velocity.Magnitude > MaxVelocityMagnitude then
               Velocity = Velocity.Unit * MaxVelocityMagnitude
          end

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