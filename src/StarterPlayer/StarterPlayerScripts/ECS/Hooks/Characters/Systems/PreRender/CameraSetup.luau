--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local ClientLoaded : BindableEvent = CharacterEvents.Client.ClientLoaded

--Variables
local RootPart : Part

ClientLoaded.Event:Once(function(_EntityPalyer : Player, _EntityID : number, Part : Part)
     RootPart = Part
end)

local function CheckCamera()
     local Camera = workspace.CurrentCamera

     if not Camera or not RootPart then return end
     if Camera.CameraSubject == RootPart then return end

     Camera.CameraSubject = RootPart
end

return table.freeze({
     Event = ClientLoaded.Event,

     SystemData = {
          name = "Camera Setup",
          system = CheckCamera,
          runConditions = table.freeze({
               
          })
     }
})