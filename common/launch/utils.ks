RUNONCEPATH("1:common/exceptions"). 

Function GET_LAUNCH_CONFIRMATION { 
    Parameter TITLE.

    ClearScreen.
    Print TITLE.
    Print "LAUNCH DIRECTOR, CONFIRM GO FOR LAUNCH: (Y/N)".

    Local GO_FOR_LAUNCH to false.
    Local CHOICE to TERMINAL:INPUT:GETCHAR().

    If CHOICE = "Y" { 
        Print "LAUNCH CONFIRMED".
        Set GO_FOR_LAUNCH to true.
    }
    Else {
        Print "LAUNCH SCRUBBED. STANDING DOWN".
        Wait 5.
        Throw("LaunchScrubbedException").
    }

    Return GO_FOR_LAUNCH.
}
