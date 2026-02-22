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

Wait 10.
flightStatus:Update("SMART SEP"). 
AG1 on.
AG3 on.
RCS on.

Wait 10.
Lock Steering to prograde.
flightStatus:Update("SMART DEPLOY").        
AG4 on.

Wait until altitude < 30_000.
RCS off.

When altitude < 3_000 then {
    AG5 on.
    flightStatus:Update("DROUGE DEPLOY"). 
}
   
When altitude < 1_000 then {
    AG6 on.
    flightStatus:Update("CHUTE DEPLOY").
    Wait 1.
    AG9 on.
}

Wait until altitude < 2.
Set Ship:Control:PilotMainThrottle to 0.
flightStatus:Update("TERMINAL").
ClearVecDraws().
Shutdown.




Wait Until false.
