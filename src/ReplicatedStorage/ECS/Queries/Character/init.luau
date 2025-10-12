--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Jecs = require(ReplicatedStorage.Packages.Jecs)

--World
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Components
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local Components = CharacterComponents.List

local PhysicsCollider = Components.PhysicsCollider
local ForceVelocities = Components.ForceVelocities
local MoveVelocity = Components.MoveVelocity
local GroundNormal = Components.GroundNormal
local LookVector = Components.LookVector
local HeldKeys = Components.HeldKeys
local Gravity = Components.Gravity
local AirTime = Components.AirTime
local Player = Components.Player

--Types
local Component = CharacterComponents
type EntityID = number

return --[[Queries]] table.freeze {
     Entities = Characters:query(Player):cached() :: {(
          EntityID |
          Player
     )},

     PhysicsColliders = Characters:query(PhysicsCollider):cached() :: {(
          EntityID |
          Component.PhysicsCollider
     )},

     MovementRequests = Characters:query(HeldKeys, LookVector, GroundNormal):with(PhysicsCollider, MoveVelocity):cached() :: {(
          EntityID |
          Component.HeldKeys |
          Component.LookVector |
          Component.GroundNormal
     )},

     GravityUpdates = Characters:query(AirTime):with(PhysicsCollider, Gravity):cached() :: {(
          EntityID |
          Component.AirTime
     )},

     GravityAppliedEntities = Characters:query(PhysicsCollider, Gravity):cached() :: {(
          EntityID |
          Component.PhysicsCollider |
          Component.Gravity
     )},

     MovementAppliedEntities = Characters:query(MoveVelocity, PhysicsCollider):cached() :: {(
          EntityID |
          Component.MoveVelocity
     )},

     ForceAppliedEntities = Characters:query(ForceVelocities, PhysicsCollider):cached() :: {(
          EntityID |
          Component.ForceVelocities
     )},
}