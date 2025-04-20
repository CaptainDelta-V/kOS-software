RUNONCEPATH("../../common/flight/hover").
RUNONCEPATH("../../common/exceptions").
RUNONCEPATH("../../common/constants").
RUNONCEPATH("../../common/landing/sites").
RUNONCEPATH("../../common/engineManager").
RUNONCEPATH("../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../common/landing/landingStatusModel").
RUNONCEPATH("../../common/landing/landingSteeringModel").
RUNONCEPATH("../../common/landing/landingBurnModel").
RUNONCEPATH("../../common/landing/gridFinManager").
RUNONCEPATH("../../common/landing/boostbackBurnController").
RUNONCEPATH("../../common/flight/hover").
RUNONCEPATH("../../common/infos").
RUNONCEPATH("../../common/control").
RUNONCEPATH("../../common/nav").
RUNONCEPATH("../../common/booting/bootUtils").
RUNONCEPATH("../../common/systems/drainValveManager").
RUNONCEPATH("../../common/launch/utils").

Local flightStatus to FlightStatusModel("HELICOPTER HOVER"). 
Local cockpitControlModule to Ship:PartsTagged("COCKPIT")[0]:GetModule("ModuleCommand").
Local upControlModule to Ship:PartsTagged("VERTICAL_CONTROL_POINT")[0]:GetModule("ModuleCommand").

RunFlightStatusScreen(flightStatus).

flightStatus:Update("WAITING FOR TARGET").

Wait Until HasTarget.

upControlModule:DoEvent("control from here").

Local hoverSite to Target:GeoPosition.
Local landingStatus to LandingStatusModel(hoverSite).
Local rotationReferenceOvershootSite is LandingStatusModel(hoverSite):Overshoot(500):GetLandingSite().
Local landingSteering is LandingSteeringModel(landingStatus). 
SAS OFF.
landingSteering:SetErrorScaling(8_000).


flightStatus:AddField("TARGET POSITION", { Return hoverSite. }).
flightStatus:AddField("TRAJECTORY ERROR (m)", landingStatus:TrajectoryErrorMeters@).
flightStatus:AddField("POSITION ERROR (m)", landingStatus:PositionErrorMeters@).

landingSteering:SetMaxAoA(-16).
Lock Steering to LookDirup(landingSteering:SteeringVectorReferenceRadialOut(), rotationReferenceOvershootSite:Position).            


// todo: turn down the torques, the aoa is probably ok.

When landingStatus:PositionErrorMeters() < 5 and landingStatus:TrajectoryErrorMeters() < 5 Then { 
    landingSteering:SetMaxAoA(-5).
    landingStatus:SetUsePositionOverTrajectory(true).
    // landingSteering:SetErrorScaling(2).
}

Local targetAltitude to Ship:Altitude.
flightStatus:AddField("TARGET ALT", targetAltitude).
RunAltitudeHold(targetAltitude, 400, 
        0.1, 0.2, 0, // PID
        0.35, 0.38, // Min/Max
        { Return False. },
        false).

Wait Until Terminal:Input:GetChar() = "E".
cockpitControlModule:DoEvent("control from here").
SAS ON.

