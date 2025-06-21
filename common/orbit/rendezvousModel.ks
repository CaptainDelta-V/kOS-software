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
        Parameter timeStepSeconds to 1.        

        Local minDist to 99_9999.
        Local minDistTimeSeconds to Time:Seconds.
        
        Local currentTime to timeStart.    
        flightStatus:Update("Seeking Closest Approach").

        Until currentTime > timeStop { 
            flightStatus:AddTempField("Time curr", Timestamp(currentTime):Full).
            flightStatus:AddTempField("Seek Timestamp", Round(currentTime, 2)).
            
            Local shipPosition to PositionAt(ship, currentTime).
            Local targetPosition to PositionAt(target, currentTime).
            Local dist to (targetPosition - shipPosition):Mag.
            flightStatus:AddTempField("Dist", { Return Round(dist, 1). }).            

            If dist < minDist { 
                Set minDist to dist.                
                Set minDistTimeSeconds to currentTime.
            }

            flightStatus:AddTempField("Min. Dist", Round(minDist, 2)).
            flightStatus:AddTempField("Min. Dist Time", Timestamp(minDistTimeSeconds):Full).

            Set currentTime to currentTime + timeStepSeconds.
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