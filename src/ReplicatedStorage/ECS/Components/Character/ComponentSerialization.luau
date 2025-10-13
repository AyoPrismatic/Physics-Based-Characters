--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Replecs = require(ReplicatedStorage.Packages.Replecs)
local Squash = require(ReplicatedStorage.Packages.Squash)

--World
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Types
type DecayRate = number
type Velocity = Vector3

--Squash Function
local GetCursor = Squash.frombuffer
local NewCursor = Squash.cursor
local NewBuffer = Squash.tobuffer
local NewRecord = Squash.record
local Optional = Squash.opt
local Type = Squash.T

--Squash
local Number = Squash.number(8)
local Table = Squash.table
local Float = Squash.number(4)
local Vect3 = Squash.Vector3
local Str = Squash.string
local Uint = Squash.uint
local Map = Squash.map


--Squash Records / Maps
local ForceVelocitiesMap = Map(
     Optional(Str()), Table {
          number = Uint(1),
          Vector3 = Vect3(Float)
     }
)

--Serdes Tables

--[[
     Converts a rounds a float to a uint which gets converted back to a float.
     The float has to be <= 1,677.9999 to not lose data
     Retains the first 4 decimal places.
--]]
local LossyUint3Float = table.freeze({
     serialize = function(Value : number) : buffer
          local Cursor = NewCursor()

          Uint(3).ser(Cursor, math.round(Value * 10000))

          return NewBuffer(Cursor)
     end,

     deserialize = function(Buffer : buffer) : number
          local Cursor = GetCursor(Buffer)

          return Uint(3).des(Cursor) / 10000
     end,

     bytespan = 3
})

local LosslessString = table.freeze({
     serialize = function(Value : string) : buffer
          local Cursor = NewCursor()
          Str().ser(Cursor, Value)
          
          return NewBuffer(Cursor)
     end,

     deserialize = function(Buffer : buffer) : string
          local Cursor = GetCursor(Buffer)

          return Str().des(Cursor)
     end
})

--[[
     Converts a native Vector3d64 to a Vector3f32
--]]
local LossyFloatVector3 = table.freeze({
     serialize = function(Value : Vector3) : buffer
          local Cursor = NewCursor()
          Vect3(Float).ser(Cursor, Value)
          
          return NewBuffer(Cursor)
     end,

     deserialize = function(Buffer : buffer) : Vector3
          return Vect3(Float).des(GetCursor(Buffer))
     end,

     bytespan = 12
})

--[[Components]]
local ComponentSerdes = {
     TravelledVelocity = LossyFloatVector3,
     
     ForceVelocities = table.freeze({
          serialize = function(Value : {[string] : {DecayRate | Velocity}}) : buffer
               local Cursor = NewCursor()
               ForceVelocitiesMap.ser(Cursor, Value)

               return NewBuffer(Cursor)
          end,

          deserialize = function(Buffer : buffer) : {[string] : {DecayRate | Velocity}}
               return ForceVelocitiesMap.des(GetCursor(Buffer))
          end
     }),

     MoveVelocity = LossyFloatVector3,

     Gravity = LossyUint3Float,

     AirTime = LossyUint3Float,
     
     PlayerState = LosslessString,

     Name = LosslessString
}

local function Setup(GlobalComponents)
     for ComponentName, SerdesTable in ComponentSerdes do
          local ComponentID = GlobalComponents[ComponentName]
          if not ComponentID then
               warn(`Couldn't Find Component ID for: {ComponentName}`)
               continue
          end

          Characters:set(ComponentID, Replecs.serdes, SerdesTable)
     end
end

return table.freeze({Setup = Setup})