@LAZYGLOBAL OFF. 
Wait Until Ship:Unpacked. 

RUNONCEPATH("constants").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").

Local flightStatus to FlightStatusModel("MISSLE PRELAUNCH").

Local TARGET_VESSEL_NAME to "KBN-DS Just Add Moar Boosters".

Set TARGET to Vessel(TARGET_VESSEL_NAME).

GetLaunchConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.5).

flightStatus:AddField("STATUS", "AWAITING INITIATION").
Wait 1.

Stage. 
flightStatus:AddField("STATUS", "LAUNCH").
SetAlternateBootFile("missle").
Reboot.