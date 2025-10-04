--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Functions
local AddSystem = require(ReplicatedStorage.ECS.Systems.Characters)

local HookedSystems, ErrorMSG = pcall(function()
     local Systems = require(script.CollectSystems)

     for _, SystemData in Systems do
          AddSystem(SystemData)
     end
end)

if HookedSystems ~= true then
     error(
          `\n SEVERE:`..
          `\n Problem when Hooking Server Systems.` ..
          `\n Reason: {ErrorMSG}`
     )
end