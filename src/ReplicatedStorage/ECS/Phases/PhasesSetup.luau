--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Planck = require(ReplicatedStorage.Packages.Planck)

local function SetupPhases(Scheduler : Planck.Scheduler, WorldSearchName : string)
     local PhasesModule = ReplicatedStorage.ECS.Phases:FindFirstChild(WorldSearchName)

     if PhasesModule then
          local PhaseFolder = require(PhasesModule)
          
          for _, PhaseData in PhaseFolder do
               if PhaseData["Before"] then
                    Scheduler:insertBefore(PhaseData.Phase, PhaseData.Before)
               elseif PhaseData["After"] then
                    Scheduler:insertAfter(PhaseData.Phase, PhaseData.After)
               else
                    Scheduler:insert(PhaseData.Phase)
               end

               Scheduler:run(PhaseData.Phase)
          end
     end
end

return SetupPhases