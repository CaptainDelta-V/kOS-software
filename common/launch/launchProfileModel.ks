@LAZYGLOBAL OFF.

Function LaunchProfileModel { 
    Parameter Rate.
    Parameter HorizontalShift.
    Parameter VerticalShift.
    Parameter MaxPitchOver.

    Local _maxPitchOver to MaxPitchOver.
    Lock _altitudeScaled to Ship:Altitude / 1_000.

    Function AltitudeScaled { 
        Return _altitudeScaled.
    }

    Function PitchTarget {                        
        Local result to (Rate * (_altitudeScaled - HorizontalShift)) + VerticalShift.
        Return 90 - Min(_maxPitchOver, Max(result, 0)).
    }

    Function DynamicPressue { 
        Return Ship:Q.
    }

    Function SetMaxPitchOver { 
        Parameter val.
        Set _maxPitchOver to val.
    }

    Function GetMaxPitchOver { 
        Return _maxPitchOver.
    }

    Return Lexicon(     
        "AltitudeScaled", AltitudeScaled@,
        "PitchTarget", PitchTarget@,
        "DynamicPressue", DynamicPressue@,
        "SetMaxPitchOver", SetMaxPitchOver@, 
        "GetMaxPitchOver", GetMaxPitchOver@
    ).
}