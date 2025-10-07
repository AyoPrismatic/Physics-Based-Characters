--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

--Modules
local PlayerEntityIDs = require(ServerStorage.Entities.Character.PlayerEntityIDs)
local Collect = require(ReplicatedStorage.Utils.Collect)

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local WASD_InputEvent : RemoteEvent = CharacterEvents.Input.WASDMovement

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local HeldKeysComponent = CharacterComponents.List.HeldKeys

--Types
type HeldKeys = {[Enum.KeyCode] : boolean}

--Variables
local PlayerRequests = Collect(WASD_InputEvent.OnServerEvent)

local IsHeld = table.freeze({[0] = false, [1] = true})
local Keys = table.freeze({
     Enum.KeyCode.W,
     Enum.KeyCode.A,
     Enum.KeyCode.S,
     Enum.KeyCode.D
})

local function HandleRequest(Player : Player, WASDRequest : buffer?) : nil
     if typeof(WASDRequest) ~= "buffer" then return end
     if buffer.len(WASDRequest) > 1 then return end

     local CharacterEntityID = PlayerEntityIDs.GetID(Player)
     local HeldKeys = Characters:get(CharacterEntityID, HeldKeysComponent) :: HeldKeys

     for i : number, Key : Enum.KeyCode in Keys do
          HeldKeys[Key] = IsHeld[buffer.readbits(WASDRequest, i - 1, 1)]
     end

     Characters:set(CharacterEntityID, HeldKeysComponent,
          HeldKeys
     )
end

local function ProccessRequests() : nil
     for _, Player, WASDRequest in PlayerRequests do
          HandleRequest(Player, WASDRequest)
     end
end

return {
     name = "Movement Request Processing",
     system = ProccessRequests,
     runConditions = table.freeze({
          
     })
}