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

Set Ship:Name to ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME.
Parameter SkipBoostback to false.
Parameter SkipWaitForInitiationMessage to true.
Parameter Debug to false.

Local engines to Ship:PartsTagged("BOOSTER_RAPTORS")[0].
Local gridFins to Ship:PartsTagged("GRID_FIN").

Local engineController to EngineManager(engines, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).
Local gridFinController to GridFinManager(gridFins, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).
Local drainValves to Ship:PartsTagged("BOOSTER_DRAIN_VALVE").
Local drainValveController to DrainValveManager(drainValves).

Local boosterRadarOffset to 63.4.
Local towerCatchAltitude to 150. // ASL reference
Local altitudePositionTarget to towerCatchAltitude - 90.
Local suicideMargin to 50.
Local maxBurnStartAltitude to 3_300.
Local undershootMeters to -80.
Local overshootMeters to 25. // 160 is very steep
Local towerStatus to "NOT CONNECTED".
Local olmTowerBaseOffsetMeters to -7.

Local towerVessel to Vessel(TOWER_CPU_NAME).
Local towerBaseGeoPosition to towerVessel:GeoPosition.
Local olmGeoPosition to LandingStatusModel(towerBaseGeoPosition, altitudePositionTarget):Overshoot(olmTowerBaseOffsetMeters):GetLandingSite().
Local olmLandRefGeoPosition to LandingStatusModel(towerBaseGeoPosition, altitudePositionTarget):Overshoot(-2):GetLandingSite(). // Inner point towards tower

Local landingSite to olmLandRefGeoPosition.
Local approachOvershootSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(overshootMeters):GetLandingSite().
Local rollReferenceOvershootSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(10):GetLandingSite().
Local approachSlightUndershootRefSite is LandingStatusModel(towerBaseGeoPosition, altitudePositionTarget):Overshoot(-60):GetLandingSite().
Local approachUndershootSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(-1_000):GetLandingSite().
Local landingStatus to LandingStatusModel(approachOvershootSite, altitudePositionTarget):Overshoot(undershootMeters).
Local landingSteering to LandingSteeringModel(landingStatus).

Local boostbackRequirementErrorThreshold to 5_000.

Local boostbackPitch to 0.
Local targetRoll to -70.

Local flightStatus to FlightStatusModel("SUPER HEAVY BOOSTER LANDING GUIDANCE").

flightStatus:AddField("TOWER CONNECTION", { Return towerVessel:Connection:IsConnected.}).
flightStatus:AddField("TARGET COORDS", { 
    Local site to landingStatus:GetLandingSite().
    Return site:lat + "," + site:lng.
}).
flightStatus:AddField("LATITUDE ERROR", landingStatus:LatitudeError@).
flightStatus:AddField("LONGITUDE ERROR", landingStatus:LongitudeError@).
flightStatus:AddField("TRAJECTORY ERROR (m)", landingStatus:TrajectoryErrorMeters@).
flightStatus:AddField("POSITION ERROR (m)", landingStatus:PositionErrorMeters@).


RunFlightStatusScreen(flightStatus).
ResetTorque().
engineController:SetThrustLimit(100).

Lock Throttle to 0.
SAS OFF. 
RCS ON.
Wait 0.

engineController:SetEngineState(true).
engineController:SetEngineMode(ENG_MODE_SH_MID_INR).
landingStatus:SetLandingSite(approachUndershootSite).
Local TargetVessel to Vessel(TOWER_VESSEL_NAME).

flightStatus:AddField("Steering", "Retrograde").
Lock Steering to Heading(landingStatus:RetrogradeHeading(), boostbackPitch, targetRoll). 

Wait 0.5.

If not SkipWaitForInitiationMessage { 
    Local startBoostback to false.
    flightStatus:Update("WAITING FOR LANDING SEQUENCE INITIATION MESSAGE").
    When Not Ship:Messages:Empty Then { 
        Local message to Ship:Messages:Peek:Content.
        If message = INITIATE_LANDING_SEQUENCE_MESSAGE { 
            Set startBoostback to true.             
        }      
    }

    Wait Until startBoostback.
} 

