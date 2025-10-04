--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Replecs = require(ReplicatedStorage.Packages.Replecs)
local Jecs = require(ReplicatedStorage.Packages.Jecs)

return Jecs.World.new() :: Jecs.World