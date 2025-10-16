return table.freeze({
     --[[Vector2 Functions]]
     [2] = table.freeze({

     }),

     --[[Vector3 Functions]]
     [3] = table.freeze({
          ProjectOnPlane = function(Vector : Vector3, PlaneNormal : Vector3) : Vector3
               local SqrMag = PlaneNormal:Dot(PlaneNormal)

               if SqrMag <= 1e-3 then
                    return Vector
               else
                    local Dot = Vector:Dot(PlaneNormal)
                    return Vector3.new(
                         Vector.X - PlaneNormal.X * Dot / SqrMag,
                         Vector.Y - PlaneNormal.Y * Dot / SqrMag,
                         Vector.Z - PlaneNormal.Z * Dot / SqrMag
                    )
               end
          end,
     })
})