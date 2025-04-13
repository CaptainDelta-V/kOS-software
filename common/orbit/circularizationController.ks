
Function CIRCULARIZATION_CONTROLLER {     

    Function CIRCULARIZE { 
        Parameter USE_PERIAPSIS.

        // Local TARGET_ALTITUDE 
        // If Not USE_PERIAPSIS { 

        // }
        // TODO: Create MANUEVER

        Local TIME_TO_NODE to Time:Seconds + Ship:Orbit:ETA:Apoapsis.
        Local MANV to NODE(TIME_TO_NODE).
        ADD MANV.

        // EXEC
    }

    Return Lexicon(
        "CIRCULARIZE", CIRCULARIZE@
    ).
}