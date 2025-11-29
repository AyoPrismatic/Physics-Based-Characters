--!optimize 2
--!native
--!strict

--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Packages
local Replecs = require(ReplicatedStorage.Packages.Replecs)

--Modules
local Replicator = require(ServerScriptService.ECS.Replicators.Characters)
local Interval = require(ReplicatedStorage.Utils.Interval)

--ECS
local Components = require(ReplicatedStorage.ECS.Components.Character)

--Events
local ReplecEvents = ReplicatedStorage.Events.REPLECS
local RequestUnreliable : UnreliableRemoteEvent = ReplecEvents.RequestUnreliable
local RequestReliable : RemoteEvent = ReplecEvents.RequestReliable

--Variables
local UnreliablesReady = Interval(70) -- fires 70 times a second
local ReliablesReady = Interval(25)

local UpdateUnreliables = false
local UpdateReliables = false

--Constants
local RELIABLE, UNRELIABLE = Replecs.Reliable, Replecs.Unreliable

--Types
type ComponentIndex = number

local function UpdateClientData() : nil?
     if UpdateUnreliables and UnreliablesReady() then
          for Player, Buffer, Variants in Replicator:collect_unreliable() do
               RequestUnreliable:FireClient(Player, Buffer, Variants)
          end
     end
     if UpdateReliables and ReliablesReady() then
          for Player, Buffer, Variants in Replicator:collect_updates() do
               RequestReliable:FireClient(Player, Buffer, Variants)
          end
     end
end

local function GameHasPlayers() : boolean
     return #Players:GetPlayers() >= 1
end

return {
     ReplicateUpdate = function(ComponentID : ComponentIndex) : nil?
          local ReplicationType = Components.SharedComponents[ComponentID]
          if ReplicationType == UNRELIABLE then
               UpdateUnreliables = true
          elseif ReplicationType == RELIABLE then
               UpdateReliables = true
          end
     end,

     SystemData = {
          name = "Data Replication",
          system = UpdateClientData,
          runConditions = table.freeze({
               GameHasPlayers,
          })
     }
}