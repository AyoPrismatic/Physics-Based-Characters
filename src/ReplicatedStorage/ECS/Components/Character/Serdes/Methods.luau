--!optimize 2
--!native
--!strict

--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService('Players')

--Packages
local Squash = require(ReplicatedStorage.Packages.Squash)

--ECS
local Components = require(ReplicatedStorage.ECS.Components.Character).List

--Squash
-- create functions
local BufferToCursor = Squash.frombuffer
local CursorToBuffer = Squash.tobuffer
local NewCursor = Squash.cursor
-- numbers
local Double = Squash.number(8)
local Float = Squash.number(4)
local Uint = Squash.uint
local int = Squash.int
-- primitives
local bool = Squash.boolean()
local Str = Squash.string
-- luau
local enum = Squash.EnumItem(Enum.KeyCode)
local Table = Squash.table
-- vectors
local Vect3F32 = Squash.Vector3(Float)
local Vect2i16 = Squash.Vector2(int(2))
local Vect3 = Squash.Vector3
-- string
local ConvertStr = Squash.string.convert

--Variables
local UsernameAlphabet = "_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" -- all Possible characters of a roblox username

local ForceVelocitiesMap = Squash.map(
     Str(), Table({
          number = Float,
          Vector3 = Vect3F32
     }, 2)
)

local HeldKeysMap = Squash.map(enum, bool)

--Types
type Cursor = Squash.Cursor
type ComponentID = number

type ComponentName = string
export type SerdesTable = {
     serialize : (Value : any) -> buffer,
     deserialize : (Buffer : buffer) -> any,
     bytespan : number?
}

return table.freeze({
     --Forces
     [Components.ForceVelocities] = table.freeze({
          serialize = function(Velocities : {[string] : {number | Vector3}}) : buffer
               local Cursor : Cursor = NewCursor()
               ForceVelocitiesMap.ser(Cursor, Velocities)

               return CursorToBuffer(Cursor)
          end,

          deserialize = function(Buffer : buffer) : {[string] : {number | Vector3}}
               return ForceVelocitiesMap.des(BufferToCursor(Buffer))
          end
     }),

     [Components.MoveVelocity] = table.freeze({
          serialize = function(Vector : Vector3) : buffer
               local Cursor : Cursor = NewCursor(12)

               Vect3F32.ser(Cursor, Vector)

               return CursorToBuffer(Cursor)
          end,

          deserialize = function(Buffer : buffer) : Vector3
               return Vect3F32.des(BufferToCursor(Buffer))
          end,

          bytespan = 12
     }),

     [Components.Gravity] = table.freeze({
          serialize = function(Value : number) : buffer
               local Cursor : Cursor = NewCursor(3)
               Uint(3).ser(Cursor, Value * 10000)
               
               return CursorToBuffer(Cursor)
          end,

          deserialize = function(Buffer : buffer) : number
               return Uint(3).des(BufferToCursor(Buffer)) / 10000
          end,

          bytespan = 3
     }),

     --Gravity Variables
     [Components.GroundNormal] = table.freeze({
          serialize = function(Value : Vector3) : buffer
               local Cursor : Cursor = NewCursor(6)
               Vect3(Uint(2)).ser(Cursor, Value * 10000) -- <- value is a normalized vector. This saves the 4 first decimal places.

               return CursorToBuffer(Cursor)
          end,

          deserialize = function(Buffer : buffer) : Vector3
               return Vect3(Uint(2)).des(BufferToCursor(Buffer)) / 10000
          end,
          
          bytespan = 6
     }),

     [Components.AirTime] = table.freeze({
          serialize = function(Value : number) : buffer
               local Cursor : Cursor = NewCursor(2)
               int(2).ser(Cursor, Value * 10000)
               
               return CursorToBuffer(Cursor)
          end,

          deserialize = function(Buffer : buffer) : number
               return int(2).des(BufferToCursor(Buffer)) / 10000
          end,

          bytespan = 2
     }),
     
     --Player Input Data
     [Components.HeldKeys] = table.freeze({
          serialize = function(Keys : {[Enum] : boolean}) : buffer
               local Cursor : Cursor = NewCursor()
               HeldKeysMap.ser(Cursor, Keys)

               return CursorToBuffer(Cursor)
          end,

          deserialize = function(Buffer : buffer) : {[Enum] : boolean}
               return HeldKeysMap.des(BufferToCursor(Buffer))
          end
     }),

     [Components.LookVector] = table.freeze({
          serialize = function(Vector : Vector3) : buffer
               local Cursor : Cursor = NewCursor(4)
               Vect2i16.ser(Cursor, Vector2int16.new(
                    Vector.X * 10000,
                    Vector.Z * 10000
               ))

               return CursorToBuffer(Cursor)
          end,

          deserialize = function(Buffer : buffer) : Vector3
               local CompressedVector : Vector2int16 = Vect2i16.des(BufferToCursor(Buffer))
               return Vector3.new(
                    CompressedVector.X,
                    0,
                    CompressedVector.Y
               )
          end,

          bytespan = 4
     }),
     
     --Extra Values
     [Components.PlayerState] = table.freeze({
          serialize = function(State : number) : buffer
               local Cursor : Cursor = NewCursor(1)
               int(1).ser(Cursor, State)

               return CursorToBuffer(Cursor)
          end,

          deserialize = function(Buffer : buffer) : number
               return int(1).des(BufferToCursor(Buffer))
          end,

          bytespan = 1
     }),

     [Components.Player] = table.freeze({
          serialize = function(PlayerObject : Player) : buffer
               local Cursor : Cursor = NewCursor(8)
               Double.ser(Cursor, PlayerObject.UserId)

               return CursorToBuffer(Cursor)
          end,

          deserialize = function(Buffer : buffer) : Player
               return Players:GetPlayerByUserId(Double.des(BufferToCursor(Buffer)))
          end,

          bytespan = 8
     }),
     
     [Components.Name] = table.freeze({
          serialize = function(PlayerName : string) : buffer
               return buffer.fromstring( -- Turns string into buffer
                    ConvertStr( -- Compresses Name
                         PlayerName,
                         UsernameAlphabet, -- Alphabet of all possible characters in a username
                         Str.utf8
                    )
               )
          end,

          deserialize = function(Buffer : buffer) : string
               return ConvertStr( -- Decompresses name
                    buffer.tostring(Buffer), -- Converts buffer to string
                    Str.utf8,
                    UsernameAlphabet
               )
          end
     }),
}) :: {[ComponentID] : SerdesTable}