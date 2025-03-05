@LAZYGLOBAL OFF.
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
RUNONCEPATH("../../../common/exceptions").
RUNONCEPATH("constants").

ClearScreen. 

Local engine to Ship:PartsTagged("BOOSTER_RAPTORS")[0].
Local engineModule to engine:GetModule(TUNDRA_ENGINE_MODULE_NAME).
Local engineManagement to EngineManager(engineModule, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).

Local startowerCore to Processor(TOWER_CPU_NAME).
Local starshipCore to Processor(STARSHIP_CPU_NAME).

Local BoosterMaxPitchOver to 55.

Local launchProfileInitial to LaunchProfileModel(0.95, 11, 8, BoosterMaxPitchOver).
Local launchProfileSecondary to LaunchProfileModel(2.0, 10, 9.7, BoosterMaxPitchOver).
Local launchProfile to launchProfileInitial.
Local launchProfileTransitionAltitude to 8_000.

Local launchHeading to 90.
Local targetApoapsis to 70_000.
Local targetRoll to -90.

Local flightStatus to FlightStatusModel("SUPER HEAVY Booster LAUNCH Control", "PRELAUNCH").
flightStatus:AddField("TARGET Pitch", launchProfileInitial:PitchTarget@).
flightStatus:AddField("DYNAMIC PRESSURE", launchProfileInitial:DynamicPressue@).
flightStatus:AddField("Alt SCALED", launchProfileInitial:AltitudeScaled@).

Lock PitchTarget to launchProfile:PitchTarget().
When Altitude > launchProfileTransitionAltitude Then { 
    Set launchProfile to launchProfileSecondary.
    flightStatus:Update("SECONDARY PROFILE").
}

GetLaunchConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.75).

Wait 1.
RCS OFF.
SAS OFF.
Lock Throttle to 0.

If (startowerCore:Connection:SendMessage(TOWER_DELUGE_START_MESSAGE)) { 
    flightStatus:Update("WATER DELUGE ACTIVATION").    
}
Else { 
    flightStatus:Update("WATER DELUGE ACTIVATION FAILURE").
    Throw("DELUGE FAIL").
    Wait 100.
}
Wait 1.

If (startowerCore:Connection:SendMessage(TOWER_QD_RELEASE_MESSAGE)) { 
    flightStatus:Update("QD RELEASE").
}
Else { 
    flightStatus:Update("QD RELEASE FAILURE").
    Throw("DELUGE FAIL").
}
Wait 1.5.

flightStatus:Update("PRE-IGNITION").
engineManagement:SetEngineState(true).
Wait 1.
Lock Throttle to 1.
Wait 0.125.

If (startowerCore:Connection:SendMessage(TOWER_RELEASE_MESSAGE)) { 
    flightStatus:Update("REQUESTING TOWER RELEASE").
}
Else { 
    flightStatus:Update("TOWER RELEASE FAILURE").
    Wait 100.
}

Wait 1.
flightStatus:Update("LIFTOFF").
Wait 2.5.

Lock Steering to Heading(launchHeading, PitchTarget - 2, targetRoll).
Wait Until Altitude > 400.
Lock Steering to Heading(launchHeading, PitchTarget, targetRoll). 

flightStatus:Update("ASCENT").

When Apoapsis > targetApoapsis Then { 
    Set flightStatus to "Ship SEPARATION".

    Unlock Throttle.
    Unlock Steering.   
    Wait 0.
    Set Ship:Control:PilotMainThrottle to 0.4.

    engineManagement:SetEngineMode(ENG_MODE_MID_INR).

    Wait 1.                
    starshipCore:Connection:SendMessage(STARSHIP_ASCENT_HANDOFF_MESSAGE).    
    Wait 0.
        
    SetAlternatBootFile("boosterland").    
    Wait 2.      
    Reboot.       
}

Wait Until false.
