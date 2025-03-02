RUNONCEPATH("1:common/math").
RUNONCEPATH("1:common/nav").

Function LandingSteeringModel {
    Parameter LandingModel.
    Parameter ErrorScaling to 1.

    Local _maxAoA to 0.
    Local _minAoA to 0.
    Local _errorScaling to ErrorScaling.
    Local _targetAoARaw to 0.
    Local _targetAoACapped to 0.
    Local _steeringDirectionPitch to 0. 
    Local _steeringDirectionHeading to 0.

    Function SetMaxAoa { 
        Parameter aoA.        
        Set _maxAoA to aoA.         
    }

    Function SetMinAoA { 
        Parameter aoA.
        Set _minAoA to aoA.
    }

    Function GetMaxAoA { 
        Return _maxAoA.
    }

    Function GetMinAoA { 
        Return _minAoA.
    }

    Function GetTargetAoARaw { 
        Return _targetAoARaw.
    }

    Function GetTargetAoA { 
        Return _targetAoACapped.
    }

    Function GetSteeringDirectionPitch { 
        Return _steeringDirectionPitch.
    }

    Function GetSteeringDirectionHeading { 
        Return _steeringDirectionHeading.
    }

    Function SetErrorScaling { 
        Parameter scaling.
        Set _errorScaling to scaling.
    }

    Function GetErrorScaling {         
        Return _errorScaling.
    }

    Function SteeringVector { 
        Local referenceVector is -Ship:Velocity:Surface.
        Local errorVector is LandingModel:ErrorVector().        
        Local result is referenceVector + errorVector * _errorScaling.
        Set _targetAoARaw to VectorAngle(result, referenceVector).

        If Abs(_targetAoARaw) > Abs(_maxAoA)
        {
            Set result to referenceVector:Normalized
                            + Tan(_maxAoA) * errorVector:Normalized.
        }        
        If (Abs(_targetAoARaw) < Abs(_minAoA)) {
            Set result to referenceVector:Normalized
                            + Tan(_minAoA) * errorVector:Normalized.
        }

        Set _targetAoACapped to VectorAngle(result, referenceVector).

        return result.
    }

    Function SteeringVectorReferenceRadialOut { 
        
        Local referenceVector to RadialOutVectorNormalized().        
        Local errorVector is LandingModel:ErrorVector().        
        Local result is referenceVector + errorVector * _errorScaling.        

        Set _targetAoARaw to VectorAngle(errorVector, referenceVector).

        If Abs(_targetAoARaw) > Abs(_maxAoA)
        {
            Set result to referenceVector:Normalized
                            + Tan(_maxAoA) * errorVector:Normalized.
        }        
        If (Abs(_targetAoARaw) < Abs(_minAoA)) {
            Set result to referenceVector:Normalized
                            + Tan(_minAoA) * errorVector:Normalized.
        }

        Set _targetAoACapped to VectorAngle(result, referenceVector).        

        // Local rotate to AngleAxis(-180, Ship:Facing:UpVector).
        // Set result to result * rotate.
        // flip horizontally
        // Set result To V(-result:x, result:y, result:z).
        // vectorCrossProduct(ship:facing, ship:up)

        return result.
    }

    Function SteeringRadialOutCrossVector { 
        Local radialOut to (Ship:Body:Position - Ship:Position):Normalized. 
        Local targetDirection to (LandingModel:GetLandingSite():Position - Ship:Position):Normalized.

        Local projectionOntoRadialOut to (VectorDotProduct(targetDirection, radialOut)) * radialOut.
        Return (targetDirection - projectionOntoRadialOut):Normalized.
    }


    Function MaxAoADynamic { 
        Parameter minA.
        Parameter maxA.    
        Parameter errorMeters.
        Parameter rate.         
        Parameter invert is false.
        
        Local ret to Min(Max(LinearFunction(rate, errorMeters, minA), minA), maxA).
        If invert  { 
            Set ret to -ret.
        }
        Return ret.
    }


    Return Lexicon(
        "SetErrorScaling", SetErrorScaling@,
        "GetErrorScaling", GetErrorScaling@,
        "SteeringVector", SteeringVector@,
        "SteeringRadialOutCrossVector", SteeringRadialOutCrossVector@,
        "SteeringVectorReferenceRadialOut", SteeringVectorReferenceRadialOut@,
        "GetSteeringDirectionPitch", GetSteeringDirectionPitch@,
        "GetSteeringDirectionHeading", GetSteeringDirectionHeading@,
        "SetMaxAoa", SetMaxAoa@,
        "SetMinAoA", SetMinAoA@,
        "GetMaxAoA", GetMaxAoA@,
        "GetMinAoA", GetMinAoA@,
        "GetTargetAoA", GetTargetAoA@, 
        "GetTargetAoARaw", GetTargetAoARaw@,
        "MaxAoADynamic", MaxAoADynamic@
    ).
}