
Function HeadingOfVector {
	Parameter inputVector.

	Local East is VectorCrossProduct(Ship:Up:Vector, Ship:North:Vector).

	Local trigX is VectorDotProduct(Ship:NORTH:Vector, inputVector).
	Local trigY is VectorDotProduct(East, inputVector).

	Local result is ArcTan2(trigY, trigX).

	If result < 0 { Return 360 + result.} Else { Return result.}
}

Function PitchOfVector {
	Parameter VECT.

	Return 90 - VectorAngle(Ship:Up:Vector, VECT).
}

Function HorizontalVelocityVecto { 
	Local velocityVector is Ship:Velocity:Surface.
  	Local upVector is Up:Vector.
	
  	Return VectorExclude(upVector, velocityVector).
}

Function RadialOutVectorNormalized { 
	Return (Ship:Position - Body:Position):Normalized.
}

Function CurrentRoll { 
	Local upDir to Ship:Up:Vector.
	Local shipUp to Ship:Facing:UpVector.
	Local shipForward to Ship:Facing:Forevector.

	// Local projection to (shipUp - (shipUp))
}

// function  { 
// 	Parameter part. 

// 	Local partPosition to part:position.
// 	Local vesselPosition to ship:position.
// 	Local vesselRotation to ship:facing:vector.
// 	// Local worldPartPosition to vesselPosition + partPosition

// 	// Local HSIP to PART:Position.
// 	// Local Position
// }



Function GetDeltaBetweenHeadings {
    Parameter heading1, heading2, delta.
    
    // Calculate the difference between the two headings
    local diff is heading1 - heading2.
    
    // Normalize the difference into the range -180 to 180 degrees.
    // This formula subtracts 360 * floor((diff+180)/360) to bring diff within the range.
    local normalizedDiff is diff - 360 * floor((diff + 180) / 360).
    
    // Return true if the absolute difference is greater than delta, false otherwise.
    if abs(normalizedDiff) > delta {
        return true.
    }
    return false.
}

Function IsGeoPosWestOf {
    parameter pos1, pos2.
    
    // Calculate the difference in longitude between the two positions.
    // A positive normalized difference indicates that pos2 is east of pos1,
    // meaning that pos1 is to the west of pos2.
    local diff is pos2:lng - pos1:lng.
    
    // Normalize diff to the range -180 to 180 using a mathematical formula.
    local normalizedDiff is diff - 360 * floor((diff + 180) / 360).
    
    // Return true if pos1 is west of pos2, i.e., normalizedDiff > 0.
    if normalizedDiff > 0 {
        return true.
    }
    return false.
}