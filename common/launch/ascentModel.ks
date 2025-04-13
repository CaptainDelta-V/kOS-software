
@LAZYGLOBAL OFF.
// For 2nd Stages
Function AscentModel { 

    Function TimeToApoapsis { 
        Return Ship:Orbit:ETA:Apoapsis.
    }

    Return Lexicon(
        "TimeToApoapsis", TimeToApoapsis@
    ).
}