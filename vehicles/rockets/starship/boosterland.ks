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

Local engineController to EngineManager(engines, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).
Local gridFinController to GridFinManager(gridFins, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).
Local drainValves to Ship:PartsTagged("BOOSTER_DRAIN_VALVE").
Local drainValveController to DrainValveManager(drainValves).

Local boosterRadarOffset to 63.4.
Local towerCatchAltitude to 150.
Local towerCatchOffsetAltitude to towerCatchAltitude - boosterRadarOffset.
Local suicideMargin to 200.
Local maxBurnStartAltitude to 2_800.
Local undershootMeters to -40.
Local overshootMeters to 25. // 160 is very steep
Local towerStatus to "NOT CONNECTED".

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

// Local landingStatusPositional to LandingStatusModel(olmGeoPosition, altitudePositionTarget).
// Local landingSteeringPositional to LandingSteeringModel().

Local boostbackPitch to 0.
Local targetRoll to -70.

Local flightStatus to FlightStatusModel("SUPER HEAVY BOOSTER LANDING GUIDANCE").

flightStatus:AddField("TOWER", towerStatus).
flightStatus:AddField("TARGET COORDS", { 
    Local site to landingStatus:GetLandingSite().
    Return site:lat + "," + site:lng.
}).
flightStatus:AddField("LATITUDE ERROR", landingStatus:LatitudeError@).
flightStatus:AddField("LONGITUDE ERROR", landingStatus:LongitudeError@).
flightStatus:AddField("TRAJECTORY ERROR (m)", landingStatus:TrajectoryErrorMeters@).
flightStatus:AddField("POSITION ERROR (m)", landingStatus:PositionErrorMeters@).
flightStatus:AddField("ECCENTRICITY", landingStatus:Eccentricity@).

RunFlightStatusScreen(flightStatus, 1).
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


// flightStatus:Update("Waiting Until Descent").
// Wait Until Ship:VerticalSpeed < 0.

