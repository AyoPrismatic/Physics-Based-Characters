--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local ClientLoaded : BindableEvent = CharacterEvents.Client.ClientLoaded

--Variables
local PhysicsCollider : MeshPart

ClientLoaded.Event:Once(function(EntityPlayer : Player, EntityID : number, Collider : MeshPart)
     PhysicsCollider = Collider
end)

local function CheckCamera()
     local Camera = workspace.CurrentCamera

     if not Camera or not PhysicsCollider then return end
     if Camera.CameraSubject == PhysicsCollider then return end

     Camera.CameraSubject = PhysicsCollider
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