--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Modules
local HeldKeys = require(PlayerScripts.Data.Input.HeldKeys)

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local ClientLoaded : BindableEvent = CharacterEvents.Client.ClientLoaded
local WASD_InputEvent : RemoteEvent = CharacterEvents.Input.WASDMovement

local Keys = table.freeze({
     Enum.KeyCode.W,
     Enum.KeyCode.A,
     Enum.KeyCode.S,
     Enum.KeyCode.D
})

local function SetBit(HeldKeys : number, Offset : number, KeyDown : boolean) : number
	local Mask = bit32.lshift(1, Offset)

     if KeyDown then
          return bit32.bxor(HeldKeys, Mask)
     else
          return bit32.band(HeldKeys, bit32.bnot(Mask))
     end
end

local function ProccessInput()
     local HeldDownKeys = buffer.create(1)
     local Int : number = 0

     for i : number, Key : InputObject in Keys do
          Int = SetBit(Int, i - 1, HeldKeys.IsKeyDown(Key))
     end

     buffer.writeu8(HeldDownKeys, 0, Int)

     WASD_InputEvent:FireServer(HeldDownKeys)
end

return table.freeze({
     Event = ClientLoaded.Event,

     SystemData = {
          name = "Movement Requesting",
          system = ProccessInput,
          runConditions = table.freeze({
               
          })
     }
})