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
local RootPart = ClientComponent.RootPart

local Component = CharacterComponents.List
local Position = Component.Position

--Types
type EntityID = number

return --[[Queries]] table.freeze({
     CharacterPositionUpdates = Characters:query(RootPart, Position):cached() :: {(
          EntityID |
          ClientComponent.RootPart |
          Component.Position
     )},
})