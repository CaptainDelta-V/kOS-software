@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.

RUNONCEPATH("0:common/constants").
RUNONCEPATH("0:common/infos").
RUNONCEPATH("0:common/flightStatus/flightStatusModel").
RUNONCEPATH("0:common/orbit/rendezvousModel").

ClearScreen.
ClearVecDraws().

Local flightStatus to FlightStatusModel("ORBITAL RENDEZVOUS", "PLANNING HOHMANN INTERCEPT").

flightStatus:AddField("ETA Apoapsis",   { Return Round(Ship:Orbit:ETA:Apoapsis, 2). }).
flightStatus:AddField("ETA Periapsis",  { Return Round(Ship:Orbit:ETA:Periapsis, 2). }).
flightStatus:AddField("OBT True Anom.", { Return Round(Ship:Orbit:TrueAnomaly, 2). }).
flightStatus:AddField("PER",            { Return Round(Ship:Orbit:Period, 1) + "s". }).

RunFlightStatusScreen(flightStatus).

Local rdvs to RendezvousModel(flightStatus).

flightStatus:AddField("Relative Inc.", { Return Round(rdvs:RelativeInclination(), 4). }).
flightStatus:AddField("Angle to AN",   { Return Round(rdvs:AngleToAN(), 4). }).
flightStatus:AddField("Angle to DN",   { Return Round(rdvs:AngleToDN(), 4). }).

Local plan to CreateHohmannInterceptNode().

If not plan:ok {
    flightStatus:Update("PLAN FAILED: " + plan:error).
    Wait Until False.
}

flightStatus:AddField("r1 (m)",          Round(plan:r1, 1)).
flightStatus:AddField("r2 (m)",          Round(plan:r2, 1)).
flightStatus:AddField("Phase now (deg)", Round(plan:phaseNowDeg, 2)).
flightStatus:AddField("Phase req (deg)", Round(plan:phaseReqDeg, 2)).
flightStatus:AddField("Synodic (s)",     Round(plan:synodicPeriod, 1)).
flightStatus:AddField("Wait to burn (s)", Round(plan:wait, 1)).
flightStatus:AddField("Burn UT",         Round(plan:burnTime, 1)).
flightStatus:AddField("TOF (s)",         Round(plan:tof, 1)).
flightStatus:AddField("Plan dv (m/s)",   Round(plan:deltaV, 3)).

flightStatus:AddField("ETA Node",  { If HasNode { Return Round(NextNode:Eta, 1). } Else { Return "n/a". } }).
flightStatus:AddField("Node dv",   { If HasNode { Return Round(NextNode:DeltaV:Mag, 3). } Else { Return "n/a". } }).

flightStatus:Update("NODE PLACED — REVIEW & EXECUTE").

Wait Until False.
