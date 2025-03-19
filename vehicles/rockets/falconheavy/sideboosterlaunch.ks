@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
RUNONCEPATH("../../../common/constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/landing/landingStatusModel"). 
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/launch/launchProfileModel").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("../../../common/utils/listutils").
RUNONCEPATH("../../../common/exceptions").

Local boosterSide to "UNKNOWN".
Local flightStatus to FlightStatusModel("FALCON HEAVY SIDE BOOSTER ", "AWAITING IDENTIFICATION").
RunFlightStatusScreen(flightStatus, 0.5).

Local stageSeparation to false. 
Until stageSeparation {
    If not Core:Messages:Empty { 
        Local content to Core:Messages:Pop:Content.
        If content = SIDE_BOOSTER_LANDING_INIT_MESSAGE { 
            Set stageSeparation to true. 
        }
        Else If content = INDICATOR_BOOSTER_LEFT or content = INDICATOR_BOOSTER_RIGHT { 
             
            flightStatus:Update("ASSIGNED AS " + content + " BOOSTER").            
        }    
        Else { 
            flightStatus:Update("RECEIVED INVALID MESSAGE: " + content).
        }
    }

    Wait 0. 
}

flightStatus:Update("STAGE SEPARATION").

Local altBootParams to Lexicon().
altBootParams:Add(KEY_BOOSTERSIDE, content).
SetAlternateBootFileWithParams("boosterland", altBootParams).  
Wait 2.
Reboot. 


Wait Until False. 