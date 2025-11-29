--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Modules
local Replicator = require(PlayerScripts.ECS.Replicators.Characters)

--Components
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character) -- Inits Components and serdes to ensure client is up to date with server
local Serdes = require(ReplicatedStorage.ECS.Components.Character.Serdes)

--Events
local ReplecsEvents = ReplicatedStorage.Events.REPLECS
local RecieveFullRequest : RemoteFunction = ReplecsEvents.RecieveFull
local RecievedFullEvent : BindableEvent = ReplecsEvents.RecievedFull

--Updates client data to the current game data on join
local Buffer, Variants = RecieveFullRequest:InvokeServer()
Replicator:apply_full(Buffer, Variants)

RecievedFullEvent:Fire() -- Lets other scripts know the Replicator is ready