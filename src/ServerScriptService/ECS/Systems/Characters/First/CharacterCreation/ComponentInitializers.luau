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

local function ZeroVector()
     return Vector3.zero
end

local function UpVector()
     return Vector3.yAxis
end

local function Zero()
     return 0
end

return table.freeze({
     GravitySpringVelocity = ZeroVector,
     TravelledVelocity = ZeroVector,
     ForceVelocities = function()
          return {
               ["X"] = {0, Vector3.xAxis * 6},
               ["-X"] = {0, Vector3.xAxis * -6},
               ["Z"] = {0, Vector3.zAxis * 6},
               ["-Z"] = {0, Vector3.zAxis * -6},
          }
     end,
     MoveVelocity = ZeroVector,
     Position = function(_, EntityID)
          local Vect3 = Instance.new("Vector3Value")

          Vect3.Value = PlayerSpawnPoint + (Vector3.new(1, 1, 1) * math.random(-8, 8))
          Vect3.Name = tostring(EntityID)
          Vect3.Parent = workspace.Data

          return Vect3
     end,

     GroundNormal = UpVector,
     GravityRate = function()
          return 196.2
     end,
     LookVector = function()
          return Vector3.zAxis * -1
     end,
     
     Gravity = Zero,
     AirTime = Zero,

     HeldKeys = function()
          return {
               [Enum.KeyCode.W] = false,
               [Enum.KeyCode.A] = false,
               [Enum.KeyCode.S] = false,
               [Enum.KeyCode.D] = false,
          }
     end,

     PlayerState = function()
          return Global.PlayerStates.Falling
     end,

     Player = function(Player : Player)
          return Player
     end,

     Name = function(Player : Player)
          return Player.Name
     end
})
