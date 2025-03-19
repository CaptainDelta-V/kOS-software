@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
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

Parameter Params to Lexicon(KEY_BOOSTERSIDE, INDICATOR_BOOSTER_CORE).
Parameter SkipBoostback to false.
Parameter Debug to true.

Local boosterSide to Params["boosterSide"].

Set Ship:Name to ACTIVE_FALCON_BOOSTER_VESSEL_NAME + boosterSide.
Local engineTag to "MERLIN_9".

Local merlinEngines to Ship:PartsTagged(engineTag)[0].
Local gridFins to Ship:PartsTagged("GRID_FIN").
Local engineController to EngineManager(merlinEngines, VESSEL_TYPE_FALCON_BOOSTER).
Local gridFinController to GridFinManager(gridFins, VESSEL_TYPE_FALCON_BOOSTER).

Local boosterRadarOffset to 32. 
Local suicideMargin to 200.
Local maxBurnStartAltitude to 3_800.
Local overshootMeters to 200. 
Local boostbackPitch to 0.
Local targetRoll to 0.
Local landingSiteAltitude to 111.
Local altitudePositionTarget to landingSiteAltitude + boosterRadarOffset.

Local avionicsCpuName to LEFT_BOOSTER_AVIONICS_CPU_NAME.
Local landingSite to LANDING_SITES[KEY_KSC_LNDG_ZONE_NORTH].
If boosterSide = INDICATOR_BOOSTER_RIGHT { 
    Set landingSite to LANDING_SITES[KEY_KSC_LNDG_ZONE_SOUTH].
    Set avionicsCpuName to RIGHT_BOOSTER_AVIONICS_CPU_NAME.
}

Local avionicsCpu to Processor(avionicsCpuName).
Local isSideBooster to boosterSide = INDICATOR_BOOSTER_LEFT or boosterSide = INDICATOR_BOOSTER_RIGHT.

Local flightStatus to FlightStatusModel("BOOSTER LANDING GUIDANCE (" + boosterSide + ")", "AWAITING INITIATION").
Local landingStatus to LandingStatusModel(landingSite, altitudePositionTarget, false, isSideBooster):Overshoot(overshootMeters).
Local landingSteering to LandingSteeringModel(landingStatus).
Local landingBurn to LandingBurnModel(boosterRadarOffset).

flightStatus:AddField("TARGET", { 
    Local site to landingStatus:GetLandingSite().
    Return site:lat + "," + site:lng.
}).
flightStatus:AddField("CCAT AVIONICS", { return isSideBooster. }).
flightStatus:AddField("IMPACT POS", landingStatus:GetImpact@).
flightStatus:AddField("TRAJECTORY ERROR (m)", landingStatus:TrajectoryErrorMeters@).
flightStatus:AddField("POSITION ERROR (m)", landingStatus:PositionErrorMeters@).
flightStatus:AddField("ECCENTRICITY", landingStatus:Eccentricity@).

RunFlightStatusScreen(flightStatus, 0.25).
ResetTorque().

flightStatus:AddField("TARGET AoA CAPPED", landingSteering:GetTargetAoA@).
flightStatus:AddField("TARGET AoA RAW", landingSteering:GetTargetAoARaw@). 
flightStatus:AddField("MIN AoA", landingSteering:GetMaxAoA@).   
flightStatus:AddField("MAX AoA", landingSteering:GetMinAoA@). 
flightStatus:AddFIeld("SURFACE MAG", { Return Ship:Velocity:Surface:Mag. }).
flightStatus:AddField("ENGINE MODE", engineController:GetEngineMode@).
flightStatus:AddField("BoosterSide", boosterSide).
flightStatus:AddField("isCore", { return boosterSide = INDICATOR_BOOSTER_CORE. }).

