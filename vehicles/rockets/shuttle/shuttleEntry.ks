@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("0:vehicles/rockets/starship/constants").
RUNONCEPATH("0:common/booting/bootUtils").
RUNONCEPATH("0:common/landing/sites").
RUNONCEPATH("0:common/landing/sites").
RUNONCEPATH("0:common/infos").
RUNONCEPATH("0:common/engineManager").
RUNONCEPATH("0:common/flightStatus/flightStatusModel").
RUNONCEPATH("0:common/control").
RUNONCEPATH("0:common/launch/utils").
RUNONCEPATH("0:common/nav").
RUNONCEPATH("0:common/systems/drainValveManager").
RUNONCEPATH("0:common/orbit/hohmannTransferController").
RUNONCEPATH("0:common/landing/deOrbitBurnController").
RUNONCEPATH("0:common/landing/landingStatusModel").
RUNONCEPATH("0:common/landing/landingSteeringModel").
RUNONCEPATH("0:common/landing/landingBurnModel").
RUNONCEPATH("0:common/flight/hover").
RUNONCEPATH("0:common/seeking/pidModel").
RUNONCEPATH("0:common/math").

ClearScreen.
ClearVecDraws(). 

Local flightStatus to FlightStatusModel("ENTRY GUIDANCE", "AWAITING INITIATION").

flightStatus:AddField("ETA APOAPSIS", { return Ship:Orbit:ETA:Apoapsis. }).
flightStatus:AddField("ETA PERIAPSIS", { return Ship:Orbit:ETA:Periapsis. }).

RunFlightStatusScreen(flightStatus).

Local landingSite to LatLng(-0.123942125673094,-74.4642469768736). // OLM
Local landingOvershootMeters to 1_000. 

Local pitchMax to 62. 
Local pitchMin to 16. 

Local parkingOrbitTolerance to 4_000.
Local parkingOrbitIdeal to Body:Atm:Height + parkingOrbitTolerance. 
Local parkingOrbitMinPeriapsis to parkingOrbitIdeal - parkingOrbitTolerance. 
Local parkingOrbitMaxApoapsis to parkingOrbitIdeal + parkingOrbitTolerance.

If Ship:Orbit:Periapsis > Body:Atm:Height { 
    If Ship:Orbit:Periapsis > parkingOrbitMinPeriapsis and Ship:Orbit:Apoapsis > parkingOrbitMaxApoapsis { 
        flightStatus:Update("ESTABLISH PARKING ORBIT").
        Local hohmannTransfer to HohmannTransferController(flightStatus, parkingOrbitIdeal).
        hohmannTransfer:Engage(0.2, 0.1, 0.35, 30). // burnThrottle, finalizationThrottle, finalizationPercentage, alignmentMargin,        
    } Else { 
        flightStatus:Update("ACCEPT CURRENT ORBIT AS PARKING").
    }


    flightStatus:Update("CREATE DEORBIT MNV.").

    Local deorbit to DeOrbitBurnController(flightStatus, 1, 0.4, 0.05, 42).    
    deorbit:DeOrbit(landingSite).
    // If Ship:Orbit:Periapsis < Body:Atm:Height { 
      
    // }
    // Else {
    //     flightStatus:Update("DEORBIT FAILURE").
    //     Shutdown.
    // }
}

RemoveAllNodes().
flightStatus:Update("DESCENT").

flightStatus:RemoveField("ETA APOAPSIS").
flightStatus:RemoveField("ETA PERIAPSIS").
Wait 1.

Local landingStatus to 

flightStatus:Update("PREPARING FOR THE HEAT").
// RCS ON.
AG6 ON.

Local landingStatus to LandingStatusModel(landingSite):Overshoot(landingOvershootMeters).
Lock isOvershooting to IsGeoPosWestOf(landingStatus:GetLandingSite(), landingStatus:GetImpact()).
Lock pitchError to landingStatus:ErrorVector():X.
Lock yawError to landingStatus:ErrorVector():Y. 
Lock yawErrorIsRight to yawError < 0.

