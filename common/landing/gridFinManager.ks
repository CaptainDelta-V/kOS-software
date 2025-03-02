
@LAZYGLOBAL OFF.
RUNONCEPATH("1:common/constants").

Function GridFinManager { 

    Parameter gridFins. 
    Parameter vesselType.

    Function SetEnabled { 
        Parameter enable.

        If enable { 
            If vesselType = VESSEL_TYPE_SUPER_HEAVY_BOOSTER { 
                For fin In gridFins {             
                    fin:GetModule("ModuleControlSurface"):DoAction("activate roll control", true).
                    fin:GetModule("ModuleControlSurface"):DoAction("toggle pitch control", true).
                    fin:GetModule("ModuleControlSurface"):DoAction("activate yaw control", true).            
                }
            }
        }
        Else { 
            If vesselType = VESSEL_TYPE_SUPER_HEAVY_BOOSTER { 
                For fin In gridFins {             
                    fin:GetModule("ModuleControlSurface"):DoAction("deactivate roll control", true).
                    fin:GetModule("ModuleControlSurface"):DoAction("toggle pitch control", true).
                    fin:GetModule("ModuleControlSurface"):DoAction("deactivate yaw control", true).            
                }
            }
       }
    }

    Function SetAuthorityLimit { 
        Parameter limit. 

        For fin In gridFins {             
            fin:GetModule("ModuleControlSurface"):SetField("authority limiter", limit).
        }    
    }

    Return Lexicon(
        "SetEnabled", SetEnabled@,
        "SetAuthorityLimit", SetAuthorityLimit@
    ).
}