
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/nav").
 
Local TARGET_VESSEL_NAME to "KBN-DS Just Add Moar Boosters".

Lock WHERE_IT_IS to Ship:GeoPosition.  

Local flightStatus to FlightStatusModel("MISSILE GUIDANCE COMPUTER SCENARIO").
RunFlightStatusScreen(flightStatus, 0.5).

flightStatus:AddField("WHERE IT is", { Return WHERE_IT_IS. }).

Wait 1.
SAS ON.
Wait 0. 
Set SASMODE to "RADIALOUT".

// SAS OFF. 
// Wait 0. 
// Lock Steering to Heading(216, 60, 180). 

Wait 8. 
Set TARGET to Vessel(TARGET_VESSEL_NAME).
Lock WHERE_IT_ISNT to TARGET:GeoPosition.
flightStatus:AddField("WHERE IT ISN'T", { Return WHERE_IT_ISNT. }).

Wait Until false. 