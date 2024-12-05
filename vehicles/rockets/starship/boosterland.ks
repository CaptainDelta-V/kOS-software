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

Set Ship:Name to ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME.
Parameter SkipBoostback to true.
Parameter SkipWaitForInitiationMessage to true.
Parameter Debug to true.

Local engines to Ship:PartsTagged("BOOSTER_RAPTORS")[0].
Local engineModule to engines:GetModule("ModuleTundraEngineSwitch").
Local gridFins to Ship:PartsTagged("GRID_FIN").

Local engineManagement to EngineManager(engineModule, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).
Local gridFinManagement to GridFinManager(gridFins, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).

Local boosterRadarOffset to 70.
Local towerCatchAltitude to 150.
Local towerCatchOffsetAltitude to towerCatchAltitude - boosterRadarOffset.
Local suicideMargin to 50.
Local maxBurnStartAltitude to 2_800.
Local undershootMeters to -15.
Local overshootMeters to 40. 
Local towerStatus to "Not CONNECTED".

Local towerVessel to Vessel(TOWER_CPU_NAME).
Local landingSite is towerVessel:GeoPosition.
Local targetLandingSite is landingSite.
Local approachOvershootSite is LandingStatusModel(landingSite, towerCatchAltitude):Overshoot(overshootMeters):GetLandingSite().
Local approachUndershootSite is LandingStatusModel(landingSite, towerCatchAltitude):Overshoot(undershootMeters):GetLandingSite().
Local landingStatus to LandingStatusModel(approachOvershootSite, towerCatchAltitude):Overshoot(undershootMeters).
Local landingSteering to LandingSteeringModel(landingStatus).
Local flightStatus to FlightStatusModel("SUPER HEAVY Booster LANDING GUIDANCE").

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
flightStatus:AddField("ECCENTRICITY", landingStatus:ECCENTRICITY@).
flightStatus:AddField("ERROR PITCH", { Return PitchOfVector(landingStatus:ErrorVector()). }).
flightStatus:AddField("ERROR HEADING", { Return HeadingOfVector(landingStatus:ErrorVector()). }).

// Local BOOSTBACK_PITCH to 45. // tanker weight
// Local BOOSTBACK_PITCH to 14. // base systems weight
Local boostbackPitch to 5.
Local targetRoll to -70.

RunFlightStatusScreen(flightStatus, 1).
ResetTorque().

Lock Throttle to 0.
SAS OFF. 
RCS ON.
Wait 0.

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
    Set directArrow:VecUpdater to { Return landingSite:AltitudePosition(towerCatchAltitude):Normalized * arrowSize. }.

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


    Set steeringVectorArrow:StartUpdater to { Return Ship:Position. }.
    Set steeringVectorArrow:VecUpdater to { Return landingSteering:SteeringVector():Normalized * arrowSize. }.
    
    // Local steeringVectorRefRadialOutRealArrow to VecDraw(
    //     V(0,0,0),
    //     V(0,0,0),
    //     RGB(1,0,1),
    //     "REAL REF RADIAL OUT", 1.0, true, 0.1, true, true
    // ).

    // Set steeringVectorRefRadialOutRealArrow:StartUpdater to { Return Ship:Position. }.
    // Set steeringVectorRefRadialOutRealArrow:VecUpdater to { Return landingSteering:SteeringVectorReferenceRadialOut() * arrowSize. }.

    Local errorVectorArrow to VecDraw(
        V(0,0,0),
        V(0,0,0),
        RGB(1,0.2,0.2),
        "ERROR", 1.0, true, 0.1, true, true
    ).

    Set errorVectorArrow:StartUpdater to { Return Ship:Position. }.
    Set errorVectorArrow:VecUpdater to { Return (landingStatus:ErrorVector()). }.
    
    Local errorAtHorizon to VecDraw(
        V(0,0,0),
        V(0,0,0),
        RGB(0.2,0.2,0.8),
        "ERROR HORIZON", 1.0, true, 0.1, true, true
    ).

    Set errorAtHorizon:StartUpdater to { Return Ship:Position. }.
    Set errorAtHorizon:VecUpdater to { Return landingStatus:ErrorVectorAtHorizon():Normalized * arrowSize. }.    
}


engineManagement:SetEngineState(true).
engineManagement:SetEngineMode(ENG_MODE_MID_INR).

RCS ON.
Lock Steering to Heading(landingStatus:RetrogradeHeading(), boostbackPitch, targetRoll). 

flightStatus:Update("CHECKING For LANDING SEQUENCE INITIATION MESSAGE").
Wait 0.5.

If Not SkipWaitForInitiationMessage { 
    Local startBoostback to false.
    When Not Ship:Messages:Empty Then { 
        Local message to Ship:Messages:Peek:Content.
        If message = INITIATE_LANDING_SEQUENCE_MESSAGE { 
            Set startBoostback to true. 
        }      
    }

    Wait Until startBoostback.
} 

