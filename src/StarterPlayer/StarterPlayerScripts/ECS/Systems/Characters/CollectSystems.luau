--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Packages
local PlanckRunService = require(ReplicatedStorage.Packages.PlanckRunService)
local Planck = require(ReplicatedStorage.Packages.Planck)

--Modules
local SystemAppend = require(ReplicatedStorage.ECS.Systems.Characters)

--Variables
local SystemsFolder = PlayerScripts.ECS.Systems.Characters
local RunServicePhases = PlanckRunService.Phases
local DefaultPhases = Planck.Phase

local Systems = {}

local function AddSystem(Module : ModuleScript, Phase : Planck.Phase) : Planck.SystemTable
     if not Module:IsA("ModuleScript") then return end

     local SystemData = require(Module)

     SystemData = SystemData["SystemData"] or SystemData
     SystemData.phase = Phase
     
     table.insert(Systems, SystemData)
     return SystemData
end

for _, PhaseFolder : Folder in SystemsFolder:GetChildren() do
     if not PhaseFolder:IsA("Folder") then continue end
     local Phase = RunServicePhases[PhaseFolder.Name] or DefaultPhases[PhaseFolder.Name]

     if Phase then
          for _, Module : ModuleScript in PhaseFolder:GetChildren() do
               AddSystem(Module, Phase)
          end

          PhaseFolder.ChildAdded:Connect(function(Child : ModuleScript?)
               local SystemData = AddSystem(Child, Phase)

               if SystemData then
                    SystemAppend(SystemData)
               end
          end)
     else
          warn(`\n Invalid Phase Name in Systems folder!` ..
               `\n Got: {PhaseFolder.Name}`)
     end
end

return Systems