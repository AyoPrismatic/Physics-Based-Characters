--Services
local Players = game:GetService('Players')

--Types
type ClientEntityID = number

--Variables
local EntityID_Dictionary : {[ClientEntityID] : Player} = {}
local Player_Dictionary : {[Player] : ClientEntityID} = {}

local function RemovePair(Player : Player) : nil
     local EntityID : ClientEntityID = Player_Dictionary[Player]

     EntityID_Dictionary[EntityID] = nil
     Player_Dictionary[Player] = nil
end

Players.PlayerRemoving:Connect(RemovePair)

return table.freeze({
     RemovePair = RemovePair,

     AddPair = function(Player : Player, EntityID : ClientEntityID) : nil
          EntityID_Dictionary[EntityID] = Player
          Player_Dictionary[Player] = EntityID
     end,

     GetPlayer = function(EntityID : ClientEntityID) : Player
          return EntityID_Dictionary[EntityID] :: Player
     end,

     GetID = function(Player : Player) : ClientEntityID
          return Player_Dictionary[Player] :: ClientEntityID
     end
})