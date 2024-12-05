@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("constants").

ClearScreen.

Local flightStatus to FlightStatusModel("STARTOWER LAUNCH Control", "WAITING FOR LAUNCH INITIATION").
RunFlightStatusScreen(flightStatus).

Until false { 
    If Not Core:Messages:Empty { 

        Local message to Core:Messages:Pop:Content.
        flightStatus:Update(message).        

        If message = TOWER_DELUGE_START_MESSAGE { 
            flightStatus:Update("STARTING WATER DELUGE").

            AG4 ON.
            AG3 ON. 
        }
        If message = TOWER_QD_RELEASE_MESSAGE { 
            flightStatus:Update("QD RELEASE").
            Local qdArm to Ship:PartsTagged(QD_ARM_TAG)[0].
            qdArm:GetModule("ModuleSLESequentialAnimate"):DoEvent("full retraction").
        }
        Else If message = TOWER_RELEASE_MESSAGE { 
            flightStatus:Update("CLAMPS RELEASE").
            
            Local olm to Ship:PartsTagged(OLM_TAG)[0].                        
            Wait 0.
            olm:GetModule("ModuleDockingNode"):DoEvent("undock").

            Wait 0.5.
            flightStatus:Update("SETTING BOOT FILE to CATCH.").
            SetAlternatBootFile("towercatch").
            Wait 8.

            // deluge off
            AG4 OFF.
            AG3 OFF. 
            Reboot.
        }
        Else { 
            flightStatus:Update("RECEIVED INVALID MESSAGE").
        }
    }
    
    Wait 0.
}

// Print TITLE.
// Print "WAITING For RELEASE COMMAND . . .".

// Wait Until Not Core:Messages:Empty.
// Local RECD_MSG to Core:Messages:Pop.    // Deluge message
// HANDLE_MESSAGE(RECD_MSG:Content).
// Wait Until Not Core:Messages:Empty.

// Wait Until false. 

// Function HANDLE_MESSAGE { 
//     Parameter Content. 
//     If Content = TOWER_DELUGE_START_MESSAGE { 
//                   
//     }
//     Else If Content = TOWER_RELEASE_MESSAGE { 

        // Local MECHAZILLA to Ship:PartsTagged(MECHAZILLA_TAG)[0]./S
        
        // Local OLM_PLATE to Ship:PartsTagged(OLM_PLATE_TAG)[0].               
        
//         Wait 0. 
//         Print "RELEASING OLM".

//     }
//     Else { 
//         Print "WTF DID YOU SEND ME BRUH".
//     }
// }
