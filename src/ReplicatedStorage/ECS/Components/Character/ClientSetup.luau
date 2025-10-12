--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

--Packages
local Jecs = require(ReplicatedStorage.Packages.Jecs)

--World
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Types
export type Entity<T> = Jecs.Entity<T>

--Component Types  (made for other scripts to use)
export type RootPart = Entity<Instance | BasePart>
export type SpringVelocity = Entity<Vector3>
export type SpringResponsiveness = Entity<number>
export type SpringFrequency = Entity<number>
export type SpringDamping = Entity<number>


--[[Components]]
local Components = {
     RootPart = Characters:component() :: Entity<Instance | BasePart>,

     --Spring System Variables
     SpringVelocity = Characters:component() :: Entity<number>,
     SpringResponsiveness = Characters:component() :: Entity<number>,
     SpringFrequency = Characters:component() :: Entity<number>,
     SpringDamping = Characters:component() :: Entity<number>,
}

local function Setup(GlobalComponents)
     for ComponentName, ComponentID in Components do
          Characters:set(ComponentID, Jecs.Name, tostring(ComponentName))
          GlobalComponents[ComponentName] = ComponentID
     end
end

return {
     ["List"] = table.freeze(Components),
     ["Setup"] = Setup
}