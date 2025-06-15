
// RUNONCEPATH("0:rsvp/main").
// RUNONCEPATH("0:rsvp/transfer").


Function RendezvousModel { 
    Parameter flightStatus. 

    Function TimeToANDN { 
        
        flightStatus:Update("Calculating Node Vector...").
        local shipPosRel to ship:obt:position.
        local shipVel to ship:obt:velocity.
        local hMe to vcrs(shipPosRel, shipVel).

        local targetPosRel to target:obt:position.
        local targetVel to target:obt:velocity.
        local hTgt to vcrs(targetPosRel, targetVel).

        local nodeVector to vcrs(hMe, hTgt).
        flightStatus:Update("Node Vector calculated.").

        local shipOrbit to ship:obt.
        local peVector to shipOrbit:periapsis.
        local orbitNormal to shipOrbit:normal.

        local angleToNodeRaw to vang(peVector, nodeVector).
        local nodeDirectionCheck to vdot(orbitNormal, vcrs(peVector, nodeVector)).

        local taAN is 0.
        if nodeDirectionCheck >= 0 {
            set taAN to angleToNodeRaw.
        } else {
            set taAN to 360 - angleToNodeRaw.
        }
        
        flightStatus:AddField("TA of AN: ", round(taAN, 1)).

        local taDN to mod((taAN + 180), 360).
        flightStatus:AddField("TA of DN: ", round(taDN, 1)).

        // 4. Calculate time until ship reaches each node's TA
        flightStatus:Update("Calculating time to nodes..."). 

        // *** CORRECTION HERE ***
        // Get the Universal Time (UT) when the ship will next be at taAN
        local utAtAN to shipOrbit:utattruaanomaly(taAN, time:seconds).
        // Get the Universal Time (UT) when the ship will next be at taDN
        local utAtDN to shipOrbit:utattruaanomaly(taDN, time:seconds).

        // Calculate time FROM NOW until those UTs
        local timeToAN to utAtAN - time:seconds.
        local timeToDN to utAtDN - time:seconds.
        // *** END CORRECTION ***

        // 5. Determine which node is next and the time
        local timeToNextNode is 0.
        local nextNodeIs is "".

        if timeToAN < timeToDN {
            set timeToNextNode to timeToAN.
            set nextNodeIs to "Ascending Node (AN)".
        } else {
            set timeToNextNode to timeToDN.
            set nextNodeIs to "Descending Node (DN)".
        }

        // --- Output ---    
        flightStatus:AddField("Current Ship TA: ", round(shipOrbit:trueanomaly, 1)).
        flightStatus:AddField("Next node crossing: ", nextNodeIs).
        flightStatus:AddField("Time until next node: ", round(timeToNextNode, 1) + " s.").
        flightStatus:AddField("Time until AN: ", round(timeToAN, 1) + " s.").
        flightStatus:AddField("Time until DN: " + round(timeToDN, 1) + " s.").
    }
    
    Function GetInfo { 

        Local positionVessel to ship:position - body:position.
        Local positionTarget to target:position - body:position.
        Local momentumVectVessel to VCRS(positionVessel, Ship:Velocity:Orbit).
        Local momentumVectTarget to VCRS(positionTarget, Target:Velocity:Orbit).

        // Debug
        Local momentumVectVesselArrow to VecDraw(
            V(0,0,0),
            V(0,0,0),
            RGB(1,1,1),
            "momentumVessel",
            1.0,
            true,
            0.1,
            true,
            true
        ).

        Set momentumVectVesselArrow:StartUpdater to { Return Body:Position. }.
        Set momentumVectVesselArrow:VecUpdater to { Return momentumVectTarget. }.

        Local planetToShipArrow to VecDraw(
            V(0,0,0),
            V(0,0,0),
            RGB(1,1,0), 
            "planetToShip", 
            1.0,
            true, 
            0.1, 
            true, 
            true
        ).

        Set planetToShipArrow:StartUpdater to { Return Body:Position. }.
        Set planetToShipArrow:VecUpdater to { Return Ship:Position. }.

        Local relativeInclination to VANG(momentumVectVessel, momentumVectTarget).
        flightStatus:AddField("REL. INC.", relativeInclination).
        Local ascDscNodeVect to VCRS(momentumVectVessel, momentumVectTarget).

        Local angleToLAN to vang(positionVessel, ascDscNodeVect).
        flightStatus:AddField("ANGLE TO LAN", { Return angleToLAN. }).
    }

    // Function ClosestApproach { 
    //     Local duration TO 3600. // seconds ahead to check
    //     Local step TO 5.        // time step

    //     Local minDist TO 1E9.
    //     Local bestTime TO Time:Seconds.    
        
    //     Local idx to 0.
    //     Until idx < duration
    //     { 
    //         Local currentTime TO Time:Seconds + idx.
    //         Local myPos to PositionAt(ship, currentTime).
    //         Local tgtPos to PositionAt(target, currentTime).
    //         Local dist TO (myPos - tgtPos):Mag.

    //         IF dist < minDist {
    //             SET minDist TO dist.
    //             SET bestTime TO currentTime.
    //         }
    //         Set idx to idx + 1.
    //         flightStatus:AddField("idx", idx).
    //     }

    //     flightStatus:AddField("d4f", { Return "Closest approach in: " + ROUND((bestTime - TIME:SECONDS),0) + " seconds". }).
    //     flightStatus:AddField("f23", { Return "Distance at closest approach: " + ROUND(minDist, 2) + " meters". }).
    // }

    Function ClosestApproach { 

        RemoveAllNodes().
         // compute LAN
        // classy option: compute using angular momentum
        set pMe to ship:position - body:position.
        set pTgt to target:position - body:position.
        set hMe to vcrs(pMe, ship:velocity:orbit).
        set hTgt to vcrs(pTgt, target:velocity:orbit).
    //    set hmeArr to vecdraw(body:position, hMe, RGB(1, 1, 1), "hMe").
    //    set htgtArr to vecdraw(body:position, hTgt, RGB(1, 1, 1), "hTgt").
        set relAng to vang(hMe, hTgt).
        set vAN to vcrs(hMe, hTgt).
        set anArr to vecdraw(body:position, vAN, RGB(1, 1, 1)).
    //    set hmeArr:show to true.
    //    set htgtArr:show to true.
        set anArr:show to true.

        // print "relative inclination: " + relAng.
        // print "angle to LAN " + vang(pMe, vAN).

        // attempt to resolve the time of LAN
        set td to 60.
        set toff to td.
        set angLast to vang(pMe, vAN).
        set tme to ship:orbit:period.
        set minAng to 999.
        set tMinAng to -1.

        until false {
            // compute a position at some future time and evaluate its angle to LAN
            set pf to positionat(ship, time:seconds + toff).
            set tf to positionat(target, time:seconds + toff).
            Local distApproach to (pf - tf):Mag.

            flightStatus:AddField("dist approach", distApproach).
            set ang to vang(pf - body:position, vAN).
            if ang < minAng {
                set minAng to ang.
                set tMinAng to time:seconds + toff.
            }
            if toff > tme {
                break.
            }
            set angLast to ang.
            set toff to toff + td.
        }

            // assumption! relative inclination is low
            // make a node at the AN to compute hohmann transfer
            set tn to node(tMinAng, 0, 0, 0).
            add tn.

            // we want to find a maneuver resulting in an orbit where we can iterate forward in time
            // until the target distance at periapsis is below 10km

            // compute the angle between me and target. use this to make an orbit with a period the same as 1+x
            // where x is the percentage of a target orbital period. wherever we burn becomes the periapsis of
            // the resulting orbit, so chart a point from the AN/DN

            set pf to positionat(ship, tMinAng) - body:position.
            set tf to positionat(target, tMinAng) - body:position.
            set taRel to vang(pf, tf).
            // angle is absolute value, never negative; need to know whether leading or lagging the target
            if vcrs(pf, tf):z < 0 {
            // lagging
            set taPerc to 1 - taRel / 360.
            }
            else {
            // leading
            set taPerc to taRel / 360.
            }
            set adjPeriod to target:orbit:period * (1 + taPerc).

            // increase the prograde delta-v until the resulting orbit has a matching period
            lock periodError to tn:orbit:period - adjPeriod.
            set periodGain to 0.05.
            until abs(periodError) < 1 {
            set tn:prograde to tn:prograde - periodError * periodGain.
            print tn:prograde + ", " + periodError.
            
            wait 0.1.
        }
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
    //
    //
    Function CheckClosestApproach { 

        // Local currentTime to Time:Seconds + Timespan(0, 3, 4, 15, 30):Seconds.
        // Local shipPosition to PositionAt(ship, currentTime).
        // Local targetPosition to PositionAt(target, currentTime).
        // Local dist to (targetPosition - shipPosition):Mag.
        // flightStatus:AddField("Dist", dist).           


        Local timeStep to 20. 
        Local secondsPerHour to 60 * 60.
        Local totalHours to (6 * 3) + 4.
        Local minutes to 30.
        // Local timeToStep to (secondsPerHour * totalHours) + minutes.
        Local timeToStep to 60 * 10.

        // Local timestampStart to Timestamp(2, 120, 4, 27

        Local minDist to 99_9999.
        Local minDistTimeSeconds to Time:Seconds.

        Local timeStart to Time:Seconds + (Ship:Orbit:Period * 13).
        Local timeStop to timeStart + (secondsPerHour).
        Local currentTime to timeStart.

        // Local expectedClosest to Time:Seconds + Timestamp(0,3,4,20,0).
        // Local expectedClosest to Timestamp(0,3,4,20,0) + Timestamp(0,3,4,20,0).
        // flightStatus:AddField("Time expct", expectedClosest:Full).

        flightStatus:AddField("Time start", Timestamp(timeStart):Full).
        flightStatus:AddField("Time stop", Timestamp(timeStop):Full).    

        flightStatus:Update("Stepping").

        Until currentTime > timeStop { 
            flightStatus:AddField("Time curr", Timestamp(currentTime):Full).
            flightStatus:AddField("Current Timestep seconds", currentTime).
            
            Local shipPosition to PositionAt(ship, currentTime).
            Local targetPosition to PositionAt(target, currentTime).
            Local dist to (targetPosition - shipPosition):Mag.
            flightStatus:AddField("Dist", dist).            

            If dist < minDist { 
                Set minDist to dist.                
                Set minDistTimeSeconds to currentTime.
            }


            flightStatus:AddField("MinDist", minDist).
            flightStatus:AddField("MinDist Time", Timestamp(minDistTimeSeconds):Full).

            Set currentTime to currentTime + timeStep.
        }

        

        flightStatus:AddField("Timestep reached", 1).

    }
                

    Return Lexicon(
        "TimeToANDN", TimeToANDN@,
        // "GetInfo", GetInfo@, 
        "GetInfo", GetInfo@,
        "ClosestApproach", ClosestApproach@, 
        "CheckClosestApproach", CheckClosestApproach@
    ).
}