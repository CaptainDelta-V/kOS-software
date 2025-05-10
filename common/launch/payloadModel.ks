RUNONCEPATH("0:common/constants").
RUNONCEPATH("0:common/utils/colorPrintUtils").

Global PAYLOAD_CONFIG_FILEPATH to "1:payloadParam.json".
Global KEY_PAYLOAD_MASS to "PayloadMass".

Function PayloadModel { 
    Parameter vesselType.

    Local _payloadParams to Lexicon(
        KEY_PAYLOAD_MASS, -1
    ).
    
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

    Function CoreBoosterPreservationPossible { 

        // Return vesselType = VESSEL_TYPE_STARSHIP.
        Return true.    
    }

    Function Review { 
        ClearScreen.
        Print "==== PAYLOAD REVIEW ====".

        Print "Payload Mass: " + TextColor(PayloadMass() + "t", COLOR_WHITE).
        Print "Core Preservation Possible: " + (Choose TextColorGreen("POSSIBLE") If CoreBoosterPreservationPossible() Else TextColorRed("NOT POSSIBLE")).
        Print "Core RTLS: " + (Choose TextColorGreen("POSSIBLE") If CoreBoosterPreservationPossible() Else TextColorRed("NOT POSSIBLE")).
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

    Function WaitForPayloadMassMessage { 


        // When not 
        // WriteToVessel
    }

    Function WritePayloadConfig { 
                
        Local payloadParams to Lexicon(
            KEY_PAYLOAD_MASS, PayloadMass()
        ).
        WriteJson(payloadParams).
    }

    Function ReadPayloadConfig { 

        If Exists(PAYLOAD_CONFIG_FILEPATH) { 
            Set _payloadParams to ReadJson(PAYLOAD_CONFIG_FILEPATH).
        }
    }

    Function HasPayloadConfig { 
        return _payloadParams[KEY_PAYLOAD_MASS] > -1.
    }

    Return Lexicon (
        "PayloadMass", PayloadMass@,
        "SideBoosterRTLSPossible", SideBoosterRTLSPossible@, 
        "CoreBoosterPreservationPossible", CoreBoosterPreservationPossible@,
        "Review", Review@
    ).
}
