RUNONCEPATH("0:CCAT/ccat", False).

Function CCATManager { 
    Parameter messageTargetCpuName is "None".
    
    Local _isRunning to false.

    Function SetTargetCpuName { 
        Parameter targetCpuName. 
        Set messageTargetCpuName to targetCpuName.
    }

    Function GetTargetCpuName { 
        Return messageTargetCpuName.
    }

    Function IsRunning{ 
        Return _isRunning.
    }

    Function RunCCAT { 
        Parameter runContinous.
        Parameter targetDT.
        Parameter onTrajectoryCalculated to { Parameter traj. }.

        Set _isRunning to true.

        // Print "CPU to receive trajectory: " + messageTargetCpuName.
        // Print "Continous processing should start . . .".
        // Wait 1. 
        // Set _runStatus to "RUNNING".
        Return CCAT( 
            not runContinous,
            "RKDP54",
            targetDT,    
            True,
            1,
            False,
            False,
            False,
            False,
            3,
            "Linear",
            "Falcon Heavy Side Booster",
            ship:body, 
            onTrajectoryCalculated
        ).        
    }

    Return Lexicon( 
        "RunCCAT", RunCCAT@, 
        "IsRunning", IsRunning@,        
        "SetTargetCpuName", SetTargetCpuName@, 
        "GetTargetCpuName", GetTargetCpuName@
    ).
}