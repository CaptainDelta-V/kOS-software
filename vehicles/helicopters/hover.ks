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
SAS OFF.

// Live target — re-read each tick so a drifting capsule is followed.
Function GetHoverSite { Return Target:GeoPosition. }

Local landingStatus to LandingStatusModel(GetHoverSite()).
// Compare against ship's current GeoPosition (not a Trajectories impact prediction).
landingStatus:SetUsePositionOverTrajectory(true).

// Initial body-top projected to horizon. Holds yaw at the heading at start.
Local initialTopRef to VectorExclude(Up:Vector, Ship:Facing:TopVector):Normalized.

flightStatus:AddField("TARGET POSITION", GetHoverSite@).
flightStatus:AddField("POSITION ERROR (m)", landingStatus:PositionErrorMeters@).

// PD on horizontal position with velocity damping. tan(tilt) = |a_h| / g.
Local KP_POS to 0.05.
Local KD_POS to 0.35.
Local MAX_TILT_DEG to 12.

Function HoverSteeringVec {
    landingStatus:SetLandingSite(GetHoverSite()).
    Local upVec to RadialOutVectorNormalized().
    Local posErrHoriz to VectorExclude(upVec, landingStatus:ErrorVector()).
    Local velHoriz to HorizontalVelocityVector().
    Local desiredAccel to (-posErrHoriz * KP_POS) - (velHoriz * KD_POS).
    If desiredAccel:Mag < 0.001 { Return upVec. }
    Local gLocal to Ship:Body:Mu / (Ship:Body:Radius + Ship:Altitude)^2.
    Local tiltAngle to Min(ArcTan2(desiredAccel:Mag, gLocal), MAX_TILT_DEG).
    Return upVec + Tan(tiltAngle) * desiredAccel:Normalized.
}

Lock Steering to LookDirUp(HoverSteeringVec(), initialTopRef).

Local targetAltitude to Ship:Altitude.
flightStatus:AddField("TARGET ALT", targetAltitude).
flightStatus:AddField("ALT ERROR (m)", { Return targetAltitude - Ship:Altitude. }).

// Cascaded altitude control: outer loop converts alt error → vertical-speed setpoint,
// inner PID drives throttle to match vs. Decouples throttle from tilt-induced lift changes
// (a direct alt-PID's I-term winds up during high-tilt approach, then drives slow climb
// once the heli arrives at the target and tilt drops).
Function GetDesiredVerticalSpeed {
    Local altError to targetAltitude - Ship:Altitude.
    Return Max(-2.0, Min(2.0, altError * 0.5)).
}

RunVerticalSpeedHold(
    GetDesiredVerticalSpeed@,
    400,
    0.2, 0.3, 0.0,    // PID on vertical speed
    0.25,             // throttle min
    { Return 0.50. }, // throttle max
    { Return Ship:VerticalSpeed. },
    { Return False. }).

Wait Until Terminal:Input:GetChar() = "E".
cockpitControlModule:DoEvent("control from here").
SAS ON.
