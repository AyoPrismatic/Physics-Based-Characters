--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Jecs = require(ReplicatedStorage.Packages.Jecs)

--World
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Components
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local Components = CharacterComponents.List

local GravitySpringVelocity = Components.GravitySpringVelocity
local PhysicsCollider = Components.PhysicsCollider
local ForceVelocity = Components.ForceVelocity
local MoveVelocity = Components.MoveVelocity
local AbsoluteY = Components.AbsoluteY
local Position = Components.Position
local Gravity = Components.Gravity
local AirTime = Components.AirTime

--Types
local Component = CharacterComponents
type EntityID = number

return --[[Queries]] table.freeze({
     GravityUpdates = Characters:query(AirTime):with(Position, Gravity):cached() :: {{
          EntityID |
          Component.AirTime
     }},

     GravityAppliedEntities = Characters:query(PhysicsCollider, Gravity, AbsoluteY, GravitySpringVelocity):with(Position):cached() :: {{
          EntityID |
          Component.PhysicsCollider |
          Component.Gravity |
          Component.AbsoluteY |
          Component.GravitySpringVelocity
     }},

     MovementAppliedEntities = Characters:query(MoveVelocity):with(PhysicsCollider, Position):cached() :: {{
          EntityID |
          Component.MoveVelocity
     }},

     ForceAppliedEntities = Characters:query(ForceVelocity):with(PhysicsCollider, Position):cached() :: {{
          EntityID |
          Component.ForceVelocity
     }},
})