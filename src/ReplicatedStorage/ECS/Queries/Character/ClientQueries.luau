--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
if RunService:IsServer() then return end

--Packages
local Jecs = require(ReplicatedStorage.Packages.Jecs)

--World
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Components
local ClientCharacterComponents = require(ReplicatedStorage.ECS.Components.Character.ClientSetup)
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)

local ClientComponent = ClientCharacterComponents.List
local SpringResponsiveness = ClientComponent.SpringResponsiveness
local SpringFrequency = ClientComponent.SpringFrequency
local SpringVelocity = ClientComponent.SpringVelocity
local SpringDamping = ClientComponent.SpringDamping
local RootPart = ClientComponent.RootPart

local Component = CharacterComponents.List
local TravelledVelocity = Component.TravelledVelocity
local PhysicsCollider = Component.PhysicsCollider

--Types
type EntityID = number

return --[[Queries]] table.freeze({
     SpringSystem = Characters:query(RootPart, PhysicsCollider, SpringVelocity, TravelledVelocity, SpringFrequency, SpringDamping, SpringResponsiveness):cached() :: {{
          EntityID |
          ClientComponent.RootPart |
          Component.PhysicsCollider |
          ClientComponent.SpringVelocity |
          Component.TravelledVelocity |
          ClientComponent.SpringFrequency |
          ClientComponent.SpringDamping |
          ClientComponent.SpringResponsiveness
     }},
})