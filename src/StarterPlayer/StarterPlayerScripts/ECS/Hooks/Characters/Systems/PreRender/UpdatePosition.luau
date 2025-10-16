--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

--Player
local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

--Packages
local Planck = require(ReplicatedStorage.Packages.Planck)

--Events
local ReplecEvents = ReplicatedStorage.Events.REPLECS
local RecievedFull : BindableEvent = ReplecEvents.RecievedFull

--ECS
local ClientCharacterQueries = require(ReplicatedStorage.ECS.Queries.Character.ClientQueries)
local CharacterPositionUpdates = ClientCharacterQueries.CharacterPositionUpdates

local Parts : {Part} = {}
local CFrames : {CFrame} = {}

local function UpdateEntity(EntityID : number, RootPart : Part, Position : Vector3Value)
     CFrames[#CFrames + 1] = CFrame.new(Position.Value)
     Parts[#Parts + 1] = RootPart
end

local function UpdateRootParts()
     for EntityID, RootPart, Position in CharacterPositionUpdates do
          UpdateEntity(EntityID, RootPart, Position)
     end

     workspace:BulkMoveTo(
          Parts,
          CFrames,
          Enum.BulkMoveMode.FireCFrameChanged
     )

     table.clear(CFrames)
     table.clear(Parts)
end

return table.freeze({
     Event = RecievedFull.Event,

     SystemData = {
          name = "Character Position Updates",
          system = UpdateRootParts,
          runConditions = table.freeze({
               
          })
     }
})