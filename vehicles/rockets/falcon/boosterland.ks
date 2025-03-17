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

Parameter Params to Lexicon().
Parameter SkipBoostback to false.
Parameter Debug to true.

Set Ship:Name to ACTIVE_FALCON_BOOSTER_VESSEL_NAME.
Local engineTag to "MERLIN_9".

Local merlinEngines to Ship:PartsTagged(engineTag)[0].
Local gridFins to Ship:PartsTagged("GRID_FIN").
Local engineController to EngineManager(merlinEngines, VESSEL_TYPE_FALCON_BOOSTER).
Local gridFinController to GridFinManager(gridFins, VESSEL_TYPE_FALCON_BOOSTER).

Local boosterRadarOffset to 32. 
Local suicideMargin to -400.
Local maxBurnStartAltitude to 2_800.
Local overshootMeters to 100. 
Local boostbackPitch to 0.
Local targetRoll to 0.
Local landingSiteAltitude to 111.
Local altitudePositionTarget to landingSiteAltitude + boosterRadarOffset.

Local landingSite to LANDING_SITES[KEY_KSC_LNDG_ZONE_SOUTH].

Local flightStatus to FlightStatusModel("BOOSTER LANDING GUIDANCE", "AWAITING INITIATION").
Local landingStatus to LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(overshootMeters).
Local landingSteering to LandingSteeringModel(landingStatus).
Local landingBurn to LandingBurnModel(boosterRadarOffset).

flightStatus:AddField("TARGET", { 
    Local site to landingStatus:GetLandingSite().
    Return site:lat + "," + site:lng.
}).
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

Lock Throttle to 0.
SAS OFF. 
RCS ON.
Wait 0.

engineController:SetEngineState(true).
engineController:SetEngineMode(ENG_MODE_MID_INR).
engineController:SetThrustLimit(100).
RCS ON.

If Not SkipBoostback { 
    flightStatus:Update("BOOSTBACK ORIENTATION").    
    Local initHeading to landingStatus:HeadingFromImpactToTarget().                
    Lock Steering to Heading(initHeading, boostbackPitch).    
    WaitUntilOriented(2,2).

    If not boosterSide = INDICATOR_BOOSTER_CORE { 
        flightStatus:AddField("no", "no").
    }

    Local boostback to BoostbackBurnController(landingStatus, landingSteering).
    Local boostbackAbortAltitude to 38_000. 

    flightStatus:Update("BOOSTBACK ENGAGED").
    boostback:Engage(boostbackPitch, 5_000, -1, boostbackAbortAltitude, 0.3, 0, 0, true).
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
    Set landingBurnStart to landingBurn:TrueRadar() < landingBurn:GetSuicideBurnAltitude() + suicideMargin.
}

Lock Throttle to 1. 
Local vsTarget to -16.
flightStatus:AddField("VS TARGET", vsTarget).

Local verticalSpeedHoldStart to false. 
Until verticalSpeedHoldStart { 
    Set verticalSpeedHoldStart to Abs(Ship:Velocity:Surface:Mag < 140).
    engineController:SetEngineMode(ENG_MODE_CTR).
    Wait 0.01. 
}

landingSteering:SetMaxAoA(-5).
Local vsSpeedTargetStage1Set to false.

When Alt:Radar < 600 Then { 
    GEAR ON.
}

RunVerticalSpeedHold({
        If not vsSpeedTargetStage1Set and landingBurn:TrueRadar() < 100 { 
            Set vsTarget to -Abs(-10).
            Set vsSpeedTargetStage1Set to true.
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
