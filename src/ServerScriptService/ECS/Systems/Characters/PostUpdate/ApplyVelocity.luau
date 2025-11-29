--!optimize 2
--!native

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local UVector3 = require(ReplicatedStorage.Utils.Vector)[3]

--ECS
local GetDeserialized = require(ReplicatedStorage.ECS.Components.Character.Serdes).GetDeserialized
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterGlobals = require(ReplicatedStorage.ECS.Globals.Character)
local ComponentLimits = CharacterGlobals.ComponentLimits
local Properties = CharacterGlobals.CharacterProperties
local PlayerStates = CharacterGlobals.PlayerStates

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local PlayerStateComponent = Components.PlayerState
local PositionComponent = Components.Position

--Types
type EntityID = number
type Velocity = Vector3

--Variables
local PlayerVelocities : {[EntityID] : {Velocity}} = {}
local UpAxis = Vector3.yAxis

local SkinWidth = 0.25
local MaxDepth = 3

--Properties
local MaxVelocityMagnitude = ComponentLimits.VelocityMagnitude

local CollisionParams = Properties.CollisionParams
local MaxSlopeAngle = Properties.MaxSlopeAngle

local CharacterRadius = Properties.CharacterRadius

local function ProjectVelocity(Velocity : Vector3, PlaneNormal : Vector3) : Vector3
     return Velocity.Magnitude * UVector3.ProjectOnPlane(Velocity, PlaneNormal).Unit
end

local function HorizontalDir(Velocity : Vector3) : Vector3?
     if Velocity ~= Velocity --[[<- Velocity is NaN]] or Velocity == Vector3.zero then return Vector3.zero end
     if Velocity.X == 0 and Velocity.Z == 0 then return Vector3.zero end -- Can't normalize

     return Vector3.new(Velocity.X, 0, Velocity.Z).Unit * -1
end

--Returns the Vector travelled
local function CollideAndSlide(DT : number, EntityID : number, Position : Vector3, Velocity : Vector3, Direction : Vector3, HorizontalDirection : Vector3, Recursions : number) : Vector3
     if Velocity ~= Velocity --[[<- Velocity is NaN]] or Velocity == Vector3.zero then return Vector3.zero end
     if Recursions >= MaxDepth then return Vector3.zero end
     
     local Collision = workspace:Spherecast(Position, CharacterRadius,
          Direction * math.min(MaxVelocityMagnitude, (Velocity.Magnitude + SkinWidth)),
          CollisionParams
     )

     if Collision then
          local VectorToGoal = Direction * (Collision.Distance - SkinWidth)

          local RemainingVelocity = Velocity - VectorToGoal
          local ProjectedVector = ProjectVelocity(
               RemainingVelocity, -- Remaining velocity from collision
               Collision.Normal
          )
          
          if UpAxis:Angle(Collision.Normal) >= MaxSlopeAngle then
               --Makes the player move slower the more perpendicular their move direction is
               local Normal = Vector3.new(Collision.Normal.X, 0, Collision.Normal.Z)
               local Scale = math.min(1, 1.2 - (Normal.Unit):Dot(HorizontalDirection))
               
               ProjectedVector = ProjectVelocity(
                    Vector3.new(RemainingVelocity.X, 0, RemainingVelocity.Z), -- Remaining velocity from collision
                    Normal
               )

               ProjectedVector = ProjectedVector.Unit * ProjectedVector.Magnitude * Scale
          end

          local NewPosition = Position + VectorToGoal
          
          return CollideAndSlide(DT, EntityID, NewPosition, ProjectedVector, ProjectedVector.Unit, HorizontalDirection, Recursions + 1)
     else
          return Velocity
     end
end

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID, Velocities in PlayerVelocities do
          local Position : Vector3Value = Characters:get(EntityID, PositionComponent)
          local PositionTransformation = Vector3.zero

          for _, Velocity in Velocities do
               PositionTransformation += CollideAndSlide(DT, EntityID,
                    Position.Value + PositionTransformation, -- Current Raycast post
                    Velocity,
                    Velocity.Unit, -- Direction
                    HorizontalDir(Velocity),
               1) -- Recursions
          end

          Position.Value += PositionTransformation
          PlayerVelocities[EntityID] = nil
     end
end

return {
     UpdateVelocityData = function(EntityID : number, Velocity : Vector3)
          Velocity = UVector3.SafeNormalize(Velocity) * math.min(MaxVelocityMagnitude, Velocity.Magnitude)
          if PlayerVelocities[EntityID] then
               table.insert(PlayerVelocities[EntityID], Velocity)
          else
               PlayerVelocities[EntityID] = {Velocity}
          end
     end,

     SystemData = {
          name = "Velocity Application",
          system = UpdateEntities,
          runConditions = table.freeze({
               
          })
     }
}