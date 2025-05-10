RUNONCEPATH("0:common/control").
RUNONCEPATH("0:common/seeking/seek").

Function ManueverNodeManager { 
    Parameter flightStatus.
    Parameter mnvNode.
    Parameter burnThrottle.

    Local _burnDuration to 1. // subject to change, calculate once and use value here. 

    Function AdjustToTarget { 
        Parameter targetVal.
        Parameter getActual.
        Parameter vectorAdjustment. 
        Parameter increasing.

        flightStatus:AddField("MAX SHIP ACCEL", { Return Ship:MaxThrust / Ship:Mass. }).
        flightStatus:AddField("BURN ACCEL", GetBurnAccel()).
        flightStatus:AddField("BURN DURATION", { Return _burnDuration. }).
        flightStatus:AddField("ETA BURN START", { Return GetBurnStartEta(). }).
        flightStatus:AddField("ETA NODE", { Return mnvNode:Eta. }).

        Local step to 0.

        Local adjuster to {
            Local targetError to Abs(targetVal) - Abs(getActual:Call()).
            Set targetError to Abs(targetError).

            flightStatus:AddField("TARGET ERROR", { Return targetError. }).
        
            If targetError > 10_000 { 
                Set step to 2.
            }            
            Else If targetError > 5_000 { 
                Set step to 1.
            }
            Else If targetError > 1_000 { 
                Set step to 0.1.
            }

            If not increasing { 
                Set step to -Abs(step).
            }

            flightStatus:AddField("STEP", step).            
            vectorAdjustment:Call(step).
        }. 

        Local seek to Seeker(flightStatus).
        seek:To(targetVal, getActual, adjuster).
        flightStatus:Update("MANUEVER SET").       
        flightStatus:RemoveField("TARGET ERROR").
        flightStatus:RemoveField("STEP").          
    }

    Function CalculateBurnDuration { 
        setBurnDuration(GetBurnDuration()).
    }

    Function setBurnDuration {
        Parameter burnDuration.
        Set _burnDuration to burnDuration.
    }

    Function GetBurnDuration {         
        Local burnDuration to mnvNode:DeltaV:Mag / GetBurnAccel().

        Return burnDuration.
    }

    Function GetBurnStartEta { 
        Return mnvNode:Eta - (_burnDuration / 2).
    }

    Function GetBurnAccel {     
        Local shipMaxAccel to Ship:MaxThrust / Ship:Mass.
        Local burnAccel to shipMaxAccel * burnThrottle.

        Return burnAccel.
    }

    Function GetTimeForAlignment { 
        Parameter alignmentTimeMargin.

        Return mnvNode:Time - ((_burnDuration / 2) + alignmentTimeMargin).
    }

    Function WarpToAlignment { 
        Parameter alignmentTimeMargin.
        
        Local timeToWarpTo to GetTimeForAlignment(alignmentTimeMargin).
        flightStatus:AddField("MNV TIME", mnvNode:Time).
        flightStatus:AddField("TIME WARP TARGET", timeToWarpTo).

        Set KUniverse:TimeWarp:Mode to "RAILS".
        KUniverse:TimeWarp:WarpTo(timeToWarpTo).
        Wait 1.
    }

    Function Engage { 
        Parameter finalizationThrottle.
        Parameter finalizationPercent to 0.20.
        Parameter stopAtRemainingMagnitude to 0.2.

        Lock Steering to mnvNode:DeltaV.
        flightStatus:Update("BURN ALIGNMENT").

        Local timeToStart to Time:Seconds + Abs(GetBurnStartEta()).
        flightStatus:AddField("TIME TO START", timeToStart).
        flightStatus:AddField("ETA TO START", { Return timeToStart - Time:Seconds. }).

        Until Time:Seconds > timeToStart { 
            Wait 0.001.
        }

        flightStatus:Update("ENGAGE BURN").
        Lock Throttle to burnThrottle.
        
        Local finalizationThrottleSet to false.
        Local burnStopTime to Time:Seconds + _burnDuration.
        Local burnStop to false. 
        Local prevBurnMagError to mnvNode:DeltaV:Mag + 1.
        Until burnStop { 
            Local currentDeltaVMagError to mnvNode:DeltaV:Mag.
            Set burnStop to  currentDeltaVMagError > prevBurnMagError or currentDeltaVMagError < stopAtRemainingMagnitude.

            If (not finalizationThrottleSet) and ((burnStopTime - Time:Seconds) < _burnDuration * finalizationPercent) { 
                Lock throttle to finalizationThrottle.
                Set finalizationThrottleSet to true.
            }

            Set prevBurnMagError to currentDeltaVMagError.
            Wait 0.001.
        }        
        Lock Throttle to 0.         
        Unlock Steering.     
    }

    Function CleanUp { 
        Remove mnvNode.
        flightStatus:RemoveField("MAX SHIP ACCEL").
        flightStatus:RemoveField("BURN ACCEL").
        flightStatus:RemoveField("BURN DURATION").
        flightStatus:RemoveField("ETA BURN START").
        flightStatus:RemoveField("ETA NODE").
    }

    Return Lexicon ( 
        "AdjustToTarget", AdjustToTarget@,
        "CalculateBurnDuration", CalculateBurnDuration@,
        "GetBurnDuration", GetBurnDuration@,
        "GetBurnStartEta", GetBurnStartEta@, 
        "GetBurnAccel", GetBurnAccel@,
        "GetTimeForAlignment", GetTimeForAlignment@,
        "WarpToAlignment", WarpToAlignment@,
        "Engage", Engage@,
        "CleanUp", CleanUp@
    ).
}

Global Function RemoveAllNodes { 
    Until not HasNode { 
        Remove NextNode.
        Wait 0.
    }
}