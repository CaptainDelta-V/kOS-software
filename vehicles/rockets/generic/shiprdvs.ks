@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("0:common/constants").
RUNONCEPATH("0:common/landing/sites").
RUNONCEPATH("0:common/infos").
RUNONCEPATH("0:common/engineManager").
RUNONCEPATH("0:common/flightStatus/flightStatusModel").
RUNONCEPATH("0:common/control").
RUNONCEPATH("0:common/launch/utils").
RUNONCEPATH("0:common/nav").
RUNONCEPATH("0:common/booting/bootUtils").
RUNONCEPATH("0:common/orbit/hohmannTransferController").
RUNONCEPATH("0:common/orbit/manueverNodeManager"). // Do not use for any function other than RemoveAllNodes
RUNONCEPATH("0:common/orbit/rendezvousModel").

ClearScreen.
ClearVecDraws(). 
RemoveAllNodes().

Local flightStatus to FlightStatusModel("ORBITAL RENDEZVOUS", "AWAITING INITIATION").

flightStatus:AddField("ETA Apoapsis", { return Round(Ship:Orbit:ETA:Apoapsis, 2). }).
flightStatus:AddField("ETA Periapsis", { return Round(Ship:Orbit:ETA:Periapsis, 2). }).
flightStatus:AddField("OBT True Anomaly", { Return Round(Ship:Orbit:TrueAnomaly, 2). }).
flightStatus:AddField("PER", { Return Round(Ship:Orbit:Period, 1) + "s". }).

RunFlightStatusScreen(flightStatus).

Local rdvs to RendezvousModel(flightStatus).

flightStatus:AddField("Relative Inc.", { Return Round(rdvs:RelativeInclination(), 4). }).
flightStatus:AddField("Angle to AN", { Return Round(rdvs:AngleToAN(), 4). }).
flightStatus:AddField("Angle to DN", { Return Round(rdvs:AngleToDN(), 4). }).

// --- Tuning constants ---
Local minAltitude to 85_100.
Local maxWaitOrbits to 60.
Local maxPhasingIterations to 4.
Local incTolerance to 0.4.
Local interceptTolerance to 5_000.
Local finalDistance to 100.
Local finalRelSpeed to 1.
Local closestStepSeconds to 10.
Local nodeSearchStepSeconds to 20.
Local burnThrottle to 0.25.
Local finalizationThrottle to 0.05.
Local finalizationPct to 0.2.
Local alignmentMargin to 45.
Local approachThrottle to 0.15.

// --- Helpers ---
Function EnsureTarget {
    If not HASTARGET {
        flightStatus:Update("NO TARGET SELECTED").
        Wait Until False.
    }.
    If Target:Body <> Ship:Body {
        flightStatus:Update("TARGET IN DIFFERENT SOI").
        Wait Until False.
    }.
}

Function RelPos {
    Return Target:Position - Ship:Position.
}

Function RelVel {
    Return Target:Velocity:Orbit - Ship:Velocity:Orbit.
}

Function RangeToTarget {
    Return RelPos():Mag.
}

Function RelSpeed {
    Return RelVel():Mag.
}

Function NormalAt {
    Parameter orbitable.
    Parameter utime.
    Local pos to PositionAt(orbitable, utime).
    Local vel to VelocityAt(orbitable, utime):Orbit.
    Return VCRS(pos, vel):Normalized.
}

Function RelativeInclinationAt {
    Parameter utime.
    Local sn to NormalAt(ship, utime).
    Local tn to NormalAt(target, utime).
    Return VANG(sn, tn).
}

Function SignedPhaseAngle {
    Local posV to Ship:Position - Body:Position.
    Local posT to Target:Position - Body:Position.
    Local n to VCRS(posV, Ship:Velocity:Orbit).
    Local ang to VANG(posV, posT).
    Local s to VDOT(n, VCRS(posV, posT)).

    If s < 0 {
        Set ang to 360 - ang.
    }.
    If ang > 180 {
        Set ang to ang - 360.
    }.
    Return ang.
}

Function FindNodeTime {
    Parameter nodeVector.
    Parameter timeStart.
    Parameter timeStop.
    Parameter timeStepSeconds.

    Local minAngle to 999999.
    Local minAngleTime to timeStart.

    Local currentTime to timeStart.
    Until currentTime > timeStop {
        Local shipPosition to PositionAt(ship, currentTime).
        Local angle to VANG(shipPosition, nodeVector).

        If angle < minAngle {
            Set minAngle to angle.
            Set minAngleTime to currentTime.
        }.

        Set currentTime to currentTime + timeStepSeconds.
    }.

    Return minAngleTime.
}

