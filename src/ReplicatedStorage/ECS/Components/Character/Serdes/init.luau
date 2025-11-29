--!optimize 2
--!native
--!strict

local Module = {}

--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Packages
local Replecs = require(ReplicatedStorage.Packages.Replecs)

--ECS
local Characters = require(ReplicatedStorage.ECS.Worlds.Characters)
local Components = require(ReplicatedStorage.ECS.Components.Character)

--Variables
local Methods = require(script.Methods)

--Types
type SerdesTable = Methods.SerdesTable

type ComponentIndex = number
type EntityIndex = number

--Serializing
function Module.Serialize(ComponentID : ComponentIndex, Value : any) : any?
     return Methods[ComponentID].serialize(Value)
end

function Module.TrySerializing(ComponentID : ComponentIndex, Value : any) : any?
     local SerdesData : SerdesTable? = Methods[ComponentID]
     if SerdesData then
          Value = SerdesData.serialize(Value)
     end

     return Value
end

function Module.SerializeAndSet(EntityID : EntityIndex, ComponentID : ComponentIndex, Value : any) : nil
     Characters:set(EntityID, ComponentID, Module.Serialize(ComponentID, Value))
end

local Replication_SerializePlaceholder = function(AlreadySerializedBuf : buffer) : buffer
     return AlreadySerializedBuf -- Server already stores it in a serialized form so we don't need to serialize when replicating
end

--Deserializing
function Module.Deserialize(ComponentID : ComponentIndex, Value : any) : any?
     return Methods[ComponentID].deserialize(Value)
end

function Module.TryDeserializing(ComponentID : ComponentIndex, Value : any) : any?
     local SerdesData : SerdesTable? = Methods[ComponentID]
     if SerdesData then
          Value = SerdesData.deserialize(Value)
     end

     return Value
end

function Module.GetDeserialized(EntityID : EntityIndex, ComponentID : ComponentIndex) : any?
     return Module.Deserialize(ComponentID, Characters:get(EntityID, ComponentID))
end

local Replication_DeserializePlaceholder = function(SerializedBuf : buffer) : buffer
     return SerializedBuf -- Server already stores it in a serialized form so we don't need to serialize when replicating
end

--Serdes Setup
for ComponentID : ComponentIndex, _ in Components.SharedComponents do
     local SerdesData : SerdesTable = Methods[ComponentID]
     if SerdesData then
          local ReplicationSerdesData = {
               serialize = Replication_SerializePlaceholder, -- Server already stores it in a serialized form so we don't need to serialize when replicating
               deserialize = Replication_DeserializePlaceholder -- The client will purposfully handle deserializing on it's own when using values.
          }

          if SerdesData["bytespan"] then
               ReplicationSerdesData["bytespan"] = SerdesData.bytespan
          end

          Characters:set(ComponentID, Replecs.Serdes, -- Serdes Placeholders lets us send buffers without Replecs bitching about it
               table.freeze(ReplicationSerdesData)
          )
     end
end

return Module