@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/landing/mechazillaCatchArmsModel").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("constants").

ClearScreen.

Set Ship:Name to TOWER_VESSEL_NAME.
Local Mechazilla to Ship:PartsTagged(MECHAZILLA_TAG)[0].
Local MechazillaAnimModule to Mechazilla:GetModule("ModuleSLEAnimate").
Local MechazillaControllerModule to Mechazilla:GetModule("ModuleSLEController").
Local ActiveBooster to Ship. // default self

If (not HasVessel(ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME)) {
    Print "No target booster detected. Probably still launching.".    
    Wait Until False.
}

Set ActiveBooster to Vessel(ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME).

Local flightStatus to FlightStatusModel("STARTOWER CATCH CONTROL", "WAITING FOR CATCH COMMAND").
RunFlightStatusScreen(flightStatus).

Local mechazillaCatchArms to MechazillaCatchArmsModel(Mechazilla, MechazillaControllerModule).

WAIT 2.
mechazillaCatchArms:ArmForCatch().  

Until false { 
    If Not Ship:Messages:Empty { 
        Local message to Ship:Messages:Pop:Content.

        If message = TOWER_CATCH_MESSAGE {                 
            flightStatus:Update("CLOSING MECHAZILLA").
            Local CLOSE_ARMS_SUFFIX to "close arms".
            Local headingToTarget to HeadingOfVector(ActiveBooster:Geoposition:Position - Ship:Geoposition:Position).
            mechazillaCatchArms:AlignToHeading(headingToTarget).              
            If MechazillaControllerModule:HasEvent(CLOSE_ARMS_SUFFIX) { 
                MechazillaControllerModule:DoEvent(CLOSE_ARMS_SUFFIX).             
            }
        }
        Else If message = TOWER_PRECATCH_MESSAGE { 
            flightStatus:Update("MECHAZILLA PRECATCH").
            Local headingToTarget to HeadingOfVector(ActiveBooster:Geoposition:Position - Ship:Geoposition:Position).           
            mechazillaCatchArms:AlignToHeading(headingToTarget).              
        }
        Else If message = TOWER_ARMS_ALIGN_MESSAGE { 
            flightStatus:Update("ARMS ALIGNMENT").
            Local headingToTarget to HeadingOfVector(ActiveBooster:Geoposition:Position - Ship:Geoposition:Position).
            mechazillaCatchArms:AlignToHeading(headingToTarget).              
        }
        Else If message = TOWER_CATCH_DAMPEN_MESSAGE {
            mechazillaCatchArms:LowerLandingRails().

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