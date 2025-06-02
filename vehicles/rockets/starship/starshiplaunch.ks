@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
RUNONCEPATH("0:common/landing/sites").
RUNONCEPATH("0:common/infos").
RUNONCEPATH("0:common/control").
RUNONCEPATH("0:common/nav").
RUNONCEPATH("0:common/booting/bootUtils").
RUNONCEPATH("0:common/launch/payloadModel").
RUNONCEPATH("0:common/flightStatus/flightStatusModel").

ClearScreen.

Local flightStatus to FlightStatusModel("STARSHIP LAUNCH", "BOOSTER RIDE").

// Local payload to PayloadModel(flightStatus, VESSEL_TYPE_STARSHIP).

// payload:CalculatePayloadMass().
// payload:WritePayloadConfigToDisk().
// payload:AddFlightStatus().

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