ClearVecDraws().
If Debug { 
    
    Local arrowSize to 50.  

    Local radialOutArrow to VecDraw(
        V(0,0,0),
        V(0,0,0),
        RGB(0,0,1),
        "RADIAL OUT",
        1.0,
        true,
        0.1,
        true,
        true
    ).

    Set radialOutArrow:StartUpdater to { Return Ship:Position. }.
    Set radialOutArrow:VecUpdater to { Return RadialOutVectorNormalized() * (arrowSize * 1.25). }.


    Local retrogradeArrow to VecDraw(    
        V(0,0,0),
        V(0,0,0),
        RGB(0,1,0),
        "RETROGRADE",
        1.0,
        true,
        0.1,
        true,
        true
    ).

    Set retrogradeArrow:StartUpdater to { Return Ship:Position. }.
    Set retrogradeArrow:VecUpdater to { Return -Ship:Velocity:Surface:Normalized * (arrowSize). }.

    Local directArrow to VecDraw(    
        V(0,0,0),
        V(0,0,0),
        RGB(1,1,1),
        "DIRECT",
        1.0,
        true,
        0.1,
        true,
        true
    ).

    Set directArrow:StartUpdater to { Return Ship:Position. }.
    Set directArrow:VecUpdater to { Return landingSite:AltitudePosition(altitudePositionTarget):Normalized * arrowSize. }.

    Local steeringRefRadialOutArrow to VecDraw(    
        V(0,0,0),
        V(0,0,0),
        RGB(1,1,1),
        "STEERING VECTOR RADIAL OUT",
        1.0,
        true,
        0.1,
        true,
        true
    ).

    Set steeringRefRadialOutArrow:StartUpdater to { Return Ship:Position. }.
    Set steeringRefRadialOutArrow:VecUpdater to { Return landingSteering:SteeringVectorReferenceRadialOut():Normalized * arrowSize. }.

    Local steeringVectorArrow to VecDraw(    
        V(0,0,0),
        V(0,0,0),
        RGB(1,1,1),
        "STEERING VECTOR",
        1.0,
        true,
        0.1,
        true,
        true
    ).    

    Set steeringVectorArrow:StartUpdater to { Return Ship:Position. }.
    Set steeringVectorArrow:VecUpdater to { Return landingSteering:SteeringVector():Normalized * arrowSize. }.
    
    Local perpendicularArrow to VecDraw(
        V(0,0,0),
        V(0,0,0),
        RGB(1,0,1),
        "PERPENDICULAR", 1.0, true, 0.1, true, true
    ).

    Set perpendicularArrow:StartUpdater to { Return Ship:Position. }.
    Set perpendicularArrow:VecUpdater to { Return landingSteering:SteeringRadialOutCrossVector() * arrowSize. }.   

    Local olmArrow to VecDraw(
        V(0,0,0),
        V(0,0,0),
        RGB(0,1,0),
        "OLM",
        1.0,
        true,
        0.1,
        true,
        true
    ).

    Set olmArrow:StartUpdater to { Return olmGeoPosition:AltitudePosition(100). }.
    Set olmArrow:VecUpdater to { Return  olmGeoPosition:AltitudePosition(1500). }.

    Local olmLandRefArrow to VecDraw(
        V(0,0,0),
        V(0,0,0),
        RGB(0,0,1),
        "OLM REF",
        1.0,
        true,
        0.1,
        true,
        true
    ).

    Set olmLandRefArrow:StartUpdater to { Return olmLandRefGeoPosition:AltitudePosition(100). }.
    Set olmLandRefArrow:VecUpdater to { Return  olmLandRefGeoPosition:AltitudePosition(1500). }.

    Local towerBaseArrow to VecDraw(
        V(0,0,0),
        V(0,0,0),
        RGB(1,0,0),
        "TOWER BASE",
        1.0,
        true,
        0.1,
        true,
        true
    ).

    Set towerBaseArrow:StartUpdater to { Return towerBaseGeoPosition:AltitudePosition(100). }.
    Set towerBaseArrow:VecUpdater to { Return  towerBaseGeoPosition:AltitudePosition(1500). }.
}


Local boostbackRe/quired to landingStatus:TrajectoryErrorMeters() > boostbackRequirementErrorThreshold.

If Not SkipBoostback and boostbackRequired { 
    flightStatus:Update("BOOSTBACK ORIENTATION").        
    WaitUntilOriented(30, 20).

    Local boostback to BoostbackBurnController(landingStatus, landingSteering).
    Local boostbackAbortAltitude to 32_000.

    flightStatus:Update("BOOSTBACK ITERATION: 1").
    boostback:Engage(boostbackPitch, 1_000, 1, boostbackAbortAltitude, 0.3, 60, 850).

    Local iteration2RequiredError to 500.
    If landingStatus:TrajectoryErrorMeters() > iteration2RequiredError { 
        flightStatus:Update("BOOSTBACK ITERATION: 2").
        boostback:Engage(boostbackPitch, iteration2RequiredError, 0.00005, boostbackAbortAltitude, 0.3).
    }
}

flightStatus:AddField("Steering", "Steering Vector").
Lock Steering to landingSteering:SteeringVector(). // todo: should roll

