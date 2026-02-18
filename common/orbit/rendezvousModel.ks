Declare Global SECONDS_PER_HOUR to 60 * 60.    

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
        "ClosestApproach", ClosestApproach@
    ).
}
