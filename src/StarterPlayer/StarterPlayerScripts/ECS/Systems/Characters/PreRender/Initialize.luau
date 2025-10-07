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

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local PhysicsColliderLoaded : BindableEvent = CharacterEvents.Client.PhysicsColliderLoaded

--Variables
local PhysicsCollidersFolder : Folder = workspace.Colliders.PlayerCharacter.Physics

local CharacterPhysicsCollider : Instance
local CharacterEntityID : number
local CharacterLoaded = false

local DisconnectReplecsCallback = Replicator:added(function(EntityID)
     Replicator:after_replication(function()
          CharacterEntityID = Replicator:get_server_entity(EntityID)
          CharacterLoaded = true
     end)
end)

local function ClientCharacterInitalize()
     workspace.CurrentCamera.CameraSubject = CharacterPhysicsCollider

     workspace.CurrentCamera:PivotTo(CFrame.new(workspace.CurrentCamera:GetPivot().Position) * CFrame.fromAxisAngle(Vector3.new(1, 0, 0), math.rad(12)))
     
     PhysicsColliderLoaded:Fire(CharacterPhysicsCollider)
end

local function IsColliderReplicated() : boolean
     if not CharacterLoaded then return false end
     DisconnectReplecsCallback()

     CharacterPhysicsCollider = PhysicsCollidersFolder:FindFirstChild(tostring(CharacterEntityID))
     if not CharacterPhysicsCollider then return false end

     return true
end

return {
     name = "Self Character Initializing",
     system = ClientCharacterInitalize,
     runConditions = table.freeze({
          IsColliderReplicated,
          Planck.runOnce()
     })
}