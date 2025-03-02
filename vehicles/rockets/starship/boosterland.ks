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

Local boosterRadarOffset to 63.4.
Local towerCatchAltitude to 150.
Local towerCatchOffsetAltitude to towerCatchAltitude - boosterRadarOffset.
Local suicideMargin to 70.
Local maxBurnStartAltitude to 2_800.
Local undershootMeters to -40.
Local overshootMeters to 18. // 160 is very steep
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
Local approachUndershootSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(undershootMeters):GetLandingSite().
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

    // Local errorVectorArrow to VecDraw(
    //     V(0,0,0),
    //     V(0,0,0),
    //     RGB(1,0.2,0.2),
    //     "ERROR", 1.0, true, 0.1, true, true
    // ).

    // Set errorVectorArrow:StartUpdater to { Return Ship:Position. }.
    // Set errorVectorArrow:VecUpdater to { Return (landingStatus:ErrorVector()). }.
    
    Local errorAtHorizon to VecDraw(
        V(0,0,0),
        V(0,0,0),
        RGB(0.2,0.2,0.8),
        "ERROR HORIZON", 1.0, true, 0.1, true, true
    ).

    Set errorAtHorizon:StartUpdater to { Return Ship:Position. }.
    Set errorAtHorizon:VecUpdater to { Return landingStatus:ErrorVectorAtHorizon():Normalized * arrowSize. }.    

    // Local facingArrow to VecDraw(
    //     V(0,0,0),
    //     V(0,0,0),
    //     RGB(0,0,1),
    //     "FACING", 1.0, true, 0.1, true, true
    // ).

    // Set facingArrow:StartUpdater to { Return Ship:Position. }.
    // Set facingArrow:VecUpdater to { Return Ship:Facing. }.
}

engineManagement:SetEngineState(true).
engineManagement:SetEngineMode(ENG_MODE_MID_INR).

landingStatus:SetLandingSite(approachOvershootSite).

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
            Set Target to Vessel(TOWER_VESSEL_NAME).
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
    flightStatus:AddFIeld("Surface Mag", { Return Ship:Velocity:Surface:Mag. }).

    flightStatus:Update("DIRECT TRAJECTORY").
    landingSteering:SetMaxAoa(40).    
    Lock Steering to landingSteering:SteeringVector().
    // Lock Steering to landingSteering:SteeringDirection(targetRoll).

Wait Until Altitude < 30_000.     
    RCS OFF.

Wait Until Altitude < 25_000.         
    // Lock Steering to landingSteering:SteeringDirection(-90, true).    
    landingSteering:SetErrorScaling(4).
    landingSteering:SetMaxAoa(12).    
    engineManagement:SetEngineMode(ENG_MODE_MID_INR).
    
    Lock Steering to landingSteering:SteeringVector().
        
    // Lock Steering to landingSteering:SteeringVector().
Wait Until Altitude < 20_000.
    landingSteering:SetMaxAoa(6).

Wait Until Altitude < maxBurnStartAltitude.
    // do not start burn stupid early

landingSteering:SetMaxAoa(12).
landingBurn:SetRadarOffset(420).  

Local landingBurnStart to false. 
Until landingBurnStart {
    Set landingBurnStart to landingBurn:TrueRadar() < landingBurn:GetStopDistance() + suicideMargin.
    Wait 0.001.
}        
    
// Lock Throttle to landingBurn:LinearLandingThrottle().    
Lock Steering to -Ship:Velocity:Surface.
Lock Throttle to 1.    
landingSteering:SetMaxAoA(-8).      
landingBurn:SetRadarOffset(boosterRadarOffset).
flightStatus:Update("LANDING BURN - 13 Engines").                

Local vsholdInitial to -14.
Local verticalSpeedHoldStart to false. 

flightStatus:AddField("REF", "RETROGRADE").
flightStatus:AddField("VS", { Return Ship:VerticalSpeed. }).
Local switchedToRadialOutReference to false.
Local steeringUnlocked to false.

