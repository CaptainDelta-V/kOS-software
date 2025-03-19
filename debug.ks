// RUNONCEPATH("common/constants").
// RUNONCEPATH("common/infos").
// RUNONCEPATH("common/engineManager").
// // RUNONCEPATH("common/flightStatus/flightStatusModel").
// // RUNONCEPATH("common/orbit/circularizationController").
// // RUNONCEPATH("common/nav").
// // RUNONCEPATH("common/landing/sites").
// // RUNONCEPATH("common/utils/listutils").
// RUNONCEPATH("common/engineManager").

ClearVecDraws().

Set LogFilepath to "logs/out.txt".
DeletePath(LogFilepath).

Log Ship:GeoPosition to LogFilepath.

// Local part to Ship:PartsTagged("MERLIN_9")[0].
// DescribePartItemToFile(part, LogFilepath).

// Local engineController to EngineManager(part, VESSEL_TYPE_FALCON_BOOSTER).
// engineController:SetEngineMode(ENG_MODE_MID_INR).

// Wait Until False. 

// Local part to Ship:PartsTagged("MERLIN_9_CORE")[0].
// DescribePartItemToFile(part, LogFilepath).

// Local enginesController to EngineManager(part, VESSEL_TYPE_FALCON_BOOSTER).
// enginesController:SetGimbalLimit(0).
// Wait 4. 
// enginesController:SetGimbalLimit(100).

// print Ship:Resources.

// Local resource to FindInList(Ship:Resource, { parameter it:Name = }). 

// Local part to Ship:PartsTagged("MECHAZILLA")[0].
// DescribePartItemToFile(part, LogFilepath).



// DescribeSuffixNamesToFile(oxy, LogFilepath).
// Log Ship:Resources to LogFilepath.
// Print Ship:Resources[0].

// Local oxy to FindInList(Ship:Resources, { parameter it. return it["Name"] = "Oxidizer". }).
// Print oxy.

// DescribePartItemToFile(drainValves[0], LogFilepath).

// DescribeSuffixNamesToFile(Ship:resources).

// Shutdown.

// Local traj to LatLng(21.232808, 43.080583).

// Local trajLat to Round(traj:Lat, 5).
// Local trajLng to Round(traj:Lng, 5).

// Print trajLat = Round(21.232808, 5). 
// Print trajLng = Round(43.080583, 5).



// drainModule



// Log part:Resources to LogFilepath.

// DescribePartItemToFile(pos, LogFilepath).

// Local geoPos to Body:GeoPositionOf(pos:Position).
// print geoPos.
// Log geoPos to LogFilepath.
// Local tank to Ship:Parts.
// Log tank to LogFilepath.
// DescribePartItemToFile(tank, LogFilePath).

// Local engines to Ship:PartsTagged("BOOSTER_RAPTORS")[0].

// DescribePartItemToFile(engines, LogFilepath).

// engines:GetModuleByIndex(1):SetField("thrust limiter", 30).

// mechazilla:getmodulebyindex(7):SetField("arms open angle", 20).

// Print HeadingOfVector(Target:Geoposition:Position - Ship:Geoposition:Position).
// Print HeadingOfVector(Ship:Geoposition:Position - Target:Geoposition:Position).

// Local cmdPart to Ship:PartsTagged("STARTOWER_COMMAND")[0].

// Local TARGET_COORDS to TARGET:GeoPosition:Position.



// ClearVecDraws().

// Set anArrow to VecDraw(
//     Ship:Position,
//     TARGET_COORDS,    
//     RGB(1,0,0),
//     "See the arrow?",
//     1.0,
//     true,
//     0.2,
//     true,
//     true
//     ).

// Wait 10.

// // Set anArrow to VECDRAWARGS(
// //       V(0,0,0),
// //       V(4,4,4),
// //       RGB(1,0,0),
// //       "See the arrow?",
// //       1.0,
// //       true,
// //       0.2,
// //       true,
// //       true
// //     ).


// // Wait 4. 
// ClearVecDraws().

// LOG TARGET:GeoPosition to DEBUG_OUT_FILE.

// Local OLM to Ship:PartsTagged("MECHAZILLA")[0]. 
// DESCRIBE_PART_ITEM_TO_FILE(OLM, DEBUG_OUT_FILE).

// Local QD_ARM to Ship:PartsTagged("QD_ARM")[0].
// // DESCRIBE_PART_ITEM_TO_FILE(MECHAZILLA, DEBUG_OUT_FILE).
// DESCRIBE_PART_ITEM_TO_FILE(QD_ARM, DEBUG_OUT_FILE).

// Local LIFT to Ship:PartsTagged("LIFT")[0].


// DESCRIBE_SUFFIXNAMES_TO_FILE(LIFT:GetModule("ModuleServo"), DEBUG_OUT_FILE).
// DESCRIBE_MODULE_TO_FILE(LIFT:GetModule("ModuleServo"), DEBUG_OUT_FILE).



// LIFT:GetModule("ModuleServo"):DoAction("increase speed", 1).


// Local CIRCULARIZATION to CIRCULARIZATION_CONTROLLER(105_000).

// Function TEST_IT { 
//     Return "2".
// }

// DESCRIBE_SUFFIXNAMES_TO_FILE(TEST_IT).











// Function TEST_IT { 
//     Function INSIDE { 
//         Return 1.
//     }

//     // Function ANOTHER { 
//     //     Return "BS".
//     // }



//     // Local flightStatus to FlightStatusModel("TEST", "WAITING").

//     // DESCRIBE_SUFFIXNAMES_TO_FILE(INSIDE@).
//     // Print INSIDE@:HasSuffix("Call").
//     // Print INSIDE@:HasSuffix("CALLDSLKJFSDLK").

