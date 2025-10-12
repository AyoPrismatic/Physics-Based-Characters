--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local InputService = game:GetService('UserInputService')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local HeldKeys = require(PlayerScripts.Data.Input.HeldKeys)

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local ClientLoaded : BindableEvent = CharacterEvents.Client.ClientLoaded
local JumpRequest : RemoteEvent = CharacterEvents.Input.Jump

--Variables
local JumpKey = Enum.KeyCode.Space
local JumpDebounce = 0
local Debounce = 0.25

local function CheckInput() : nil
     if JumpDebounce > 0 then
          JumpDebounce = math.max(0, JumpDebounce - Scheduler:getDeltaTime())
          return
     end
     
     if HeldKeys.IsKeyDown(JumpKey) == true then
          JumpRequest:FireServer()
          JumpDebounce = Debounce
     end
end

return table.freeze({
     Event = ClientLoaded.Event,

     SystemData = {
          name = "Jump Requests",
          system = CheckInput,
          runConditions = table.freeze({
               
          })
     }
})