--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Jecs = require(ReplicatedStorage.Packages.Jecs)

--World
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Components
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local Components = CharacterComponents.List

local PhysicsColliderRadius = Components.PhysicsColliderRadius
local ForceVelocities = Components.ForceVelocities
local MoveVelocity = Components.MoveVelocity
local GroundNormal = Components.GroundNormal
local LookVector = Components.LookVector
local Position = Components.Position
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

     PositionUpdates = Characters:query(Position, PhysicsColliderRadius):cached() :: {(
          EntityID |
          Component.Position |
          Component.PhysicsColliderRadius
     )},

     MovementRequests = Characters:query(HeldKeys, LookVector, GroundNormal):with(Position, MoveVelocity):cached() :: {(
          EntityID |
          Component.HeldKeys |
          Component.LookVector |
          Component.GroundNormal
     )},

     GravityUpdates = Characters:query(AirTime):with(Position, Gravity):cached() :: {(
          EntityID |
          Component.AirTime
     )},

     GravityAppliedEntities = Characters:query(Position, PhysicsColliderRadius, Gravity):cached() :: {(
          EntityID |
          Component.Position |
          Component.PhysicsColliderRadius |
          Component.Gravity
     )},

     MovementAppliedEntities = Characters:query(MoveVelocity):with(Position):cached() :: {(
          EntityID |
          Component.MoveVelocity
     )},

     ForceAppliedEntities = Characters:query(ForceVelocities):with(Position):cached() :: {(
          EntityID |
          Component.ForceVelocities
     )},
}