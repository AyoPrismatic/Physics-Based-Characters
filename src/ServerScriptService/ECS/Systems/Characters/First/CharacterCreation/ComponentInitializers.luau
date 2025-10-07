--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Variables
local PlayerSpawnPointPart : BasePart = workspace.SpawnPoint
local PlayerSpawnPoint = PlayerSpawnPointPart:GetPivot()

local PlayerPhysicsCollider : BasePart = ReplicatedStorage.Colliders.Player.PhysicsCollider
local PhysicsCollidersFolder : Folder = workspace.Colliders.PlayerCharacter.Physics

local PlayerStates = require(ReplicatedStorage.ECS.EntityData.PlayerCharacter.PlayerStates)

local function ZEROVECTOR()
     return Vector3.zero
end

local function UPVECTOR()
     return Vector3.yAxis
end

local function ZERO()
     return 0
end

return table.freeze({
     PhysicsCollider = function(_, EntityID : number)
          local PhysicsCollider = PlayerPhysicsCollider:Clone()
          PhysicsCollider.Parent = PhysicsCollidersFolder
          PhysicsCollider:PivotTo(PlayerSpawnPoint)

          PhysicsCollider.Name = EntityID

          return PhysicsCollider
     end,

     Position = function()
          return PlayerSpawnPoint
     end,

     GravitySpringVelocity = ZEROVECTOR,
     ForceVelocity = ZEROVECTOR,
     MoveVelocity = ZEROVECTOR,
     GroundNormal = UPVECTOR,
     LookVector = function()
          return Vector3.new(0, 0, -1)
     end,
     
     Gravity = ZERO,
     AirTime = ZERO,

     HeldKeys = function()
          return {
               [Enum.KeyCode.W] = false,
               [Enum.KeyCode.A] = false,
               [Enum.KeyCode.S] = false,
               [Enum.KeyCode.D] = false,
          }
     end,

     PlayerState = function()
          return PlayerStates.Falling
     end,

     Player = function(Player : Player)
          return Player
     end,

     Name = function(Player : Player)
          return Player.Name
     end
})
