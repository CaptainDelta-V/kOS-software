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

    // Axial: positional PID with derivative damping.
    Local forePid to PidModel(0.4, 0, 0.6, -1, 1).
    // Lateral (hold mode): positional PID — fine for small drifts.
    Local starPid to PidModel(0.4, 0, 0.6, -1, 1).
    Local topPid  to PidModel(0.4, 0, 0.6, -1, 1).
    // Lateral (align mode): inner velocity PID. kP=1 → 1 m/s error saturates translation.
    Local starVelPid to PidModel(1.0, 0, 0, -1, 1).
    Local topVelPid  to PidModel(1.0, 0, 0, -1, 1).

    Local enabled to False.

    // alignToAxis=True drops the lateral setpoint to zero so the ship slides onto the port's
    // approach axis and holds there. lateralVelMax (m/s) caps the desired lateral closing speed
    // in align mode to prevent overshoot.
    Function Start {
        Parameter alignToAxis is False.
        Parameter lateralVelMax is 1.0.

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
        Set Ship:Control:Fore to 0.
        Set Ship:Control:Starboard to 0.
        Set Ship:Control:Top to 0.
        Set Ship:Control:Neutralize to True.
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
        // shipOffset = me - me_setpoint, in world. PIDs drive this to zero.
        // (currentOffset = port - me; desiredOffset = port - me_setpoint; so shipOffset = desiredOffset - currentOffset.)
        Local shipOffset to desiredOffset - currentOffset.

        // Axial: positional control on the fore axis.
        Local foreErr to VDOT(shipOffset, Ship:Facing:Vector).
        forePid:Update(foreErr).
        Set Ship:Control:Fore to forePid:GetCalcOut().

        If aligning {
            // Cascaded lateral control: position → desired velocity (capped) → velocity PID.
            Local lateralOffset to shipOffset - VDOT(shipOffset, portFwd) * portFwd.
            Local lateralOffsetMag to lateralOffset:Mag.

            // desiredLatVel points back toward setpoint (opposite lateralOffset).
            // Outer P=0.5 → ramp-down within ~2 m of axis when lateralVelMax=1 m/s.
            Local desiredLatVel to V(0, 0, 0).
            If lateralOffsetMag > 0.001 {
                Local desiredSpeed to Min(lateralOffsetMag * 0.5, lateralVelMaxLocal).
                Set desiredLatVel to -lateralOffset:Normalized * desiredSpeed.
            }

            // d(shipOffset)/dt ≈ relVel = vel_ship - vel_targetShip; project onto lateral plane.
            Local relVel to Ship:Velocity:Orbit - targetPort:Ship:Velocity:Orbit.
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

    Function GetStatus {
        Local portFwd to targetPort:PortFacing:Vector:Normalized.

        Local currentOffset to targetPort:NodePosition.
        Local currentAxial to VDOT(currentOffset, portFwd).
        Local currentLateral to (currentOffset - currentAxial * portFwd):Mag.

        Local relVel to Ship:Velocity:Orbit - targetPort:Ship:Velocity:Orbit.
        Local latVelMag to (relVel - VDOT(relVel, portFwd) * portFwd):Mag.

        Local lateralSetMag to Sqrt(topSetpoint^2 + starSetpoint^2).

        Return Lexicon(
            "axial", currentAxial,
            "axialSetpoint", axialSetpoint,
            "lateralMag", currentLateral,
            "lateralSetpointMag", lateralSetMag,
            "rangeToPort", currentOffset:Mag,
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
        "GetStatus", GetStatus@
    ).
}