flightStatus:AddField("Max AoA", landingSteering:GetMaxAoA@).
flightStatus:AddField("Target AoA Raw", landingSteering:GetTargetAoARaw@).
flightStatus:AddField("Retrograde pitch", { Return PitchOfVector(-Ship:Velocity:Surface). }).

flightStatus:Update("POST BOOSTBACK COAST").
RCS ON.

Wait Until Altitude < 80_000.
    flightStatus:Update("GRID FIN CORRECTIONS").            
    Local landingBurn to LandingBurnModel(boosterRadarOffset).            

    flightStatus:AddField("TRUE RADAR", landingBurn:TrueRadar@).
    flightStatus:AddField("RADAR OFFSET", landingBurn:GetRadarOffset@).
    flightStatus:AddField("IMPACT TIME", landingBurn:ImpactTime@).    

    gridFinController:SetEnabled(true).
    gridFinController:SetAuthorityLimit(48).        
    landingStatus:SetTargetAltitude(0).        

    flightStatus:Update("DIRECT TRAJECTORY").
    Wait 1.

    flightStatus:Update("FUEL VENTING").
    drainValveController:DrainToAmount(5_100, RESOURCE_OXIDIZER).
    flightStatus:Update("VENTING COMPLETE").

    // Set SteeringManager:RollTorqueFactor to 0.
    landingSteering:SetMaxAoa(60).


Wait Until Altitude < 60_000.
    flightStatus:Update("LANDING SITE: SLIGHT UNDERSHOOT").            
    landingStatus:SetLandingSite(approachSlightUndershootRefSite).
    engineController:SetEngineMode(ENG_MODE_SH_MID_INR).        

When Altitude < 35_000 Then { 
    RCS OFF.        
}