flightStatus:Update("INITIATING AVIONICS CPU").
avionicsCpu:Connection:SendMessage(AVIONICS_CPU_ASSIGN + "|" + Core:Tag).
Wait 0.5.
avionicsCpu:Connection:SendMessage(AVIONICS_CPU_RUN).
Wait 1.

Lock Throttle to 0.
SAS OFF. 
RCS ON.
Wait 0.

engineController:SetEngineState(true).
engineController:SetEngineMode(ENG_MODE_SH_MID_INR).
engineController:SetThrustLimit(100).
RCS ON.

If Not SkipBoostback { 
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
    Else { 
        Throw("WTF").
    }
    
    flightStatus:AddField("other booster name", otherBoosterName).
    Local otherBoosterVessel to Vessel(otherBoosterName).

    otherBoosterVessel:Connection:SendMessage(TWIN_BOOSTER_ALIGNMENT_MESSAGE).
  
    flightStatus:AddField("ALIGNED", "YES").    
    Wait 2.
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
    Local boostbackAbortAltitude to 45_000. 

    flightStatus:Update("BOOSTBACK ITERATION: 1").
    boostback:Engage(boostbackPitch, 20_000, 0, boostbackAbortAltitude, 0.3, 0, 0, true).

    // If boosterSide = INDICATOR_BOOSTER_LEFT { 
        
    // }

    // Local iteration2RequiredError to 500.
    // if landingStatus:TrajectoryErrorMeters() > iteration2RequiredError { 
    //     flightStatus:Update("BOOSTBACK ITERATION: 2").
    //     boostback:Engage(boostbackPitch, iteration2RequiredError, 0.00005, boostbackAbortAltitude, 0.3).
    // }
}

flightStatus:Update("TRAJECTORY COAST").
BRAKES ON.

landingSteering:SetMaxAoa(20).    
Lock Steering to landingSteering:SteeringVector().

Wait Until Altitude < 20_000. 
landingSteering:SetMaxAoA(12). 

Wait Until Altitude < 12_000. 
landingSteering:SetMaxAoA(8).

Wait Until Altitude < 6_000.
landingStatus:SetLandingSite(landingSite).

Wait Until Altitude < maxBurnStartAltitude. 

landingSteering:SetMaxAoA(5).
Local landingBurnStart to false. 
Until landingBurnStart { 
    Set landingBurnStart to landingBurn:TrueRadar() < landingBurn:GetStopDistance() + suicideMargin.
}
RCS OFF.
Lock Steering to landingSteering:SteeringVectorReferenceRadialOut().
landingSteering:SetMaxAoA(-5).

Lock Throttle to 1. 
Local vsTarget to -25.
flightStatus:AddField("VS TARGET", vsTarget).

Local verticalSpeedHoldStart to false. 
Until verticalSpeedHoldStart { 
    Set verticalSpeedHoldStart to Abs(Ship:Velocity:Surface:Mag < 140).
    engineController:SetEngineMode(ENG_MODE_FN_CTR).
    Wait 0.01. 
}

landingSteering:SetMaxAoA(-8).
Local vsSpeedTargetStage1Set to false.
Local vsSpeedTargetStage2Set to false. 

When Alt:Radar < 800 Then { 
    GEAR ON.
    // landingStatus:SetUsePositionOverTrajectory(true).
    // avionicsCpu:Connection:SendMessage(AVIONICS_CPU_STOP).
}

RunVerticalSpeedHold({
    If not vsSpeedTargetStage1Set and landingBurn:TrueRadar() < 100 { 
        Set vsTarget to -Abs(-10).
        Set vsSpeedTargetStage1Set to true.
    }

    If not vsSpeedTargetStage2Set and landingBurn:TrueRadar() < 15 { 
        Set vsTarget to -Abs(-1).
        Set vsSpeedTargetStage2Set to true.
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
        Return Ship:Status = "LANDED".
    }).

Lock Throttle to 0.
flightStatus:Update("TERMINAL").
ClearVecDraws().
Shutdown.

Wait Until False. 
