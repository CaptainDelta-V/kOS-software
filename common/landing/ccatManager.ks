RUNONCEPATH("0:CCAT/ccat", False).

Function CCATManager { 
    Parameter messageTargetCpuName is "None".

    Local _ccat to Lexicon().
    Local _runStatus to "NOT RUNNING".

    Function GetCCAT { 
        Return _ccat.
    }

    Function SetTargetCpuName { 
        Parameter targetCpuName. 
        Set messageTargetCpuName to targetCpuName.
    }

    Function GetTargetCpuName { 
        Return messageTargetCpuName.
    }

    Function GetRunStatus{ 
        Return _runStatus.
    }

    Function IsRunning { 
        Return _runStatus = "RUNNING".
    }

    Function RunContinous { 
        // Print "CPU to receive trajectory: " + messageTargetCpuName.
        // Print "Continous processing should start . . .".
        // Wait 1. 
        // Set _runStatus to "RUNNING".
        Return CCAT( 
            False,
            "RKDP54",
            10,    
            True,
            1,
            False,
            False,
            True,
            True,
            3,
            "Linear",
            "Falcon Heavy Side Booster",
            ship:body
        ).        
    }

    Return Lexicon( 
        "GetCCAT", GetCCAT@, 
        "GetRunStatus", GetRunStatus@,
        "IsRunning", IsRunning@,
        "RunContinous", RunContinous@,
        "SetTargetCpuName", SetTargetCpuName@, 
        "GetTargetCpuName", GetTargetCpuName@
    ).
}