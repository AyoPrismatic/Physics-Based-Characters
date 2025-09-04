--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerGUI = Player.PlayerGui

--Folders
local EventsFolder = ReplicatedStorage.Events

--GUI
local GameGUI = PlayerGUI:WaitForChild('GameGUI')

--Events
