@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
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
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/systems/drainValveManager").


Local flightStatus to FlightStatusModel("VULCAN SMART LANDING GUIDANCE").

RunFlightStatusScreen(flightStatus).

WAIT 7.
AG3 on.
RCS on.

Lock Steering to prograde.

flightStatus:Update("SMART DEPLOY").        

AG4 on.

Wait until altitude < 3_000.
AG5 on.
flightStatus:Update("CHUTE DEPLOY"). 
RCS Off.


When altitude < 1_000 then {
    AG6 on.
    Wait 1.
    AG9 on.
}

When altitude < 3 then {
    flightStatus:Update("SPLASHDOWN"). 
}


Wait until altitude < 2.
Set Ship:Control:PilotMainThrottle to 0.
flightStatus:Update("TERMINAL").
ClearVecDraws().
Shutdown.




Wait Until false.
