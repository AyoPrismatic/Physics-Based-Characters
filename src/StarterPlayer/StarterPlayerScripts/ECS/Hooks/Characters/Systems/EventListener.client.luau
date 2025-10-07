--Services
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Variables
local SystemsToBeAdded : Folder = PlayerScripts.ECS.Hooks.Characters.Systems
local PhasesFolder : Folder = PlayerScripts.ECS.Systems.Characters

local function ListenForEvent(Module : ModuleScript?, PhaseFolder : Folder)
     if not Module:IsA("ModuleScript") then return end

     local SystemData = require(Module)
     local AmendEvent : RBXScriptSignal = SystemData.Event

     if AmendEvent then
          AmendEvent:Once(function()
               Module.Parent = PhaseFolder
          end)
     else
          error(`\n Amend Event not given for idle system!` ..
               `\n Module: {Module}`)
     end
end

for _, IdlePhaseFolder : Folder in SystemsToBeAdded:GetChildren() do
     if not IdlePhaseFolder:IsA("Folder") then continue end
     local RunningPhaseFolder = PhasesFolder:FindFirstChild(IdlePhaseFolder.Name)

     if RunningPhaseFolder then
          for _, Module : ModuleScript? in IdlePhaseFolder:GetChildren() do
               ListenForEvent(Module, RunningPhaseFolder)
          end
     else
          warn(`\n Invalid Phase Name in Idle Systems folder!` ..
               `\n Got: {IdlePhaseFolder.Name}`)
     end
end