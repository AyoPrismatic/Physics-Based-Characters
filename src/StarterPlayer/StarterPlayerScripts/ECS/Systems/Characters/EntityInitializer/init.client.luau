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
local Serdes = require(ReplicatedStorage.ECS.Components.Character.Serdes)
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local ClientCharacterComponents = require(ReplicatedStorage.ECS.Components.Character.ClientSetup).List
local RootPartComponent = ClientCharacterComponents.RootPart
local NameTagComponent = ClientCharacterComponents.NameTag

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character).List
local PlayerComponent = CharacterComponents.Player

--Variables
local EntityIDsDataTable = require(PlayerScripts.Data.Entities.Character.PlayerEntityIDs)
local ComponentInitializers = require(script.ComponentInitializers)

local function AddComponent(EntityID : number, ComponentID : number, ComponentValue : any)
     if ComponentValue then
          Characters:set(EntityID, ComponentID, ComponentValue)
     else
          Characters:add(EntityID, ComponentID)
     end
end

local function SetupEntity(EntityID : number, EntityPlayer : Player?)
     if EntityIDsDataTable.GetPlayer(EntityID) then return end -- <- already set up

     EntityPlayer = EntityPlayer or Serdes.GetDeserialized(EntityID, PlayerComponent)

     for ComponentName, ComponentID in ClientCharacterComponents do
          local Value = ComponentInitializers[ComponentName]

          if type(Value) == "function" then
               local Successful
               Successful, Value = pcall(Value, EntityPlayer, EntityID)
               if Successful ~= true then
                    warn(`\n Failed to create Component:`..
                         `\n Name: {ComponentName}` ..
                         `\n Reason: {Value}`)
                    continue
               end
          end
          
          AddComponent(EntityID, ComponentID, Value)
     end

     local NameTag : BillboardGui = Characters:get(EntityID, NameTagComponent)
     local RootPart : BasePart = Characters:get(EntityID, RootPartComponent)
     
     NameTag.Adornee = RootPart
     NameTag.Parent = RootPart

     Replicator:hook(EntityID, "deleted", function()
          RootPart:Destroy()
          NameTag:Destroy()
     end)
     
     local LoadedEvent = if EntityPlayer == Player then ClientLoaded else EntityLoaded
     LoadedEvent:Fire(EntityPlayer, EntityID, RootPart)
     EntityIDsDataTable.AddPair(EntityPlayer, EntityID)
end

Replicator:added(function(EntityID : number)
     Replicator:after_replication(function()
          SetupEntity(EntityID)
     end)
end)

RecievedFull.Event:Once(function()
     for EntityID : number, EntityPlayer : Player in Characters:query(PlayerComponent) do
          SetupEntity(EntityID, EntityPlayer)
     end
end)