--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Variables
local PhysicsCollider : Part = ReplicatedStorage.Colliders.Player.PhysicsCollider
local ColliderSize = PhysicsCollider.Size

local Globals = {}

Globals.PlayerCharacterRadius = (ColliderSize.X + ColliderSize.Y + ColliderSize.Z) / 6 :: number

Globals.PlayerStates = table.freeze({
     Grounded = 1,
     Falling = 2,
})

Globals.ComponentLimits = table.freeze({
     VelocityMagnitude = 1024,
     Gravity = 1000
})

Globals.RateOfGravity = 196.2

return Globals