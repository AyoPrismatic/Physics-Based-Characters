--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Packages
local Planck = require(ReplicatedStorage.Packages.Planck)

--Modules
local Replicator = require(PlayerScripts.ECS.Replicators.Characters)

--Variables
local PhysicsCollidersFolder : Folder = workspace.Colliders.PlayerCharacter.Physics

local CharacterPhysicsCollider : Instance
local CharacterEntityID : number
local CharacterLoaded = false

local DisconnectReplecsCallback = Replicator:added(function(EntityID)
     Replicator:after_replication(function()
          CharacterEntityID = EntityID
          CharacterLoaded = true
     end)
end)

local function ClientCharacterInitalize()
     workspace.CurrentCamera.CameraSubject = CharacterPhysicsCollider
end

local function IsCharacterLoaded() : boolean
     if not CharacterLoaded then return false end
     
     DisconnectReplecsCallback()
     return true
end

local function IsColliderReplicated() : boolean
     local PhysicsCollider = PhysicsCollidersFolder:FindFirstChild(tostring(CharacterEntityID))
     if not PhysicsCollider then return false end

     CharacterPhysicsCollider = PhysicsCollider
     return true
end

return {
     name = "Self Character Initializing",
     system = ClientCharacterInitalize,
     runConditions = table.freeze({
          IsCharacterLoaded,
          IsColliderReplicated,

          Planck.runOnce()
     })
}