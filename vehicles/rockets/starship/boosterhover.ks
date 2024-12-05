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
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("../../../common/booting/bootUtils").

Local ENGINES to Ship:PartsTagged("BOOSTER_RAPTORS")[0].
Local ENGINE_MODULE to ENGINES:GetModule("ModuleTundraEngineSwitch").
Local ENGINE_MANAGEMENT to EngineManager(ENGINE_MODULE, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).

Local TOWER_STATUS to "Not CONNECTED".
Local landingSite is LANDING_SITES[KEY_KSC_PAD_MAIN].

Local landingStatus to LandingStatusModel(landingSite).
Local landingSteering to LandingSteeringModel(landingSite).

Local flightStatus to FlightStatusModel("SUPER HEAVY Booster HOVER TEST").
Local STARTOWER_Core to Processor(TOWER_CPU_NAME).

GET_LAUNCH_CONFIRMATION(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.5).

Wait 2.
Lock Throttle to 1.
ENGINE_MANAGEMENT:SetEngineState(true).
ENGINE_MANAGEMENT:SetEngineMode(ENG_MODE_MID_INR).

Wait 3.
STARTOWER_Core:Connection:SendMessage(TOWER_RELEASE_MESSAGE).
Wait 0.5.
Stage.

///

Declare Local CALC_THROTTLE to .5.
Lock Throttle to CALC_THROTTLE.

Lock Steering to LookDirUp(Up:FOREVECTOR, Heading(180, 0, 0):FOREVECTOR).

Stage.

Declare Local TARGETALT to 143.
flightStatus:Update("STARTING pid Control. TARGETING: <color=""#ffffff"">" + TARGETALT + "</color>").

Local KP to .05.
Local KI to .08.
Local KD to .1.
Local MIN_THROTT to 0.1.
// Local MAX_THROTT


// Declare Local KP to .05.
// Declare Local KI to .009.
// Declare Local KD to .8.

flightStatus:AddField("pid:", "LOOP(" + KP + ", " + KI + "," + KD + ", .1, 1).").
Declare Local pid to PidLoop(KP, KI, KD, 0.05, 1).
Set pid:SetPoint to TARGETALT.


Local HOVER_START to false. 
Local CATCH_ALT to 138.
Local ALT_THRESHOLD to 5. 

Until HOVER_START { 
    Set HOVER_START to Altitude < CATCH_ALT.
    Wait 0.                
}

Local REQUEST_CATCH to false. 
Local TOWER_VESSEL to Vessel(TOWER_VESSEL_NAME).

// Until false {
//     Set CALC_THROTTLE to pid:Update(Time:Seconds, Ship:Altitude). 
//     flightStatus:AddField("Alt", { Return Round(Ship:Altitude, 2). }).

//     If Not REQUEST_CATCH AND (Altitude < CATCH_ALT + ALT_THRESHOLD AND Altitude > CATCH_ALT - ALT_THRESHOLD) { 
//         TOWER_VESSEL:Connection:SendMessage(TOWER_CATCH_MESSAGE).
//         Set REQUEST_CATCH to TOWER_VESSEL:Connection:SendMessage(TOWER_CATCH_DAMPEN_MESSAGE).
//     }

//     Wait 0.
// }




// If Vessel(TOWER_VESSEL_NAME):Connection:SendMessage(TOWER_CATCH_MESSAGE) { 
//     flightStatus:AddField("TOWER", "CATCHING"). 
// }
// Else { 
//     flightStatus:AddField("TOWER", "FAIL STATE"). 
// }                       

// Wait Until false. 