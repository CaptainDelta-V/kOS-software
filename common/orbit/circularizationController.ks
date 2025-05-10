@LAZYGLOBAL OFF. 
RUNONCEPATH("0:common/seeking/seek").
RUNONCEPATH("0:common/orbit/manueverNodeManager").

Function CircularizationController { 
    Parameter flightStatus.
    Parameter circularizeAtApoapsis to false.

    Local circularizationNode to Node(Time:Seconds + 100, 0, 0, 1). // placeholder

    Function Engage { 
        Parameter burnThrottle.
        Parameter finalizationThrottle to 0.01.
        Parameter finalizationPercentage to 0.2.
        Parameter alignmentTimeMargin to 30.
        
        RemoveAllNodes().

        Local targetAltitude to 0.
        Local ascending to true. // is the target above the current node point
        Local getActual to { Return 0. }. // used for goal seeking

        If circularizeAtApoapsis { 
            Set circularizationNode to Node(Time:Seconds + Ship:Orbit:Eta:Apoapsis, 0,0, 0).
            Set targetAltitude to Ship:Orbit:Apoapsis.
            Set getActual to { Return circularizationNode:Orbit:Periapsis. }.
            Set ascending to true.
        }
        Else { 
            Set circularizationNode to Node(Time:Seconds + Ship:Orbit:Eta:Periapsis, 0,0, 0).
            Set targetAltitude to Ship:Orbit:Periapsis.
            Set getActual to { Return circularizationNode:Orbit:Apoapsis. }.
            Set ascending to false.
        }        

        flightStatus:AddField("CIRC. AT AP", circularizeAtApoapsis).
        flightStatus:AddField("TARGET ALTITUDE", targetAltitude).
        flightStatus:AddField("ASCENDING", ascending).
        
        Add circularizationNode.

        Local vectorAdjustment to { 
            parameter step.

            Set circularizationNode:Prograde to circularizationNode:Prograde + step.           
        }.                        

        Local manueverNodeController to ManueverNodeManager(flightStatus, circularizationNode, burnThrottle).
        manueverNodeController:AdjustToTarget(targetAltitude, getActual, vectorAdjustment, ascending).        
        Wait 2.
        flightStatus:Update("WARP TO BURN").
        manueverNodeController:WarpToAlignment(alignmentTimeMargin).
        manueverNodeController:Engage(finalizationThrottle, finalizationPercentage).        
        manueverNodeController:CleanUp().

        flightStatus:RemoveField("ASCENDING").
        flightStatus:RemoveField("INC").
    }

    Return Lexicon(
        "Engage", Engage@
    ).
}