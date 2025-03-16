@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
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
RUNONCEPATH("../../../common/utils/listutils").
RUNONCEPATH("../../../common/exceptions").

Local flightStatus to FlightStatusModel("").

Local coreEngine to Ship:PartsTagged("MERLIN_9_CORE")[0]. 
Local merlinEngines to Ship:PartsTagged("MERLIN_9").
Local leftBoosterEngine to merlinEngines[0].
Local rightBoosterEngine to merlinEngines[1].
Local leftBoosterTank to Ship:PartsTagged("TANK_BOOSTER_LEFT")[0].
Local coreBoosterTank to Ship:PartsTagged("TANK_BOOSTER_CORE")[0].
Local coreRcsUnits to Ship:PartsTagged("RCS_CORE").

Local coreEngineController to EngineManager(coreEngine, VESSEL_TYPE_FALCON_BOOSTER).
Local leftBoosterEngineController to EngineManager(leftBoosterEngine, VESSEL_TYPE_FALCON_BOOSTER). 
Local rightBoosterEngineController to EngineManager(rightBoosterEngine, VESSEL_TYPE_FALCON_BOOSTER). 

Local leftBoosterCpu to Processor(LEFT_BOOSTER_CPU_NAME).
Local rightBoosterCpu to Processor(RIGHT_BOOSTER_CPU_NAME).

Local BoosterMaxPitchOver to 75.

Local launchProfileInitial to LaunchProfileModel(0.95, 11, 8, BoosterMaxPitchOver).
Local launchProfileSecondary to LaunchProfileModel(2.0, 10, 9.7, BoosterMaxPitchOver).
Local launchProfile to launchProfileInitial.
Local launchProfileTransitionAltitude to 8_000.

Local launchHeading to 90.
Local targetApoapsis to 60_000.
Local targetRoll to -180.

Local flightStatus to FlightStatusModel("FALCON HEAVY LAUNCH CONTROL", "PRELAUNCH").
flightStatus:AddField("TARGET Pitch", launchProfileInitial:PitchTarget@).
flightStatus:AddField("DYNAMIC PRESSURE", launchProfileInitial:DynamicPressue@).
flightStatus:AddField("Alt SCALED", launchProfileInitial:AltitudeScaled@).

Local leftBoosterLiquidFuelResource to FindInList(leftBoosterTank:Resources, { Parameter it. return it:Name = RESOURCE_LIQUID_FUEL. }).
flightStatus:AddField("BOOSTER LQD FUEL", { return leftBoosterLiquidFuelResource:Amount. }).

Local coreThrustLimit to 75. 
flightStatus:AddField("CORE THRUST LIMIT", coreThrustLimit). 

coreEngineController:SetThrustLimit(coreThrustLimit).

GetLaunchConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.75).

Lock PitchTarget to launchProfile:PitchTarget().
When Altitude > launchProfileTransitionAltitude Then { 
    Set launchProfile to launchProfileSecondary.
    flightStatus:Update("SECONDARY PROFILE").
}

For nozzle in coreRcsUnits { 
    nozzle:GetModule("ModuleRCSFX"):DoAction("toggle rcs thrust", TRUE).
}

// Lock Steering to Heading(launchHeading, PitchTarget - 2, 0).
Lock Steering to Up.

Lock Throttle to 1. 
Stage. 
Wait Until Stage:Ready. 
Stage. 

Wait Until Altitude > 100.
Lock Steering to Heading(launchHeading, PitchTarget, targetRoll). 

Local boosterSeparation to false. 
Until boosterSeparation { 
    If leftBoosterLiquidFuelResource:Amount < 2_600 { 
        Set boosterSeparation to true.
    }
    Wait 0.
}

Unlock Steering. 
coreEngineController:SetGimbalLimit(0).
RCS ON.
Wait 0.
leftBoosterCpu:Connection:SendMessage(SIDE_BOOSTER_LANDING_INIT_MESSAGE).
rightBoosterCpu:Connection:SendMessage(SIDE_BOOSTER_LANDING_INIT_MESSAGE).
leftBoosterEngineController:SetThrustLimit(0).
rightBoosterEngineController:SetThrustLimit(0).
Stage.

coreEngineController:SetThrustLimit(100).
coreEngineController:SetGimbalLimit(100).
Local coreBoosterLiquidFuel to FindInList(coreBoosterTank:Resources, { parameter it. return it:Name = RESOURCE_LIQUID_FUEL. }).

Local upperstageSeparation to false. 
Until upperstageSeparation { 
    If coreBoosterLiquidFuel:Amount < 10 { 
        Set upperstageSeparation to true.
    }
}

Lock Throttle to 0.
Stage.

Wait Until False. 


