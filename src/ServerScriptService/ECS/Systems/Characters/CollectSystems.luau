--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local PlanckRunService = require(ReplicatedStorage.Packages.PlanckRunService)
local Planck = require(ReplicatedStorage.Packages.Planck)

--Variables
local SystemsFolder = ServerScriptService.ECS.Systems.Characters
local RunServicePhases = PlanckRunService.Phases
local DefaultPhases = Planck.Phase


local Systems = {}

local function FindPhase(PhaseName) : Planck.Phase?
     local Phase = RunServicePhases[PhaseName] or DefaultPhases[PhaseName]
     if Phase then return Phase end

     local SuccessfullyFound, Phase = pcall(function()
          return require(ReplicatedStorage.ECS.Phases.Character:FindFirstChild(PhaseName))
     end)

     if SuccessfullyFound then
          return Phase.Phase
     end
end

for _, PhaseFolder in SystemsFolder:GetChildren() do
     if not PhaseFolder:IsA("Folder") then continue end

     local Phase = FindPhase(PhaseFolder.Name)
     if not Phase then
          warn(`\n Invalid Phase Name in Systems folder!` ..
               `\n Got: {PhaseFolder.Name}`)
          continue
     end

     for _, Module : ModuleScript in PhaseFolder:GetChildren() do
          if not Module:IsA("ModuleScript") then continue end

          local SystemData = require(Module)

          SystemData = SystemData["SystemData"] or SystemData
          SystemData.phase = Phase

          table.insert(Systems, SystemData)
     end
end

return if #Systems > 0 then Systems else nil