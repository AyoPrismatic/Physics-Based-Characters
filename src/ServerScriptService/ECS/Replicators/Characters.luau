--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Replicator = require(ReplicatedStorage.ECS.Replicators.Characters)
Replicator.server:init()

print("Initilized Server Replicator")

return Replicator.server