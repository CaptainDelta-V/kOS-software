RUNONCEPATH("1:common/exceptions"). 
RUNONCEPATH("1:common/utils/listutils").

Function GetLaunchConfirmation { 
    Parameter title.
    Parameter checkRangeViolations to false.

    ClearScreen.

    Print title.
    Print "LAUNCH DIRECTOR GO/NOGO POLL".

    If checkRangeViolations { 
        Local clearForConfirmation to false. 
        Until clearForConfirmation { 
            Local rangeLimitKm to 669.
            Print "RANGE REQUIREMENT: " + rangeLimitKm.        
            If not RangeIsClear(rangeLimitKm) { 
                ClearScreen.
                Print "<color=#ff0026>RANGE NOT CLEAR</color>".
                Print "<color=#ff0026>VIOLATIONS:</color>".
                Local rangeViolations to GetRangeViolations(rangeLimitKm).
                For violation in rangeViolations { 
                    Print "     (" + violation:Type + ") " + violation:Name + " " + violation:Distance + "km".
                }
            }
            Else {             
                ClearScreen.
                Print "<color=#11ff00>RANGE IS CLEAR</color>".
                Print " ".
                Set clearForConfirmation to true. 
            }   
            Wait 1.
        }     
    }
    
    Print "CONFIRM GO FOR LAUNCH: (Y/N)".

    Local goForLunch to false.
    Local choice to Terminal:Input:GetChar().

    If choice = "Y" { 
        Print "LAUNCH CONFIRMED".
        Set goForLunch to true.
    }
    Else {
        Print "LAUNCH SCRUBBED. STANDING DOWN".
        Wait 5.
        Throw("LaunchScrubbedException").
    }

    Return goForLunch.
}

Function GetRangeViolations { 
    Parameter rangeLimitKm. 

    Local rangeViolations to List(). 

    Local allVessels is List().
    List targets in allVessels.
    For otherVessel in allVessels { 
        
        Local otherVesselDistance to (otherVessel:Position - Ship:Position):Mag / 1000.
        // Print otherVessel:Name + ": " + otherVesselDistance.
        

        Local shouldIgnore to otherVessel:Type = "Debris" or otherVessel:Type = "DroppedPart".
         
        If (otherVesselDistance < rangeLimitKm and (not shouldIgnore)) {
            Local violationInfo to Lexicon().

            Set violationInfo["Name"] to otherVessel:Name.
            Set violationInfo["Distance"] to Round(otherVesselDistance, 1).
            Set violationInfo["type"] to otherVessel:Type.
            rangeViolations:Add(violationInfo).            
        }
    }

    return rangeViolations.
}

Function RangeIsClear { 
    Parameter rangeLimitKm.
    
    return GetRangeViolations(rangeLimitKm):Length() = 0.
}
