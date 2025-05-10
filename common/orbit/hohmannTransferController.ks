RUNONCEPATH("0:common/control").
RUNONCEPATH("0:common/orbit/circularizationController"). 
RUNONCEPATH("0:common/orbit/manueverNodeManager").

Function HohmannTransferController { 
    Parameter flightStatus.
    Parameter targetAltitude. 

    Function Engage { 
        Parameter burnThrottle. 
        Parameter finalizationThrottle to 0.01.
        Parameter finalizationPercentage to 0.20.
        Parameter alignmentTimeMargin to 32.

        RemoveAllNodes().

        Local adjustmentBurnNode to Node(Time:Seconds, 0,0,0).
        Local ascending to true.
        Local vectorAdjustment to { 
            Parameter step.
            Set adjustmentBurnNode:Prograde to adjustmentBurnNode:Prograde + step.
        }.
        Local getActual to { Return 0.}.

        If targetAltitude < Ship:Orbit:Periapsis { 
            flightStatus:Update("RETRO AT APOAPSIS").
            Set ascending to false.
            Set adjustmentBurnNode to Node(Time:Seconds + Ship:Orbit:Eta:Apoapsis, 0, 0, 0).            
            Set getActual to { Return adjustmentBurnNode:Orbit:Periapsis. }.
        }
        Else If targetAltitude > Ship:Orbit:Apoapsis { 
            flightStatus:Update("PROGRADE AT PERIAPSIS").
            Set ascending to true. 
            Set adjustmentBurnNode to Node(Time:Seconds + Ship:Orbit:Eta:Periapsis, 0, 0, 0).
            Set getActual to { Return adjustmentBurnNode:Orbit:Apoapsis. }.
        }            

        Add adjustmentBurnNode.    

        Local manueverNodeController to ManueverNodeManager(flightStatus, adjustmentBurnNode, burnThrottle).
        manueverNodeController:AdjustToTarget(targetAltitude, getActual, vectorAdjustment, ascending).
        manueverNodeController:CalculateBurnDuration().
        
        Wait 2.
        flightStatus:Update("WARP TO BURN").
        manueverNodeController:WarpToAlignment(alignmentTimeMargin).
        manueverNodeController:Engage(finalizationThrottle, finalizationPercentage).
        manueverNodeController:CleanUp().

        flightStatus:Update("CIRCULARIZE").
        Local circularizeAtApoapsis to ascending.
        Local circularization to CircularizationController(flightStatus, circularizeAtApoapsis).
        circularization:Engage(burnThrottle, finalizationThrottle, finalizationPercentage).

        flightStatus:Update("CIRCULARIZATION COMPLETE").
        flightStatus:AddField("ECC", Ship:Orbit:Eccentricity).
    }

    Return Lexicon(
        "Engage", Engage@
    ).
}