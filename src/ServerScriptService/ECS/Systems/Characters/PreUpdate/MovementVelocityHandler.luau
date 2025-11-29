--!optimize 2
--!native

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local UVector3 = require(ReplicatedStorage.Utils.Vector)[3]

--ECS
local Serdes = require(ReplicatedStorage.ECS.Components.Character.Serdes)
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local MovementRequests = CharacterQueries.MovementRequests

local Components = require(ReplicatedStorage.ECS.Components.Character).List
local GroundNormalComponent = Components.GroundNormal
local MoveVelocityComponent = Components.MoveVelocity
local LookVectorComponent = Components.LookVector
local HeldKeysComponent = Components.HeldKeys

--Types
type HeldKeys = {[Enum.KeyCode] : boolean}

--Variables
local Keys = table.freeze({
     [Enum.KeyCode.W] = Vector3.xAxis,
     [Enum.KeyCode.A] = Vector3.zAxis,
     [Enum.KeyCode.S] = -Vector3.xAxis,
     [Enum.KeyCode.D] = -Vector3.zAxis
})

local MoveSpeed = 33
local SpeedUpTime = 0.4 -- Takes 0.25s to achieve max speed

SpeedUpTime = math.pow(SpeedUpTime, -1)

local function CalculateVelocity(DT : number, EntityID : number, HeldKeys : HeldKeys, LookVector : Vector3, GroundNormal : Vector3)
     local MoveVector = Vector3.zero

     for KeyCode, UnitVector in Keys do
          local HeldDown = HeldKeys[KeyCode]

          if HeldDown == true then
               MoveVector += UnitVector
          end
     end

     if MoveVector == Vector3.zero then
          return Serdes.SerializeAndSet(EntityID, MoveVelocityComponent, Vector3.zero)
     end
     
     local RightVector = Vector3.yAxis:Cross(LookVector)
     MoveVector = MoveVector.Unit
     
     Serdes.SerializeAndSet(EntityID, MoveVelocityComponent,
          -- |
          -- V Creates the tangent Direction on the surface of the ground and multiplies it to our move velocity
          UVector3.ProjectOnPlane(
               LookVector * MoveVector.X + RightVector * MoveVector.Z, -- <-- The Horizontal direction were moving in
               GroundNormal
          ).Unit * math.min( -- <-- The min function is slowly ramping up the velocity's over time to max speed.
               MoveSpeed,
               Serdes.GetDeserialized(EntityID, MoveVelocityComponent).Magnitude + (SpeedUpTime * MoveSpeed * DT)
          )
     )
end

local function ProccessRequests()
     local DT = Scheduler:getDeltaTime()

     for EntityID : number, HeldKeys : buffer, LookVector : buffer, GroundNormal : buffer in MovementRequests do
          CalculateVelocity(DT, EntityID,
               Serdes.Deserialize(HeldKeysComponent, HeldKeys),
               Serdes.Deserialize(LookVectorComponent, LookVector),
               Serdes.Deserialize(GroundNormalComponent, GroundNormal)
          )
     end
end

return {
     name = "Movement Request Handling",
     system = ProccessRequests,
     runConditions = table.freeze({
          
     })
}
