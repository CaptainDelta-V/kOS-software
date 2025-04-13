@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").

ClearScreen.

Local flightStatus to FlightStatusModel("STARSHIP LAUNCH", "BOOSTER RIDE").
RunFlightStatusScreen(flightStatus, 0.75).

Wait Until Altitude > 20_000.
flightStatus:Update("WAITING FOR ASCENT HANDOFF . . .").

Wait Until Not Core:Messages:Empty. 
Local message to Core:Messages:Pop. 

If message:Content = STARSHIP_ASCENT_HANDOFF_MESSAGE {     
    Wait Until Stage:Ready.
    Stage.            
    flightStatus:Update("BOOTING INTO ASCENT MODE").
    SetAlternateBootFile("starshipascent").
    Wait 0.
    Reboot. 
}
Else {    
    flightStatus:Update("WTF").
}

