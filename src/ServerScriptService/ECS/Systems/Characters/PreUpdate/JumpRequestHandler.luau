--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

--Modules
local PlayerEntityIDs = require(ServerStorage.Entities.Character.PlayerEntityIDs)
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local Collect = require(ReplicatedStorage.Utils.Collect)

--Events
local CharacterEvents = ReplicatedStorage.Events.Entities.Character
local JumpRequest : RemoteEvent = CharacterEvents.Input.Jump

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local ForceVelocitiesComponent = CharacterComponents.List.ForceVelocities

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
     local ForceVelocities = Characters:get(EntityID, ForceVelocitiesComponent)
     
     ForceVelocities["Jump"] = {JumpVelocityDecay, Vector3.new(0, JumpVelocity, 0)}
     Characters:set(EntityID, ForceVelocitiesComponent,
          ForceVelocities
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
