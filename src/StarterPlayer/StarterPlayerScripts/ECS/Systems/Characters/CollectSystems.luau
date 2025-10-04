--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Packages
local PlanckRunService = require(ReplicatedStorage.Packages.PlanckRunService)
local Planck = require(ReplicatedStorage.Packages.Planck)

--Variables
local SystemsFolder = PlayerScripts.ECS.Systems.Characters
local RunServicePhases = PlanckRunService.Phases
local DefaultPhases = Planck.Phase

local Systems = {}

for _, PhaseFolder in SystemsFolder:GetChildren() do
     if not PhaseFolder:IsA("Folder") then continue end
     local PhaseName = PhaseFolder.Name

     local Phase = RunServicePhases[PhaseName] or DefaultPhases[PhaseName]
     if not Phase then
          warn(`\n Invalid Phase Name in Systems folder!` ..
               `\n Got: {PhaseName}`)
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