--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Events
local Events = ReplicatedStorage.Events.PlayerDataUpdates
local LookVectorUpdateEvent : UnreliableRemoteEvent = Events.LookVector

--Variables
local PlayerCharacterData : {[Player] : {}} = {}

local CharacterDataTemplate = {
     ["LookVector"] = Vector3int16.new(0, 0, 0) -- The Vector is compressed on the client by multiplying by 100,000 to be stored in a 16 bit Vector
}

--[[Module]]
local Data = {}

function Data.GetCharacterData(Player : Player)
     return PlayerCharacterData[Player]
end

--[[Getting / Updating Data]]
local function LookVectorUpdate(Player : Player, LookVector : Vector3int16)
     if typeof(LookVector) ~= "Vector3int16" then
          warn(`Recieved invalid LookVector from {Player}`)
          return
     end

     PlayerCharacterData[Player]["LookVector"] = LookVector
     print(LookVector)
end

LookVectorUpdateEvent.OnServerEvent:Connect(LookVectorUpdate) -- Hooking updates to events

--[[Init / Cleanup]]
local function OnPlayerAdded(Player : Player)
     PlayerCharacterData[Player] = table.clone(CharacterDataTemplate)
end

local function OnPlayerRemoval(Player : Player)
     PlayerCharacterData[Player] = nil
end

Players.PlayerRemoving:Connect(OnPlayerRemoval)
Players.PlayerAdded:Connect(OnPlayerAdded)

--[[Module]]
return Data