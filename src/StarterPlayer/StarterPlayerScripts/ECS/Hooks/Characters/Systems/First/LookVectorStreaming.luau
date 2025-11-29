--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local ClientLoaded : BindableEvent = CharacterEvents.Client.ClientLoaded
local LookVectorUpdate : RemoteEvent = CharacterEvents.Input.LookVector

local function UpdateLookVector()
     local Camera : Camera = workspace.CurrentCamera
     if not Camera then return end

     LookVectorUpdate:FireServer(Camera.CFrame.LookVector)
end

return table.freeze({
     Event = ClientLoaded.Event,

     SystemData = {
          name = "LookVector Streaming",
          system = UpdateLookVector,
          runConditions = table.freeze({
               
          })
     }
})