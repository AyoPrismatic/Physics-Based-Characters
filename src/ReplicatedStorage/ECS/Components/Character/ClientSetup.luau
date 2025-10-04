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
export type Example = Entity<any>

--[[Components]]
local Components = {
     --Example = Characters:component() :: Entity<any>,
}

local function Setup(CubeComponents)
     local GlobalComponents = CubeComponents.List
     
     for ComponentName, ComponentID in Components do
          if GlobalComponents[ComponentName] then
               error(`Conflicting Component Names found: {ComponentName}`)
          end

          Characters:set(ComponentID, Jecs.Name, tostring(ComponentName))
          GlobalComponents[ComponentName] = ComponentID
     end
end

return {
     ["List"] = table.freeze(Components),
     ["Setup"] = Setup
}