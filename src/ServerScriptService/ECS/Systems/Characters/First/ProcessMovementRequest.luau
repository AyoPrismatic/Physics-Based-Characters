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
local WASD_InputEvent : UnreliableRemoteEvent = CharacterEvents.Input.WASDMovement

--ECS
local Serdes = require(ReplicatedStorage.ECS.Components.Character.Serdes)
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local HeldComponent = CharacterComponents.List.HeldKeys

--Types
type HeldKeys = {[Enum.KeyCode] : boolean}
local KeyCode = Enum.KeyCode

--Variables
local PlayerRequests = Collect(WASD_InputEvent.OnServerEvent)

local Keys : {Enum.KeyCode} = table.freeze{KeyCode.W, KeyCode.A, KeyCode.S, KeyCode.D}
local IsHeld = table.freeze({[0] = false, [1] = true})

local function HandleRequest(Player : Player, WASDRequest : buffer?) : nil
     if typeof(WASDRequest) == "buffer" then
          local CharacterEntityID = PlayerEntityIDs.GetID(Player)

          local HeldKeys : HeldKeys = Serdes.Deserialize(HeldComponent,
               Characters:get(CharacterEntityID, HeldComponent)
          )
          
          for i, Key in Keys do
               HeldKeys[Key] = IsHeld[buffer.readbits(WASDRequest, i - 1, 1)]
          end

          Characters:set(
               CharacterEntityID, HeldComponent,
               Serdes.Serialize(HeldComponent, HeldKeys)
          )
     end
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