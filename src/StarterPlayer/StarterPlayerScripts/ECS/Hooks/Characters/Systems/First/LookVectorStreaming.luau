--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local ClientLoaded : BindableEvent = CharacterEvents.Client.ClientLoaded
local LookVectorUpdate : RemoteEvent = CharacterEvents.Input.LookVector

local function UpdateLookVector()
     local Camera : Camera = workspace.CurrentCamera
     if not Camera then return end

     local LookVector = Camera.CFrame.LookVector
     LookVectorUpdate:FireServer(Vector3int16.new(
          LookVector.X * 10000,
          LookVector.Y * 10000,
          LookVector.Z * 10000
     ))
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