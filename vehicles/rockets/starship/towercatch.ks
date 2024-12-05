@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("constants").

ClearScreen.

Set Ship:Name to TOWER_VESSEL_NAME.
Local MECHAZILLA to Ship:PartsTagged(MECHAZILLA_TAG)[0].
Local MECHAZILLA_ANIMATE_MODULE to MECHAZILLA:GetModule("ModuleSLEAnimate").
Local MECHAZILLA_CONTROLLER_MODULE to MECHAZILLA:GetModule("ModuleSLEController").

Local flightStatus to FlightStatusModel("STARTOWER CATCH Control", "WAITING For CATCH COMMAND").
RunFlightStatusScreen(flightStatus).

Until false { 
    If Not Ship:Messages:Empty { 
        Local MESSAGE to Ship:Messages:Pop:Content.

        If MESSAGE = TOWER_CATCH_MESSAGE {                 
            flightStatus:Update("CLOSING MECHAZILLA GRABBY").
            Local CLOSE_ARMS_SUFFIX to "close arms".
            If MECHAZILLA_CONTROLLER_MODULE:HASEVENT(CLOSE_ARMS_SUFFIX) { 
                MECHAZILLA_CONTROLLER_MODULE:DoEvent(CLOSE_ARMS_SUFFIX).             
            }
        }
        Else If MESSAGE = TOWER_PRECATCH_MESSAGE { 
            flightStatus:Update("MECHAZILLA CLOSING").
            MECHAZILLA_CONTROLLER_MODULE:SETFIELD("arms open angle", 40).
        }
        Else If MESSAGE = TOWER_CATCH_DAMPEN_MESSAGE {
            MECHAZILLA_ANIMATE_MODULE:SETFIELD("target extension", 6).
            Wait 1.9.
            MECHAZILLA_ANIMATE_MODULE:SETFIELD("target speed", 1).
            MECHAZILLA_ANIMATE_MODULE:SETFIELD("target extension", 8).            
            Wait 1.
            MECHAZILLA_ANIMATE_MODULE:SETFIELD("target speed", 0.5).
            MECHAZILLA_ANIMATE_MODULE:SETFIELD("target extension", 9).                        

            Set Core:BootFilename to "".
            SHUTDOWN.
        }
        Else { 
            flightStatus:Update("RECEIVED INVALID MESSAGE").        
        }    
    }    

    Wait 0.1.
}

Wait Until false.