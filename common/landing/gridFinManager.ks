
@LAZYGLOBAL OFF.
RUNONCEPATH("0:common/constants").

Function GridFinManager { 

    Parameter gridFins. 
    Parameter vesselType.

    Function SetEnabled { 
        Parameter enable.

        If enable { 
            For fin In gridFins {             
                fin:GetModule("ModuleControlSurface"):DoAction("activate roll control", true).
                fin:GetModule("ModuleControlSurface"):DoAction("toggle pitch control", true).
                fin:GetModule("ModuleControlSurface"):DoAction("activate yaw control", true).            
            }
        }
        Else { 
            For fin In gridFins {             
                fin:GetModule("ModuleControlSurface"):DoAction("deactivate roll control", true).
                fin:GetModule("ModuleControlSurface"):DoAction("toggle pitch control", true).
                fin:GetModule("ModuleControlSurface"):DoAction("deactivate yaw control", true).            
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