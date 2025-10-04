--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Modules
local Replicator = require(PlayerScripts.ECS.Replicators.Characters)
local Collect = require(ReplicatedStorage.Utils.Collect)

--Events
local ReplecEvents = ReplicatedStorage.Events.REPLECS
local RequestUnreliable : RemoteEvent = ReplecEvents.RequestUnreliable
local RequestReliable : RemoteEvent = ReplecEvents.RequestReliable
local RecievedFull : BindableEvent = ReplecEvents.RecievedFull

--Data Collections
local Unreliables = Collect(RequestUnreliable.OnClientEvent)
local Reliables = Collect(RequestReliable.OnClientEvent)

local ClientReplicatorReady = false

RecievedFull.Event:Once(function()
     ClientReplicatorReady = true

     print("Client is updating data")
end)

local function UpdateClientData()
     for _, Buffer, Variants in Reliables do
          Replicator:apply_updates(Buffer, Variants)
     end
     for _, Buffer, Variants in Unreliables do
          Replicator:apply_unreliable(Buffer, Variants)
     end
end

local function ClientReplicatorIsReady()
     return ClientReplicatorReady == true
end

return {
     name = "Data Updates",
     system = UpdateClientData,
     runConditions = table.freeze({
          ClientReplicatorIsReady,
     })
}