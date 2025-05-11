@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
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

Local boosterIndicator to "UNKNOWN".
Local flightStatus to FlightStatusModel("FALCON HEAVY SIDE BOOSTER ", "AWAITING IDENTIFICATION").
RunFlightStatusScreen(flightStatus, 0.5).

Local expend to false.

Local stageSeparation to false. 
Until stageSeparation {
    If not Core:Messages:Empty { 
        Local content to Core:Messages:Peek:Content.
        If content = SIDE_BOOSTER_LANDING_INIT_MESSAGE { 
            Set stageSeparation to true. 
            Core:Messages:Pop.
        }
        Else If content = INDICATOR_BOOSTER_LEFT or content = INDICATOR_BOOSTER_RIGHT {         
            flightStatus:Update("ASSIGNED AS " + content + " BOOSTER").     
            Set boosterIndicator to content.
            Core:Messages:Pop.
        }
        Else If Core:Messages:Peek:Content = BOOSTER_EXPEND_SIGNAL { 
            Set expend to true.
            Set receivedExpendMessage to true.
            Core:Messages:Pop.
        }    
        Else { 
            flightStatus:Update("RECEIVED INVALID MESSAGE: " + content).
        }
    }

    Wait 0. 
}

flightStatus:Update("STAGE SEPARATION").

Local altBootParams to Lexicon().
altBootParams:Add(KEY_BOOSTERSIDE, boosterIndicator).
altBootParams:Add(KEY_EXPEND_OPTION, expend).
SetAlternateBootFileWithParams("boosterland", altBootParams).  
Wait 2.
Reboot. 


Wait Until False. 