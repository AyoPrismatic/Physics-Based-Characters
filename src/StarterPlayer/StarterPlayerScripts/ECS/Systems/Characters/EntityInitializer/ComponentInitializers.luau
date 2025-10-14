--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

return table.freeze({
     RootPart = function(_, EntityID : number, ColliderRadius : number)
          local Collider = Instance.new("Part")
          
          Collider.Size = Vector3.one * ColliderRadius * 2
          Collider.Shape = Enum.PartType.Ball

          Collider.CanCollide = false
          Collider.CastShadow = false
          Collider.CanQuery = false
          Collider.CanTouch = false
          Collider.Massless = true
          Collider.Anchored = true

          Collider.BrickColor = BrickColor.new("Really red")
          Collider.Material = Enum.Material.Neon
          Collider.Transparency = 0.9

          Collider.Name = tostring(EntityID)
          Collider.Parent = workspace

          return Collider
     end
})
