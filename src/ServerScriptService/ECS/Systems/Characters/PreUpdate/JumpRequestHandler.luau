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
local ForceVelocityComponent = CharacterComponents.List.ForceVelocity

--Variables
local Requests = Collect(JumpRequest.OnServerEvent)
local Debounces : {[Player] : number} = {}

local JumpVelocity = 100
local DebounceTime = 0.25

local function ProcessJumpRequest(DT : number, Player : Player)
     if Debounces[Player] then
          local NewDebounceTime = Debounces[Player] - DT
          if NewDebounceTime <= 0 then
               Debounces[Player] = nil
          end
     end
     
     local EntityID = PlayerEntityIDs.GetID(Player)
     local CurrentVelocity = Characters:get(EntityID, ForceVelocityComponent)

     Characters:set(EntityID, ForceVelocityComponent,
          CurrentVelocity + Vector3.new(0, JumpVelocity, 0)
     )

     Debounces[Player] = DebounceTime
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