If Not SkipBoostback { 
    flightStatus:Update("BOOSTBACK ORIENTATION").    
    Local boostback to BoostbackBurnController(landingStatus, landingSteering).
    Local boostbackAbortAltitude to 64_000.

    flightStatus:Update("BOOSTBACK ITERATION: 1").
    boostback:Engage(boostbackPitch, 5_000, 0.00005, boostbackAbortAltitude, 0.3).

    flightStatus:Update("BOOSTBACK ITERATION: 2").
    engineManagement:SetEngineMode(ENG_MODE_CTR).        
    boostback:Engage(boostbackPitch, 500, 0.5, boostbackAbortAltitude, 0.2).

    // flightStatus:Update("BOOSTBACK ITERATION: 3").    
    // boostback:Engage(boostbackPitch, 100, 0.5, boostbackAbortAltitude, 0.1).
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

    // Lock Steering to Heading(landingStatus:RetrogradeHeading() + 180, 45, 0). 
    // Lock Steering to -Ship:Velocity:Surface.

    gridFinManagement:SetEnabled(true).
    gridFinManagement:SetAuthorityLimit(38).        
    landingStatus:SetTargetAltitude(0).        

    flightStatus:AddField("TARGET AoA CAPPED", landingSteering:GetTargetAoA@).
    flightStatus:AddField("TARGET AoA RAW", landingSteering:GetTargetAoARaw@). 
    flightStatus:AddField("MAX AoA", { Return landingSteering:GetMaxAoA(). }).   
    flightStatus:AddField("MIN AoA", { Return landingSteering:GetMinAoA(). }).   

    flightStatus:AddField("SDP", { Return landingSteering:GetSteeringDirectionPitch(). }).
    flightStatus:AddField("SDH", { Return landingSteering:GetSteeringDirectionHeading(). }).

    flightStatus:Update("DIRECT TRAJECTORY").
    landingSteering:SetMaxAoa(40).
    Lock Steering to landingSteering:SteeringVector().
    // Lock Steering to landingSteering:SteeringDirection(targetRoll).

Wait Until Altitude < 30_000.     
    RCS OFF.

Wait Until Altitude < 25_000.         
    // Lock Steering to landingSteering:SteeringDirection(-90, true).    
    landingSteering:SetErrorScaling(1).
    landingSteering:SetMaxAoa(20).    
    engineManagement:SetEngineMode(ENG_MODE_MID_INR).
    landingStatus:SetLandingSite(approachOvershootSite).
    Lock Steering to landingSteering:SteeringVector().
        
    // Lock Steering to landingSteering:SteeringVector().

Wait Until Altitude < maxBurnStartAltitude.
    // do not start burn stupid early

landingBurn:SetRadarOffset(600).  

Local landingBurnStart to false. 
Until landingBurnStart {
    Set landingBurnStart to landingBurn:TrueRadar() < landingBurn:GetStopDistance() + suicideMargin.
    Wait 0.001.
}        
    
    // Lock Throttle to landingBurn:LinearLandingThrottle().    
    Lock Steering to -Ship:Velocity:Surface.
    Lock Throttle to 1.    
    landingSteering:SetMaxAoA(-1).      
    landingBurn:SetRadarOffset(boosterRadarOffset).
    flightStatus:Update("LANDING BURN - 13 Engines").                

Local vsholdInitial to -60.
Local threeEnginesStart to false. 
// Local landingSiteSet to false.

When landingBurn:TrueRadar() < 1_000 Then { 
    landingStatus:SetLandingSite(targetLandingSite).    
    flightStatus:AddField("FINAL SITE SET", "1").
}

flightStatus:AddField("REF", "RETROGRADE").
// Lock Steering to landingSteering:SteeringVector(RadialOutVectorNormalized()).  
Local switchedToRadialOutReference to false.

Until threeEnginesStart { 

    Set threeEnginesStart to Abs(Ship:VerticalSpeed) < Abs(vsholdInitial).

    If (not switchedToRadialOutReference and Abs(Ship:VerticalSpeed) < Abs(vsholdInitial * 2)) { 
        // Lock Steering to landingSteering:SteeringVector(RadialOutVectorNormalized()).  
        // Lock Steering to RadialOutVectorNormalized().
        Lock Steering to landingSteering:SteeringVectorReferenceRadialOut().
        flightStatus:AddField("REF", "RADIAL OUT").
        Set switchedToRadialOutReference to true.        
    }
  
    Wait 0.001.
}            
    
    flightStatus:Update("LANDING BURN - 3 Engines").         
    engineManagement:SetEngineMode(ENG_MODE_CTR).        
    gridFinManagement:SetEnabled(false).                      
    landingSteering:SetMaxAoa(-5).                  
    
    towerVessel:Connection:SendMessage(TOWER_PRECATCH_MESSAGE).                   

    flightStatus:Update("VERTICAL SPEED HOLD").
    RunVerticalSpeedHold({   
        Local vsTarget to vsholdInitial.  

        Set vsTarget to -10.
        // If landingBurn:TrueRadar() < 1200 { 
        //     Set vsTarget to 40.
        // }     
        // If landingBurn:TrueRadar() < 650 { 
        //     Set vsTarget to 20.
        // }
        // If landingBurn:TrueRadar() < 150 { 
        //     Set vsTarget to 12.
        // }
        // If landingBurn:TrueRadar() < 30 { 
        //     flightStatus:Update("VS STABILIZE").
        //     Set vsTarget to 2.
        // }        

        Set vsTarget to -Abs(vsTarget).

        flightStatus:AddField("VS TARGET", vsTarget).
        Return vsTarget.                
    }, 60, 0.01, 0, 0, 10, 1, 
    { 
        // Getting actual
        Return Ship:VerticalSpeed. 
    },
    {        
        // Termination condition
        Return Abs(Ship:Altitude - towerCatchAltitude) < 5 and Abs(Ship:VerticalSpeed < 4.5).
    }).     

    flightStatus:Update("HOVER").
    RunAltitudeHold(towerCatchAltitude, 60, 0.05, 10, 0.0, 0.1, 1). 


Wait Until false.


//////////////////// post landing
 // When Altitude < 5 Then { 
    //     Local TOWER_VESSEL to Vessel(TOWER_VESSEL_NAME).
    //     TOWER_VESSEL:Connection:SendMessage(TOWER_CATCH_MESSAGE).  
                
    //     Lock Throttle to 0.
                            

    //     Set Ship:Name to "RETURNED Booster".
    //     Set Core:BootFilename to "".         
    //     SHUTDOWN.
    // }