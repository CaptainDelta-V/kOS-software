RUNONCEPATH("0:common/constants").
RUNONCEPATH("0:common/utils/colorPrintUtils").

Global PAYLOAD_CONFIG_FILEPATH to "1:payloadParams.json".
Global KEY_PAYLOAD_MASS to "PayloadMass".

Function PayloadModel { 
    Parameter flightStatus.
    Parameter vesselType.

    Local _payloadParams to Lexicon(
        KEY_PAYLOAD_MASS, -1
    ).

    Function AddFlightStatus { 
        flightStatus:AddField("Vessel Type", vesselType).
        flightStatus:AddField("Payload Mass", Round(PayloadMass(), 2) + "t").
        flightStatus:AddField("Payload Capacity", Round(PayloadCapacity(), 2) + "t").
        flightStatus:AddField("Payload Utilization", Round(100 * PayloadPercent(), 2) + "%").
    }

    Function CalculatePayloadMass { 
        If vesselType = VESSEL_TYPE_STARSHIP { 
            Set _payloadParams[KEY_PAYLOAD_MASS] to 0.
        }
        If vesselType = VESSEL_TYPE_FALCON_HEAVY {     
            Set _payloadParams[KEY_PAYLOAD_MASS] to Ship:Mass - 1451.42.
        }    
        If vesselType = VESSEL_TYPE_FALCON_9 { 
            Set _payloadParams[KEY_PAYLOAD_MASS] TO Ship:Mass -  1173.345.
        }

        If _payloadParams[KEY_PAYLOAD_MASS] < 0 { 
            Throw("PAYLOAD MASS: " + _payloadParams[KEY_PAYLOAD_MASS] +  "t IS NEGATIVE").
        }    
    }
    
    Function PayloadMass { 
        If _payloadParams[KEY_PAYLOAD_MASS] < 0 {
            Throw("PAYLOAD MASS NOT CALCULATED").
        }
        Return _payloadParams[KEY_PAYLOAD_MASS].        
    }

    Function PayloadCapacity { 
        If vesselType = VESSEL_TYPE_FALCON_HEAVY { 
            Return 28.
        }
        If vesselType = VESSEL_TYPE_FALCON_9 { 
            Return 14.
        }

        Throw("Not Implemented").
    }

    Function PayloadPercent { 
        Return PayloadMass() / PayloadCapacity().
    }

    Function SideBoosterRTLSPossible { 
        // If vesselType = VESSLE
        If vesselType = VESSEL_TYPE_FALCON_HEAVY { 
            Return PayloadMass() < 19.
        }
        Return true. 
    }

    Function CoreBoosterPreservationPossible { 

        // Return vesselType = VESSEL_TYPE_STARSHIP.
        // If 
        // FH can do 16.38t core recovery with side booster recovery
        
        Return true.    
    }

    Function Review { 
        ClearScreen.
        Print "==== PAYLOAD REVIEW ====".

        Print "Payload Mass: " + TextColor(ROUND(PayloadMass(), 2) + "t", COLOR_WHITE).
        Print "Core Preservation Possible: " + (Choose TextColorGreen("POSSIBLE") If CoreBoosterPreservationPossible() Else TextColorRed("(maybe) POSSIBLE")).
        Print "Core RTLS: " + (Choose TextColorGreen("POSSIBLE") If CoreBoosterPreservationPossible() Else TextColorRed("(maybe) POSSIBLE")).
        Print "Side Booster RTLS: " + (Choose TextColorGreen("POSSIBLE") If SideBoosterRTLSPossible() Else TextColorRed("(maybe) POSSIBLE")).

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

    Function SetPayloadMass { 
        Parameter pm.
        Set _payloadParams[KEY_PAYLOAD_MASS] to pm.
    }

    Function GetPayloadConfig { 
        Return Lexicon(
            KEY_PAYLOAD_MASS, PayloadMass()
        ).
    }

    Function WritePayloadConfigToDisk { 
        WriteJson(GetPayloadConfig(), PAYLOAD_CONFIG_FILEPATH).
    }

    Function ReadPayloadConfigFromDisk { 
        If Exists(PAYLOAD_CONFIG_FILEPATH) { 
            Set _payloadParams to ReadJson(PAYLOAD_CONFIG_FILEPATH).
        }
        Else { 
            Throw("PAYLOAD CONFIG NOT ON DISK WTF").
        }
    }

    Function HasPayloadConfigOnDisk { 
        ReadPayloadConfigFromDisk().
        return _payloadParams[KEY_PAYLOAD_MASS] > -1.
    }

    Return Lexicon (
        "AddFlightStatus", AddFlightStatus@,
        "CalculatePayloadMass", CalculatePayloadMass@,
        "PayloadMass", PayloadMass@,
        "PayloadCapacity", PayloadCapacity@,
        "PayloadPercent", PayloadPercent@,
        "SideBoosterRTLSPossible", SideBoosterRTLSPossible@, 
        "CoreBoosterPreservationPossible", CoreBoosterPreservationPossible@,
        "Review", Review@,
        "SetPayloadMass", SetPayloadMass@,
        "GetPayloadConfig", GetPayloadConfig@, 
        "WritePayloadConfigToDisk", WritePayloadConfigToDisk@, 
        "ReadPayloadConfigFromDisk", ReadPayloadConfigFromDisk@,        
        "HasPayloadConfigOnDisk", HasPayloadConfigOnDisk@
    ).
}
