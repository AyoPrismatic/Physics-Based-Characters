--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Jecs = require(ReplicatedStorage.Packages.jecs)

--Variables
local CharacterCollisionBox : Part = ReplicatedStorage.Colliders.Player.PhysicsCollider

local ZERO_VECTOR : Vector3 = Vector3.new(0, 0, 0) -- Constants
local SPAWNPOSITION : Vector3 = Vector3.new(0, 4, 0)

--[[World & Components]]
local Characters = Jecs.World.new()          :: Jecs.World -- Main Container for characters
--   Player Data related components
local PlayerID = Characters:component()      :: Jecs.Entity<number>
local PlayerName = Characters:component()    :: Jecs.Entity<string>
--   Collision related components
local HurtBox = Characters:component()       :: Jecs.Entity<Part>
local CollisionBox = Characters:component()  :: Jecs.Entity<Part>
--   Movement related components
local PastPositions = Characters:component() :: Jecs.Entity<{[number] : Vector3}> -- [Timestamp] : Position
local MoveVelocity = Characters:component()  :: Jecs.Entity<Vector3>
local LookVector = Characters:component()    :: Jecs.Entity<Vector3>
local Velocity = Characters:component()      :: Jecs.Entity<Vector3>
--   Gravity related components
local GravityForce = Characters:component()  :: Jecs.Entity<number>
local Mass = Characters:component()          :: Jecs.Entity<number>

--[[Module]]
local Module = {
     Private = {},
     Public = {}
}
local Private = Module.Public
local Public = Module.Public

function Public.CreateCharacter(Player : Player)
     local CharacterEntity = Characters:entity()
     local UserID = Player.UserId
     local Name = Player.Name

     Characters:set(CharacterEntity, PlayerName, Name) -- Player Data
     Characters:set(CharacterEntity, PlayerID, UserID)

     Characters:set(CharacterEntity, CollisionBox, Private.CreatePhysicsCollider()) -- Colliders
     
     Characters:set(CharacterEntity, PastPositions, Private.PastPositionsTemplate()) -- Movement related Data
     Characters:set(CharacterEntity, MoveVelocity, ZERO_VECTOR)
     Characters:set(CharacterEntity, LookVector, ZERO_VECTOR)
     Characters:set(CharacterEntity, Velocity, ZERO_VECTOR)

     Characters:set(CharacterEntity, GravityForce, 0) -- Gravity related Data
     Characters:set(CharacterEntity, Mass, 0.25)
end

function Public.OnTickPhysics(DT)
     for ID, ColliderBox, CharacterVelocity, Gravity in Private.Iter(CollisionBox, Velocity, GravityForce) do
          ColliderBox.Position += CharacterVelocity * DT
          ColliderBox.Position += CharacterVelocity * DT
     end
end

function Public.GetWorld() : Jecs.World
     return Characters
end

--[[Private Helpers]]
function Private.CreatePhysicsCollider() : Part
     local CollisionBox = CharacterCollisionBox:Clone()
     local StartPosition = CFrame.fromMatrix(
          SPAWNPOSITION,
          ZERO_VECTOR,
          ZERO_VECTOR,
          ZERO_VECTOR
     )

     CollisionBox:PivotTo(StartPosition)
     return CollisionBox
end

function Private.PastPositionsTemplate() : {[number] : Vector3}
     return {
          [tick()] = ZERO_VECTOR,
          [tick()] = ZERO_VECTOR,
          [tick()] = ZERO_VECTOR,
          [tick()] = ZERO_VECTOR,
          [tick()] = ZERO_VECTOR
     }
end

function Private.Iter(... : {Jecs.Entity<any>}) : {any}
     return Characters:Query(...):iter()
end

return Public