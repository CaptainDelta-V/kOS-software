RUNONCEPATH("0:common/orbit/stationKeeping").

// Docking is a thin reconfiguration of an already-running StationKeepingModel:
// drive the axial setpoint to a small final distance at a slow approach velocity, with
// the existing cascaded controllers doing the actual translation. No duplicated control
// math — DRY by composition with stationKeeping.

// Approach velocity for docking (m/s). Used as the axial velocity cap during approach.
Global DOCKING_APPROACH_VEL to 0.2.

// Final axial distance to drive toward (m). Slightly positive rather than zero so the
// cascaded controller doesn't fight magnetic capture once the ports touch.
Global DOCKING_FINAL_DISTANCE to 0.5.

// Lateral tolerance for "aligned enough to begin docking" (m).
Global DOCKING_ALIGN_TOLERANCE to 1.

// Reconfigure an active StationKeepingModel for docking approach. Caller is responsible
// for verifying readiness via ReadyToDock first if they want gated behavior.
Global Function BeginDocking {
    Parameter sk.
    sk:SetAxialDistance(DOCKING_FINAL_DISTANCE).
    sk:SetAxialVelMax(DOCKING_APPROACH_VEL).
}

// True when the ship is in align mode and lateral position is within the tolerance —
// i.e. on the port axis and safe to start the slow axial approach.
Global Function ReadyToDock {
    Parameter sk.
    Local stat to sk:GetStatus().
    Return stat:aligning And stat:lateralMag < DOCKING_ALIGN_TOLERANCE.
}
