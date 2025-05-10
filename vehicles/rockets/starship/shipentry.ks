@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/orbit/hohmannTransferController").
RUNONCEPATH("../../../common/landing/deOrbitBurnController").

ClearScreen.
ClearVecDraws(). 

Local flightStatus to FlightStatusModel("STARSHIP ENTRY GUIDANCE", "AWAITING INITIATION").

flightStatus:AddField("ETA APOAPSIS", { return Ship:Orbit:ETA:Apoapsis. }).
flightStatus:AddField("ETA PERIAPSIS", { return Ship:Orbit:ETA:Periapsis. }).
// flightStatus:AddField("").

GetLaunchConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.5).

Local pitchMax to 75. 
Local pitchMin to 25. 

Local parkingOrbitIdeal to 87_000. 
Local parkingOrbitTolerance to 2_000.
Local parkingOrbitMinPeriapsis to parkingOrbitIdeal - parkingOrbitTolerance. 
Local parkingOrbitMaxApoapsis to parkingOrbitIdeal + parkingOrbitTolerance.

If Ship:Orbit:Periapsis > parkingOrbitMinPeriapsis and Ship:Orbit:Apoapsis > parkingOrbitMaxApoapsis { 
    flightStatus:Update("ESTABLISH PARKING ORBIT").
    Local hohmannTransfer to HohmannTransferController(flightStatus, parkingOrbitIdeal).
    hohmannTransfer:Engage(0.2, 0.05, 0.35, 60). // burnThrottle, finalizationThrottle, finalizationPercentage, alignmentMargin,
}
Else { 
    flightStatus:Update("ACCEPT CURRENT ORBIT AS PARKING").
}

Wait 2. 


flightStatus:Update("CREATE DEORBIT MNV.").

Local deorbit to DeOrbitBurnController(flightStatus, 0.2, 0.1, 0.3, 50).
Local landingSite to LatLng(-0.123942125673094,-74.4642469768736). // OLM
deorbit:DeOrbit(landingSite).

flightStatus:Update("PREPARING FOR THE HEAT").
RCS ON.

Lock Steering to Heading(HeadingOfVector(landingSite:Position - Ship:Geoposition:Position), 55, 0).

WAIT 20. 
RCS OFF.

Wait Until Ship:Velocity:Surface:Mag < 700. 
Lock Steering to Heading(HeadingOfVector(landingSite:Position - Ship:Geoposition:Position), -20, 0).



Wait Until False.