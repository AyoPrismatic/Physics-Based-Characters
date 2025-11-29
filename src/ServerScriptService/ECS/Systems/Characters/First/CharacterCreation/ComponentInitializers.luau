--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--ECS
local Global = require(ReplicatedStorage.ECS.Globals.Character)

--Variables
local PlayerSpawnPointPart : BasePart = workspace.SpawnPoint
local PlayerSpawnPoint = PlayerSpawnPointPart:GetPivot().Position

local function ZeroVector() : Vector3
     return Vector3.zero
end

local function UpVector() : Vector3
     return Vector3.yAxis
end

local function Zero() : number
     return 0
end

return table.freeze({
     TravelledVelocity = ZeroVector,
     MoveVelocity = ZeroVector,
     Position = function(_, EntityID : number) : Vector3Value
          local Vect3 = Instance.new("Vector3Value")

          Vect3.Value = PlayerSpawnPoint + (Vector3.new(1, 1, 1) * math.random(-8, 8))
          Vect3.Name = tostring(EntityID)
          Vect3.Parent = workspace.Data

          return Vect3
     end,

     GroundNormal = UpVector,
     LookVector = function() : Vector3
          return Vector3.zAxis * -1
     end,
     
     Gravity = Zero,
     AirTime = Zero,

     HeldKeys = function() : {[Enum.KeyCode] : boolean}
          return {
               [Enum.KeyCode.W] = false,
               [Enum.KeyCode.A] = false,
               [Enum.KeyCode.S] = false,
               [Enum.KeyCode.D] = false,
          }
     end,

     PlayerState = function() : number
          return Global.PlayerStates.Falling
     end,

     Player = function(Player : Player) : Player
          return Player
     end,

     Name = function(Player : Player) : string
          return Player.Name
     end
})