Function PickNormalSign {
    Parameter nodeTime.
    Local testDv to 1.
    Local testNode to Node(nodeTime, 0, testDv, 0).
    Add testNode.

    Local incPlus to RelativeInclinationAt(nodeTime + 10).

    Set testNode:Normal to -testDv.
    Local incMinus to RelativeInclinationAt(nodeTime + 10).

    Remove testNode.

    If incPlus < incMinus {
        Return 1.
    }.
    Return -1.
}

Function WarpToTime {
    Parameter utime.
    If utime <= Time:Seconds + 1 { Return. }.
    Set KUniverse:TimeWarp:Mode to "RAILS".
    KUniverse:TimeWarp:WarpTo(utime).
    Wait 1.
}

Function CurrentMeanAltitude {
    Return (Ship:Orbit:Apoapsis + Ship:Orbit:Periapsis) / 2.
}

Function TargetMeanAltitude {
    Return (Target:Orbit:Apoapsis + Target:Orbit:Periapsis) / 2.
}

Function DesiredPhasingAltitude {
    Parameter maxOrbits.
    Parameter minAlt.

    Local theta to SignedPhaseAngle().
    Local P_t to Target:Orbit:Period.
    Local bestAlt to TargetMeanAltitude().

    If Abs(theta) < 0.5 {
        Return bestAlt.
    }.

    Local k to maxOrbits.
    Until k < 1 {
        Local pPrime to P_t * (1 - (theta / (360 * k))).
        If pPrime <= 0 {
            Set k to k - 1.
            Continue.
        }.

        Local a to (Ship:Body:Mu * (pPrime / (2 * Constant:Pi))^2) ^ (1/3).
        Local alty to a - Ship:Body:Radius.

        If alty >= minAlt {
            Set bestAlt to alty.
            Break.
        }.

        Set k to k - 1.
    }.

    If bestAlt < minAlt {
        Set bestAlt to minAlt.
    }.

    Return bestAlt.
}

// --- Core steps ---
Function MatchInclination {
    If rdvs:RelativeInclination() <= incTolerance {
        flightStatus:Update("INC OK").
        Return.
    }.

    flightStatus:Update("MATCH INC").
    Local now to Time:Seconds.

    Local posV to Ship:Position - Body:Position.
    Local posT to Target:Position - Body:Position.
    Local momV to VCRS(posV, Ship:Velocity:Orbit).
    Local momT to VCRS(posT, Target:Velocity:Orbit).
    Local nodeVector to VCRS(momV, momT).

    Local timeAN to FindNodeTime(nodeVector, now, now + Ship:Orbit:Period, nodeSearchStepSeconds).
    Local timeDN to FindNodeTime(-nodeVector, now, now + Ship:Orbit:Period, nodeSearchStepSeconds).

    Local nodeTime to timeAN.
    If timeDN < timeAN { Set nodeTime to timeDN. }.

    Local sign to PickNormalSign(nodeTime).
    Local veloc to VelocityAt(ship, nodeTime):Orbit:Mag.
    Local inc to rdvs:RelativeInclination().
    Local dv to 2 * veloc * SIN(inc / 2).

    RemoveAllNodes().
    Local theNode to Node(nodeTime, 0, sign * dv, 0).
    Add theNode.

    Local mnv to ManueverNodeManager(flightStatus, theNode, burnThrottle).
    mnv:CalculateBurnDuration().
    flightStatus:Update("WARP TO INC BURN").
    mnv:WarpToAlignment(alignmentMargin).
    mnv:Engage(finalizationThrottle, finalizationPct).
    mnv:CleanUp().
}

Function FindInterceptWindow {
    Local timeStart to Time:Seconds.
    Local timeStop to timeStart + (Ship:Orbit:Period * maxWaitOrbits).
    Return rdvs:ClosestApproach(timeStart, timeStop, closestStepSeconds).
}