Local lastVerticalSpeed to Ship:VerticalSpeed.
Local landingBurnStart to false. 
Until landingBurnStart {

    Local aeroMaxAoA to 10.
    Local referenceMaxError to 50_000.

    If Altitude < 8_000 { 
        Set aeroMaxAoA to 12.
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

    landingSteering:SetMaxAoA((proportion * aeroMaxAoA) + minAoA).    

    If Altitude < maxBurnStartAltitude { 
        Local vs to Ship:VerticalSpeed.
        Set landingBurnStart to landingBurn:TrueRadar() < landingBurn:GetStopDistance() + suicideMargin.
        Set lastVerticalSpeed to vs.
    }    
    Wait 0.001.
}      

landingSteering:SetMaxAoa(2).
landingStatus:SetLandingSite(olmLandRefGeoPosition).    

ResetTorque().
landingSteering:SetErrorScaling(4).
flightStatus:AddField("Steering", "Vector, Rel. Radial Out").
Lock Steering to LookDirUp(landingSteering:SteeringVectorReferenceRadialOut(),  rollReferenceOvershootSite:Position).
Lock Throttle to 1.    
landingSteering:SetMaxAoA(-2).      
landingBurn:SetRadarOffset(boosterRadarOffset).
flightStatus:Update("LANDING BURN - 13 Engines").                

Local vsTarget to -10.
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
         (Abs(Ship:VerticalSpeed) < 20 or Ship:Velocity:Surface:Mag < 52)) {
            
        Set swtichedTo3Engines to true.   
        Lock Throttle to 0.25.     
        flightStatus:Update("LANDING BURN - 3 Engines").         
        engineController:SetEngineMode(ENG_MODE_SH_CTR).        
        gridFinController:SetEnabled(false).         
        landingSteering:SetMaxAoA(-3).
        Set verticalSpeedHoldStart to true.

        Break.
    }
  
    Wait 0.001.
}                  
    landingSteering:SetMaxAoA(-6).              
    landingSteering:SetMinAoA(0).

    Set olmGeoPosition to LandingStatusModel(towerBaseGeoPosition, altitudePositionTarget):Overshoot(olmTowerBaseOffsetMeters):GetLandingSite().
    landingStatus:SetLandingSite(olmGeoPosition).

    Local errorPrevious to landingStatus:TrajectoryErrorMeters() + 1.
    Local minimumApproachErrorMeters is 15.
    Local traverseCoastStart is false.

    Local timeBetweenAlignments to 2.
    Local timeNextAlignment to Time:Second + timeBetweenAlignments.

    Local precatchMessageSent to false.
    Local catchMessageSent to false. 
    Local towerCatchDampenMessageSent to false.    
    Local vsAdjusted to false.
    Local intermidVsSet to false.
    Local traverseCoastVsSet to false.
    Local actualLandingTargetSet to false.
    Local landingVSpeedStage1Set to false.
    Local landingVSpeedStage2Set to false.

    Local finalHoverRadarAltitude to 64.5.
    Local throttleCutTimeSeconds to Time:Seconds + 10_000.

    flightStatus:Update("VERTICAL SPEED HOLD").
    RunVerticalSpeedHold({             

        // If not traverseCoastVsSet and traverseCoastStart { 
        //     Set traverseCoastVsSet to true.            
        //     // Set vsTarget to -16.
        //     // landingSteering:SetMaxAoA(-2.5).
        //     // flightStatus:Update("AoA -2.5").            
        // }        
        If not landingVSpeedStage1Set and landingBurn:TrueRadar() < 280 { 
            landingSteering:SetMaxAoA(-4).              
            Set landingVSpeedStage1Set to true.
        }

        
        If not actualLandingTargetSet and landingBurn:TrueRadar() < 108 {             
            landingStatus:SetLandingSite(olmGeoPosition).
            flightStatus:Update("LANDING SITE: OLM").
            landingSteering:SetMaxAoA(-4).       
            Set actualLandingTargetSet to true.             
        }

        If not vsAdjusted and landingBurn:TrueRadar() < 60 { 
            
            flightStatus:Update("VS ADJUSTED").
            Set vsAdjusted to true.            
        }

        If not intermidVsSet and landingBurn:TrueRadar() < 30 { 
            Set vsTarget to -1.
            Set intermidVsSet to true.                               
            flightStatus:Update("INTERMID VS SET").
            landingSteering:SetMaxAoA(-2.8).
        }

        If not landingVSpeedStage2Set and landingBurn:TrueRadar() < 5 {                         
            Set landingVSpeedStage2Set to true.                      
            flightStatus:Update("LANDING VS STAGE 2 SET. Horizontal Kill Active").
            landingSteering:SetMaxAoA(-1.5).  
            Lock Steering to LookDirUp(landingSteering:SteeringVectorHorizontalKill(),  rollReferenceOvershootSite:Position).
            Set vsTarget to -0.1.
        }

        flightStatus:AddField("VS TARGET", vsTarget).        

        Return vsTarget.                
    },
    60, // arbitrary max duration
    0.1, 0.02, 0.0, // PID
    0.35, { // min/max

        Local maxOutput to 1.
        
        Return maxOutput.
    }, 
    { 
        Local errorCurrent is landingStatus:TrajectoryErrorMeters().

        If (not traverseCoastStart and errorCurrent < 20) {                       
            flightStatus:Update("MOMENTUM TO TOWER ACHIEVED").            
            // VS Target will be set
            Set traverseCoastStart to true.        
        }

        If (not precatchMessageSent) { 
            Set precatchMessageSent to towerVessel:Connection:SendMessage(TOWER_PRECATCH_MESSAGE).  
            flightStatus:Update("REQUESTING PRECATCH").            
        }

        // If (not catchMessageSent and landingBurn:TrueRadar() < boosterRadarOffset * 0.6) {
        //     Set catchMessageSent to towerVessel:Connection:SendMessage(TOWER_CATCH_MESSAGE).  
        //     flightStatus:Update("REQUESTING CATCH").                            
        // }              

        // landingBurn:TrueRadar() > 40
        // If (landingBurn:TrueRadar() < 30 and Time:Second > timeNextAlignment) { 
        //     towerVessel:Connection:SendMessage(TOWER_ARMS_ALIGN_MESSAGE).            
        //     Set timeNextAlignment to Time:Second + timeBetweenAlignments.
        //     flightStatus:AddField("Alignment", "Done.").            
        // }

        If (not catchMessageSent and landingBurn:TrueRadar() < 15) { 
            towerVessel:Connection:SendMessage(TOWER_CATCH_MESSAGE).  
            Set throttleCutTimeSeconds to Time:Seconds + 4.
            flightStatus:Update("REQUESTING CATCH").            
            Set catchMessageSent to true.
        }

        Set errorPrevious to errorCurrent.

        // Get actual
        Return Ship:VerticalSpeed. 
    },
    {        
        Return Time:Seconds > throttleCutTimeSeconds and Alt:Radar < finalHoverRadarAltitude + 0.25.
        // Return landingBurn:TrueRadar() < 8.        
    }).     

    towerVessel:Connection:SendMessage(TOWER_CATCH_DAMPEN_MESSAGE).
    Set towerCatchDampenMessageSent to true.      

    Lock Throttle to 0.    
    Set Ship:Control:PilotMainThrottle to 0.

    flightStatus:Update("TERMINAL").
    ClearVecDraws().
    Shutdown.


Wait Until false.