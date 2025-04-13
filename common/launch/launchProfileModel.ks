@LAZYGLOBAL OFF.

Function LaunchProfileModel { 
    Parameter Rate.
    Parameter HorizontalShift.
    Parameter VerticalShift.
    Parameter MaxPitchOver.

    Lock _altitudeScaled to Ship:Altitude / 1_000.

    Function AltitudeScaled { 
        Return _altitudeScaled.
    }

    Function PitchTarget {                        
        Local result to (Rate * (_altitudeScaled - HorizontalShift)) + VerticalShift.
        Return 90 - Min(MaxPitchOver, Max(result, 0)).
    }

    Function DynamicPressue { 
        Return Ship:Q.
    }

    Return Lexicon( 
        "AltitudeScaled", AltitudeScaled@,
        "PitchTarget", PitchTarget@,
        "DynamicPressue", DynamicPressue@
    ).
}