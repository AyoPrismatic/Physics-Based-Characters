--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Global = require(ReplicatedStorage.ECS.Globals.Character)

--Variables
local ColliderRadius = Global.PlayerCharacterRadius

return table.freeze({
     RootPart = function(_, EntityID : number)
          local Collider = Instance.new("Part")
          
          Collider.Size = Vector3.one * ColliderRadius * 2
          Collider.Shape = Enum.PartType.Ball

          Collider.CanCollide = false
          Collider.CastShadow = false
          Collider.CanQuery = false
          Collider.CanTouch = false
          Collider.Massless = true
          Collider.Anchored = true

          Collider.Color = Color3.new(1, 0, 0)
          Collider.Material = Enum.Material.Neon
          Collider.Transparency = 0.7

          Collider.Name = tostring(EntityID)
          Collider.Parent = workspace

          return Collider
     end
})
