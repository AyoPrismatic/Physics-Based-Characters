--!optimize 2
--!native

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

--Modules
local Collect = require(ReplicatedStorage.Utils.Collect)

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local LookVectorUpdate : UnreliableRemoteEvent = CharacterEvents.Input.LookVector

--ECS
local Components = require(ReplicatedStorage.ECS.Components.Character).List
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local LookComponent = Components.LookVector

--Variables
local Serialize = require(ReplicatedStorage.ECS.Components.Character.Serdes).Serialize
local GetEntityID = require(ServerStorage.Entities.Character.PlayerEntityIDs).GetID
local PlayerUpdates = Collect(LookVectorUpdate.OnServerEvent)

local function ProccessRequests() : nil
     for _, Player : Player, LookVector : Vector3? in PlayerUpdates do
          if typeof(LookVector) ~= "Vector3" then continue end

          Characters:set(
               GetEntityID(Player), LookComponent,
               Serialize(LookComponent, LookVector)
          )
     end
end

return {
     name = "LookVector Updates",
     system = ProccessRequests,
     runConditions = table.freeze({
          
     })
}