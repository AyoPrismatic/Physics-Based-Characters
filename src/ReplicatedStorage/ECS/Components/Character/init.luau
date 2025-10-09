--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

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

--Component Types (made for other scripts to use)
export type HeldKeys = Entity<{[Enum.KeyCode] : boolean}>
export type GravitySpringVelocity = Entity<Vector3>
export type PhysicsCollider = Entity<Instance>
export type ForceVelocity = Entity<Vector3>
export type MoveVelocity = Entity<Vector3>
export type GroundNormal = Entity<Vector3>
export type LookVector = Entity<Vector3>
export type AbsoluteY = Entity<number>
export type Gravity = Entity<number>
export type AirTime = Entity<number>

--[[Components]]
local Components = {
     --Colliders
     PhysicsCollider = Characters:component() :: Entity<Instance>,

     --Forces
     ForceVelocity = Characters:component() :: Entity<Vector3>, -- Externally Based Velocity
     MoveVelocity = Characters:component() :: Entity<Vector3>, -- Player Input Based Velocity
     Gravity = Characters:component() :: Entity<number>,

     --Gravity Variables
     GravitySpringVelocity = Characters:component() :: Entity<Vector3>, -- The Velocity for a second-order spring system
     GroundNormal = Characters:component() :: Entity<Vector3>, -- The Normal of the collision between the collider and floor
     GravityRate = Characters:component() :: Entity<number>, -- The Rate that Gravity will increase by each second
     AbsoluteY = Characters:component() :: Entity<number>, -- The Y Position of the character without the spring system
     AirTime = Characters:component() :: Entity<number>,

     --Limiting variables
     MaxTotalVelocity = Characters:component() :: Entity<number>,
     MaxMoveVelocity = Characters:component() :: Entity<Vector3>,
     MaxGravity = Characters:component() :: Entity<number>,

     --Player Input Data
     HeldKeys = Characters:component() :: Entity<{[Enum.KeyCode] : boolean}>,
     LookVector = Characters:component() :: Entity<Vector3>,
     
     --Extra Values
     PlayerState = Characters:component() :: Entity<string>,
     Player = Characters:component() :: Entity<Player>,
     Name = Characters:component() :: Entity<string>,
}

local SharedComponents = {
     [Components.ForceVelocity] = UNRELIABLE,
     [Components.MoveVelocity] = UNRELIABLE,
     [Components.Gravity] = UNRELIABLE,
     [Components.AirTime] = UNRELIABLE,
     
     [Components.PlayerState] = RELIABLE,
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
end

return table.freeze({
     SharedComponents = table.freeze(SharedComponents),
     List = table.freeze(Components),

     GetComponents = GetComponents,
     SetComponents = SetComponents
})
