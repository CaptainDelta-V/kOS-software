
// TERMINAL 

Global flightStatus to "UNKNOWN".

Global Function DISPLAY_STATUS_IN_BACKGRound { 
    Parameter TITLE.
    Parameter UPDATE_RATE to 0.75.

    Until false { 
        ClearScreen.
        Print "==== " + TITLE + " ====".
        Print "FLIGHT STATUS: " + flightStatus.
        Wait UPDATE_RATE.
    }
}