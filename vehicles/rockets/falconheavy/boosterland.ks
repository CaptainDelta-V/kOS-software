@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("../../../common/exceptions").
RUNONCEPATH("../../../common/constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/landing/landingStatusModel").
RUNONCEPATH("../../../common/landing/landingSteeringModel").
RUNONCEPATH("../../../common/landing/landingBurnModel").
RUNONCEPATH("../../../common/landing/gridFinManager").
RUNONCEPATH("../../../common/landing/boostbackBurnController").
RUNONCEPATH("../../../common/flight/hover").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").

Parameter Params to Lexicon(
    KEY_BOOSTERSIDE, INDICATOR_BOOSTER_CORE,
    KEY_EXPEND_OPTION, KEY_PRESERVE_BOOSTER,
    KEY_VESSEL_TYPE, VESSEL_TYPE_FALCON_9
).
Parameter SkipBoostback to false.
Parameter Debug to true.

Local boosterSide to Params[KEY_BOOSTERSIDE].

If Params[KEY_EXPEND_OPTION] = BOOSTER_EXPEND_SIGNAL { 
    Clearscreen. 
    Print "Thank you for your service".
    Shutdown.
}

Set Ship:Name to ACTIVE_FALCON_BOOSTER_VESSEL_NAME + boosterSide.

Local partsTaggedNoCore to Ship:PartsTagged(ENGINES_MERLIN_9).
Local partsTaggedCore to Ship:PartsTagged(ENGINES_MERLIN_9_CORE).

Local merlinEngines to Choose partsTaggedCore[0] If partsTaggedCore:Length > 0 Else partsTaggedNoCore[0].
Local gridFins to Ship:PartsTagged("GRID_FIN").
Local engineController to EngineManager(merlinEngines, VESSEL_TYPE_FALCON_BOOSTER).
Local gridFinController to GridFinManager(gridFins, VESSEL_TYPE_FALCON_BOOSTER).

Local boosterRadarOffset to 25. 
Local suicideMargin to 200.
Local maxBurnStartAltitude to 4_500.
Local overshootMeters to 100. 
Local boostbackPitch to 0.
Local targetRoll to 0.
Local landingSiteAltitude to 60.
Local altitudePositionTarget to landingSiteAltitude.

// If boosterside = INDICATOR_BOOSTER_CORE { 
//     ClearScreen.
//     Print "EXPENDING BOOSTER. GOODBYE".
//     Shutdown.
// }

Local avionicsCpuName to LEFT_BOOSTER_AVIONICS_CPU_NAME.
Local landingSite to LANDING_SITES[KEY_KSC_LNDG_ZONE_SOUTH].
If boosterSide = INDICATOR_BOOSTER_RIGHT { 
    Set landingSite to LANDING_SITES[KEY_KSC_LNDG_ZONE_NORTH].
    Set avionicsCpuName to RIGHT_BOOSTER_AVIONICS_CPU_NAME.
}
Else If boosterSide = INDICATOR_BOOSTER_CORE { 
    If Params[KEY_VESSEL_TYPE] = VESSEL_TYPE_FALCON_HEAVY { 
        Set landingSite to LANDING_SITES[KEY_DS_OCEAN_MED].
    }
      
    Set avionicsCpuName to CORE_BOOSTER_AVIONICS_CPU_NAME.    
}

Local avionicsCpu to Processor(avionicsCpuName).
// Local isSideBooster to boosterSide = INDICATOR_BOOSTER_LEFT or boosterSide = INDICATOR_BOOSTER_RIGHT.
Local isSideBooster to boosterSide = INDICATOR_BOOSTER_LEFT or boosterSide = INDICATOR_BOOSTER_RIGHT. // not side booster and not core means the side booster that I am watching actively.
Local useCCAT to isSideBooster.
// Local useCCAT to boosterSide = INDICATOR_BOOSTER_LEFT or INDICATOR_BOOSTER_CORE.

