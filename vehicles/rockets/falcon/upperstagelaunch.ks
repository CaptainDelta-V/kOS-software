@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.

RUNONCEPATH("../../../common/exceptions").
RUNONCEPATH("../../../common/constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/landing/landingStatusModel").
RUNONCEPATH("../../../common/landing/landingSteeringModel").
RUNONCEPATH("../../../common/landing/landingBurnModel").
RUNONCEPATH("../../../common/landing/gridFinManager").
RUNONCEPATH("../../../common/landing/boostbackBurnController").
RUNONCEPATH("../../../common/flight/hover").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/launch/ascentModel").
RUNONCEPATH("../../../common/booting/bootUtils").

ClearScreen. 

Local flightStatus to FlightStatusModel("FALCON UPPER STAGE LAUNCH CONTROL","AWAITING HANDOFF").
// flightStatus:AddField().

RunFlightStatusScreen(flightStatus, 0.5).


When not Core:Messages:Empty Then { 
    Local message to Core:Messages:Pop:Content.
   
    flightStatus:Update("RECEIVED HANDOFF").
    Wait 1. 
    flightStatus:Update("REBOOTING FOR STAGING").
    Wait 6.
    SetAlternateBootFile("upperstageascent").
    Reboot.
}

Wait Until False.