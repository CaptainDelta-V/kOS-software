@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("0:vehicles/rockets/starship/constants").
RUNONCEPATH("0:vehicles/rockets/starship/shipSystemsManager").
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

// TODO: Ship fuel balance to header tank. deploy fins, control rcs

ClearScreen.
ClearVecDraws(). 

Local flightStatus to FlightStatusModel("ENTRY GUIDANCE v1", "AWAITING INITIATION").

flightStatus:AddField("ETA APOAPSIS", { return Ship:Orbit:ETA:Apoapsis. }).
flightStatus:AddField("ETA PERIAPSIS", { return Ship:Orbit:ETA:Periapsis. }).

RunFlightStatusScreen(flightStatus).

Local frontLeftFlap to Ship:PartsTagged("FL_FLAP")[0].
Local frontRightFlap to Ship:PartsTagged("FR_FLAP")[0].
Local rearLeftFlap to Ship:PartsTagged("RL_FLAP")[0].
Local rearRightFlap to Ship:PartsTagged("RR_FLAP")[0].
Local shipSystemsController to ShipSystemsManager(List(frontLeftFlap, frontRightFlap), List(rearLeftFlap, rearRightFlap)).

shipSystemsController:SetFrontFlapsControlActive(false).
shipSystemsController:SetRearFlapsControlActive(false).

shipSystemsController:SetFrontFlapsDeployAngle(SS_FLAP_MAX_ANGLE).
shipSystemsController:SetRearFlapsDeployAngle(SS_FLAP_MAX_ANGLE).

Wait 0.

shipSystemsController:DeployFrontFlaps(false).
shipSystemsController:DeployRearFlaps(true).

Local landingSite to LANDING_SITES[KEY_KSC_LNDG_ZONE_NORTH].

SetTrajectoriesForDescent(70).
Addons:TR:SetTarget(landingSite).

Local pitchMax to 47. 
Local pitchMin to 43. 

Local parkingOrbitTolerance to 1_000.
Local parkingOrbitIdeal to Body:Atm:Height + parkingOrbitTolerance. 
Local parkingOrbitMinPeriapsis to parkingOrbitIdeal - parkingOrbitTolerance. 
Local parkingOrbitMaxApoapsis to parkingOrbitIdeal + parkingOrbitTolerance.

If Ship:Orbit:Periapsis > Body:Atm:Height { 

    // shipSystemsController:EngageVacEngines(true).
    // shipSystemsController:EngageSeaEngines(false).

    // If Ship:Orbit:Periapsis > parkingOrbitMinPeriapsis and Ship:Orbit:Apoapsis > parkingOrbitMaxApoapsis { 
    //     flightStatus:Update("ESTABLISH PARKING ORBIT").
    //     Local hohmannTransfer to HohmannTransferController(flightStatus, parkingOrbitIdeal).
    //     hohmannTransfer:Engage(0.2, 0.1, 0.35, 30). // burnThrottle, finalizationThrottle, finalizationPercentage, alignmentMargin,        
    // } Else { 
    //     flightStatus:Update("ACCEPT CURRENT ORBIT AS PARKING").
    // }

    flightStatus:Update("CREATE DEORBIT MNV.").

    Local deorbit to DeOrbitBurnController(flightStatus, 1, 0.4, 0.05, 42).    
    deorbit:DeOrbit(landingSite, 15_000).
    // If Ship:Orbit:Periapsis < Body:Atm:Height { 
      
    // }
    // Else {
    //     flightStatus:Update("DEORBIT FAILURE").
    //     Shutdown.
    // }
}

RemoveAllNodes().
flightStatus:Update("DESCENT").

// shipSystemsController:EngageVacEngines(false).
// shipSystemsController:EngageSeaEngines(true).

flightStatus:RemoveField("ETA APOAPSIS").
flightStatus:RemoveField("ETA PERIAPSIS").
Wait 1.

flightStatus:Update("PREPARING FOR THE HEAT").
// RCS ON.
AG6 ON.

Local landingStatus to LandingStatusModel(landingSite):Overshoot(0).
Lock isOvershooting to IsGeoPosWestOf(landingStatus:GetLandingSite(), landingStatus:GetImpact()).
Lock pitchError to landingStatus:ErrorVector():X.
Lock yawError to landingStatus:ErrorVector():Y. 
Lock yawErrorIsRight to yawError < 0.

Lock zError to landingStatus:ErrorVector():Z.

flightStatus:AddField("Is Overshooting", { Return isOvershooting. }).
flightStatus:AddField("Trajectory Error", { Return Round(landingStatus:TrajectoryErrorMeters(), 1) + "m". }).