Local flightStatus to FlightStatusModel("BOOSTER LANDING GUIDANCE (" + boosterSide + ")", "AWAITING INITIATION").
Local landingStatus to LandingStatusModel(landingSite, altitudePositionTarget, false, useCCAT):Overshoot(overshootMeters).
Local landingSteering to LandingSteeringModel(landingStatus).
Local landingBurn to LandingBurnModel(boosterRadarOffset).

flightStatus:AddField("TRAJECTORY DIST PRE BOOSTBACK", landingStatus:TrajectoryErrorMeters(), true).

// Local approachSlightUndershootRefSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(-200):GetLandingSite().

flightStatus:AddField("Target", { 
    Local site to landingStatus:GetLandingSite().
    Return site:lat + "," + site:lng.
}).
flightStatus:AddField("CCAT Avionics", { return useCCAT. }).
flightStatus:AddField("Impact Position", landingStatus:GetImpact@).
flightStatus:AddField("Traj. Error (m)", landingStatus:TrajectoryErrorMeters@).
flightStatus:AddField("Position Error (m)", landingStatus:PositionErrorMeters@).
flightStatus:AddField("Eccentricity", landingStatus:Eccentricity@).
flightStatus:AddField("Max Thrust", { Return Ship:AvailableThrust. }).

RunFlightStatusScreen(flightStatus, 0.25).
ResetTorque().

flightStatus:AddField("Target AoA CAPPED", landingSteering:GetTargetAoA@).
flightStatus:AddField("Target AoA RAW", landingSteering:GetTargetAoARaw@). 
flightStatus:AddField("Max AoA", landingSteering:GetMaxAoA@).   
flightStatus:AddField("Min AoA", landingSteering:GetMinAoA@). 
flightStatus:AddFIeld("Surface Mag", { Return Ship:Velocity:Surface:Mag. }).
flightStatus:AddField("Engine Mode", engineController:GetEngineMode@).
flightStatus:AddField("BoosterSide", boosterSide).
flightStatus:AddField("Is Core Booster", { return boosterSide = INDICATOR_BOOSTER_CORE. }).
flightStatus:AddField("Avail ThrustT", { return Ship:AvailableThrust. }).
flightStatus:AddField("MASS", { return Ship:Mass. }).
flightStatus:AddField("Stop Distnace:.", landingBurn:GetStopDistance@).
flightStatus:AddField("v/s", { return Ship:VerticalSpeed. }).
flightStatus:AddField("Throttle %", { Return Throttle. }).

flightStatus:Update("IDENTIFYING AVIONICS CPU").
avionicsCpu:Connection:SendMessage(AVIONICS_CPU_ASSIGN + "|" + Core:Tag).
Wait 0.5.
avionicsCpu:Connection:SendMessage(AVIONICS_CPU_RUN).
Wait 1.

Lock Throttle to 0.
SAS OFF. 
RCS ON.
Wait 0.

engineController:SetEngineState(true).
engineController:SetEngineMode(ENG_MODE_FN_MID_INR).
engineController:SetThrustLimit(100).

Local boostbackRequired to landingStatus:TrajectoryErrorMeters() > 2_000.
flightStatus:AddField("Boostback requried", boostbackRequired, true).

ClearVecDraws(). 
If Debug { 

    // Local arrowSize to 20.
    // Local directArrow to VecDraw(    
    //     V(0,0,0),
    //     V(0,0,0),
    //     RGB(1,1,1),
    //     "DIRECT",
    //     1.0,
    //     true,
    //     0.1,
    //     true,
    //     true
    // ).

    // Set directArrow:StartUpdater to { Return Ship:Position. }.
    // Set directArrow:VecUpdater to { Return landingSite:AltitudePosition(altitudePositionTarget):Normalized * arrowSize. }.

    // Local steeringRefRadialOutArrow to VecDraw(    
    //     V(0,0,0),
    //     V(0,0,0),
    //     RGB(1,1,1),
    //     "STEERING VECTOR RADIAL OUT",
    //     1.0,
    //     true,
    //     0.1,
    //     true,
    //     true
    // ).
}

