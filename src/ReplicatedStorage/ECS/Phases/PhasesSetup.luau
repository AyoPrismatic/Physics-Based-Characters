--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Planck = require(ReplicatedStorage.Packages.Planck)

local function SetupPhases(Scheduler : Planck.Scheduler, WorldSearchName : string)
     local PhasesModule = ReplicatedStorage.ECS.Phases:FindFirstChild(WorldSearchName)

     if PhasesModule then
          local Phases = require(PhasesModule)
          
          for _, Phase in Phases do
               Scheduler:insert(Phase)
          end
     end
end

return SetupPhases