--Services
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

--Modules
local ForceVelocityManager = require(ServerScriptService.ECS.Modules.Characters.ForceVelocityManager)
local PlayerEntityIDs = require(ServerStorage.Entities.Character.PlayerEntityIDs)
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local Collect = require(ReplicatedStorage.Utils.Collect)

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local JumpRequest : RemoteEvent = CharacterEvents.Input.Jump

--Variables
local Requests = Collect(JumpRequest.OnServerEvent)
local Debounces : {[Player] : number} = {}
local DebounceTime = 0.25

local JumpVelocity = 150
local JumpVelocityDecay = 5

local function DebouncePlayer(Player : Player)
     Debounces[Player] = true
     
     task.wait(DebounceTime)
     
     Debounces[Player] = false
end

local function ProcessJumpRequest(DT : number, Player : Player)
     if Debounces[Player] then return end
     
     local EntityID = PlayerEntityIDs.GetID(Player)

     ForceVelocityManager.SetVelocity(nil, EntityID, "Jump", JumpVelocityDecay, Vector3.yAxis * JumpVelocity)

     task.spawn(DebouncePlayer, Player)
end

local function ProcessRequests()
     local DT = Scheduler:getDeltaTime()
     
     for _, Player in Requests do
         ProcessJumpRequest(DT, Player)
     end
end

return {
  name = "Jump Request Processing",
  system = ProcessRequests,
  runConditions = table.freeze({
    
  })
}
