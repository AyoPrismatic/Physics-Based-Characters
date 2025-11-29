--Types
type PropertyName = string
type StateName = string

type int = number

local CollisionParams = RaycastParams.new()
CollisionParams.FilterType = Enum.RaycastFilterType.Include
CollisionParams.FilterDescendantsInstances = {workspace}
CollisionParams.RespectCanCollide = true
CollisionParams.CollisionGroup = "Game"

local CharacterProperties : {[PropertyName] : any} = table.freeze{
     CharacterRadius = 2.081,

     MaxSlopeAngle = math.rad(55), -- Vector3.Angle returns an angle in radians, so radians is used here
     CollisionEpsilon = 0.12,
     FloatHeight = 1.35,

     RateOfGravity = 196.2,

     JumpVelocityDecay = 5,
     JumpVelocity = 150,
     JumpDebounce = 0.25,

     MinForceVelocity = 5,

     ["CollisionParams"] = CollisionParams
}

local ComponentLimits : {[string] : any} = table.freeze{
     VelocityMagnitude = 1024,
     Gravity = 1000
}

local PlayerStates : {[StateName] : int} = table.freeze{
     Grounded = 1,
     Falling = 2,
}

return table.freeze{
     ["CharacterProperties"] = CharacterProperties,
     ["ComponentLimits"] = ComponentLimits,
     ["PlayerStates"] = PlayerStates
}