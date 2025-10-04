--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Planck
local Planck = require(ReplicatedStorage.Packages.Planck)
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)

--Setup Phases
local PhasesSetup = require(ReplicatedStorage.ECS.Phases.PhasesSetup)
PhasesSetup(Scheduler, script.Name)

--Constants
local WORLDNAME = script.Name
local WORLDTAG = ` [{WORLDNAME}]`

Scheduler:runAll()

local function AddSystem(SystemTable : Planck.SystemTable)
     SystemTable.name ..= WORLDTAG
     table.freeze(SystemTable)

     Scheduler:addSystem(SystemTable)
end

return AddSystem