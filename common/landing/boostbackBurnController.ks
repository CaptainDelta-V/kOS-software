RUNONCEPATH("1:common/control").
RUNONCEPATH("1:common/math").

Function BoostbackBurnController {     
    Parameter landingStatus.
    Parameter landingSteering.
    Parameter CourseCorrectionIterations to 1.

    Function Engage { 
        Parameter BoostbackPitch to 0.
        Parameter MinimumError to 10_000.
        Parameter ThrottleCurve to -1.        
        Parameter AbortAltitude to 50_000.  
        Parameter MinThrottle to 0.05.      
        
        Local courseCorrectionIdx to 1.
        Until courseCorrectionIdx > CourseCorrectionIterations {             
            Local initHeading to landingStatus:HeadingFromImpactToTarget().                

            Lock Steering to Heading(initHeading, BoostbackPitch).
            Wait 1.
            WaitUntilOriented(25, 50).
            Set initHeading to landingStatus:HeadingFromImpactToTarget().
            If ThrottleCurve = -1 {
                Lock Throttle to 1.            
            }
            Else { 
                Lock Throttle to LinearFallOff(0.00005, landingStatus:TrajectoryErrorMeters(), 1). 
            }
            Wait 0.1.        

            // Go until error increases or ship goes below abort altitude
            Local previousErrorMeters to landingStatus:TrajectoryErrorMeters() + 1.
            Until false {        

                Local errorCurrent is landingStatus:TrajectoryErrorMeters().                

                // Local minThrottle to 0.15.
                Local cutoffThrottle to Throttle - 0.01.
                If ((errorCurrent > previousErrorMeters OR Throttle < cutoffThrottle) and errorCurrent < MinimumError) 
                    or Ship:Altitude < AbortAltitude {    
                    Lock Throttle to 0.
                    Set courseCorrectionIdx to courseCorrectionIdx + 1.
                    Break.
                }

                Set previousErrorMeters to errorCurrent.
                Wait 0. 
            }
        }       
    }

    Return Lexicon( 
        "Engage", Engage@
    ).      
}