If Not SkipBoostback { 
    flightStatus:Update("BOOSTBACK ORIENTATION").        
    WaitUntilOriented(3, 2).

    Local boostback to BoostbackBurnController(landingStatus, landingSteering).
    Local boostbackAbortAltitude to 50_000. // 64_000 for 6 engines

    flightStatus:Update("BOOSTBACK ITERATION: 1").
    boostback:Engage(boostbackPitch, 5_000, 0.00005, boostbackAbortAltitude, 0.3, 25, 50).

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
    flightStatus:AddField("IMPACT TIME", landingBurn:ImpactTime@).
    flightStatus:AddField("IDEAL THROTTLE", landingBurn:LinearLandingThrottle@).    
    flightStatus:AddField("VIRUTAL TARGET ALTITUDE", landingStatus:GetTargetAltitude@).    

    gridFinController:SetEnabled(true).
    gridFinController:SetAuthorityLimit(38).        
    landingStatus:SetTargetAltitude(0).        

    flightStatus:AddField("TARGET AoA CAPPED", landingSteering:GetTargetAoA@).
    flightStatus:AddField("TARGET AoA RAW", landingSteering:GetTargetAoARaw@). 
    flightStatus:AddField("MAX AoA", { Return landingSteering:GetMaxAoA(). }).   
    flightStatus:AddField("MIN AoA", { Return landingSteering:GetMinAoA(). }).       
    flightStatus:AddFIeld("SURF VEL MAG", { Return Ship:Velocity:Surface:Mag. }).

    flightStatus:Update("DIRECT TRAJECTORY").
    Wait 1.

    flightStatus:Update("FUEL VENTING").
    drainValveController:DrainToAmount(5_100, "Oxidizer").
    flightStatus:Update("VENTING COMPLETE").

    // Set SteeringManager:RollTorqueFactor to 0.
    landingSteering:SetMaxAoa(20).    
    Lock Steering to LookDirUp(landingSteering:SteeringVector(), rollReferenceOvershootSite:Position).                

Wait Until Altitude < 30_000.     
    RCS OFF.

Wait Until Altitude < 25_000.           
    engineController:SetEngineMode(ENG_MODE_SH_MID_INR).
    
    landingStatus:SetLandingSite(approachSlightUndershootRefSite).
    flightStatus:Update("LANDING SITE: SLIGHT UNDERSHOOT").
    Lock Steering to LookDirup(landingSteering:SteeringVector(),  rollReferenceOvershootSite:Position).            

Wait Until Altitude < 20_000.
    landingSteering:SetMaxAoa(16).

Wait Until Altitude < 12_000. 
    landingSteering:SetMaxAoA(12).

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

Local vsTarget to -15.
Local verticalSpeedHoldStart to false. 

flightStatus:AddField("REF", "RETROGRADE").
flightStatus:AddField("VS", { Return Ship:VerticalSpeed. }).
Local switchedToRadialOutReference to false.
Local steeringFlag to false.

Until verticalSpeedHoldStart { 
        
    If (not steeringFlag and Abs(Ship:Velocity:Surface:Mag) < 140) { 
        Set steeringFlag to true.

        flightStatus:Update("TRAVERSE STEERING").
        Set landingSite to towerVessel:Geoposition.                
        Lock Steering to LookDirUp(landingSteering:SteeringVectorReferenceRadialOut(),  rollReferenceOvershootSite:Position).
        ResetTorque().
    }    

    // Todo: should be checking accelerometer 
    If (not switchedToRadialOutReference and 
         (Abs(Ship:VerticalSpeed) < 40 or Ship:Velocity:Surface:Mag < 52)) {
            
        Set switchedToRadialOutReference to true.   
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
    landingSteering:SetMaxAoA(-4).              
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
            // Set vsTarget to -16.
            landingSteering:SetMaxAoA(-2.5).
            flightStatus:Update("TRAVERSE COAST START").
            // landingStatus:SetLandingSite(olmLandRefGeoPosition).
        }        

        If not intermidAoaSet and landingBurn:TrueRadar() < 60 { 
            Set vsTarget to -5.
            landingSteering:SetMaxAoA(-1.5).
            flightStatus:Update("INTERMID AoA SET").
            Set intermidAoaSet to true.            
        }

        If not actualLandingTargetSet and landingBurn:TrueRadar() < 30 { 
            landingStatus:SetLandingSite(olmGeoPosition).
            flightStatus:Update("LANDING SITE: OLM").
            Set actualLandingTargetSet to true.             
        }

        If not intermidVsSet and landingBurn:TrueRadar() < 20 { 
            Set vsTarget to -2.5.
            Set intermidVsSet to true.
            landingSteering:SetMaxAoA(-1).
            flightStatus:Update("INTERMID VS SET").
        }

        If not landingVSpeedStage2Set and landingBurn:TrueRadar() < 10 { 
            Set vsTarget to -1.          
            Set landingVSpeedStage2Set to true.            
            landingStatus:SetLandingSite(olmGeoPosition).
            flightStatus:Update("LANDING VS STAGE 2 SET, LANDING SITE: OLM").
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
            towerVessel:Connection:SendMessage(TOWER_PRECATCH_MESSAGE).  
            flightStatus:Update("REQUESTING PRECATCH").
            Set precatchMessageSent to true.
        }

        If (not catchMessageSent and landingBurn:TrueRadar() < boosterRadarOffset * 0.75) {
            towerVessel:Connection:SendMessage(TOWER_CATCH_MESSAGE).  
            flightStatus:Update("REQUESTING CATCH").                
            Set catchMessageSent to true.
        }              

        If (landingBurn:TrueRadar() > 40 and Time:Second > timeNextAlignment and landingBurn:TrueRadar() > 70) { 
            towerVessel:Connection:SendMessage(TOWER_ARMS_ALIGN_MESSAGE).            
            Set timeNextAlignment to Time:Second + timeBetweenAlignments.
            flightStatus:AddField("Alignment", "Done.").
        }

        Set errorPrevious to errorCurrent.

        // Get actual
        Return Ship:VerticalSpeed. 
    },
    {        
        Return landingBurn:TrueRadar() < 5.        
    }).     

    towerVessel:Connection:SendMessage(TOWER_CATCH_DAMPEN_MESSAGE).
    Set towerCatchDampenMessageSent to true.      

    flightStatus:Update("HOVER FOR CATCH").
    RunRadarAltitudeHold(64.5, 4, 
        0.1, 0.02, 0.0, // PID
        0.35, 1, // Min/Max
        { Return Ship:Status = "LANDED". }).

    Lock Throttle to 0.
    flightStatus:Update("TERMINAL").
    ClearVecDraws().
    Shutdown.


Wait Until false.