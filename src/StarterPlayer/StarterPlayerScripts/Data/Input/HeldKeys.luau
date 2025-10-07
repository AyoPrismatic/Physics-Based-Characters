--Services
local InputService = game:GetService('UserInputService')

local KeyStates : {Enum.KeyCode} = {
     [Enum.KeyCode.W] = false,
     [Enum.KeyCode.A] = false,
     [Enum.KeyCode.S] = false,
     [Enum.KeyCode.D] = false
}

local function InputBegan(Key : InputObject, IsTyping : boolean) : nil
     if IsTyping then return end

     if KeyStates[Key.KeyCode] ~= nil then
          KeyStates[Key.KeyCode] = true
     end
end

local function InputEnded(Key : InputObject, IsTyping : boolean) : nil
     if IsTyping then return end

     if KeyStates[Key.KeyCode] ~= nil then
          KeyStates[Key.KeyCode] = false
     end
end

InputService.InputBegan:Connect(InputBegan)
InputService.InputEnded:Connect(InputEnded)

return {
     IsKeyDown = function(Key : InputObject) : boolean?
          return KeyStates[Key]
     end
}