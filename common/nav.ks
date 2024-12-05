
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