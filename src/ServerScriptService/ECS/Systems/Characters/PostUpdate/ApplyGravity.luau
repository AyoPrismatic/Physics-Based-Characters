--!optimize 2
--!native

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local UVector3 = require(ReplicatedStorage.Utils.Vector)[3]

--Packages
local Squash = require(ReplicatedStorage.Packages.Squash)

--ECS
local Global = require(ReplicatedStorage.ECS.Globals.Character)

local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local GravityAppliedEntities = CharacterQueries.GravityAppliedEntities

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local GroundNormalComponent = Components.GroundNormal
local PlayerStateComponent = Components.PlayerState
local GravityComponent = Components.Gravity
local AirTimeComponent = Components.AirTime

--Squash
local CursorFromBuffer = Squash.frombuffer
local Uint = Squash.uint

--Variables
local MaxSlopeAngle = math.rad(55) -- Vector3.Angle returns an angle in radians, so radians is used here
local Radius = Global.PlayerCharacterRadius
local AddedRayLength = 5
local FloatHeight = 1.35
local MaxBounces = 3

local Epsilon = 0.12

local CollisionParams = RaycastParams.new()
CollisionParams.FilterType = Enum.RaycastFilterType.Include
CollisionParams.FilterDescendantsInstances = {workspace}
CollisionParams.RespectCanCollide = true
CollisionParams.CollisionGroup = "Game"

local function ProjectVelocity(LeftoverVelocity : Vector3, SurfaceNormal : Vector3) : Vector3
     return LeftoverVelocity.Magnitude * UVector3.ProjectOnPlane(
          LeftoverVelocity,
          SurfaceNormal
     ).Unit
end

local function CollideAndSlide(DT : number, EntityID : number, Position : Vector3, Velocity : Vector3, Direction : Vector3, Recursions : number) : Vector3
     if Recursions >= MaxBounces then return Vector3.zero end

     local RayVector = Direction * (Velocity.Magnitude + AddedRayLength)
     
     local Collision : RaycastResult? = workspace:Spherecast(
          Position,
          Radius,
          RayVector,
          CollisionParams
     )
     
     if Collision then
          Characters:set(EntityID, GroundNormalComponent, Collision.Normal)
          
          --The distance from the bottom of the collider to the collision point (Y)
          local DistanceToSurface = Position.Y - Radius - Collision.Position.Y
          local DistanceToFloatPoint = DistanceToSurface - FloatHeight

          if (DistanceToSurface >= FloatHeight - Epsilon) and (DistanceToSurface <= FloatHeight + Epsilon) then
               --Character Landed
               Characters:set(EntityID, PlayerStateComponent, Global.PlayerStates.Grounded)
               Characters:set(EntityID, GravityComponent, 0)
               Characters:set(EntityID, AirTimeComponent, 0)
          end
          
          --Due to added length, the distance can be farther than the gravity magnitude
          if DistanceToFloatPoint >= Velocity.Magnitude then
               return Velocity
          end

          local VectorToGoal = Direction * DistanceToFloatPoint
          local Angle = Vector3.yAxis:Angle(Collision.Normal)
          
          -- Slope isn't as steep as we want it for it to slide
          if Angle <= MaxSlopeAngle then
               return VectorToGoal
          end
          
          local ProjectedVelocity = ProjectVelocity(
               Velocity - VectorToGoal, -- Remaining velocity from collision
               Collision.Normal
          )

          -- Makes slopes over the max angle make you move slower and slower the steeper it is
          DT += (Angle - MaxSlopeAngle) * (1 - (MaxSlopeAngle/Angle))

          ProjectedVelocity *= DT

          return VectorToGoal + CollideAndSlide(DT, EntityID, Position, ProjectedVelocity, ProjectedVelocity.Unit, Recursions + 1)
     else
          Characters:set(EntityID, GroundNormalComponent, Vector3.yAxis)
          return Velocity
     end
end

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID : number, Position : Vector3Value, Gravity : buffer in GravityAppliedEntities do
          if Characters:get(EntityID, PlayerStateComponent) ~= Global.PlayerStates.Falling then continue end

          Position.Value += CollideAndSlide(
               DT,
               EntityID,
               Position.Value,
               
               -- | Velocity/Gravity
               -- V
               -Vector3.yAxis * -- Gravity Buffer Contains the last 4 decimals of Gravity, so we divide by 10k
               (Uint(3).des(CursorFromBuffer(Gravity)) / 10000 * DT),

               -Vector3.yAxis,
               1 -- <- Recursions
          )
     end
end

return {
     name = "Gravity Application",
     system = UpdateEntities,
     runConditions = table.freeze({
          
     })
}
