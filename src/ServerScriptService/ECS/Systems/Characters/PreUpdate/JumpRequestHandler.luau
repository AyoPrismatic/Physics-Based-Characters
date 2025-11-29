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

--ECS
local CharacterGlobals = require(ReplicatedStorage.ECS.Globals.Character)

--Variables
local Requests = Collect(JumpRequest.OnServerEvent)
local Debounces : {[Player] : boolean} = {}

--Properties
local Properties = CharacterGlobals.CharacterProperties

local JumpVelocityDecay = Properties.JumpVelocityDecay
local JumpVelocity = Properties.JumpVelocity * Vector3.yAxis
local JumpDebounce = Properties.JumpDebounce
local function DebouncePlayer(Player : Player)
     Debounces[Player] = true
     
     task.wait(JumpDebounce)
     
     Debounces[Player] = false
end

local function ProcessJumpRequest(DT : number, Player : Player)
     if Debounces[Player] then return end
     
     ForceVelocityManager.SetVelocity(nil, PlayerEntityIDs.GetID(Player),
          "Jump", JumpVelocityDecay, JumpVelocity
     )
     
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