flightStatus:AddField("Pitch Min", pitchMin).
flightStatus:AddField("Pitch Max", pitchMax).
flightStatus:AddField("Error (Pitch)", { Return Round(pitchError, 1). }).
flightStatus:AddField("Error (Yaw)", { Return Round(yawError, 1). }).
flightStatus:AddField("Error (Z)", { Return Round(zError, 1). }).
flightStatus:AddField("Current Pitch", { Return Round(PitchOFVessel(), 2). }).
flightStatus:AddField("Current Heading", { Return Round(HeadingOfVessel(), 2). }).
flightStatus:AddField("Pitch of Retrograde", { Return PitchOfVector(-Ship:Velocity:Surface). }).

Lock targetHeading to HeadingOfVector(landingSite:Position - Ship:Geoposition:Position).

// Lock Steering to Heading(correctiveHeading, targetPitch, correctiveRoll).
Lock Steering to Addons:TR:PlannedVec.

Local bellyFlopStart to false. 
Until bellyFlopStart { 

    Local correctedVector to Addons:TR:CorrectedVec.
    Local plannedVector to Addons:TR:PlannedVec.

    flightStatus:AddField("Pitch of planned vector", PitchOfVector(plannedVector)).
    flightStatus:AddField("Heading of planned vector", PitchOfVector(plannedVector)).
    flightStatus:AddField("Pitch of corrected vector", PitchOfVector(correctedVector)).
    flightStatus:AddField("Heading of corrected vector", PitchOfVector(correctedVector)).

    Set bellyFlopStart to Ship:Velocity:Surface:Mag < 300.
    Wait 0.01.
}

shipSystemsController:DeployFrontFlaps(false).
shipSystemsController:DeployRearFlaps(false).


flightStatus:Update("Belly Flopping").
Lock Steering to Heading(targetHeading, 0, 0).

Local fuelTransferStart to false. 
Until fuelTransferStart  { 
    Set fuelTransferStart to Alt:Radar < 620.
}
flightStatus:Update("Fuel Transfer").

shipSystemsController:FuelToRear().

Local landingBurnStart to false. 
Until landingBurnStart { 

    Set landingBurnStart to Alt:Radar < 560.
    Wait 0.01.
}

shipSystemsController:DeployFrontFlaps(true).
shipSystemsController:DeployRearFlaps(false).


Lock Steering to RadialOutVectorNormalized().
Lock Throttle to 1.

Local startVsHold to false.

Local startVsHold to false. 
Until startVsHold { 

    If (not startVsHold and PitchOfVector(-Ship:Velocity:Surface) > 60) {
        flightStatus:Update("VS Hold").
        Set startVsHold to true.         
    }

    Wait 0.01.
}

Set landingStatus to LandingStatusModel(Ship:GeoPosition, 2).
Local landingSteering to LandingSteeringModel(landingStatus).
Local landingBurn to LandingBurnModel(42).  

When landingBurn:TrueRadar() < 300 Then { 
    landingStatus:SetLandingSite(Ship:GeoPosition).
}

When landingBurn:TrueRadar() < 100 Then { 
    landingStatus:SetLandingSite(Ship:GeoPosition).
}

When landingBurn:TrueRadar() < 100 Then { 
    landingStatus:SetLandingSite(Ship:GeoPosition).
}

When landingBurn:TrueRadar() < 50 Then { 
    landingStatus:SetLandingSite(Ship:GeoPosition).
}


landingSteering:SetMaxAoA(-35).
Lock Steering to landingSteering:SteeringVectorHorizontalKill().


flightStatus:AddField("Vertical Speed", { Return Ship:VerticalSpeed. }).

flightStatus:Update("VS Hold").
RunVerticalSpeedHold({             
        Local vsTarget to -20.

        If landingBurn:TrueRadar() < 100 { 
            landingSteering:SetMaxAoa(-12).
            Set vsTarget to -10.
        }

        If landingBurn:TrueRadar() < 50 { 
            landingSteering:SetMaxAoa(-8).
            Set vsTarget to -5.
        }

        If landingBurn:TrueRadar() < 10 { 
            landingSteering:SetMaxAoa(-4).
            Set vsTarget to -2.
        }

        Return vsTarget.                
    },
    60, // arbitrary max duration
    0.1, 0.02, 0.0, // PID
    0.35, { // min/max
        Local maxOutput to 1.
        
        Return maxOutput.
    }, 
    { 
        // Get actual
        Return Ship:VerticalSpeed. 
    },
    {        
        Return Ship:Status = "LANDED" or Ship:Status = "SPLASHED".
    }).     


// Lock Steering to RadialOutVectorNormalized().

Set Ship:Control:PilotMainThrottle to 0.


// Wait Until False.