Until verticalSpeedHoldStart { 
        
    If (not steeringUnlocked and Abs(Ship:Velocity:Surface:Mag) < 100) { 
        Set steeringUnlocked to true.

        flightStatus:Update("TRAVERSE STEERING").
        Set landingSite to towerVessel:Geoposition.        

        // manual mode
        // Unlock Steering.          
        // Wait 0.
        // SAS ON.
        // wAIT 0.
        // SET SASMODE to "RADIALOUT".            
        // flightStatus:Update("MANUAL STEERING").
        // end manual mode
        
        // Lock surfaceNorth to Body:North:Vector:Normalized.

        // // Compute the Radial Out vector (upward direction)        
        // Lock RadialOutVector to landingSteering:SteeringVectorReferenceRadialOut().
        // Lock RadialOutVector to RadialOutVectorNormalized().
        

        // // Compute the Right Vector (horizontal axis perpendicular to Radial Out and North)
        // Lock RightVector to VCRS(surfaceNorth, RadialOutVector):Normalized.

        // // Compute the Corrected Up Vector (perpendicular to Radial Out and Right)
        // Lock CorrectedUpVector to VCRS(RadialOutVector, RightVector):Normalized.

        // // 90 is west, not corresponding to heading, offset this for the direction to the tower and lock so that can move dynamically
        // // Rotate Up Vector by 90° to the West (left-hand rotation around RadialOutVector)
        // Lock OffsetUpVector to CorrectedUpVector * COS(90) + RightVector * SIN(90). 

        // Lock SteeringVector to LOOKDIRUP(RadialOutVector, OffsetUpVector).

        // // Lock steering to the computed vector (only once)
        // Lock steering to SteeringVector.

        // Lock OffsetUpVector to landingSteering:SteeringVectorReferenceRadialOut()
        //  * COS(90) + RightVector * SIN(90). 
        
        Lock Steering to landingSteering:SteeringVectorReferenceRadialOut().
    }

    // If (not switchedToRadialOutReference and Abs(Ship:VerticalSpeed) < Abs(vsholdInitial * 2.5)) { 
    // If (not switchedToRadialOutReference and Abs(Ship:Velocity:Surface:Mag) < 80) { 
    // Abs(landingStatus:RetrogradePitch() > 78

    

    // Todo: should be checking accelerometer 
    If (not switchedToRadialOutReference and 
         (Abs(Ship:VerticalSpeed) < 40 or Ship:Velocity:Surface:Mag < 50)) {
        
        // Lock Steering to landingSteering:SteeringVectorReferenceRadialOut().
        Set switchedToRadialOutReference to true.   

        // Lock Steering to RadialOutVectorNormalized().             
        Lock Throttle to 0.25.     
        flightStatus:Update("LANDING BURN - 3 Engines").         
        engineManagement:SetEngineMode(ENG_MODE_CTR).        
        gridFinManagement:SetEnabled(false).   
        landingStatus:SetLandingSite(olmLandRefGeoPosition).

        Set verticalSpeedHoldStart to true.

        Break.
    }
  
    Wait 0.001.
}                    
    landingSteering:SetMaxAoa(-8).              
    landingSteering:SetMinAoa(0).
    landingSteering:SetErrorScaling(10_000).

    Local previousErrorMeters to landingStatus:TrajectoryErrorMeters() + 1.
    Local minimumApproachErrorMeters is 15.
    Local traverseCoastStart is false.

    Local timeBetweenAlignments to 4.
    Local timeNextAlignment to Time:Second + timeBetweenAlignments.

    Local precatchMessageSent to false.
    Local catchMessageSent to false. 
    Local finalAlignmentMessageSent to false.
    Local finalRadialOutEngaged to false.
    Local towerCatchDampenMessageSent to false.

    flightStatus:Update("VERTICAL SPEED HOLD").
    RunVerticalSpeedHold({   
        Local vsTarget to vsholdInitial.          

        If landingBurn:TrueRadar() < 250 { 
            Set vsTarget to -10.
        }    

        If landingBurn:TrueRadar() < 110 { 
            Set vsTarget to -8.
            landingSteering:SetMaxAoa(-4).
            landingStatus:SetLandingSite(towerBaseGeoPosition).
        }

        If landingBurn:TrueRadar() < 80 { 
            Set vsTarget to -6.            
        }

        If landingBurn:TrueRadar() < 40 { 
            Set vsTarget to -3.
            landingStatus:SetLandingSite(olmLandRefGeoPosition).
        }

        If landingBurn:TrueRadar() < 25 { 
            landingSteering:SetMaxAoa(-2.5).            
        }     

        If landingBurn:TrueRadar() < 10 { 
            Set vsTarget to -1.
            landingSteering:SetMaxAoA(-1).            
        }

        If landingBurn:TrueRadar() < 6 { 
            Set vsTarget to -0.25.
            // landingSteering:SetMaxAoA(-0.5).
        }

        Set vsTarget to -Abs(vsTarget).

        flightStatus:AddField("VS TARGET", vsTarget).        
        Return vsTarget.                
    }, 60, 0.1, 0, 0, 0.15, {

        Local maxOutput to 1.

        // If landingBurn:TrueRadar() < 100 { 
        //     Set maxOutput to 0.6.
        // }
        
        return maxOutput.
    }, 
    { 
        Local errorCurrent is landingStatus:TrajectoryErrorMeters().

        If (not precatchMessageSent) { 
            towerVessel:Connection:SendMessage(TOWER_PRECATCH_MESSAGE).  
            flightStatus:Update("REQUESTING PRECATCH").
            Set precatchMessageSent to true.
        }

        If (not catchMessageSent and landingBurn:TrueRadar() < boosterRadarOffset * 0.5) {
            towerVessel:Connection:SendMessage(TOWER_CATCH_MESSAGE).  
            flightStatus:Update("REQUESTING CATCH").    
            Set catchMessageSent to true.
        }              

        If (Time:Second > timeNextAlignment) { 
            towerVessel:Connection:SendMessage(TOWER_ARMS_ALIGN_MESSAGE).            
            Set timeNextAlignment to Time:Second + timeBetweenAlignments.
        }

        If (landingBurn:TrueRadar() < 4 and not finalRadialOutEngaged) {                
            // Lock steering to RadialOutVectorNormalized().
            Lock Steering to Heading(0,90,90).
            flightStatus:Update("RADIAL OUT ROT LOCK").
            Set finalRadialOutEngaged to true.                            
        }

        If (landingBurn:TrueRadar() < 2 and not towerCatchDampenMessageSent) { 
            towerVessel:Connection:SendMessage(TOWER_CATCH_DAMPEN_MESSAGE).
            Set towerCatchDampenMessageSent to true.            
        }        

        // If (not finalAlignmentMessageSent and landingBurn:TrueRadar() < 10) {         
        //     Unlock Steering.          
        //     Wait 0.
        //     SAS ON.
        //     wAIT 0.
        //     SET SASMODE to "RADIALOUT".                    
        //     flightStatus:Update("ROTATE ALIGN RADIAL OUT").
        //     Set finalAlignmentMessageSent to true.
        // }
        
        Set previousErrorMeters to errorCurrent.

        // Get actual
        Return Ship:VerticalSpeed. 
    },
    {        
        Return landingBurn:TrueRadar() < 0.    
    }).     

    Lock Throttle to 0.
    flightStatus:Update("TERMINAL").
    Shutdown.


Wait Until false.

// Function CheckMomentumTowardsTower { 


// }

//////////////////// post landing
 // When Altitude < 5 Then { 
    //     Local TOWER_VESSEL to Vessel(TOWER_VESSEL_NAME).
    //     TOWER_VESSEL:Connection:SendMessage(TOWER_CATCH_MESSAGE).  
                
    //     Lock Throttle to 0.
                            

    //     Set Ship:Name to "RETURNED Booster".
    //     Set Core:BootFilename to "".         
    //     SHUTDOWN.
    // }