Lock zError to landingStatus:ErrorVector():Z.

flightStatus:AddField("Is Overshooting", { Return isOvershooting. }).
flightStatus:AddField("Trajectory Error", { Return Round(landingStatus:TrajectoryErrorMeters(), 1) + "m". }).

Local maximumReasonableRangeError to 1_000. // The highest error expected to start after deorbit
Local maximumReasonableYawError to 1_000.

Local maxPitchErrorTolerance to 1_000.
Local maxYawErrorTolerance to 1_000.

Local maxYawErrorTolerance to 500.
Local defaultPitch to 35.
Local yawRange to 18.

flightStatus:AddField("Pitch Min", pitchMin).
flightStatus:AddField("Pitch Max", pitchMax).
flightStatus:AddField("Error (Pitch)", { Return Round(pitchError, 1). }).
flightStatus:AddField("Error (Yaw)", { Return Round(yawError, 1). }).
flightStatus:AddField("Error (Z)", { Return Round(zError, 1). }).
flightStatus:AddField("Current Pitch", { Return Round(PitchOFVessel(), 2). }).
flightStatus:AddField("Current Heading", { Return Round(HeadingOfVessel(), 2). }).

Lock targetHeading to HeadingOfVector(landingSite:Position - Ship:Geoposition:Position).

Local targetPitch to 0.
Lock correctiveHeading to 0.
Lock correctiveRoll to 0.

Lock Steering to Heading(correctiveHeading, targetPitch, correctiveRoll).

Local finalDescentStart to false. 
Until finalDescentStart { 

    Local pitchUpperRange to pitchMax - defaultPitch.
    Local pitchLowerRange to defaultPitch - pitchMin.

    flightStatus:AddField("Pitch Upper Range", pitchUpperRange).
    flightStatus:AddField("Pitch Lower Range", pitchLowerRange).
    
    If Abs(pitchError) > maxPitchErrorTolerance { 

        Local errorPct to Abs(pitchError / maximumReasonableRangeError).
        flightStatus:AddField("Pitch (Range) Error", errorPct + "% of " + maximumReasonableRangeError).
        Set errorPct to Min(1, errorPct).
        Local correctivePitch to 0.

        if isOvershooting {         
            Set correctivePitch to pitchUpperRange * errorPct.
        }
        Else { 
            Set correctivePitch to pitchLowerRange * errorPct * -1.
        }    
        
        Set targetPitch to defaultPitch + correctivePitch.
    } Else { 
        Set targetPitch to defaultPitch.        
    }
    
    If Abs(yawError) > maxYawErrorTolerance {         

        Local errorPct to Abs(yawError / maximumReasonableYawError).
        // flightStatus:LogMessage("yaw error pct: " + errorPct + " of " + maximumReasonableYawError).

        flightStatus:AddField("Yaw Error", Round(errorPct, 2) + "% of " + maximumReasonableYawError).
        Set errorPct to Min(1, errorPct).
        Lock correctiveHeading to 0.

        flightStatus:AddField("Yaw Error Right?", yawErrorIsRight).

        If not yawErrorIsRight {             
            Lock correctiveHeading to targetHeading + (yawRange * errorPct).
            Lock correctiveRoll to -25.
        } Else { 
            Lock correctiveHeading to targetHeading + (-1 * yawRange * errorPct).
            Lock correctiveRoll to 25.
        }       
    } Else { 
        Lock correctiveHeading to targetHeading.
        Lock correctiveRoll to 0.
    }

    flightStatus:AddField("Corrective Pitch", Round(targetPitch, 2)).
    flightStatus:AddField("Corrective Heading", Round(correctiveHeading, 2)).
    flightStatus:AddField("Heading to Target", Round(targetHeading, 2)).        

    Wait 0.01.
}

Wait Until Ship:Velocity:Surface:Mag < 800. 
flightStatus:Update("Belly Flopping").
Lock Steering to Heading(targetHeading, 0, 0).



Wait Until False.