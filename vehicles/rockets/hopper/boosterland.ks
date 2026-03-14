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
RUNONCEPATH("../../../common/systems/drainValveManager").


Parameter SkipBoostback to false.
Parameter SkipWaitForInitiationMessage to true.

Local flightStatus to FlightStatusModel("HOPPER LANDING GUIDANCE").
Local boosterRadarOffset to 11.8.
Local overshootMeters to 100.
Local landingSiteAltitude to 5.
Local altitudePositionTarget to landingSiteAltitude.                                      
Local truelandingSite to LANDING_SITES[KEY_KSC_LNDG_ZONE_NORTH].
Local landingsite to LandingStatusModel(truelandingsite, altitudePositionTarget):Overshoot(200):GetLandingSite(). 
Local rollReferenceOvershootSite is LandingStatusModel(truelandingSite, altitudePositionTarget):Overshoot(10000):GetLandingSite().

Local landingStatus to LandingStatusModel(landingSite, altitudePositionTarget, false):Overshoot(overshootMeters).
Local landingSteering to LandingSteeringModel(landingStatus).
Local landingBurn to LandingBurnModel(boosterRadarOffset) .


Local gridFins to Ship:PartsTagged("FIN").
Local gridFinController to GridFinManager(gridFins, VESSEL_TYPE_HOPPER).



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
AG1 on.

Local boostbackRequirementErrorThreshold to 20_000.
Local boostbackPitch to 10.
Local targetRoll to 0.


Lock Steering to Heading(landingStatus:RetrogradeHeading(), boostbackPitch, targetRoll).

WaitUntilOriented(2,10). 
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

flightStatus:Update("POST BOOSTBACK COAST").




Wait Until Altitude < 80_000.
    flightStatus:Update("FIN CORRECTIONS").                   
    flightStatus:AddField("TRUE RADAR", landingBurn:TrueRadar@).
    flightStatus:AddField("RADAR OFFSET", landingBurn:GetRadarOffset@).
    flightStatus:AddField("IMPACT TIME", landingBurn:ImpactTime@).    

    gridFinController:SetEnabled(true).
    gridFinController:SetAuthorityLimit(25).        
    landingStatus:SetTargetAltitude(0).        

    flightStatus:Update("DIRECT TRAJECTORY").
    Wait 3.

    // Set SteeringManager:RollTorqueFactor to 0.
    landingSteering:SetMaxAoa(60).


Wait Until Altitude < 60_000.
    flightStatus:Update("PRE LANDING BURN").            

Local lastVerticalSpeed to Ship:VerticalSpeed.
Local landingBurnStart to false.     
Until landingBurnStart {

    Local aeroMaxAoA to 10.
    Local referenceMaxError to 50_000.

    If Altitude < 8_000 { 
        Set aeroMaxAoA to 12.
        landingStatus:SetLandingSite(truelandingSite).
        Set referenceMaxError to 500.
    } Else If Altitude < 12_000 { 
        Set aeroMaxAoA to 18.
        Set referenceMaxError to 2_500.
    } Else If Altitude < 20_000 { 
        Set aeroMaxAoA to 22.
        Set referenceMaxError to 3_000.
    } Else If Altitude < 25_000 { 
        Set aeromaxAoA to 38.
        Set referenceMaxError to 16_000.
    } Else If Altitude > 36_000 { 
        Set aeroMaxAoA to 60.
        Set referenceMaxError to 25_000.
    }
    

    
    Local proportion to landingStatus:TrajectoryErrorMeters() / referenceMaxError.
    flightStatus:AddField("Error Prop", proportion).
    Local minAoA to 5.
    
    Local maxBurnStartAltitude to 6_000.
    Local suicideMargin to 100.

    landingSteering:SetMaxAoA((proportion * aeroMaxAoA) + minAoA).    

    If Altitude < maxBurnStartAltitude { 
        Local vs to Ship:VerticalSpeed.
        Set landingBurnStart to landingBurn:TrueRadar() < landingBurn:GetStopDistance() + suicideMargin.
        Set lastVerticalSpeed to vs.
    }    
    Wait 0.001.
}      



ResetTorque().
landingSteering:SetErrorScaling(4).
flightStatus:AddField("Steering", "Vector, Rel. Radial Out").
Lock Steering to LookDirUp(landingSteering:SteeringVectorReferenceRadialOut(),  rollReferenceOvershootSite:Position).
Lock Throttle to 1.    
landingSteering:SetMaxAoA(2).      
landingBurn:SetRadarOffset(boosterRadarOffset).
flightStatus:Update("LANDING BURN - 3 Engines").                

Local vsTarget to -20.
Local verticalSpeedHoldStart to false. 

flightStatus:AddField("VS", { Return Ship:VerticalSpeed. }).
Local swtichedTo3Engines to false.
Local switchedToRefRadialOut to false.

Until verticalSpeedHoldStart { 
        
    If (not switchedToRefRadialOut and Abs(Ship:Velocity:Surface:Mag) < 140) { 
        Set switchedToRefRadialOut to true.

        flightStatus:Update("TRAVERSE STEERING").                
        Lock Steering to LookDirUp(landingSteering:SteeringVectorReferenceRadialOut(),  rollReferenceOvershootSite:Position).
        ResetTorque().
    }    

    // Todo: should be checking accelerometer 
    If (not swtichedTo3Engines and 
         (Abs(Ship:VerticalSpeed) < 20 or Ship:Velocity:Surface:Mag < 20)) {
            
        Set swtichedTo3Engines to true.   
        Lock Throttle to 0.25.     
        flightStatus:Update("LANDING BURN - 1 Engines").   
              
        AG1 on.
        Gear on.    
        gridFinController:SetEnabled(false).         
        landingSteering:SetMaxAoA(-3).
        Set verticalSpeedHoldStart to true.

        Break.
    }
  
    Wait 0.001.
}                  
    landingSteering:SetMaxAoA(-10).              
    landingSteering:SetMinAoA(0).

    Local landingVSpeedStage1Set to false.
    Local landingVSpeedStage2Set to false.

    Local finalHoverRadarAltitude to 64.5.
    Local throttleCutTimeSeconds to Time:Seconds + 10_000.


    Local horizontalKillStart to false.

    flightStatus:Update("VERTICAL SPEED HOLD").
    flightStatus:AddField("VS TARGET", vsTarget).
    RunVerticalSpeedHold({             
        If landingBurn:TrueRadar() < 800 { 
            landingSteering:SetMaxAoA(-5). 
        }
        If landingBurn:TrueRadar() < 150 { 
            Set vsTarget to -10.
        }
        If landingBurn:TrueRadar() < 50 {
            landingSteering:SetMaxAoA(-2.5). 
            Set vsTarget to -5.
        }
        If landingBurn:TrueRadar() < 10 { 
            Set vsTarget to -1.
        }
        If not horizontalKillStart and landingBurn:TrueRadar() < 15 { 
            Lock Steering to LookDirUp(landingSteering:SteeringVectorHorizontalKill(),  rollReferenceOvershootSite:Position).
            landingSteering:SetMaxAoA(-4).   
            Set horizontalKillStart to true.

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
        //Local errorCurrent is landingStatus:TrajectoryErrorMeters().

        // Get actual
        Return Ship:VerticalSpeed. 
    },
    {        
        Return Ship:Status = "LANDED" or Ship:Status = "SPLASHED".  
    }).     

    Lock Throttle to 0.    
    Set Ship:Control:PilotMainThrottle to 0.

    flightStatus:Update("TERMINAL").
    ClearVecDraws().
    Shutdown.



Wait Until false.