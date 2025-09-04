--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

--Folders
local Events = ReplicatedStorage.Events.PlayerDataUpdates
local LookVectorUpdate : UnreliableRemoteEvent = Events.LookVector

--Variables
local CumulativeDeltaTime = 0
local UpdatesPerSecond = 35
local UpdateInterval = 1 / UpdatesPerSecond

RunService.Heartbeat:Connect(function(DT)
     CumulativeDeltaTime += DT

     -- Prevents too much updates sent to the server
     if CumulativeDeltaTime >= UpdateInterval then
          CumulativeDeltaTime -= UpdateInterval

          local CameraLookVector = workspace.CurrentCamera.CFrame.LookVector
          local SentVector = Vector3int16.new(
               CameraLookVector.X * 100000,
               CameraLookVector.Y * 100000,
               CameraLookVector.Z * 100000
          )

          LookVectorUpdate:FireServer(SentVector)
     end
end)