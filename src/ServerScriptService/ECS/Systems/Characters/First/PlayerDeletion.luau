--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')
local Players = game:GetService('Players')

--Packages
local Planck = require(ReplicatedStorage.Packages.Planck)

--Modules
local Collect = require(ReplicatedStorage.Utils.Collect)

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local PositionComponent = Components.Position

--Variables
local GetID = require(ServerStorage.Entities.Character.PlayerEntityIDs).GetID
local RemovedPlayers = Collect(Players.PlayerRemoving)

local function ClearEntity(EntityID : number, Player : Player)
     local PositionValueObject : Vector3Value = Characters:get(EntityID, PositionComponent)

     PositionValueObject:Destroy()

     Characters:delete(EntityID)
end

local function ClearRemovedPlayers()
     for _, Player : Player in RemovedPlayers do
          ClearEntity(GetID(Player), Player)
     end
end

return {
     name = "Character Deletion",
     system = ClearRemovedPlayers,
     runConditions = table.freeze({
          Planck.onEvent(Players.PlayerAdded),
     })
}