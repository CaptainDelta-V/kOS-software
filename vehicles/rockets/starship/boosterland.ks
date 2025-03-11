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
Parameter Debug to true.

Local engines to Ship:PartsTagged("BOOSTER_RAPTORS")[0].
Local gridFins to Ship:PartsTagged("GRID_FIN").
// Local drainValves

Local engineManagement to EngineManager(engines, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).
Local gridFinManagement to GridFinManager(gridFins, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).
Local drainValves to Ship:PartsTagged("BOOSTER_DRAIN_VALVE").
Local drainValveController to DrainValveManager(drainValves).

Local boosterRadarOffset to 63.4.
Local towerCatchAltitude to 150.
Local towerCatchOffsetAltitude to towerCatchAltitude - boosterRadarOffset.
Local suicideMargin to 222.
Local maxBurnStartAltitude to 2_800.
Local undershootMeters to -40.
Local overshootMeters to 25. // 160 is very steep
Local towerStatus to "Not CONNECTED".

Local towerVessel to Vessel(TOWER_CPU_NAME).
// Local landingSite is towerVessel:GeoPosition.
Local olmGeoPosition to LatLng(-0.0971988972860862,-74.5565400064737). // center of OLM
Local olmLandRefGeoPosition to LatLng(-0.0971957998740445,-74.5570880721982). // Inner point towards tower
Local towerBaseGeoPosition to LatLng(-0.0972415730475416,-74.5585281410506). 
Local landingSite to olmLandRefGeoPosition.
Local targetLandingSite is landingSite.
Local altitudePositionTarget to towerCatchAltitude - 90.
Local approachOvershootSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(overshootMeters):GetLandingSite().
Local rollReferenceOvershootSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(500):GetLandingSite().
Local approachSlightUndershootRefSite is LandingStatusModel(towerBaseGeoPosition, altitudePositionTarget):Overshoot(-25):GetLandingSite().
Local approachUndershootSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(-2_000):GetLandingSite().
Local landingStatus to LandingStatusModel(approachOvershootSite, altitudePositionTarget):Overshoot(undershootMeters).
Local landingSteering to LandingSteeringModel(landingStatus).
Local flightStatus to FlightStatusModel("SUPER HEAVY BOOSTER LANDING GUIDANCE").

flightStatus:AddField("TOWER", towerStatus).
flightStatus:AddField("TARGET COORDS", { 
    Local site to landingStatus:GetLandingSite().
    Return site:lat + "," + site:lng.
}).
flightStatus:AddField("LATITUDE ERROR", landingStatus:LatitudeError@).
flightStatus:AddField("LONGITUDE ERROR", landingStatus:LongitudeError@).
flightStatus:AddField("TRAJECTORY ERROR METERS", landingStatus:TrajectoryErrorMeters@).
flightStatus:AddField("POSITION ERROR METERS", landingStatus:PositionErrorMeters@).
flightStatus:AddField("RETROGRADE", {
    Local retroVector to -Ship:Velocity:Surface.
    Return "HEADING: " + Round(HeadingOfVector(retroVector), 2) + " Pitch: " + Round(PitchOfVector(retroVector), 2).
}).
flightStatus:AddField("ECCENTRICITY", landingStatus:Eccentricity@).
flightStatus:AddField("ERROR PITCH", { Return PitchOfVector(landingStatus:ErrorVector()). }).
flightStatus:AddField("ERROR HEADING", { Return HeadingOfVector(landingStatus:ErrorVector()). }).

// Local BOOSTBACK_PITCH to 45. // tanker weight
// Local BOOSTBACK_PITCH to 14. // base systems weight
// Local boostbackPitch to 15.
Local boostbackPitch to 0.
Local targetRoll to -70.

RunFlightStatusScreen(flightStatus, 1).
ResetTorque().
engineManagement:SetThrustLimit(100).

Lock Throttle to 0.
SAS OFF. 
RCS ON.
Wait 0.

engineManagement:SetEngineState(true).
engineManagement:SetEngineMode(ENG_MODE_MID_INR).
landingStatus:SetLandingSite(approachUndershootSite).
Local TargetVessel to Vessel(TOWER_VESSEL_NAME).

RCS ON.
Lock Steering to Heading(landingStatus:RetrogradeHeading(), boostbackPitch, targetRoll). 

Wait 0.5.

If Not SkipWaitForInitiationMessage { 
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
}


// flightStatus:Update("Waiting Until Descent").
// Wait Until Ship:VerticalSpeed < 0.

If Not SkipBoostback { 
    flightStatus:Update("BOOSTBACK ORIENTATION").        
    WaitUntilOriented().

    Local boostback to BoostbackBurnController(landingStatus, landingSteering).
    Local boostbackAbortAltitude to 50_000. // 64_000 for 6 engines

    flightStatus:Update("BOOSTBACK ITERATION: 1").
    boostback:Engage(boostbackPitch, 5_000, 0.00005, boostbackAbortAltitude, 0.3).

    Local iteration2RequiredError to 500.
    if landingStatus:TrajectoryErrorMeters() > iteration2RequiredError { 
        flightStatus:Update("BOOSTBACK ITERATION: 2").
        boostback:Engage(boostbackPitch, iteration2RequiredError, 0.00005, boostbackAbortAltitude, 0.3).
    }
}

