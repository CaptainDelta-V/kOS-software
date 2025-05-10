RUNONCEPATH("0:common/constants").
RUNONCEPATH("0:common/utils/colorPrintUtils").

Function PayloadModel { 
    Parameter vesselType.
    
    Function PayloadMass { 
        If vesselType = VESSEL_TYPE_STARSHIP { 
            Return 0.
        }
        If vesselType = VESSEL_TYPE_FALCON_HEAVY { 
            Return Ship:Mass - 1451.42.
        }
    }

    Function SideBoosterRTLSPossible { 
        // If vesselType = VESSLE
        Return true. 
    }

    Function CoreBoosterRTLSPossible { 

        Return vesselType = VESSEL_TYPE_STARSHIP.
    }

    Function Review { 
        ClearScreen.
        Print "==== PAYLOAD REVIEW ====".

        Print "Payload Mass: " + TextColor(PayloadMass() + "t", COLOR_WHITE).
        Print "Core RTLS: " + (Choose TextColorGreen("POSSIBLE") If CoreBoosterRTLSPossible() Else TextColorRed("NOT POSSIBLE")).
        Print "Side Booster RTLS: " + (Choose TextColorGreen("POSSIBLE") If SideBoosterRTLSPossible() Else TextColorRed("NOT POSSIBLE")).

        Print "CONFIRM (Y)".        
        Local goForLunch to false.

        Until goForLunch {         
            Local choice to Terminal:Input:GetChar().

            If choice = "Y" { 
                Print "PAYLOAD REVIEW COMPLETE".
                Wait 0.5.
                Set goForLunch to true.
            }
        }
    }

    Return Lexicon (
        "PayloadMass", PayloadMass@,
        "SideBoosterRTLSPossible", SideBoosterRTLSPossible@, 
        "CoreBoosterRTLSPossible", CoreBoosterRTLSPossible@,
        "Review", Review@
    ).
}
