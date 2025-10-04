--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Replecs = require(ReplicatedStorage.Packages.Replecs)

--World
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

return Replecs.create(Characters)