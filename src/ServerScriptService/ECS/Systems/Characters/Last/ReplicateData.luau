--!optimize 2
--!native
--!strict

--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Modules
local Replicator = require(ServerScriptService.ECS.Replicators.Characters)
local Interval = require(ReplicatedStorage.Utils.Interval)

--Events
local ReplecEvents = ReplicatedStorage.Events.REPLECS
local RequestUnreliable : UnreliableRemoteEvent = ReplecEvents.RequestUnreliable
local RequestReliable : RemoteEvent = ReplecEvents.RequestReliable

--Variables
local UnreliablesReady = Interval(70) -- fires every 70 seconds
local ReliablesReady = Interval(25)

local function UpdateClientData()
     if ReliablesReady() then
          for Player, Buffer, Variants in Replicator:collect_updates() do
               RequestReliable:FireClient(Player, Buffer, Variants)
          end
     end
     if UnreliablesReady() then
          for Player, Buffer, Variants in Replicator:collect_unreliable() do
               RequestUnreliable:FireClient(Player, Buffer, Variants)
          end
     end
end

local function GameHasPlayers()
     return #Players:GetPlayers() >= 1
end

return {
     name = "Data Replication",
     system = UpdateClientData,
     runConditions = table.freeze({
          GameHasPlayers,
     })
}