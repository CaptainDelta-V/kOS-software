@LAZYGLOBAL OFF.
// RUNONCEPATH("0:common/constants").

Function AscentModel { 
    Parameter payloadMass.
    Parameter payloadCapacity.
    Parameter ascentPitchMin.
    Parameter ascentPitchMax.

    Function GetMinAscentPitch {         
        Local pitchRange to ascentPitchMax - Abs(ascentPitchMin).

        Local payloadPercent to payloadMass / payloadCapacity.
        Return payloadPercent * pitchRange.
    }

    Function TimeToApoapsis { 
        Return Ship:Orbit:ETA:Apoapsis.
    }

    Return Lexicon(
        "GetMinAscentPitch", GetMinAscentPitch@,
        "TimeToApoapsis", TimeToApoapsis@
    ).
}