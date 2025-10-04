--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Replicator = require(ReplicatedStorage.ECS.Replicators.Characters)
Replicator.client:init()

print("Initilized Client Replicator")

return Replicator.client