//     // Print INSIDE@:TYPENAME().
//     // Print ANOTHER@:TYPENAME().
    
//     // Print INSIDE:SUFFIXNAMES.
//     // Print INSIDE:TYPENAME(). 
//     // Print ANOTHER:TYPENAME().

//     // DESCRIBE_SUFFIXNAMES_TO_FILE(INSIDE@).
//     // Print(INSIDE:SUFFIXNAMES()).
//     // Print(INSIDE:inheritance).
//     // Print(INSIDE:TYPENAME()).
//     // Print(INSIDE:TOSTRING()).
// }

// TEST_IT().
// RUNONCEPATH("common/landing/landingmodel").

// Local METERS_PER_DEGREE to Ship:Body:Radius * 2 * Constant:Pi / 360.    
// Print 10 * METERS_PER_DEGREE + "meters".



// // Local ENGINES to Ship:PartsTagged("BOOSTER_RAPTORS")[0].
// // DESCRIBE_PART_ITEM_TO_FILE(ENGINES, DEBUG_OUT_FILE).

// // Lock MAXDECEL to (Ship:AvailableThrust / Ship:Mass) - G.	

// // Print Ship:availablethrust.

// // Local MECHAZILLA to Ship:PartsTagged("MECH_ARMS")[0].
// // DESCRIBE_PART_ITEM_TO_FILE(MECHAZILLA, DEBUG_OUT_FILE).

// // Local SLE_CONTROLLER to MECHAZILLA:GetModule("ModuleSLEController").
// // DESCRIBE_SUFFIXNAMES_TO_FILE(SLE_CONTROLLER, DEBUG_OUT_FILE).
// // DESCRIBE_SUFFIXNAMES_TO_FILE(MECHAZILLA:MODULES, DEBUG_OUT_FILE).

// // Local GRID_FINS to Ship:PartsTagged("GRID_FIN").
// // // // Print GRID_FINS[0].
// // // Print GRID_FINS[3][].

// // DESCRIBE_PART_ITEM_TO_FILE(GRID_FINS[0], DEBUG_OUT_FILE).

// // GRID_FINS[0]:GetModule("ModuleControlSurface"):DoAction("activate roll control", true).
// // GRID_FINS[0]:GetModule("ModuleControlSurface"):DoAction("activate pitch control", true).
// // GRID_FINS[0]:GetModule("ModuleControlSurface"):DoAction("activate yaw control", true).



// // Local LANDINGSITE to  LANDINGSITE is LANDING_SITES[KEY_KSC_LNDG_ZONE_WEST].
// // LatLng(-0.2054109, -74.473228).
// Parameter landingSite to Ship:Velocity:Surface.
// LOG landingSite to "logs/site.txt".

// // Set ENGINES to Ship:PartsTagged("BOOSTER_RAPTORS")[0].

// // DESCRIBE_PART_ITEM_TO_FILE(ENGINES, "logs/out.txt").
// // DESCRIBE_SUFFIXNAMES_TO_FILE(ENGINES, "logs/out.txt").

// Print "PREPARING to LAUNCH".
// Wait 1.
// Lock Throttle to 1.
// Stage.
// Wait Until false. 

// Function PRINT_STATUS { 
//     ClearScreen.
//     Print TITLE.
//     Print "FLIGHT STATUS: " + flightStatus.
//     Print "TOWER:: " + TOWER_STATUS.
//     Print "TARGET: " + LANDING_MODEL:GETSITE().
//     Print "lat ERR: " + Round(LANDING_MODEL:LAT_ERR(), 2).
//     Print "lng ERR: " + Round(LANDING_MODEL:LNG_ERR(), 2).
//     Print "TGT ERR: " + Round(LANDING_MODEL:TOT_ERR_MTRS(), 1) + "m".
//     Print "true TGT ERR: " + Round(TRUE_LANDING_MODEL:TOT_ERR_MTRS(), 1) + "m".
//     Print "POS ERR: " + Round(LANDING_MODEL:POS_ERR_MTRS(), 1) + "m".
//     Print "ERR VECT: " + LANDING_MODEL:ERR_VECT().
//     Print "ERR VECT HDG: " + HEADING_OF_VECTOR(LANDING_MODEL:ERR_VECT()).
//     Print "ERR VECT Pitch: " + PITCH_OF_VECTOR(LANDING_MODEL:ERR_VECT()).
//     Print "HVEL VECT: " + HORIZONTAL_VELOCITY_VECTOR.
//     Print "Max AOA: " + Round(MAX_AOA, 2).    
//     Print "IMPACT Time: " + Round(ImpactTime, 1).
//     Print "AVAL THRUST: " + Round(MaxThrustActual,1) + " Max DECEL: " + Round(MAXDECEL) + " STOPDIST: " + Round(STOPDIST, 2).
//     Print "ECC: " + Round(OBT:ECCENTRICITY, 6).
//     Print "ACCEL TOT: " + Round(ACCEL_TOT,3).    
//     Print "VERT SPEED: " + Round(Ship:VerticalSpeed, 1).
//     Print "Velocity: " + Ship:Velocity:Surface.
//     Print "Velocity Mag: " + Ship:Velocity:Surface:Mag.
//     Print "HORIZ SPEED | lat: " + Round(SPEED_LAT, 2) + " lng: " + Round(SPEED_LNG, 2).
//     Print "RETROGRADE Pitch: " + Round(RetrogradePitch,2).
//     Print "RETROGRADE Heading: " + Round(RetrogradeHeading, 2).    
//     Print "Altitude: " + Round(Altitude, 0).
//     Print "true RADAR: " + Round(TrueRadar, 0).
// }
