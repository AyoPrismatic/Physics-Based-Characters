--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Modules
local Replicator = require(PlayerScripts.ECS.Replicators.Characters)

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local EntityLoaded : BindableEvent = CharacterEvents.Client.EntityLoaded
local ClientLoaded : BindableEvent = CharacterEvents.Client.ClientLoaded

local ReplecEvents = ReplicatedStorage.Events.REPLECS
local RecievedFull : BindableEvent = ReplecEvents.RecievedFull

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local PhysicsColliders = CharacterQueries.PhysicsColliders

local ClientCharacterComponents = require(ReplicatedStorage.ECS.Components.Character.ClientSetup)

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local PhysicsColliderComponent = CharacterComponents.List.PhysicsCollider
local PlayerComponent = CharacterComponents.List.Player

--Variables
local EntityIDsDataTable = require(PlayerScripts.Data.Entities.Character.PlayerEntityIDs)
local ComponentInitializers = require(script.ComponentInitializers)

local PhysicsCollidersFolder = workspace.Colliders.PlayerCharacter.Physics

local function AddComponent(EntityID : number, ComponentID : number, ComponentValue : any)
     if ComponentValue ~= nil then
          Characters:set(EntityID, ComponentID, ComponentValue)
     else
          Characters:add(EntityID, ComponentID)
     end
end

local function SetupEntity(EntityID : number, Collider : MeshPart)
     if EntityIDsDataTable.GetPlayer(EntityID) then return end -- <- already set up

     local EntityPlayer = Characters:get(EntityID, PlayerComponent)

     Characters:set(EntityID, PhysicsColliderComponent, Collider) -- <- Sometimes it doesn't replicate properly so we set it here

     for ComponentName, ComponentID in ClientCharacterComponents.List do
          local Value = ComponentInitializers[ComponentName]

          if type(Value) == "function" then
               local Successful, Value = pcall(Value, EntityPlayer, EntityID, Collider)
               if Successful ~= true then
                    warn(`\n Failed to create Component:`..
                         `\n Name: {ComponentName}` ..
                         `\n Reason: {Value}`)
                    continue
               end

               AddComponent(EntityID, ComponentID, Value)
          else
               AddComponent(EntityID, ComponentID, Value)
          end

          EntityIDsDataTable.AddPair(EntityPlayer, EntityID)
     end
     
     local LoadedEvent = if EntityPlayer == Player then ClientLoaded else EntityLoaded
     LoadedEvent:Fire(EntityPlayer, EntityID, Collider)
end

Replicator:added(function(EntityID)
     Replicator:after_replication(function()
          local ServerID = Replicator:get_server_entity(EntityID)
          local PhysicsCollider = PhysicsCollidersFolder:WaitForChild(tostring(ServerID))

          SetupEntity(EntityID, PhysicsCollider)
     end)
end)

RecievedFull.Event:Once(function()
     for EntityID, PhysicsCollider in PhysicsColliders do
          SetupEntity(EntityID, PhysicsCollider)
     end
end)