--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Planck = require(ReplicatedStorage.Packages.Planck)

--PlanckPlugins
local PlanckRunService = require(ReplicatedStorage.Packages.PlanckRunService)
local PlanckJabby = require(ReplicatedStorage.Packages.PlanckJabby)

--World
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Scheduler
local SchedulerClass = Planck.Scheduler
local Scheduler = SchedulerClass.new(Characters)
Scheduler:addPlugin(PlanckJabby.new())
Scheduler:addPlugin(PlanckRunService.Plugin.new())

--RunService:RenderStepped()
Scheduler:insert(PlanckRunService.Phases.PreRender)
Scheduler:insert(PlanckRunService.Pipelines.PreRender)
--RunService:PreAnimation()
Scheduler:insert(PlanckRunService.Phases.PreAnimation)
Scheduler:insert(PlanckRunService.Pipelines.PreAnimation)
--RunService:PreSimulation()
Scheduler:insert(PlanckRunService.Phases.PreSimulation)
Scheduler:insert(PlanckRunService.Pipelines.PreSimulation)
--RunService:PostSimulation()
Scheduler:insert(PlanckRunService.Phases.PostSimulation)
Scheduler:insert(PlanckRunService.Pipelines.PostSimulation)

return Scheduler