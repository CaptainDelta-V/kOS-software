
RUNONCEPATH("1:common/constants").
RUNONCEPATH("1:common/exceptions").

Declare Global TUNDRA_ENGINE_MODULE_NAME to "ModuleTundraEngineSwitch".
Declare Global TUNDRA_ENGINE_SWITCH_NEXT to "next engine mode".
Declare Global TUNDRA_ENGINE_SWITCH_PREV to "previous engine mode".
Declare Global ENG_MODE_ALL to "All Engines".
Declare Global ENG_MODE_MID_INR to "Middle Inner".
Declare Global ENG_MODE_CTR to "Center Three".

Function EngineManager { 
    Parameter engine.    
    Parameter vesselType.    

    Local engineModule to "".
    
    If vesselType = VESSEL_TYPE_SUPER_HEAVY_BOOSTER { 
        Set engineModule to engine:GetModule(TUNDRA_ENGINE_MODULE_NAME).
    }
    Else If vesselType = VESSEL_TYPE_STARSHIP { 

    }

    Function SetEngineState { 
        Parameter state. 

        If vesselType = VESSEL_TYPE_SUPER_HEAVY_BOOSTER {         
            If state { 
                engineModule:DoAction("activate engine", true).
            }
            Else { 
                engineModule:DoAction("shutdown engine", true).
            }
        }
        Else If vesselType = VESSEL_TYPE_STARSHIP {
            Throw("Vessel type not supported.").
        }
        Else { 
            Throw("Vessel type not supported.").
        }
    }

    Function SetEngineMode { 
        Parameter targetMode.

        If vesselType = VESSEL_TYPE_SUPER_HEAVY_BOOSTER {             
            Local CURR_MODE is engineModule:GETFIELD("mode").            

            If CURR_MODE = ENG_MODE_ALL AND targetMode = ENG_MODE_MID_INR {     
                engineModule:DoEvent(TUNDRA_ENGINE_SWITCH_NEXT).
            }
            Else If CURR_MODE = ENG_MODE_MID_INR AND targetMode = ENG_MODE_CTR {
                engineModule:DoEvent(TUNDRA_ENGINE_SWITCH_NEXT).
            }
            Else If CURR_MODE = ENG_MODE_CTR AND targetMode = ENG_MODE_MID_INR {
                engineModule:DoEvent(TUNDRA_ENGINE_SWITCH_PREV).
            }
            Else If CURR_MODE = ENG_MODE_MID_INR AND targetMode = ENG_MODE_ALL { 
                engineModule:DoEvent(TUNDRA_ENGINE_SWITCH_PREV).
            }
        }
        Else If vesselType = VESSEL_TYPE_FALCON_BOOSTER { 
            Local currMode is engineModule:GETFIELD("mode").       

            If currMode = ENG_MODE_ALL AND targetMode = ENG_MODE_MID_INR {     
                engineModule:DoEvent(TUNDRA_ENGINE_SWITCH_NEXT).
            }
            Else If currMode = ENG_MODE_MID_INR AND targetMode = ENG_MODE_CTR {
                engineModule:DoEvent(TUNDRA_ENGINE_SWITCH_NEXT).
            }
            Else If currMode = ENG_MODE_CTR AND targetMode = ENG_MODE_MID_INR {
                engineModule:DoEvent(TUNDRA_ENGINE_SWITCH_PREV).
            }
            Else If currMode = ENG_MODE_MID_INR AND targetMode = ENG_MODE_ALL { 
                engineModule:DoEvent(TUNDRA_ENGINE_SWITCH_PREV).
            }
        }
        Else {         
            Throw("Not implemented").
        }
    }

    Function SetThrustLimit { 
        Parameter limit. 

        If vesselType = VESSEL_TYPE_SUPER_HEAVY_BOOSTER { 
            engine:GetModuleByIndex(1):SetField("thrust limiter", limit).
            engine:GetModuleByIndex(2):SetField("thrust limiter", limit).
            engine:GetModuleByIndex(3):SetField("thrust limiter", limit).
        }
    }

    Return Lexicon(         
        "SetEngineState", SetEngineState@,
        "SetEngineMode", SetEngineMode@, 
        "SetThrustLimit", SetThrustLimit@
    ).
}