If Not SkipBoostback and boostbackRequired { 
    flightStatus:Update("BOOSTBACK ORIENTATION").    
    flightStatus:AddField("ALIGNED", "NO").
    Local initHeading to landingStatus:HeadingFromImpactToTarget().                
    Lock Steering to Heading(initHeading, boostbackPitch).    
    WaitUntilOriented(2,2).
    flightStatus:AddField("ALIGNED", "YES").

    Local otherBoosterName to "None".
    If boosterSide = INDICATOR_BOOSTER_LEFT { 
        Set otherBoosterName to ACTIVE_FALCON_BOOSTER_VESSEL_NAME + INDICATOR_BOOSTER_RIGHT.
    }
    Else If boosterSide = INDICATOR_BOOSTER_RIGHT {
        Set otherBoosterName to ACTIVE_FALCON_BOOSTER_VESSEL_NAME + INDICATOR_BOOSTER_LEFT.
    } 
    Else If not (boosterSide = INDICATOR_BOOSTER_CORE) { 
        Throw("WTF").
    }
    
    If not (boosterSide = INDICATOR_BOOSTER_CORE) { 
        flightStatus:AddField("other booster name", otherBoosterName).
        Local otherBoosterVessel to Vessel(otherBoosterName).

        otherBoosterVessel:Connection:SendMessage(TWIN_BOOSTER_ALIGNMENT_MESSAGE).
    
        flightStatus:AddField("ALIGNED", "YES").    
        Wait 2.
    }

    // flightStatus:Update("AWAITING TWIN ALIGNMENT").

    // Local otherBoosterIsOriented to false. 
    // Until otherBoosterIsOriented { 
    //     If not Ship:Messages:Empty { 
    //         If Ship:Messages:Pop:Content = TWIN_BOOSTER_ALIGNMENT_MESSAGE { 
    //             Set otherBoosterIsOriented to true.
    //             flightStatus:Update("TWIN ALIGNMENT CONFIRMED").
    //         }
    //     }

    //     Wait 0.01.
    // }

    Local boostback to BoostbackBurnController(landingStatus, landingSteering).
    Local boostbackAbortAltitude to 36_000.    

    flightStatus:AddField("Trajectory at boostback start", landingStatus:GetImpact(), true).
    flightStatus:Update("BOOSTBACK BURN").

    Local minThrottle to Choose 0.05 If useCCAT Else 0.3.
    Local minError to Choose 3_000 If useCCAT Else 2_000.
    boostback:Engage(boostbackPitch, minError, 2, boostbackAbortAltitude, minThrottle, 0, 0, true).
    flightStatus:Update("Boostback complete").
}

Lock Steering to Up. 
Wait Until Ship:VerticalSpeed < -10. 
Lock Steering to landingSteering:SteeringVector().
landingStatus:SetLandingSite(landingSite).

// When IsGeoPosWestOf(Ship:GeoPosition, approachSlightUndershootRefSite) Then { 
    // landingStatus:SetLandingSite(landingSite).
// }

landingSteering:SetMaxAoa(14).

flightStatus:Update("TRAJECTORY COAST").
BRAKES ON.

landingSteering:SetMaxAoa(14).    
Lock Steering to landingSteering:SteeringVector().

Wait Until Altitude < 40_000. 
RCS OFF.

// Entry burn
Wait Until Altitude < 28_000.
Lock Throttle to 1. 
flightStatus:Update("Entry Burn Start").
Wait Until Ship:VerticalSpeed < 250.
Lock Throttle to 0.
flightStatus:Update("Entry Burn Complete").

Wait Until Altitude < 20_000. 
landingSteering:SetMaxAoA(11). 

Wait Until Altitude < 12_000. 
landingSteering:SetMaxAoA(5).

Wait Until Altitude < 4_000. 
landingSteering:SetMaxAoA(2).

Local padSiteSet to false. 
Until padSiteSet { 
    Set padSiteSet to Altitude < 10_000.
    Wait 0.01.
}

// Wait Until Altitude < 6_000.
// landingSteering:SetMaxAoA(4).

Set SteeringManager:RollTorqueFactor to 0.

