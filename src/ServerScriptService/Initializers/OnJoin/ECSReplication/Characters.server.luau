--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Replecs = require(ReplicatedStorage.Packages.Replecs)
local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Jabby = require(ReplicatedStorage.Packages.Jabby)

--Modules
local Replicator = require(ServerScriptService.ECS.Replicators.Characters)

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)
local Components = require(ReplicatedStorage.ECS.Components.Character)

--Events
local ReplecsEvents = ReplicatedStorage.Events.REPLECS
local RecieveFullRequest : RemoteFunction = ReplecsEvents.RecieveFull

RecieveFullRequest.OnServerInvoke = function(Player : Player)
     print(Player," recieved current game data")
     
     Replicator:mark_player_ready(Player)

     return Replicator:get_full(Player)
end