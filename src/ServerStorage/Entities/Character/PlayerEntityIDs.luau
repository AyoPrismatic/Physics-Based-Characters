--Services
local Players = game:GetService('Players')

--Types
type EntityID = number

--Variables
local EntityID_Dictionary : {[EntityID] : Player} = {}
local Player_Dictionary : {[Player] : EntityID} = {}

local function RemovePair(Player : Player) : nil
     local EntityID : EntityID = Player_Dictionary[Player]

     EntityID_Dictionary[EntityID] = nil
     Player_Dictionary[Player] = nil
end

Players.PlayerRemoving:Connect(RemovePair)

return table.freeze({
     RemovePair = RemovePair,

     AddPair = function(Player : Player, EntityID : EntityID) : nil
          EntityID_Dictionary[EntityID] = Player
          Player_Dictionary[Player] = EntityID
     end,

     GetPlayer = function(EntityID : EntityID) : Player
          return EntityID_Dictionary[EntityID] :: Player
     end,

     GetID = function(Player : Player) : EntityID
          return Player_Dictionary[Player] :: EntityID
     end
})