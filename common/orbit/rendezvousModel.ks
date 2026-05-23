Declare Global SECONDS_PER_HOUR to 60 * 60.

// Analytical Hohmann transfer to a target orbiting the same body — closed-form Δv and
// closed-form phase-window wait time, matching MechJeb's "Hohmann transfer to target".
// Approximates both orbits as coplanar circles. Plane mismatch and small eccentricity
// errors are left to a separate mid-course correction.
//
// Returns Lexicon:
//   ok            : Boolean — False with :error string on bail
//   burnTime      : absolute UT for the departure burn (s)
//   wait          : seconds from now until burn
//   deltaV        : signed prograde Δv (m/s); positive raises, negative lowers
//   tof           : transfer time of flight (s)
//   phaseNowDeg   : current signed phase ahead of ship (deg, [-180, 180])
//   phaseReqDeg   : phase ahead of ship required at burn (deg)
//   synodicPeriod : seconds between consecutive launch windows
//   r1, r2        : semi-major axes used (m)
Global Function PlanHohmannIntercept {
    If not HasTarget {
        Return Lexicon("ok", False, "error", "No target set.").
    }
    If Target:Body:Name <> Ship:Body:Name {
        Return Lexicon(
            "ok", False,
            "error", "Target body (" + Target:Body:Name + ") differs from ship body (" + Ship:Body:Name + ")."
        ).
    }

    Local mu to Ship:Body:Mu.
    Local r1 to Ship:Orbit:SemiMajorAxis.
    Local r2 to Target:Orbit:SemiMajorAxis.

    Local at to (r1 + r2) / 2.
    Local tof to Constant:Pi * Sqrt(at^3 / mu).

    Local nShip to Sqrt(mu / r1^3).
    Local nTgt  to Sqrt(mu / r2^3).
    Local dPhiDt to nTgt - nShip.

    If Abs(dPhiDt) < 1.0e-9 {
        Return Lexicon("ok", False, "error", "Orbits too similar; no phase closure.").
    }

    Local phiReq to Constant:Pi - nTgt * tof.

    Local rs to Ship:Position - Ship:Body:Position.
    Local rt to Target:Position - Ship:Body:Position.
    Local nrm to VCRS(rs, Ship:Velocity:Orbit):Normalized.

    Local rsN to rs:Normalized.
    Local rtN to rt:Normalized.
    Local cosA to VDOT(rsN, rtN).
    Local sinA to VDOT(VCRS(rsN, rtN), nrm).
    Local phiNow to ArcTan2(sinA, cosA) * Constant:DegToRad.

    Local dphi to phiReq - phiNow.
    If dPhiDt > 0 and dphi < 0 { Set dphi to dphi + 2 * Constant:Pi. }
    Else If dPhiDt < 0 and dphi > 0 { Set dphi to dphi - 2 * Constant:Pi. }

    Local waitT to dphi / dPhiDt.

    Local dv1 to Sqrt(mu / r1) * (Sqrt(2 * r2 / (r1 + r2)) - 1).

    Return Lexicon(
        "ok", True,
        "burnTime", Time:Seconds + waitT,
        "wait", waitT,
        "deltaV", dv1,
        "tof", tof,
        "phaseNowDeg", phiNow * Constant:RadToDeg,
        "phaseReqDeg", phiReq * Constant:RadToDeg,
        "synodicPeriod", 2 * Constant:Pi / Abs(dPhiDt),
        "r1", r1,
        "r2", r2
    ).
}

// Plans the transfer and creates the corresponding maneuver node. Clears existing nodes first.
// Returns the same lexicon as PlanHohmannIntercept, with an added "node" key on success.
Global Function CreateHohmannInterceptNode {
    Local plan to PlanHohmannIntercept().
    If not plan:ok { Return plan. }

    Until not HasNode { Remove NextNode. Wait 0. }

    Local mnv to Node(plan:burnTime, 0, 0, plan:deltaV).
    Add mnv.
    plan:Add("node", mnv).
    Return plan.
}

Function RendezvousModel {
    Parameter flightStatus. 

    Lock positionVessel to Ship:Position - Body:Position.
    Lock positionTarget to Target:Position - Body:Position.
    Lock momentumVectVessel to VCRS(PositionVessel, Ship:Velocity:Orbit).
    Lock momentumVectTarget to VCRS(PositionTarget, Target:Velocity:Orbit).
    
    Function AngleToAN { 
        Lock ascDscNodeVect to VCRS(momentumVectVessel, momentumVectTarget).

        Return vang(positionVessel, ascDscNodeVect).
    }

    Function AngleToDN { 
        Lock descNodeVect to VCRS(momentumVectTarget, momentumVectVessel).

        Return vang(positionVessel, descNodeVect).
    }

    Function RelativeInclination { 
        Return VANG(momentumVectVessel, momentumVectTarget).
    }

    //
    // todo: create node
    //   determine prograde/retro
    //   node to burn to max allowance diff
    //   check dist on current orbit, 
    //   add n number of orbits until max time or start increasing
    //   back to the closest orbit 
    //   adjust prograde/retro to move closest closer (determine where on the orbit so can reduce search area)
    //

    Function ClosestApproach { 
        Parameter timeStart to Time:Seconds.
        Parameter timeStop to Time:Seconds + Ship:Orbit:Period.
        Parameter timeStepSeconds to 0.

        If timeStop <= timeStart {
            Set timeStop to timeStart + Ship:Orbit:Period.
        }.

        Local span to timeStop - timeStart.
        Local minStep to 0.5.
        Local maxSamples to 160.
        Local step to span / maxSamples.

        If timeStepSeconds > 0 {
            Set minStep to timeStepSeconds.
        }.

        If step < minStep { Set step to minStep * 5. }.

        Local searchStart to timeStart.
        Local searchStop to timeStop.

        Local minDist to 99_9999.
        Local minDistTimeSeconds to timeStart.
        Local pass to 0.

        Until step <= minStep or pass >= 4 {
            Set minDist to 99_9999.
            Set minDistTimeSeconds to searchStart.

            Local currentTime to searchStart.
            Until currentTime > searchStop {
                Local shipPosition to PositionAt(ship, currentTime).
                Local targetPosition to PositionAt(target, currentTime).
                Local dist to (targetPosition - shipPosition):Mag.

                If dist < minDist { 
                    Set minDist to dist.                
                    Set minDistTimeSeconds to currentTime.
                }.

                Set currentTime to currentTime + step.
            }.

            // Narrow search window around the best time and refine step for accuracy
            Local window to step * 2.
            Set searchStart to Max(timeStart, minDistTimeSeconds - window).
            Set searchStop to Min(timeStop, minDistTimeSeconds + window).
            Set step to step / 4.
            Set pass to pass + 1.
        }        

        Return Lexicon(
            "MinDist", minDist,
            "Time", minDistTimeSeconds
        ).
    }
                

    Return Lexicon(
        "AngleToDN", AngleToDN@,
        "AngleToAN", AngleToAN@,
        "RelativeInclination", RelativeInclination@,
        "ClosestApproach", ClosestApproach@,
        "PlanHohmannIntercept", PlanHohmannIntercept@,
        "CreateHohmannInterceptNode", CreateHohmannInterceptNode@
    ).
}
