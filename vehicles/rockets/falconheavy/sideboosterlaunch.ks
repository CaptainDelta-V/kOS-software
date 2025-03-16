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

Parameter BoosterSide.

Local flightStatus to FlightStatusModel("FALCON HEAVY SIDE BOOSTER", "AWAITING SEPARATION").

RunFlightStatusScreen(flightStatus, 0.5).

Local stageSeparation to false. 
Until stageSeparation {
    If not Core:Messages:Empty { 
        If Core:Messages:Pop:Content = SIDE_BOOSTER_LANDING_INIT_MESSAGE { 
            Set stageSeparation to true. 
        }
    }

    Wait 0. 
}

flightStatus:Update("STAGE SEPARATION").
Wait 8. 
SetAlternatBootFile("boosterland").    
Reboot. 


Wait Until False. 