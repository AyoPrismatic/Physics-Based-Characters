--Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--Packages
local Replecs = require(ReplicatedStorage.Packages.Replecs)
local Squash = require(ReplicatedStorage.Packages.Squash)

--World
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)

--Squash Function
local GetCursor = Squash.frombuffer
local NewCursor = Squash.cursor
local NewBuffer = Squash.tobuffer

--Squash
local Float = Squash.number(4)
local Vect3 = Squash.Vector3
local Str = Squash.string

--Serdes Tables
local LossyVector3 = table.freeze({
     serialize = function(Value : string) : buffer
          local Cursor = NewCursor()
          Vect3(Float).ser(Cursor, Value)
          
          return NewBuffer(Cursor)
     end,

     deserialize = function(Buffer : buffer) : string
          return Vect3(Float).des(GetCursor(Buffer))
     end,

     bytespan = 12
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

--[[Components]]
local ComponentSerdes = {
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