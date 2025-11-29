--!optimize 2
--!native

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--ECS
local Serdes = require(ReplicatedStorage.ECS.Components.Character.Serdes)
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local VelocitiesComponent = Components.ForceVelocities

type Velocities = {[string] : {number | Vector3}}

local function GetVelocities(VelocitiesBuffer : buffer?, EntityID : number) : Velocities
     return Serdes.Deserialize(VelocitiesComponent,
          VelocitiesBuffer or Characters:get(EntityID, VelocitiesComponent)
     )
end

local function UpdateVelocities(ForceVelocities : Velocities, EntityID : number)
     Serdes.SerializeAndSet(EntityID, VelocitiesComponent, ForceVelocities)
end

local function SetVelocity(ForceVelocities : {}?, EntityID : number, VelocityID : string, DecayRate : number, Velocity : Vector3)
     ForceVelocities = ForceVelocities or GetVelocities(nil, EntityID)
     ForceVelocities[VelocityID] = {DecayRate, Velocity}
     
     UpdateVelocities(ForceVelocities, EntityID)
end

return table.freeze({
     ["UpdateVelocities"] = UpdateVelocities,
     ["GetVelocities"] = GetVelocities,
     ["SetVelocity"] = SetVelocity
})