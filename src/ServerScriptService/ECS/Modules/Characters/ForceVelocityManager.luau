--!optimize 2
--!native

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Squash = require(ReplicatedStorage.Packages.Squash)

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local ForceVelocitiesComponent = Components.ForceVelocities

--Squash
local BufferToCursor = Squash.frombuffer
local NewBuffer = Squash.tobuffer
local NewCursor = Squash.cursor

local Table = Squash.table
local Float = Squash.number(4)
local String = Squash.string
local Vect3f32 = Squash.Vector3(Float)

local ForceVelocitiesMap = Squash.map(
     String(), -- <- Key
     
     Table({ -- <- Value
          number = Float,
          Vector3 = Vect3f32
     })
)

local function GetVelocities(ForceVelocitiesBuf : buffer?, EntityID : number) : {[string] : {number & Vector3}}
     ForceVelocitiesBuf = ForceVelocitiesBuf or Characters:get(EntityID, ForceVelocitiesComponent)

     return ForceVelocitiesMap.des(BufferToCursor(ForceVelocitiesBuf))
end

local function UpdateVelocities(ForceVelocities : {[string] : {number & Vector3}}, EntityID : number)
     local Cursor = NewCursor()

     ForceVelocitiesMap.ser(Cursor, ForceVelocities)

     Characters:set(EntityID, ForceVelocitiesComponent, NewBuffer(Cursor))
end

return table.freeze({
     SetVelocity = function(ForceVelocities : {}?, EntityID : number, VelocityID : string, DecayRate : number, Velocity : Vector3)
          ForceVelocities = ForceVelocities or GetVelocities(nil, EntityID)
          
          ForceVelocities[VelocityID] = {DecayRate, Velocity}

          UpdateVelocities(ForceVelocities, EntityID)
     end,

     UpdateVelocities = UpdateVelocities,

     GetVelocities = GetVelocities
})