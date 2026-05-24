@LAZYGLOBAL OFF.
RUNONCEPATH("0:common/nav").
RUNONCEPATH("0:common/landing/landingStatusModel").

// Helicopter hover-in-place: PD horizontal position-hold with velocity damping driving
// steering tilt, plus cascaded altitude → vs → throttle for vertical control. The caller
// owns the per-tick cadence (calls Update each tick) and exit handling (calls Stop before
// returning) — mirrors the StationKeepingModel pattern.
//
// Caller responsibility before Start():
//   - HasTarget is True (the getTarget closure assumes a valid Target on initial read).
//   - Control point already set to the rotor-thrust-aligned part ("control from here") so
//     Ship:Facing's ForeVector points along thrust and TopVector defines body yaw.
Global Function HeliHoverModel {
    Parameter getTarget.    // closure returning GeoCoordinates; only invoked when HasTarget.

    // Horizontal position controller. tan(tilt) = |a_h| / g; KD_POS damps surface velocity
    // directly so we don't need to differentiate position.
    Local KP_POS to 0.05.
    Local KD_POS to 0.35.
    Local MAX_TILT_DEG to 12.

    // Inner-loop PID on vertical speed. Outer-loop is a P-only altitude → vs converter
    // (see Update()) so altitude is the true setpoint; the inner loop just isolates throttle
    // from tilt-induced lift changes by tracking vs instead of altitude directly.
    Local pidVs to PidLoop(0.2, 0.3, 0.0, 0.05, 1.0).

    Local lastKnownTargetGeo to Ship:GeoPosition.
    Local landingStatus to LandingStatusModel(Ship:GeoPosition).
    Local initialTopRef to V(1, 0, 0).
    Local targetAltitude to 0.

    // LOCK targets — Update() writes to these each tick, the LOCKs read them.
    Local currentSteeringDir to LookDirUp(Up:Vector, V(1, 0, 0)).
    Local calcThrottle to 0.0.

    Local enabled to False.

    Function GetHoverSite {
        // Re-read live target each tick if available; fall back to last known position so
        // a transient HasTarget=False (e.g. Kerbal EVA clearing source vessel's target)
        // doesn't crash on Target:GeoPosition or jump the hover point.
        If HasTarget {
            Set lastKnownTargetGeo to getTarget:Call().
        }
        Return lastKnownTargetGeo.
    }

    Function Start {
        // No target → hover in place at current GeoPosition. With a target → track it.
        If HasTarget {
            Set lastKnownTargetGeo to getTarget:Call().
        } Else {
            Set lastKnownTargetGeo to Ship:GeoPosition.
        }
        Set landingStatus to LandingStatusModel(lastKnownTargetGeo).
        landingStatus:SetUsePositionOverTrajectory(true).
        // Horizontal projection of the body-top direction so yaw doesn't follow tilt.
        Set initialTopRef to VectorExclude(Up:Vector, Ship:Facing:TopVector):Normalized.
        Set targetAltitude to Ship:Altitude.
        Set calcThrottle to 0.0.
        Set currentSteeringDir to LookDirUp(RadialOutVectorNormalized(), initialTopRef).
        SAS OFF.
        Lock Steering to currentSteeringDir.
        Lock Throttle to calcThrottle.
        Set enabled to True.
    }

    Function Update {
        If not enabled { Return. }

        landingStatus:SetLandingSite(GetHoverSite()).
        Local upVec to RadialOutVectorNormalized().
        Local posErrHoriz to VectorExclude(upVec, landingStatus:ErrorVector()).
        Local velHoriz to HorizontalVelocityVector().
        Local desiredAccel to (-posErrHoriz * KP_POS) - (velHoriz * KD_POS).
        Local steeringVec to upVec.
        If desiredAccel:Mag >= 0.001 {
            Local gLocal to Ship:Body:Mu / (Ship:Body:Radius + Ship:Altitude)^2.
            Local tiltAngle to Min(ArcTan2(desiredAccel:Mag, gLocal), MAX_TILT_DEG).
            Set steeringVec to upVec + Tan(tiltAngle) * desiredAccel:Normalized.
        }
        Set currentSteeringDir to LookDirUp(steeringVec, initialTopRef).

        Local altError to targetAltitude - Ship:Altitude.
        Local desiredVs to Max(-2.0, Min(2.0, altError * 0.5)).
        Set pidVs:Setpoint to desiredVs.
        Set calcThrottle to pidVs:Update(Time:Seconds, Ship:VerticalSpeed).
    }

    Function Stop {
        Set enabled to False.
        Unlock Steering.
        Unlock Throttle.
        SAS ON.
    }

    Function GetStatus {
        Local altErr to targetAltitude - Ship:Altitude.
        Return Lexicon(
            "positionErrorMeters", landingStatus:PositionErrorMeters(),
            "altError", altErr,
            "verticalSpeed", Ship:VerticalSpeed,
            "targetAltitude", targetAltitude,
            "currentAltitude", Ship:Altitude,
            "currentRadarAlt", Alt:Radar,
            "targetRadarAlt", Alt:Radar + altErr,
            "hasTarget", HasTarget,
            "enabled", enabled,
            "throttle", calcThrottle
        ).
    }

    Function AdjustTargetAltitude {
        Parameter delta.
        Set targetAltitude to targetAltitude + delta.
    }

    Return Lexicon(
        "Start", Start@,
        "Update", Update@,
        "Stop", Stop@,
        "GetStatus", GetStatus@,
        "AdjustTargetAltitude", AdjustTargetAltitude@
    ).
}
