--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Interval = require(ReplicatedStorage.Utils.Interval)

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Variables
local Clean = Interval(1 / 60) -- fires every Minute

local function CleanUp()
     if Clean() then
          Characters:cleanup()
     end
end

return {
     name = "Archetype Cleanup",
     system = CleanUp,
     runConditions = table.freeze({
     })
}