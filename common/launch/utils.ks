RUNONCEPATH("0:common/exceptions"). 
RUNONCEPATH("0:common/utils/listutils").
RUNONCEPATH("0:common/utils/colorPrintUtils").

Function GetConfirmation { 
    Parameter title.
    Parameter checkRangeViolations to false.

    ClearScreen.

    Print title.

    If checkRangeViolations { 
        Local clearForConfirmation to false. 
        Until clearForConfirmation { 
            Local rangeLimitKm to 669.
            Print "RANGE REQUIREMENT: " + rangeLimitKm.        
            If not RangeIsClear(rangeLimitKm) { 
                ClearScreen.
        
                Print TextColorRed("RANGE NOT CLEAR").
                Print TextColorRed("VIOLATIONS").
                Local rangeViolations to GetRangeViolations(rangeLimitKm).
                For violation in rangeViolations { 
                    Print "     (" + violation:Type + ") " + violation:Name + " " + violation:Distance + "km".
                }
            }
            Else {          

                ClearScreen.
                Print TextColorGreen("RANGE IS CLEAR").
                Print " ".
                Set clearForConfirmation to true. 
            }   
            Wait 1.
        }     
    }
    
    Print "CONFIRM INITIATION?: (Y)".
    Local goForLunch to false.
    Until goForLunch {         
        Local choice to Terminal:Input:GetChar().

        If choice = "Y" { 
            Print "INITIATION CONFIRMED".
            Set goForLunch to true.
            Set goForLunch to true.
        }
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

        Local shouldIgnore to otherVessel:Type = "Debris" or 
            otherVessel:Type = "DroppedPart" or
            otherVessel:Type = "Flag".
         
        If (otherVesselDistance < rangeLimitKm and (not shouldIgnore)) {
            Local violationInfo to Lexicon().

            Set violationInfo["Name"] to otherVessel:Name.
            Set violationInfo["Distance"] to Round(otherVesselDistance, 1).
            Set violationInfo["Type"] to otherVessel:Type.
            rangeViolations:Add(violationInfo).            
        }
    }

    return rangeViolations.
}

Function RangeIsClear { 
    Parameter rangeLimitKm.
    
    return GetRangeViolations(rangeLimitKm):Length() = 0.
}