Function PhaseToIntercept {
    Local iteration to 0.

    Until iteration >= maxPhasingIterations {
        Local caNow to FindInterceptWindow().
        flightStatus:Update("INTERCEPT SEEK").
        flightStatus:AddField("CA DIST", Round(caNow:MinDist, 1) + "m", true).
        flightStatus:AddField("CA TIME", Timestamp(caNow:Time):Full, true).

        If caNow:MinDist <= interceptTolerance {
            flightStatus:Update("INTERCEPT WINDOW FOUND").
            WarpToTime(caNow:Time - 120).
            Return.
        }.

        // More aggressive phasing when the current CA is large
        Local orbitsForTarget to maxWaitOrbits.
        If caNow:MinDist > 500_000 { Set orbitsForTarget to 1. }.
        If caNow:MinDist > 200_000 and caNow:MinDist <= 500_000 { Set orbitsForTarget to 2. }.
        If caNow:MinDist > 50_000 and caNow:MinDist <= 200_000 { Set orbitsForTarget to 3. }.
        If caNow:MinDist > 10_000 and caNow:MinDist <= 50_000 { Set orbitsForTarget to 4. }.
        If orbitsForTarget > maxWaitOrbits { Set orbitsForTarget to maxWaitOrbits. }.
        If orbitsForTarget < 1 { Set orbitsForTarget to 1. }.

        Local phaseAngle to SignedPhaseAngle().
        Local currentAlt to CurrentMeanAltitude().
        Local targetAlt to DesiredPhasingAltitude(orbitsForTarget, minAltitude).
        Local minAltBuffer to 5_000.
        Local preferHigher to currentAlt <= (minAltitude + minAltBuffer).

        If preferHigher {
            // Near atmosphere: always go higher to slow down and let target catch up
            If targetAlt <= currentAlt { Set targetAlt to currentAlt + 5_000. }.
        } Else {
            If phaseAngle > 0 {
                // Target ahead (+) -> lower orbit to catch up.
                If targetAlt >= currentAlt { Set targetAlt to Max(minAltitude, currentAlt - 5_000). }.
            } Else {
                // Target behind (-) -> higher orbit to let it catch up.
                If targetAlt <= currentAlt { Set targetAlt to currentAlt + 5_000. }.
            }.
        }.

        // Enforce a minimum phasing delta so the burn is meaningful
        If Abs(targetAlt - currentAlt) < 200 {
            If preferHigher {
                Set targetAlt to currentAlt + 5_000.
            } Else {
                If phaseAngle > 0 { Set targetAlt to Max(minAltitude, currentAlt - 5_000). }.
                If phaseAngle <= 0 { Set targetAlt to currentAlt + 5_000. }.
            }.
        }.

        flightStatus:Update("PHASING BURN").
        Local hohmann to HohmannTransferController(flightStatus, targetAlt).
        hohmann:Engage(burnThrottle, finalizationThrottle, finalizationPct, alignmentMargin).

        Set iteration to iteration + 1.
    }.
}

Function FinalApproachAndMatchVelocity {
    flightStatus:Update("FINAL APPROACH").
    Set NAVMODE to "TARGET".

    Until (RangeToTarget() <= finalDistance and RelSpeed() <= finalRelSpeed) {
        Local dist to RangeToTarget().
        Local relSpeed to RelSpeed().

        Local desiredSpeed to 1.
        If dist > 2000 { Set desiredSpeed to 20. }.
        If dist > 1000 and dist <= 2000 { Set desiredSpeed to 12. }.
        If dist > 500 and dist <= 1000 { Set desiredSpeed to 8. }.
        If dist > 200 and dist <= 500 { Set desiredSpeed to 5. }.
        If dist > 100 and dist <= 200 { Set desiredSpeed to 2. }.

        If relSpeed < desiredSpeed - 0.5 {
            Lock Steering to RelPos().
            Lock Throttle to approachThrottle.
        } Else If relSpeed > desiredSpeed + 0.5 {
            Lock Steering to -RelVel().
            Lock Throttle to approachThrottle.
        } Else {
            Lock Throttle to 0.
        }.

        Wait 0.1.
    }.

    // Final velocity sync
    flightStatus:Update("SYNC VELOCITY").
    Until RelSpeed() <= finalRelSpeed {
        If RelSpeed() > 0.2 {
            Lock Steering to -RelVel().
            Lock Throttle to approachThrottle.
        } Else {
            Lock Throttle to 0.
        }.
        Wait 0.1.
    }.

    Lock Throttle to 0.
    Unlock Steering.
    flightStatus:Update("RENDEZVOUS COMPLETE").
}

// --- Sequence ---
EnsureTarget().
MatchInclination().
PhaseToIntercept().
FinalApproachAndMatchVelocity().

Wait Until False. 
