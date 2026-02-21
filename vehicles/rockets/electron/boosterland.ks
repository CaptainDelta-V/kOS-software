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
RUNONCEPATH("../../../common/systems/drainValveManager").


Parameter SkipBoostback to false.
Parameter SkipWaitForInitiationMessage to true.

Local flightStatus to FlightStatusModel("ELECTRON BOOSTER LANDING GUIDANCE").
Local boosterRadarOffset to 34.3.
Local overshootMeters to 100.
Local landingSiteAltitude to 5.
Local altitudePositionTarget to landingSiteAltitude.                                      
Local truelandingSite to LANDING_SITES[KEY_DS_OCEAN_SHORT].
Local landingsite to LandingStatusModel(truelandingsite, altitudePositionTarget):Overshoot(200):GetLandingSite(). 
Local rollReferenceOvershootSite is LandingStatusModel(truelandingSite, altitudePositionTarget):Overshoot(10000):GetLandingSite().

Local landingStatus to LandingStatusModel(landingSite, altitudePositionTarget, false):Overshoot(overshootMeters).
Local landingSteering to LandingSteeringModel(landingStatus).
Local landingBurn to LandingBurnModel(boosterRadarOffset) .

flightStatus:AddField("TARGET COORDS", { 
    Local site to landingStatus:GetLandingSite().
    Return site:lat + "," + site:lng.
}).
flightStatus:AddField("LATITUDE ERROR", landingStatus:LatitudeError@).
flightStatus:AddField("LONGITUDE ERROR", landingStatus:LongitudeError@).
flightStatus:AddField("TRAJECTORY ERROR (m)", landingStatus:TrajectoryErrorMeters@).
flightStatus:AddField("POSITION ERROR (m)", landingStatus:PositionErrorMeters@).


RunFlightStatusScreen(flightStatus).


RCS on.

Local boostbackRequirementErrorThreshold to 20_000.
Local boostbackPitch to 10.
Local targetRoll to 0.


Lock Steering to Heading(landingStatus:RetrogradeHeading(), boostbackPitch, targetRoll).

WaitUntilOriented(1.5,10). 
flightStatus:Update("BOOSTBACK ORIENTATION").        
         
Local boostback to BoostbackBurnController(landingStatus, landingSteering).
Local boostbackAbortAltitude to 32_000.

flightStatus:Update("BOOSTBACK ITERATION: 1").
boostback:Engage(boostbackPitch, 1_000, 1, boostbackAbortAltitude, 0.3, 60, 850).

Local iteration2RequiredError to 500.
    If landingStatus:TrajectoryErrorMeters() > iteration2RequiredError { 
        flightStatus:Update("BOOSTBACK ITERATION: 2").
        boostback:Engage(boostbackPitch, iteration2RequiredError, 0.00005, boostbackAbortAltitude, 0.3).
    }

flightStatus:AddField("Steering", "Steering Vector").
Lock Steering to landingSteering:SteeringVector(). 

flightStatus:AddField("Max AoA", landingSteering:GetMaxAoA@).
flightStatus:AddField("Target AoA Raw", landingSteering:GetTargetAoARaw@).
flightStatus:AddField("Retrograde pitch", { Return PitchOfVector(-Ship:Velocity:Surface). }).

flightStatus:Update("Landing").

When altitude < 4_000 then {
    AG4 on.
}

When altitude < 2_200 then {
    AG5 on.
    Wait 1.
    AG6 on.
}




Wait Until false.
