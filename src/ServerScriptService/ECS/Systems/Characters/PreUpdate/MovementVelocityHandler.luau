--!optimize 2
--!native

--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Modules
local Scheduler = require(ReplicatedStorage.ECS.Schedulers.Characters)
local UVector3 = require(ReplicatedStorage.Utils.Vector)[3]

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

local CharacterQueries = require(ReplicatedStorage.ECS.Queries.Character)
local MovementRequests = CharacterQueries.MovementRequests

local CharacterComponents = require(ReplicatedStorage.ECS.Components.Character)
local MoveVelocityComponent = CharacterComponents.List.MoveVelocity

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
          Characters:set(EntityID, MoveVelocityComponent, Vector3.zero)
          return
     end
     
     LookVector = Vector3.new(LookVector.X, 0, LookVector.Z).Unit
     MoveVector = MoveVector.Unit

     local RightVector = Vector3.yAxis:Cross(LookVector)

     local MoveDirection = LookVector * MoveVector.X + RightVector * MoveVector.Z

     --The direction made into a tangent line on the surface of the ground
     local TangentDirection = UVector3.ProjectOnPlane(MoveDirection, GroundNormal).Unit

     local PreviousMoveVelocity : Vector3 = Characters:get(EntityID, MoveVelocityComponent)
     local PreviousMagnitude = PreviousMoveVelocity.Magnitude

     Characters:set(EntityID, MoveVelocityComponent,
          TangentDirection * math.min(MoveSpeed, PreviousMagnitude + (SpeedUpTime * MoveSpeed * DT))
     )
end

local function ProccessRequests()
     local DT = Scheduler:getDeltaTime()

     for EntityID, HeldKeys, LookVector, GroundNormal in MovementRequests do
          CalculateVelocity(DT, EntityID, HeldKeys, LookVector, GroundNormal)
     end
end

return {
     name = "Movement Request Handling",
     system = ProccessRequests,
     runConditions = table.freeze({
          
     })
}
