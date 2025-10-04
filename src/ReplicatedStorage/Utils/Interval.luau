local function Timer(s: number)
    local Pin : number = nil :: any

    local function Throttle()
        if not Pin then
            Pin = os.clock()
        end

        local Elapsed = os.clock() - Pin > s
        if Elapsed then
            Pin = os.clock()
        end

        return Elapsed
    end

    return Throttle
end

local function Interval(IntervalsPerSecond : number)
     return Timer(1 / IntervalsPerSecond)
end

return Interval