--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Modules
local Raycaster = require(script.Parent.Raycaster)

--Events

--[[
Raycaster.Start()
Raycaster.Stop()
--]]