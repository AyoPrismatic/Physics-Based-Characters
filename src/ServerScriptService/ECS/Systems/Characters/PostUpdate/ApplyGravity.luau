--!optimize 2
--!native

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local UVector3 = require(ReplicatedStorage.Utils.Vector)[3]

--ECS
local Serdes = require(ReplicatedStorage.ECS.Components.Character.Serdes)
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local GravityAppliedEntities = require(ReplicatedStorage.ECS.Queries.Character).GravityAppliedEntities

local CharacterGlobals = require(ReplicatedStorage.ECS.Globals.Character)
local Properties = CharacterGlobals.CharacterProperties
local PlayerStates = CharacterGlobals.PlayerStates

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local GroundNormalComponent = Components.GroundNormal
local PlayerStateComponent = Components.PlayerState
local GravityComponent = Components.Gravity
local AirTimeComponent = Components.AirTime

--Variables
local DownVector = -Vector3.yAxis
local UpAxis = Vector3.yAxis
local MaxBounces = 3

--Properties
local CollisionEpsilon = Properties.CollisionEpsilon
local CollisionParams = Properties.CollisionParams
local MaxSlopeAngle = Properties.MaxSlopeAngle

local CharacterRadius = Properties.CharacterRadius
local FloatHeight = Properties.FloatHeight

local function ProjectVelocity(LeftoverVelocity : Vector3, SurfaceNormal : Vector3) : Vector3
     return LeftoverVelocity.Magnitude * UVector3.ProjectOnPlane(
          LeftoverVelocity,
          SurfaceNormal
     ).Unit
end

local function CollideAndSlide(DT : number, EntityID : number, Position : Vector3, Velocity : Vector3, Direction : Vector3, Recursions : number) : Vector3
     if Recursions >= MaxBounces then return Vector3.zero end

     local Collision = workspace:Spherecast(
          Position,
          CharacterRadius,
          Direction * (Velocity.Magnitude + FloatHeight),
          CollisionParams
     )
     
     if Collision then
          Serdes.SerializeAndSet(EntityID, GroundNormalComponent, Collision.Normal)
          
          --The distance from the bottom of the collider to the collision point (Y)
          local DistanceToSurface = Position.Y - CharacterRadius - Collision.Position.Y
          local DistanceToFloatPoint = DistanceToSurface - FloatHeight

          if (DistanceToSurface >= FloatHeight - CollisionEpsilon) and (DistanceToSurface <= FloatHeight + CollisionEpsilon) then -- Character Landed
               Serdes.SerializeAndSet(EntityID, PlayerStateComponent, PlayerStates.Grounded)
               Serdes.SerializeAndSet(EntityID, GravityComponent, 0)
               Serdes.SerializeAndSet(EntityID, AirTimeComponent, 0)
          end
          
          --Due to added length, the distance can be farther than the gravity magnitude
          if DistanceToFloatPoint >= Velocity.Magnitude then
               return Velocity
          end

          local VectorToGoal = Direction * DistanceToFloatPoint
          local Angle = UpAxis:Angle(Collision.Normal)
          
          -- Slope isn't as steep as we want it for it to slide
          if Angle <= MaxSlopeAngle then
               return VectorToGoal
          end
          
          local ProjectedVelocity = ProjectVelocity(
               Velocity - VectorToGoal, -- Remaining velocity from collision
               Collision.Normal
          )

          -- Makes slopes over the max angle make you move Faster and Faster the steeper it is
          ProjectedVelocity *= (DT + ((Angle - MaxSlopeAngle) * -(1 - (Angle/MaxSlopeAngle))))

          return CollideAndSlide(DT, EntityID, Position + VectorToGoal, ProjectedVelocity, ProjectedVelocity.Unit, Recursions + 1)
     else
          Serdes.SerializeAndSet(EntityID, GroundNormalComponent, UpAxis)
          return Velocity
     end
end

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID : number, Position : Vector3Value, Gravity : buffer in GravityAppliedEntities do
          if Serdes.GetDeserialized(EntityID, PlayerStateComponent) == PlayerStates.Falling then
               Position.Value += CollideAndSlide(DT, EntityID, Position.Value,
                    DownVector * Serdes.Deserialize(GravityComponent, Gravity) * DT, -- Velocity
                    DownVector, -- Direction
               1) -- Recursions
          end
     end
end

return {
     name = "Gravity Application",
     system = UpdateEntities,
     runConditions = table.freeze({
          
     })
}
