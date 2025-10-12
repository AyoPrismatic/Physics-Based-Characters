--!optimize 2
--!native

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

--Modules
local PlayerEntityIDs = require(ServerStorage.Entities.Character.PlayerEntityIDs)
local Collect = require(ReplicatedStorage.Utils.Collect)

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local LookVectorUpdate : UnreliableRemoteEvent = CharacterEvents.Input.LookVector

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local LookVectorComponent = CharacterComponents.List.LookVector

--Types
type HeldKeys = {[Enum.KeyCode] : boolean}

--Variables
local PlayerUpdates = Collect(LookVectorUpdate.OnServerEvent)

local function HandleRequest(Player : Player, CompressedLookVector : Vector3int16?) : nil
     if typeof(CompressedLookVector) ~= "Vector3int16" then return end

     local CharacterEntityID = PlayerEntityIDs.GetID(Player)

     Characters:set(CharacterEntityID, LookVectorComponent,
          Vector3.new(
               CompressedLookVector.X / 10000,
               CompressedLookVector.Y / 10000,
               CompressedLookVector.Z / 10000
          )
     )
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