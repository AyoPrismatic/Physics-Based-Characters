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
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local LookVectorComponent = require(ReplicatedStorage.ECS.Components.Character)
LookVectorComponent = LookVectorComponent.List.LookVector

--Variables
local GetEntityID = require(ServerStorage.Entities.Character.PlayerEntityIDs).GetID
local PlayerUpdates = Collect(LookVectorUpdate.OnServerEvent)

local function HandleRequest(Player : Player, CompressedLookVector : Vector3int16?) : nil
     if typeof(CompressedLookVector) == "Vector3int16" then
          Characters:set(GetEntityID(Player), LookVectorComponent,
               CompressedLookVector
          )
     end
end

local function ProccessRequests() : nil
     for _, Player, LookVector in PlayerUpdates do
          HandleRequest(Player, LookVector)
     end
end

return {
     name = "LookVector Updates",
     system = ProccessRequests,
     runConditions = table.freeze({
          
     })
}