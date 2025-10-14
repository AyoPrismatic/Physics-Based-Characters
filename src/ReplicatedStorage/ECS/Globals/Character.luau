--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Variables
local PhysicsCollider : Part = ReplicatedStorage.Colliders.Player.PhysicsCollider
local ColliderSize = PhysicsCollider.Size

local Globals = {}

Globals.PlayerCharacterRadius = (ColliderSize.X + ColliderSize.Y + ColliderSize.Z) / 6 :: number

Globals.PlayerStates = table.freeze({
     Grounded = "GROUNDED",
     Falling = "FALLING",
})

return Globals