flightStatus:Update("POST BOOSTBACK COAST").
RCS ON.

Wait Until Altitude < 80_000.
    flightStatus:Update("GRID FIN CORRECTIONS").            
    Local landingBurn to LandingBurnModel(boosterRadarOffset).            

    flightStatus:AddField("TRUE RADAR", landingBurn:TrueRadar@).
    flightStatus:AddField("RADAR OFFSET", landingBurn:GetRadarOffset@).
    flightStatus:AddField("IMPACT Time", landingBurn:ImpactTime@).
    flightStatus:AddField("IDEAL Throttle", landingBurn:LinearLandingThrottle@).
    flightStatus:AddField("STOP DISTANCE", landingBurn:GetStopDistance@).
    flightStatus:AddField("VIRUTAL TARGET Altitude", landingStatus:GetTargetAltitude@).
    flightStatus:AddField("SPEED lat", { Return Round(landingStatus:SpeedLatitude(), 2). }).
    flightStatus:AddField("SPEED LONG", { Return Round(landingStatus:SpeedLongitude(), 2). }).    
    flightStatus:AddField("RETRO Pitch", landingStatus:RetrogradePitch).

    gridFinManagement:SetEnabled(true).
    gridFinManagement:SetAuthorityLimit(38).        
    landingStatus:SetTargetAltitude(0).        

    flightStatus:AddField("TARGET AoA CAPPED", landingSteering:GetTargetAoA@).
    flightStatus:AddField("TARGET AoA RAW", landingSteering:GetTargetAoARaw@). 
    flightStatus:AddField("MAX AoA", { Return landingSteering:GetMaxAoA(). }).   
    flightStatus:AddField("MIN AoA", { Return landingSteering:GetMinAoA(). }).   

    flightStatus:AddField("SDP", { Return landingSteering:GetSteeringDirectionPitch(). }).
    flightStatus:AddField("SDH", { Return landingSteering:GetSteeringDirectionHeading(). }).
    flightStatus:AddFIeld("Surface Mag", { Return Ship:Velocity:Surface:Mag. }).

    flightStatus:Update("DIRECT TRAJECTORY").
    Wait 1.

    flightStatus:Update("FUEL VENTING").
    drainValveController:DrainToAmount(5_500, "Oxidizer").
    flightStatus:Update("VENTING COMPLETE").

    landingSteering:SetMaxAoa(20).    
    Lock Steering to LookDirUp(landingSteering:SteeringVector(), rollReferenceOvershootSite:Position).                

Wait Until Altitude < 30_000.     
    RCS OFF.

Wait Until Altitude < 25_000.           
    engineManagement:SetEngineMode(ENG_MODE_MID_INR).
    
    landingStatus:SetLandingSite(approachSlightUndershootRefSite).
    Lock Steering to LookDirup(landingSteering:SteeringVector(),  rollReferenceOvershootSite:Position).            

Wait Until Altitude < 20_000.
    landingSteering:SetMaxAoa(16).

Wait Until Altitude < 12_000. 
    landingSteering:SetMaxAoA(8).

Wait Until Altitude < maxBurnStartAltitude.
    // do not start burn stupid early

landingSteering:SetMaxAoa(2).
landingBurn:SetRadarOffset(420).

Local landingBurnStart to false. 
Until landingBurnStart {
    Set landingBurnStart to landingBurn:TrueRadar() < landingBurn:GetStopDistance() + suicideMargin.
    Wait 0.001.
}        
    
landingSteering:SetErrorScaling(4).
// Lock Throttle to landingBurn:LinearLandingThrottle().    
Lock Steering to -Ship:Velocity:Surface.
Lock Throttle to 1.    
landingSteering:SetMaxAoA(-2).      
landingBurn:SetRadarOffset(boosterRadarOffset).
flightStatus:Update("LANDING BURN - 13 Engines").                

Local vsTarget to -10.
Local verticalSpeedHoldStart to false. 

flightStatus:AddField("REF", "RETROGRADE").
flightStatus:AddField("VS", { Return Ship:VerticalSpeed. }).
Local switchedToRadialOutReference to false.
Local steeringFlag to false.
landingStatus:SetLandingSite(olmGeoPosition).

