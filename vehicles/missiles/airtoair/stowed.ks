

RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("constants").

ClearScreen. 

Local flightStatus to FlightStatusModel("AIM-8 MISSILE Control", "STOWED").
flightStatus:AddField("Ready", "YEP").

GET_LAUNCH_CONFIRMATION(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.25).

flightStatus:Update("MISSLE LAUNCH INITIATED").
Set BEEPER to GETVOICE(1).
BEEPER:PLAY( NOTE(400, 0.20) ).

SetAlternatBootFile("missleguidance").



