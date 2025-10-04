--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local Interpolator = require(ReplicatedStorage.Utils.Interpolator)

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)

local GravityAppliedEntities = CharacterQueries.GravityAppliedEntities

local SpringVelocityComponent = CharacterComponents.List.GravitySpringVelocity
local PlayerStateComponent = CharacterComponents.List.PlayerState
local AbsoluteYComponent = CharacterComponents.List.AbsoluteY
local GravityComponent = CharacterComponents.List.Gravity

--Variables
local CharacterStates = require(ReplicatedStorage.ECS.EntityData.PlayerCharacter.PlayerStates)

local DownVector = Vector3.new(0, -1, 0)

local Frequency, Damping, Responsiveness = Interpolator.GenerateParameters(1.5, 0.8, 1.75)
local FloatHeight = 1
local AddedLength = 1 -- extra move length to prevent glitches

local Epsilon = 1e-3

local function CharacterLandedUpdate(EntityID : Instance)
     Characters:set(EntityID, PlayerStateComponent,
          CharacterStates.Grounded
     )

     Characters:set(EntityID, GravityComponent,
          0
     )
end

local function MakeParams(Collider : Instance) : RaycastParams
     local Params = RaycastParams.new()

     Params.FilterType = Enum.RaycastFilterType.Exclude
     Params.FilterDescendantsInstances = {Collider}
     Params.RespectCanCollide = true
     Params.CollisionGroup = "Game"

     return Params
end

local function ApplyGravity(DT : number, EntityID : number, PhysicsCollider : MeshPart, AbsoluteY : number, SpringVelocity : Vector3, Gravity : number)
     local ColliderSize = PhysicsCollider.Size
     local ColliderPivot = PhysicsCollider:GetPivot()
     local ColliderPos = ColliderPivot.Position
     local ColliderRadius = (ColliderSize.X + ColliderSize.Z) / 4 -- Averages side lengths and divides by 2

     if not AbsoluteY then
          -- Creates a vector for the top side of the Capsule Collider
          AbsoluteY = ColliderPos.Y + (ColliderSize.Y / 2) + (ColliderRadius * 0.125)
          Characters:set(EntityID, AbsoluteYComponent, AbsoluteY)
     end

     local RaycastPos = Vector3.new(ColliderPos.X, AbsoluteY, ColliderPos.Z)
     local GravityMagnitude = Gravity + AddedLength + FloatHeight

     local Collision : RaycastResult? = workspace:Spherecast(
          RaycastPos,
          ColliderRadius,
          DownVector * GravityMagnitude,
          MakeParams(PhysicsCollider)
     )

     if Collision then
          -- The Y of the bottom side of the Capsule collider, Without considering the cosmetic spring physics
          local ColliderBottomY = AbsoluteY - (ColliderSize.Y / 2)

          local DistanceToCollision = ColliderBottomY - Collision.Position.Y

          if (DistanceToCollision > FloatHeight + Epsilon) or (DistanceToCollision < FloatHeight - Epsilon) then
               Gravity = (DistanceToCollision - FloatHeight)
          else
               CharacterLandedUpdate(EntityID)
               Gravity = 0
          end
     end

     AbsoluteY -= Gravity

     local AbsolutePosition = Vector3.new(ColliderPos.X, AbsoluteY, ColliderPos.Z)

     local NewPosition, NewVelocity = Interpolator.UpdateSystem(DT,
          AbsolutePosition, ColliderPos, -- Goal Position & Position
          DownVector * Gravity, SpringVelocity, -- Goal Velocity & Velocity
          Frequency, Damping, Responsiveness
     )

     PhysicsCollider:PivotTo(CFrame.new(NewPosition) * ColliderPivot.Rotation)

     Characters:set(EntityID, SpringVelocityComponent, NewVelocity)
     Characters:set(EntityID, AbsoluteYComponent, AbsoluteY)
end

local function UpdateEntities()
     local DT = Scheduler:getDeltaTime()

     for EntityID, PhysicsCollider, Gravity, AbsoluteY, GravitySpringVelocity in GravityAppliedEntities do
          ApplyGravity(DT, EntityID, PhysicsCollider, AbsoluteY, GravitySpringVelocity, Gravity * DT)
     end
end

return {
     name = "Gravity Application",
     system = UpdateEntities,
     runConditions = table.freeze({
          
     })
}