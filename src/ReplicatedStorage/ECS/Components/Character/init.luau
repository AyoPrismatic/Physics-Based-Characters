--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

--Packages
local Replecs = require(ReplicatedStorage.Packages.Replecs)
local Jabby = require(ReplicatedStorage.Packages.Jabby)
local Jecs = require(ReplicatedStorage.Packages.Jecs)

--World
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Constants
local RELIABLE, UNRELIABLE = Replecs.Reliable, Replecs.Unreliable

--Types
type Entity<T> = Jecs.Entity<T>
type EntityIndex = number
type ComponentIndex = number

type DecayRate = number
type Velocity = Vector3

--Component Types (made for other scripts to use)
export type ForceVelocities = Entity<{[string] : {DecayRate | Velocity}}>
export type HeldKeys = Entity<{[Enum.KeyCode] : boolean}>
export type PhysicsColliderRadius = Entity<number>
export type TravelledVelocity = Entity<Vector3>
export type Position = Entity<Vector3Value>
export type MoveVelocity = Entity<Vector3>
export type GroundNormal = Entity<Vector3>
export type LookVector = Entity<Vector3>
export type Gravity = Entity<number>
export type AirTime = Entity<number>

--[[Components]]
local Components = {
     --Colliders
     Position = Characters:component() :: Entity<Vector3Value>,

     --Forces
     ForceVelocities = Characters:component() :: Entity<{[string] : {DecayRate | Velocity}}>, -- Externally Based Velocity
     MoveVelocity = Characters:component() :: Entity<Vector3>, -- Player Input Based Velocity
     Gravity = Characters:component() :: Entity<number>,

     --Gravity Variables
     GroundNormal = Characters:component() :: Entity<Vector3>, -- The Normal of the collision between the collider and floor
     GravityRate = Characters:component() :: Entity<number>, -- The Rate that Gravity will increase by each second
     AirTime = Characters:component() :: Entity<number>,

     --Player Input Data
     HeldKeys = Characters:component() :: Entity<{[Enum.KeyCode] : boolean}>,
     LookVector = Characters:component() :: Entity<Vector3>,
     
     --Extra Values
     PlayerState = Characters:component() :: Entity<string>,
     Player = Characters:component() :: Entity<Player>,
     Name = Characters:component() :: Entity<string>,
}

local SharedComponents = {
     [Components.Position] = RELIABLE, -- The instance gets sent from Replecs but roblox's replication handles updating the client's position
     
     [Components.Player] = RELIABLE,
     [Components.Name] = RELIABLE
}

for ComponentName, ComponentID in Components do
     Characters:set(ComponentID, Jecs.Name, tostring(ComponentName))

     if SharedComponents[ComponentID] then
          Characters:add(ComponentID, Replecs.Shared)
     end
end

--[[Helper Functions]]
local function GetComponents(EntityID : EntityIndex, ... : ComponentIndex) : (any)
     local ComponentValues = {}

     for _, ComponentID in {...} do
          if type(ComponentID) ~= "number" then
               warn(
                    `\n Invalid ComponentID recieved` ..
                    `\n Type: {type(ComponentID)}` ..
                    `\n Got: {ComponentID}`)
               continue
          end

          local Successful, ComponentValue = pcall(Characters.get, Characters, EntityID, ComponentID)
          if Successful ~= true then
               local ErrorMSG = ComponentValue
               warn(
                    `\n Couldn't Fetch Component Value.` ..
                    `\n ComponentID: {ComponentID}` ..
                    `\n Reason: {ErrorMSG}`)
               continue
          end
          
          table.insert(ComponentValues, ComponentValue)
     end

     return table.unpack(ComponentValues)
end

local function SetComponents(EntityID : EntityIndex, ComponentData : {[ComponentIndex] : any}) : nil
     for ComponentID, ComponentData in ComponentData do
          if type(ComponentID) ~= "number" then
               warn(
                    `\n Invalid ComponentID recieved` ..
                    `\n Type: {type(ComponentID)}` ..
                    `\n Got: {ComponentID}`
               )
          else
               local Successful, ComponentValue = pcall(Characters.set, Characters, EntityID, ComponentID, ComponentData)
               if Successful == true then continue end
               local ErrorMSG = ComponentValue
               warn(
                    `\n Couldn't Fetch Component Value.` ..
                    `\n ComponentID: {ComponentID}` ..
                    `\n Reason: {ErrorMSG}`
               )
          end
     end
end

--[[Ser / Des]]
local ComponentSerialization = require(script.ComponentSerialization)
ComponentSerialization.Setup(Components)

--[[Jabby]]
local JabbyRegistered, ErrorMSG = pcall(Jabby.register, {
     name = "Characters",
     applet = Jabby.applets.world,
     configuration = {
          world = Characters
     }
})

if JabbyRegistered ~= true then
     warn(`Jabby Failed to register for {script.Name} because {ErrorMSG}`)
else
     Jabby.set_check_function(function(Player : Player)
          return true
     end)
end

--[[Client]]
if RunService:IsClient() then
     local ClientComponents = require(script.ClientSetup)
     ClientComponents.Setup(Components)
end

return table.freeze({
     SharedComponents = table.freeze(SharedComponents),
     List = table.freeze(Components),

     GetComponents = GetComponents,
     SetComponents = SetComponents
})
