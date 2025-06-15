

Function EntrySteeringModel { 
    Parameter LandingModel.

    Local _maxAoA to 0.
    Local _minAoA to 0.
    Local _errorScaling to ErrorScaling.
    Local _targetAoARaw to 0.
    Local _targetAoACapped to 0.
    Local _steeringDirectionPitch to 0. // no idea why here
    Local _steeringDirectionHeading to 0. // 

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

    Return Lexicon(        
        "SetMaxAoa", SetMaxAoa@,
        "SetMinAoA", SetMinAoA@,
        "GetMaxAoA", GetMaxAoA@,
        "GetMinAoA", GetMinAoA@
    ).
}