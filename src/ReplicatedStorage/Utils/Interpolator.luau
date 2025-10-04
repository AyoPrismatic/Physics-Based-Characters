--Types
type Frequency = number -- K1
type Damping = number -- K2
type Responsiveness = number -- K3

type DeltaTime = number

local Pi = math.pi

return {
     GenerateParameters = function(F : Frequency, D : Damping, R : Responsiveness) : (Frequency, Damping, Responsiveness)
          local v1 = (Pi * F) -- Value 1
          local v2 = 2 * v1 -- Value 2
          
          local Frequency = D / v1
          local Damping = 1 / math.pow(v2, 2)
          local Responsiveness = R * D / v2

          return Frequency, Damping, Responsiveness
     end,

     UpdateSystem = function(DT : DeltaTime, GoalPos : Vector3, Pos : Vector3, GoalVel : Vector3, Vel : Vector3, F : Frequency, D : Damping, R : Responsiveness)
          local StableDamping = math.max(D, DT*F, math.pow(DT, 2)/2 + DT*F/2)
          
          local NewPos = Pos + DT*Vel
          local NewVel = Vel + DT*(GoalPos + R*GoalVel - NewPos - F*Vel) / StableDamping
          
          return NewPos, NewVel
     end
}

