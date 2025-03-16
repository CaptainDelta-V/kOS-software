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

Parameter BoosterSide to "LEFT". 
Parameter SkipBoostback to false.
Parameter Debug to true.

// Set Ship:Name to ACTIVE_FALCON_BOOSTER_VESSEL_NAME + BoosterSide.
Local engineTag to "MERLIN_9".

// If BoosterSide = "CORE" { 
//     Set engineTag to engineTag + "CORE".
// } 
// Else If BoosterSide = "LEFT" { 
//     Set engineTag to engineTag + "LEFT". 
// }
// Else If BoosterSide = "RIGHT" { 
//     Set engineTag to engineTag + "RIGHT". 
// }

Local merlinEngines to Ship:PartsTagged(engineTag)[0].
Local gridFins to Ship:PartsTagged("GRID_FIN").
Local engineController to EngineManager(merlinEngines, VESSEL_TYPE_FALCON_BOOSTER).
Local gridFinController to GridFinManager(gridFins, VESSEL_TYPE_FALCON_BOOSTER).

Local boosterRadarOffset to 32. 
Local suicideMargin to 100.
Local maxBurnStartAltitude to 2_800.
Local overshootMeters to 25. 
Local boostbackPitch to 0.
Local targetRoll to 0.
Local landingSite to LANDING_SITES[KEY_KSC_LNDG_ZONE_NORTH].
Local landingSiteAltitude to 111.
Local altitudePositionTarget to landingSiteAltitude + boosterRadarOffset.

Local flightStatus to FlightStatusModel("BOOSTER LANDING GUIDANCE", "AWAITING INITIATION").
Local landingStatus to LandingStatusModel(landingSite, altitudePositionTarget).
Local landingSteering to LandingSteeringModel(landingStatus).
Local landingBurn to LandingBurnModel(boosterRadarOffset).

flightStatus:AddField("TARGET", { 
    Local site to landingStatus:GetLandingSite().
    Return site:lat + "," + site:lng.
}).
flightStatus:AddField("TRAJECTORY ERROR (M)", landingStatus:TrajectoryErrorMeters@).
flightStatus:AddField("POSITION ERROR (M)", landingStatus:PositionErrorMeters@).
flightStatus:AddField("ECCENTRICITY", landingStatus:Eccentricity@).

RunFlightStatusScreen(flightStatus, 0.25).
ResetTorque().

flightStatus:AddField("TARGET AoA CAPPED", landingSteering:GetTargetAoA@).
flightStatus:AddField("TARGET AoA RAW", landingSteering:GetTargetAoARaw@). 
flightStatus:AddField("MIN AoA", landingSteering:GetMaxAoA@).   
flightStatus:AddField("MAX AoA", landingSteering:GetMinAoA@). 
flightStatus:AddFIeld("SURFACE MAG", { Return Ship:Velocity:Surface:Mag. }).
flightStatus:AddField("ENGINE MODE", engineController:GetEngineMode()).

Lock Throttle to 0.
SAS OFF. 
RCS ON.
Wait 0.

engineController:SetEngineState(true).
engineController:SetEngineState(ENG_MODE_MID_INR).
engineController:SetThrustLimit(100).

If Not SkipBoostback { 
    flightStatus:Update("BOOSTBACK ORIENTATION").        
    WaitUntilOriented().

    Local boostback to BoostbackBurnController(landingStatus, landingSteering).
    Local boostbackAbortAltitude to 30_000. 

    flightStatus:Update("BOOSTBACK ITERATION: 1").
    boostback:Engage(boostbackPitch, 5_000, 0.00005, boostbackAbortAltitude, 0.3).

    Local iteration2RequiredError to 500.
    if landingStatus:TrajectoryErrorMeters() > iteration2RequiredError { 
        flightStatus:Update("BOOSTBACK ITERATION: 2").
        boostback:Engage(boostbackPitch, iteration2RequiredError, 0.00005, boostbackAbortAltitude, 0.3).
    }
}

flightStatus:Update("TRAJECTORY COAST").
Brakes ON.

landingSteering:SetMaxAoa(20).    
Lock Steering to LookDirUp(landingSteering:SteeringVector(), landingSite:Position).                

Wait Until False. 
