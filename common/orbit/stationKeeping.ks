RUNONCEPATH("0:common/seeking/pidModel").

// Holds station relative to a target DockingPort: anti-parallel facing,
// 3-axis position lock on the port's approach axis, RCS translation.
// Setpoints are captured at Start() in the *port's* local frame (axial / top / star scalars)
// so they rotate with the target — any RCS-induced or natural target rotation is tracked
// instead of leaving the controller chasing a stale world-frame axis.
Global Function StationKeepingModel {
    Parameter targetPort.

    // Setpoints in port-local frame.
    Local axialSetpoint to 0.   // distance along PortFacing:Vector
    Local topSetpoint   to 0.   // offset along PortFacing:TopVector
    Local starSetpoint  to 0.   // offset along PortFacing:StarVector

    Local aligning to False.
    Local lateralVelMaxLocal to 1.0.
    Local axialVelMaxLocal to 1.0.

    // Lateral hold-mode positional PIDs — fine for small drifts off the captured lateral offset.
    Local starPid to PidModel(0.7, 0, 0.6, -1, 1).
    Local topPid  to PidModel(0.7, 0, 0.6, -1, 1).
    // Velocity-loop PIDs (axial always, lateral in align mode).
    // kP=1.0 → 1 m/s velocity error saturates translation; smaller errors ramp proportionally.
    Local foreVelPid to PidModel(1.0, 0, 0, -1, 1).
    Local starVelPid to PidModel(1.0, 0, 0, -1, 1).
    Local topVelPid  to PidModel(1.0, 0, 0, -1, 1).

    Local enabled to False.

    // alignToAxis=True drops the lateral setpoint to zero so the ship slides onto the port's
    // approach axis. lateralVelMax / axialVelMax (m/s) cap the cascaded closing speeds so the
    // controller doesn't overshoot when the offset is large.
    Function Start {
        Parameter alignToAxis is False.
        Parameter lateralVelMax is 1.0.
        Parameter axialVelMax is 1.0.

        Local portFwd to targetPort:PortFacing:Vector:Normalized.
        Local portUp  to targetPort:PortFacing:TopVector:Normalized.
        Local portRt  to targetPort:PortFacing:StarVector:Normalized.
        Local initialOffset to targetPort:NodePosition.

        Set axialSetpoint to VDOT(initialOffset, portFwd).
        If alignToAxis {
            Set topSetpoint  to 0.
            Set starSetpoint to 0.
        } Else {
            Set topSetpoint  to VDOT(initialOffset, portUp).
            Set starSetpoint to VDOT(initialOffset, portRt).
        }
        Set aligning to alignToAxis.
        Set lateralVelMaxLocal to lateralVelMax.
        Set axialVelMaxLocal to axialVelMax.

        RCS on.
        // Both LookDirUp inputs are live so steering tracks the target's actual orientation
        // — captured + live mixed would feed inconsistent vectors when the target rotates.
        // Assumes "Control from Here" on our docking port so Ship:Facing tracks the port.
        Lock Steering to LookDirUp(-targetPort:PortFacing:Vector, targetPort:PortFacing:TopVector).
        Set enabled to True.
    }

    Function Stop {
        Set enabled to False.
        Unlock Steering.
        // Per-axis 0 is the documented per-axis release ("To free any single control, set it
        // back to zero"). Neutralize then releases everything as a safety net.
        Set Ship:Control:Fore to 0.
        Set Ship:Control:Starboard to 0.
        Set Ship:Control:Top to 0.
        Set Ship:Control:Neutralize to True.
        // Force a tick boundary so the engine processes the release before Stop returns —
        // otherwise the previous Update()'s Fore claim can persist through the script's
        // return into the menu loop, locking pilot H/N translation.
        Wait 0.
    }

    // Caller must invoke each tick (or in a WHEN/UPDATE trigger) while active.
    Function Update {
        If not enabled Return.

        // Live port basis — rebuilt each tick so target rotation is tracked.
        Local portFwd to targetPort:PortFacing:Vector:Normalized.
        Local portUp  to targetPort:PortFacing:TopVector:Normalized.
        Local portRt  to targetPort:PortFacing:StarVector:Normalized.

        // Reconstruct desired offset in world frame from port-local setpoints.
        Local desiredOffset to axialSetpoint * portFwd + topSetpoint * portUp + starSetpoint * portRt.
        Local currentOffset to targetPort:NodePosition.
        // shipOffset = me - me_setpoint, in world. Controllers drive this to zero.
        // (currentOffset = port - me; desiredOffset = port - me_setpoint; so shipOffset = desiredOffset - currentOffset.)
        Local shipOffset to desiredOffset - currentOffset.

        // Relative velocity of ship w.r.t. the target vessel — d(shipOffset)/dt to first order.
        Local relVel to Ship:Velocity:Orbit - targetPort:Ship:Velocity:Orbit.

        // Axial: cascaded position → desired velocity (capped by axialVelMax) → velocity PID.
        // Always-on (both hold and align modes) since the cap is generally useful.
        Local foreOffset to VDOT(shipOffset, Ship:Facing:Vector).
        Local desiredFwdVel to 0.
        If Abs(foreOffset) > 0.001 {
            Local desiredFwdSpeed to Min(Abs(foreOffset) * 0.5, axialVelMaxLocal).
            // Move opposite the offset to return to setpoint.
            Set desiredFwdVel to -(foreOffset / Abs(foreOffset)) * desiredFwdSpeed.
        }
        Local foreVelActual to VDOT(relVel, Ship:Facing:Vector).
        Local foreVelErr to foreVelActual - desiredFwdVel.
        foreVelPid:Update(foreVelErr).
        Set Ship:Control:Fore to foreVelPid:GetCalcOut().

        If aligning {
            // Cascaded lateral control: position → desired velocity (capped) → velocity PID.
            Local lateralOffset to shipOffset - VDOT(shipOffset, portFwd) * portFwd.
            Local lateralOffsetMag to lateralOffset:Mag.

            Local desiredLatVel to V(0, 0, 0).
            If lateralOffsetMag > 0.001 {
                Local desiredSpeed to Min(lateralOffsetMag * 0.5, lateralVelMaxLocal).
                Set desiredLatVel to -lateralOffset:Normalized * desiredSpeed.
            }

            Local latVelActual to relVel - VDOT(relVel, portFwd) * portFwd.
            Local latVelErr to latVelActual - desiredLatVel.

            Local starErr to VDOT(latVelErr, Ship:Facing:StarVector).
            Local topErr  to VDOT(latVelErr, Ship:Facing:TopVector).

            starVelPid:Update(starErr).
            topVelPid:Update(topErr).
            Set Ship:Control:Starboard to starVelPid:GetCalcOut().
            Set Ship:Control:Top       to topVelPid:GetCalcOut().
        } Else {
            // Hold mode: positional lateral control.
            Local starErr to VDOT(shipOffset, Ship:Facing:StarVector).
            Local topErr  to VDOT(shipOffset, Ship:Facing:TopVector).

            starPid:Update(starErr).
            topPid:Update(topErr).
            Set Ship:Control:Starboard to starPid:GetCalcOut().
            Set Ship:Control:Top       to topPid:GetCalcOut().
        }
    }

    Function IsEnabled {
        Return enabled.
    }

    // distance is a positive distance from the target port. Internally axialSetpoint is a
    // signed projection onto PortFacing:Vector (negative when ship is on the outward side).
    Function SetAxialDistance {
        Parameter distance.
        Set axialSetpoint to -Abs(distance).
    }

    Function SetLateralVelMax {
        Parameter vmax.
        If vmax < 0.05 { Return. }
        Set lateralVelMaxLocal to vmax.
    }

    Function SetAxialVelMax {
        Parameter vmax.
        If vmax < 0.05 { Return. }
        Set axialVelMaxLocal to vmax.
    }

    Function GetStatus {
        Local portFwd to targetPort:PortFacing:Vector:Normalized.

        Local currentOffset to targetPort:NodePosition.
        Local currentAxial to VDOT(currentOffset, portFwd).
        Local currentLateral to (currentOffset - currentAxial * portFwd):Mag.

        Local relVel to Ship:Velocity:Orbit - targetPort:Ship:Velocity:Orbit.
        Local axVelMag  to Abs(VDOT(relVel, portFwd)).
        Local latVelMag to (relVel - VDOT(relVel, portFwd) * portFwd):Mag.

        Local lateralSetMag to Sqrt(topSetpoint^2 + starSetpoint^2).

        Return Lexicon(
            "axial", currentAxial,
            "axialSetpoint", axialSetpoint,
            "lateralMag", currentLateral,
            "lateralSetpointMag", lateralSetMag,
            "rangeToPort", currentOffset:Mag,
            "axVelMag", axVelMag,
            "axialVelMax", axialVelMaxLocal,
            "latVelMag", latVelMag,
            "lateralVelMax", lateralVelMaxLocal,
            "aligning", aligning
        ).
    }

    Return Lexicon(
        "Start", Start@,
        "Stop", Stop@,
        "Update", Update@,
        "IsEnabled", IsEnabled@,
        "GetStatus", GetStatus@,
        "SetAxialDistance", SetAxialDistance@,
        "SetLateralVelMax", SetLateralVelMax@,
        "SetAxialVelMax", SetAxialVelMax@
    ).
}