Until verticalSpeedHoldStart { 
        
    If (not steeringFlag and Abs(Ship:Velocity:Surface:Mag) < 140) { 
        Set steeringFlag to true.

        flightStatus:Update("TRAVERSE STEERING").
        Set landingSite to towerVessel:Geoposition.                
        Lock Steering to LookDirUp(landingSteering:SteeringVectorReferenceRadialOut(),  rollReferenceOvershootSite:Position).
    }    

    // Todo: should be checking accelerometer 
    If (not switchedToRadialOutReference and 
         (Abs(Ship:VerticalSpeed) < 40 or Ship:Velocity:Surface:Mag < 52)) {
            
        Set switchedToRadialOutReference to true.   
        Lock Throttle to 0.25.     
        flightStatus:Update("LANDING BURN - 3 Engines").         
        engineManagement:SetEngineMode(ENG_MODE_CTR).        
        gridFinManagement:SetEnabled(false).         
        landingSteering:SetMaxAoA(-5).
        Set verticalSpeedHoldStart to true.

        Break.
    }
  
    Wait 0.001.
}                  
    landingSteering:SetMaxAoA(-6).              
    landingSteering:SetMinAoA(0).

    Local errorPrevious to landingStatus:TrajectoryErrorMeters() + 1.
    Local minimumApproachErrorMeters is 15.
    Local traverseCoastStart is false.

    Local timeBetweenAlignments to 2.
    Local timeNextAlignment to Time:Second + timeBetweenAlignments.

    Local precatchMessageSent to false.
    Local catchMessageSent to false. 
    Local towerCatchDampenMessageSent to false.    
    Local intermidAoaSet to false.
    Local intermidVsSet to false.
    Local traverseCoastVsSet to false.
    Local actualLandingTargetSet to false.
    Local landingVSpeedStage1Set to false.
    Local landingVSpeedStage2Set to false.

    flightStatus:Update("VERTICAL SPEED HOLD").
    RunVerticalSpeedHold({             

        If not traverseCoastVsSet and traverseCoastStart { 
            Set traverseCoastVsSet to true.            
            Set vsTarget to -16.
            landingSteering:SetMaxAoA(-5).
            flightStatus:Update("TRAVERSE COAST START").
        }

        If not actualLandingTargetSet and landingBurn:TrueRadar() < 140 { 
            landingStatus:SetLandingSite(olmLandRefGeoPosition).
            Set actualLandingTargetSet to true.
             flightStatus:Update("FINAL LANDING SITE SET").
        }

        If not intermidAoaSet and landingBurn:TrueRadar() < 100 { 
            Set vsTarget to -10.
            landingSteering:SetMaxAoA(-7).
            Set intermidAoaSet to true.
             flightStatus:Update("INTERMID AOA SET").
        }

        If not intermidVsSet and landingBurn:TrueRadar() < 80 { 
            Set vsTarget to -5.
            Set intermidVsSet to true.
            landingSteering:SetMaxAoA(-3).
             flightStatus:Update("INTERMID VS SET").
        }

        If not landingVSpeedStage1Set and landingBurn:TrueRadar() < 40 { 
            Set vsTarget to -2.5.
            Set landingVSpeedStage1Set to true. 
            flightStatus:Update("LANDING VS STAGE 1 SET").
        }

        If not landingVSpeedStage2Set and landingBurn:TrueRadar() < 20 { 
            Set vsTarget to -1.          
            Set landingVSpeedStage2Set to true.            
            flightStatus:Update("LANDING VS STAGE 2 SET").
        }

        flightStatus:AddField("VS TARGET", vsTarget).        

        Return vsTarget.                
    }, 60, 0.1, 0, 0, 0.15, {

        Local maxOutput to 1.
        
        return maxOutput.
    }, 
    { 
        Local errorCurrent is landingStatus:TrajectoryErrorMeters().

        If (not traverseCoastStart and errorCurrent < 20) {                       
            flightStatus:Update("MOMENTUM TO TOWER ACHIEVED").
            //  landingSteering:SetMaxAoA(0).
            // VS Target will be set
            Set traverseCoastStart to true.        
        }

        If (not precatchMessageSent) { 
            towerVessel:Connection:SendMessage(TOWER_PRECATCH_MESSAGE).  
            flightStatus:Update("REQUESTING PRECATCH").
            Set precatchMessageSent to true.
        }

        If (not catchMessageSent and landingBurn:TrueRadar() < boosterRadarOffset * 0.45) {
            towerVessel:Connection:SendMessage(TOWER_CATCH_MESSAGE).  
            flightStatus:Update("REQUESTING CATCH").                
            Set catchMessageSent to true.
        }              

        If (landingBurn:TrueRadar() > 10 and Time:Second > timeNextAlignment and landingBurn:TrueRadar() > 70) { 
            towerVessel:Connection:SendMessage(TOWER_ARMS_ALIGN_MESSAGE).            
            Set timeNextAlignment to Time:Second + timeBetweenAlignments.
            flightStatus:AddField("Alignment", "Done.").
        }

        If (landingBurn:TrueRadar() < 6 and not towerCatchDampenMessageSent) { 
            towerVessel:Connection:SendMessage(TOWER_CATCH_DAMPEN_MESSAGE).
            Set towerCatchDampenMessageSent to true.            
        }        
        
        Set errorPrevious to errorCurrent.

        // Get actual
        Return Ship:VerticalSpeed. 
    },
    {        
        Return landingBurn:TrueRadar() < 0.8.    
    }).     

    Lock Throttle to 0.
    flightStatus:Update("TERMINAL").
    ClearVecDraws().
    Shutdown.


Wait Until false.