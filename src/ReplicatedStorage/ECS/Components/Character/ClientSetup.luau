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

--[[Components]]
local Components = {
     RootPart = Characters:component() :: Entity<BasePart>,
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