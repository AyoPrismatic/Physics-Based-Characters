--!optimize 2
--!native

--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')
local Players = game:GetService('Players')

--Packages
local Replecs = require(ReplicatedStorage.Packages.Replecs)
local Planck = require(ReplicatedStorage.Packages.Planck)
local Jecs = require(ReplicatedStorage.Packages.Jecs)

--Modules
local ForceVelocityManager = require(ServerScriptService.ECS.Modules.Characters.ForceVelocityManager)
local EntityIDsDataTable = require(ServerStorage.Entities.Character.PlayerEntityIDs)
local Collect = require(ReplicatedStorage.Utils.Collect)

--ECS
local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local Serdes = require(ReplicatedStorage.ECS.Components.Character.Serdes)
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Variables
local ComponentInitializers = require(script.ComponentInitializers)
local AddedPlayersCollection = Collect(Players.PlayerAdded)

type CharacterVelocities = {[string] : {number | Vector3}}

local function NewForceVelocityTable() : CharacterVelocities
     return {
          ["X"] = {0, Vector3.xAxis * 6},
          ["-X"] = {0, Vector3.xAxis * -6},
          ["Z"] = {0, Vector3.zAxis * 6},
          ["-Z"] = {0, Vector3.zAxis * -6},
          ["Y"] = {0, Vector3.yAxis * 6},
          ["-Y"] = {0, Vector3.yAxis * -6},
     }
end

local function AddComponent(EntityID : number, ComponentID : number, ComponentValue : any)
     if ComponentValue then
          ComponentValue = Serdes.TrySerializing(ComponentID, ComponentValue)
          Characters:set(EntityID, ComponentID, ComponentValue)
     else
          Characters:add(EntityID, ComponentID)
     end
end

local function ReplicateComponent(EntityID : number, ComponentID : number, ReplicationType : number)
     if not ReplicationType then return end

     Characters:add(EntityID, Jecs.pair(ReplicationType, ComponentID))
end

local function OnPlayerAdded(Player : Player)
     local EntityID = Characters:entity()

     for ComponentName, ComponentID in CharacterComponents.List do
          local ReplicationType = CharacterComponents.SharedComponents[ComponentID]
          local Value = ComponentInitializers[ComponentName]

          if type(Value) == "function" then
               local Successful
               Successful, Value = pcall(Value, Player, EntityID)
               if Successful ~= true then
                    warn(`\n Failed to create Component:`..
                         `\n Name: {ComponentName}` ..
                         `\n Reason: {Value}`)
                    continue
               end
          end

          AddComponent(EntityID, ComponentID, Value)
          ReplicateComponent(EntityID, ComponentID, ReplicationType)
     end
     
     EntityIDsDataTable.AddPair(Player, EntityID)
     ForceVelocityManager.UpdateVelocities(
          NewForceVelocityTable(),
          EntityID
     )

     Characters:add(EntityID, Replecs.Networked)

     print(`\n Created Player Character:`..
           `\n Player Name: {Player.Name}`)
end

local function ProcessPlayers()
     for _, Player : Player in AddedPlayersCollection do
          OnPlayerAdded(Player)
     end
end

return {
     name = "Character Creation",
     system = ProcessPlayers,
     runConditions = table.freeze({
          Planck.onEvent(Players.PlayerAdded),
     })
}