RUNONCEPATH("1:common/control").
RUNONCEPATH("1:common/math").
RUNONCEPATH("1:common/flight/flightControlModel").

Function BoostbackBurnController {     
    Parameter landingStatus.
    Parameter landingSteering.
    Parameter CourseCorrectionIterations to 1.

    Function Engage { 
        Parameter boostbackPitch to 0.
        Parameter minimumError to 10_000.
        Parameter throttleCurveCode to -1.        
        Parameter abortAltitude to 50_000.  
        Parameter minThrottle to 0.05.
        Parameter orientationAngleErrorThreshold to 2. 
        Parameter orientationAngleMagThreshold to 2.
        Parameter assumeOriented to false.
        Parameter supplementalCheckFn to { return false. }.
        
        Local courseCorrectionIdx to 1.
        Until courseCorrectionIdx > CourseCorrectionIterations {             
            // Local initHeading to                 /

            Lock Steering to Heading(landingStatus:HeadingFromImpactToTarget(), boostbackPitch).
            Wait 1.
            If not assumeOriented { 
                WaitUntilOriented(orientationAngleErrorThreshold, orientationAngleMagThreshold).
            }

            Set initHeading to landingStatus:HeadingFromImpactToTarget().

            If throttleCurveCode = 1 {
                Lock Throttle to LinearFallOff(0.00005, landingStatus:TrajectoryErrorMeters(), 1). 
            }
            Else If throttleCurveCode = 2 {                 
                Lock Throttle to FalloffThrottle(landingStatus:TrajectoryErrorMeters(), 70_000, 0.03).                    
            }            

            Local minBoostbackDuration to 8. 
            Local minTimeEnd to Time:Seconds + minBoostbackDuration.
            
            
            // Go until error increases or ship goes below abort altitude
            Local previousErrorMeters to landingStatus:TrajectoryErrorMeters() + 1.
            Until false {        

                Local errorCurrent is landingStatus:TrajectoryErrorMeters().
                Local currentHeadingImpactToTarget to landingStatus:HeadingFromImpactToTarget().

                // Local minThrottle to 0.15.
                Local cutoffThrottle to Throttle - 0.01.
                If ((errorCurrent > previousErrorMeters and errorCurrent < minimumError) 
                    or GetDeltaBetweenHeadings(initHeading, currentHeadingImpactToTarget, 10)
                    or (Ship:Altitude < abortAltitude and Ship:VerticalSpeed < 0) 
                    or IsGeoPosWestOf(landingStatus:GetImpact(), landingStatus:GetLandingSite())
                    or supplementalCheckFn:Call()) {    
                    Lock Throttle to 0.
                    Set courseCorrectionIdx to courseCorrectionIdx + 1.
                    Break.
                }

                Set previousErrorMeters to errorCurrent.
                Wait 0.01.
            }
            Wait Until Throttle < 0.07.
        }       
    }

    Return Lexicon( 
        "Engage", Engage@
    ).      
}