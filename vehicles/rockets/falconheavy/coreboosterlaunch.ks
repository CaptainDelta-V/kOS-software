Wait Until Ship:Unpacked.
RUNONCEPATH("../../../common/constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/landing/landingStatusModel"). 
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/launch/launchProfileModel").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("constants").

// Parameter Ship

Local ENGINE to Ship:PartsTagged("MERLINS")[0].
Local ENGINE_MODULE to ENGINE:GetModule(TUNDRA_ENGINE_MODULE_NAME).
Local EngineManager to EngineManager(ENGINE_MODULE, VESSEL_TYPE_FALCON_BOOSTER).

Local LAUNCH_PROFILE to LaunchProfileModel(1.4, 11, 8, 16).
Local LAUNCH_HDG to 90.
Local TARGET_APOAPSIS to 70_000.


Local flightStatus to FlightStatusModel("FALCON HEAVY Core LAUNCH", "PRELAUNCH").
flightStatus:AddField("TARGET Pitch", LAUNCH_PROFILE:PitchTarget@).
flightStatus:AddField("DYNAMIC PRESSURE", LAUNCH_PROFILE:DynamicPressue@).
flightStatus:AddField("Alt SCALED", LAUNCH_PROFILE:AltitudeScaled@).

Lock PitchTarget to LAUNCH_PROFILE:PitchTarget@.

GET_LAUNCH_CONFIRMATION(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.75).

Wait 1. 
RCS OFF. 
SAS OFF. 
Lock Throttle to 0. 

flightStatus:Update("PRE-IGNITION").
Wait 0.

Lock Throttle to 0.5.
Stage. 
Wait 1. 
Lock Throttle to 1. 
Wait 0.25. 

Stage. 
flightStatus:Update("LIFTOFF"). 

Lock Steering to Heading(LAUNCH_HDG, PitchTarget). 

Wait 4. 
flightStatus:Update("ASCENT").

When Apoapsis > TARGET_APOAPSIS Then { 

    flightStatus:Update("Booster SEPARATION").
  Stage.  
}