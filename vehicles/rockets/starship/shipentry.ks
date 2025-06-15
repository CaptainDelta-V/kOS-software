@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/systems/drainValveManager").
RUNONCEPATH("../../../common/orbit/hohmannTransferController").
RUNONCEPATH("../../../common/landing/deOrbitBurnController").
RUNONCEPATH("../../../common/landing/landingStatusModel").
RUNONCEPATH("../../../common/landing/landingSteeringModel").
RUNONCEPATH("../../../common/landing/landingBurnModel").
RUNONCEPATH("../../../common/flight/hover").
RUNONCEPATH("../../../common/seeking/pidModel").
RUNONCEPATH("../../../common/math").

ClearScreen.
ClearVecDraws(). 

Local flightStatus to FlightStatusModel("STARSHIP ENTRY GUIDANCE", "AWAITING INITIATION").

flightStatus:AddField("ETA APOAPSIS", { return Ship:Orbit:ETA:Apoapsis. }).
flightStatus:AddField("ETA PERIAPSIS", { return Ship:Orbit:ETA:Periapsis. }).

// GetLaunchConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.5).

Local landingSite to LatLng(-0.123942125673094,-74.4642469768736). // OLM
Local landingOvershootMeters to 1_000. 

Local pitchMax to 75. 
Local pitchMin to 25. 

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
RCS ON.
AG6 ON.

Local landingStatus to LandingStatusModel(landingSite):Overshoot(landingOvershootMeters).
Lock isOvershooting to IsGeoPosWestOf(landingStatus:GetLandingSite(), landingStatus:GetImpact()).
Lock pitchError to landingStatus:ErrorVector():X.
Lock yawError to landingStatus:ErrorVector():Y. 
Lock yawErrorIsRight to yawError < 0.

flightStatus:AddField("Is Overshooting", { Return isOvershooting. }).
flightStatus:AddField("Trajectory Error", { Return Round(landingStatus:TrajectoryErrorMeters(), 1) + "m". }).

Local maxErrorTolerance to 1_000.
Local defaultPitch to 55.
Local pitchMin to 10.
Local pitchMax to 75.
Local pitchErrorScale to 0.25.
Local yawRange to 20.

flightStatus:AddField("Pitch Min", pitchMin).
flightStatus:AddField("Pitch Max", pitchMax).
flightStatus:AddField("Error (Pitch)", { Return Round(pitchError, 1). }).
flightStatus:AddField("Error (Yaw)", { Return Round(yawError, 1). }).
flightStatus:AddField("Current Pitch", PitchOFVessel@).
flightStatus:AddField("Current Heading", HeadingOfVessel@).

Local pitchPid to PidModel(
        0.01, 0.02, 0, // p,i,d    
        pitchMin, pitchMax
    ).

pitchPid:UpdateSetpoint(0).

Local yawPid to PidModel( 
    0.01, 0.02, 0 // p,i,d        
).

Lock targetPitch to pitchPid:GetCalcOut().
Lock targetHeading to HeadingOfVector(landingSite:Position - Ship:Geoposition:Position).
Lock Steering to Heading(targetHeading, targetPitch, 0).

Local bellyFlopStart to false. 
Until bellyFlopStart { 

    pitchPid:SetMinOutput(pitchMin).
    pitchPid:SetMaxOutput(pitchMax).
    
    Local pitchErrorScaled to pitchError * pitchErrorScale.
    pitchPid:Update(pitchErrorScaled).
    flightStatus:AddField("Pitch Error Scaled", pitchErrorScaled, false, true).
    flightStatus:AddField("Pitch PID Out", pitchPid:GetCalcOut@, false, true). 
    

    Wait 0.001.
}



// When landingStatus:TrajectoryErrorMeters() > maxErrorTolerance Then { 
//     If isOvershooting { 
//         flightStatus:AddField("Pitch Adjust", "max").
//         Lock Steering to Heading(targetHeading, maxPitch, 0).
//     }
//     Else { 
//         flightStatus:AddField("Pitch Adjust", "min").
//         Lock Steering to Heading(targetHeading, minPitch, 0).
//     }
//     Preserve.
// }

// When landingStatus:TrajectoryErrorMeters() > maxErrorTolerance Then { 
//     flightStatus:AddField("Pitch Adjust", "default").
//         Lock Steering to Heading(targetHeading, defaultPitch, 0).
// }

Wait Until Ship:Velocity:Surface:Mag < 700. 
Lock Steering to Heading(targetHeading, -20, 0).



Wait Until False.