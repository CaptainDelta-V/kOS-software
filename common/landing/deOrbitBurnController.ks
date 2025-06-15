RUNONCEPATH("0:common/control").
RUNONCEPATH("0:common/orbit/manueverNodeManager").
RUNONCEPATH("0:common/seeking/seek").
RUNONCEPATH("0:common/constants").

Function DeOrbitBurnController { 
    Parameter flightStatus.
    Parameter burnThrottle.
    Parameter finalizationThrottle to 0.01. 
    Parameter finalizationPercentage to 0.20.
    Parameter alignmentTimeMargin to 32.

    Function DeOrbit { 
        Parameter landingSite.

        RemoveAllNodes().
        Wait 0. 

        Local deorbitNode to Node(Time:Seconds + 100, 0,0,0).
        Add deorbitNode.

        Local targetDeOrbitPeriapsis to 20_000.
        Local acceptableTargetError to 50_000. // within 100km of target        

        Local getActualError to { 
            Return deorbitNode:Orbit:Periapsis.
        }.

        Local vectorAdjustment to { 
            Parameter step.
            Set deorbitNode:Prograde to deorbitNode:Prograde - step.
        }.

        Local manueverNodeController to ManueverNodeManager(flightStatus, deorbitNode, burnThrottle).
        manueverNodeController:AdjustToTarget(targetDeOrbitPeriapsis, getActualError, vectorAdjustment, true).
        manueverNodeController:CalculateBurnDuration().
        
        Set getActualError to { 
            Local errorMeters to 0.
            If Addons:TR:HasImpact { 
                Set errorMeters to (Addons:TR:ImpactPos:Position - landingSite:Position):Mag.
            }
            Else { 
                Set errorMeters to 999_999.
            }

            flightStatus:AddField("ITERATION ERROR METERS", errorMeters).

            Return errorMeters.
        }.

        Set deorbitNode:Time to deorbitNode:Time + Ship:Orbit:Period. 

        Local adjuster to { 
            Local step to 10.

            If getActualError() < 200_000 { 
                Set step to 2.
            }
            Else If getActualError() < 100_000 { 
                Set step to 1.
            }
            Else if getActualError() < 50_000 { 
                Set step to 0.5.
            }

            Set deorbitNode:Time to deorbitNode:Time + step.
        }.

        Local terminator to { 
            Return getActualError() < acceptableTargetError.
        }.

        flightStatus:Update("ADJUST DEORBIT TIME").
        flightStatus:AddField("MNV. TRAJECTORY ERROR", getActualError()).

        Local seek to Seeker(flightStatus).
        seek:To(acceptableTargetError, getActualError, adjuster, true, terminator).        
        flightStatus:Update("DEORBIT TIME SET").    
        Wait 2. 

        manueverNodeController:WarpToAlignment(alignmentTimeMargin).
        manueverNodeController:Engage(finalizationThrottle, finalizationPercentage).
        manueverNodeController:CleanUp().           
    }

    Function CleanUp { 
        flightStatus:RemoveField("MNV. TRAJECTORY ERROR").
    }

    Return Lexicon(
        "DeOrbit", DeOrbit@, 
        "CleanUp", CleanUp@
    ).
}