Local landingBurnStart to false. 
Until landingBurnStart { 
    Set landingBurnStart to landingBurn:TrueRadar() < landingBurn:GetStopDistance() + suicideMargin
        and Altitude < maxBurnStartAltitude.
    Wait 0.001.
}

landingStatus:SetLandingSite(landingSite).

Lock Throttle to 1. 
Local vsTarget to -25.
landingSteering:SetMaxAoA(-4). 

flightStatus:Update("LANDING BURN").
flightStatus:AddField("TRUE RADAR", landingBurn:TrueRadar@).
flightStatus:AddField("LANDING BURN START ALT", Ship:Altitude, true).
flightStatus:AddField("LANDING BURN START PITCH", PitchOfVessel(), true).
flightStatus:AddField("LANDING BURN START RETRO PITCH ", PitchOfVector(-Ship:Velocity:Surface), true).
flightStatus:AddField("VS TARGET", vsTarget).

Local verticalSpeedHoldStart to false. 
Until verticalSpeedHoldStart { 
    Set verticalSpeedHoldStart to Abs(Ship:Velocity:Surface:Mag) < 86.6.      
    Wait 0.01. 
}

Lock Steering to landingSteering:SteeringVectorReferenceRadialOut().
// engineController:SetEngineMode(ENG_MODE_FN_MID_INR).
// Wait 0.
engineController:SetEngineMode(ENG_MODE_FN_CTR).

Local vsSpeedTargetStage0Set to false.
Local vsSpeedTargetStage1Set to false.
Local vsSpeedTargetStage2Set to false. 

When landingBurn:TrueRadar() < 120 Then { 
    GEAR ON.
    flightStatus:AddField("GEAR DEPLOYED AT", landingBurn:TrueRadar(), true).
    
    // landingSteering:SetErrorScaling(0.1).
    
}

When landingBurn:TrueRadar() < 10 Then { 
    // landingStatus:SetUsePositionOverTrajectory(true).    
    // avionicsCpu:Connection:SendMessage(AVIONICS_CPU_STOP).
    flightStatus:Update("LANDING").   
}

When landingBurn:TrueRadar() < 5 Then { 
    // landingStatus:SetLandingSite(landingStatus:GetImpact()).
    landingStatus:SetLandingSite(Ship:GeoPosition).
}

RunVerticalSpeedHold({
        If not vsSpeedTargetStage0Set and landingBurn:TrueRadar() < 300 {             
            Set vsSpeedTargetStage0Set to true. 
            landingSteering:SetMaxAoA(-2.5). 
        }

        If not vsSpeedTargetStage1Set and landingBurn:TrueRadar() < 100 { 
            Set vsTarget to -18.
            Set vsSpeedTargetStage1Set to true.
            landingSteering:SetMaxAoA(-1.5).  
        }

        If not vsSpeedTargetStage1Set and landingBurn:TrueRadar() < 50 { 
            Set vsTarget to -10.
            Set vsSpeedTargetStage1Set to true.
            landingSteering:SetMaxAoA(-1.5).  
        }

        If not vsSpeedTargetStage2Set and landingBurn:TrueRadar() < 25 { 
            Set vsTarget to -1.
            Set vsSpeedTargetStage2Set to true.
            // landingSteering:SetMaxAoA(-1.5).  
        }

        Return vsTarget.
    }, 
    60, // arbitrary duration
    0.1, 0.02, 0.0,  // PID
    0.1, { // Min/Max
        Local maxOutput to 1. 
        Return maxOutput.
    }, { // Get Actual
        Return Ship:VerticalSpeed.   
    }, 
    {  // Terminator
        Return Ship:Status = "LANDED" or Ship:Status = "SPLASHED".
    }).

Lock Throttle to 0.
Set Ship:Control:PilotMainThrottle to 0.
Lock Steering to Ship:Up.
Set Core:Bootfilename to "".
RCS ON.
flightStatus:Update("TERMINAL").
ClearVecDraws().

Wait 5. 
RCS OFF.
Shutdown.

Wait Until False. 
