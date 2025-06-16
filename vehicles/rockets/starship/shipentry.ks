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

// GetLaunchConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.5).

Local landingSite to LatLng(-0.123942125673094,-74.4642469768736). // OLM
Local landingOvershootMeters to 1_000. 

Local pitchMax to 55. 
Local pitchMin to 10. 

Local parkingOrbitTolerance to 2_000.
Local parkingOrbitIdeal to Body:Atm:Height + parkingOrbitTolerance. 
Local parkingOrbitMinPeriapsis to parkingOrbitIdeal - parkingOrbitTolerance. 
Local parkingOrbitMaxApoapsis to parkingOrbitIdeal + parkingOrbitTolerance.

If Ship:Orbit:Periapsis > Body:Atm:Height { 
    If Ship:Orbit:Periapsis > parkingOrbitMinPeriapsis and Ship:Orbit:Apoapsis > parkingOrbitMaxApoapsis { 
        flightStatus:Update("ESTABLISH PARKING ORBIT").
        Local hohmannTransfer to HohmannTransferController(flightStatus, parkingOrbitIdeal).
        hohmannTransfer:Engage(0.2, 0.05, 0.35, 60). // burnThrottle, finalizationThrottle, finalizationPercentage, alignmentMargin,        
    } Else { 
        flightStatus:Update("ACCEPT CURRENT ORBIT AS PARKING").
    }

    If Ship:Orbit:Periapsis < Body:Atm:Height { 
        flightStatus:Update("CREATE DEORBIT MNV.").

        Local deorbit to DeOrbitBurnController(flightStatus, 0.2, 0.1, 0.3, 50).    
        deorbit:DeOrbit(landingSite).
    }
    Else {
        flightStatus:Update("DEORBIT FAILURE").
        Shutdown.
    }
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

flightStatus:AddField("Is Overshooting", { Return isOvershooting. }).
flightStatus:AddField("Trajectory Error", { Return Round(landingStatus:TrajectoryErrorMeters(), 1) + "m". }).

Local maximumReasonableRangeError to 5_000. // The highest error expected to start after deorbit
Local maximumReasonableYawError to 5_000.

Local maxPitchErrorTolerance to 1_000.
Local maxYawErrorTolerance to 1_000.

Local maxYawErrorTolerance to 500.
Local defaultPitch to 55.
Local pitchMin to 10.
Local pitchMax to 85.
Local errorScale to 0.25.
Local yawRange to 20.

flightStatus:AddField("Pitch Min", pitchMin).
flightStatus:AddField("Pitch Max", pitchMax).
flightStatus:AddField("Error (Pitch)", { Return Round(pitchError, 1). }).
flightStatus:AddField("Error (Yaw)", { Return Round(yawError, 1). }).
flightStatus:AddField("Current Pitch", PitchOFVessel@).
flightStatus:AddField("Current Heading", HeadingOfVessel@).

Lock targetHeading to HeadingOfVector(landingSite:Position - Ship:Geoposition:Position).

Local targetPitch to 0.
Local correctiveHeading to 0.
Local correctiveRoll to 0.

Local bellyFlopStart to false. 
Until bellyFlopStart { 

    Local pitchUpperRange to pitchMax - defaultPitch.
    Local pitchLowerRange to defaultPitch - pitchMin.

    flightStatus:AddField("Pitch Upper Range", pitchUpperRange).
    flightStatus:AddField("Pitch Lower Range", pitchLowerRange).
    
    If Abs(pitchError) > maxPitchErrorTolerance { 

        Local errorPct to Abs(pitchError / maximumReasonableRangeError).
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

    If yawError > maxYawErrorTolerance { 

        Local errorPct to yawError / maximumReasonableYawError.
        Set errorPct to Min(1, errorPct).
        Set correctiveHeading to 0.

        If yawErrorIsRight {             
            Set correctiveHeading to -(targetHeading + (yawRange * errorPct)).
            Set correctiveRoll to 25.
        } Else { 
            Set correctiveHeading to targetHeading + (yawRange * errorPct).
            Set CorrectiveRoll to -25.
        }       
    } Else { 
        Set correctiveHeading to targetHeading.
        Set correctiveRoll to 0.
    }

    flightStatus:AddField("Corrective Pitch", targetPitch, false, true).
    flightStatus:AddField("Corrective Heading", correctiveHeading, false, true).
    flightStatus:AddField("Heading to Target", targetHeading, false, true).

    Lock Steering to Heading(correctiveHeading, targetPitch, correctiveRoll).

    Wait 0.01.
}

Wait Until Ship:Velocity:Surface:Mag < 700. 
Lock Steering to Heading(targetHeading, -20, 0).



Wait Until False.