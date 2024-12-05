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

print "WTF".

Set Ship:Name to ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME.
Parameter SkipBoostback to false.
Parameter SkipWaitForInitiationMessage to true.
Parameter Debug to true.


Local boosterRadarOffset to 70.
Local towerCatchAltitude to 150.
Local towerCatchOffsetAltitude to towerCatchAltitude - boosterRadarOffset.
Local undershoot to -10.
Local towerStatus to "NOT CONNECTED".

Local towerVessel to Vessel(TOWER_CPU_NAME).
Local landingSite is towerVessel:GeoPosition.
Local targetLandingSite is LandingStatusModel(landingSite, towerCatchAltitude):Offset(0,2):GetLandingSite().
Local landingStatus to LandingStatusModel(landingSite, towerCatchAltitude).
Local landingSteering to LandingSteeringModel(landingStatus).
Local flightStatus to FlightStatusModel("SUPER HEAVY Booster LANDING GUIDANCE").

flightStatus:AddField("TOWER", towerStatus).
flightStatus:AddField("TARGET COORDS", { 
    Local site to landingStatus:GetLandingSite().
    Return site:Lat + "," + site:Lng.
}).
flightStatus:AddField("CURRENT", { Return Ship:GeoPosition:Lat + ", " + Ship:GeoPosition:Lng. }).

landingSteering:SetMaxAoa(-42).


// flightStatus:AddField("LATITUDE ERROR", { Return towerVess }).
// flightStatus:AddField("LONGITUDE ERROR", landingStatus:LongitudeError@).
// flightStatus:AddField("TRAJECTORY ERROR METERS", landingStatus:TrajectoryErrorMeters@).
// flightStatus:AddField("POSITION ERROR METERS", landingStatus:PositionErrorMeters@).
// flightStatus:AddField("RETROGRADE", {
//     Local retroVector to -Ship:Velocity:Surface.
//     Return "HEADING: " + Round(HeadingOfVector(retroVector), 2) + " Pitch: " + Round(PitchOfVector(retroVector), 2).
// }).
// flightStatus:AddField("ECCENTRICITY", landingStatus:ECCENTRICITY@).
// flightStatus:AddField("ERROR PITCH", { Return PitchOfVector(landingStatus:ErrorVector()). }).
// flightStatus:AddField("ERROR HEADING", { Return HeadingOfVector(landingStatus:ErrorVector()). }).

// Local BOOSTBACK_PITCH to 45. // tanker weight
// Local BOOSTBACK_PITCH to 14. // base systems weight

RunFlightStatusScreen(flightStatus, 1).
ResetTorque().
ClearVecDraws().

If Debug { 
    
    Local arrowSize to 200.  

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

    Local directArrow to VecDraw(    
        V(0,0,0),
        V(0,0,0),
        RGB(0.2,1,0),
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
        RGB(0,1,1),
        "STEERING LIMITED AoA",
        1.0,
        true,
        0.1,
        true,
        true
    ).

    Set steeringRefRadialOutArrow:StartUpdater to { Return Ship:Position. }.
    Set steeringRefRadialOutArrow:VecUpdater to { Return landingSteering:SteeringVector(RadialOutVectorNormalized()):Normalized * arrowSize. }.

    
    Local perpendicularArrow to VecDraw(
        V(0,0,0),
        V(0,0,0),
        RGB(1,0,1),
        "PERPENDICULAR", 1.0, true, 0.1, true, true
    ).


    Set perpendicularArrow:StartUpdater to { Return Ship:Position. }.
    Set perpendicularArrow:VecUpdater to { 

        
        Local radialOut to (Ship:Body:Position - Ship:Position):Normalized. 
        Local targetDirection to (targetLandingSite:Position - Ship:Position):Normalized.

        Local projectionOntoRadialOut to (VectorDotProduct(targetDirection, radialOut)) * radialOut.
        Local perpendicularVect to (targetDirection - projectionOntoRadialOut):Normalized.

        Set perpendicularVect to perpendicularVect * arrowSize.

     
        Return perpendicularVect.     
     }.

}


Wait Until false. 