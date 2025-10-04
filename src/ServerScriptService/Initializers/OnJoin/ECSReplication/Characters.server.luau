--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Replicator = require(ServerScriptService.ECS.Replicators.Characters)

--Events
local ReplecsEvents = ReplicatedStorage.Events.REPLECS
local RecieveFullRequest : RemoteFunction = ReplecsEvents.RecieveFull

RecieveFullRequest.OnServerInvoke = function(Player : Player)
     print(`{Player} recieved current game data`)
     
     Replicator:mark_player_ready(Player)

     return Replicator:get_full(Player)
end