--[[
--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Modules
local Replicator = require(PlayerScripts.ECS.Replicators.Characters)

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)

local _ = Replicator:added(function(EntityID)
     Replicator:after_replication(function()

     end)
end)
--]]