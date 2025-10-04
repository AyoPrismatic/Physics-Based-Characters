local RunService = game:GetService('RunService')
local Server = RunService:IsServer()

local function Collect(Event : RBXScriptSignal)
    local Storage = {}
    local MT = {}
    local Iter = function()
        local n = #Storage
        return function()
            if n <= 0 then
                MT.__iter = nil
                return nil
            end

            n -= 1
            return n + 1, unpack(table.remove(Storage, 1) :: any)
        end
    end

    if type(Event) == "function" then
        Event(function(...)
            table.insert(Storage, { ... })
            MT.__iter = Iter
        end)
    else
        if typeof(Event) ~= "RBXScriptSignal" then
            warn("Must be function or script signal!")
            return
        end
        
        Event:Connect(function(...)
            table.insert(Storage, { ... })
            MT.__iter = Iter
        end)
    end

    setmetatable(Storage, MT)
    return (Storage :: any) :: () -> (number, ...any)
end

return Collect