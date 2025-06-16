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
RUNONCEPATH("../../../common/launch/ascentModel").
RUNONCEPATH("../../../common/launch/payloadModel").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("../../../common/utils/physicsRangeModel").
RUNONCEPATH("../../../common/utils/listutils").
RUNONCEPATH("../../../common/exceptions").

Local coreEngine to Ship:PartsTagged(ENGINES_MERLIN_9_CORE)[0]. 
Local sideBoosterEngines to Ship:PartsTagged(ENGINES_MERLIN_9).
Local sideBoosterTank to "None".
Local hasSideBoosters to sideBoosterEngines:Length = 2.

Local leftBoosterEngine to "None".
Local rightBoosterEngine to "None".
Local sideBoosterTank to "None".
Local leftBoosterEngineController to "None".
Local rightBoosterEngineController to "None".
Local leftBoosterCpu to "None".
Local rightBoosterCpu to "None".
Local leftBoosterAvionicsCpu to "None".
Local rightBoosterAvionicsCpu to "None".
Local coreBoosterAvionicsCpu to "None".

If hasSideBoosters { 
    Set leftBoosterEngine to sideBoosterEngines[0].
    Set rightBoosterEngine to sideBoosterEngines[1].
    Set sideBoosterTank to Ship:PartsTagged("TANK_BOOSTER_LEFT")[0].
    Set leftBoosterEngineController to EngineManager(leftBoosterEngine, VESSEL_TYPE_FALCON_BOOSTER). 
    Set rightBoosterEngineController to EngineManager(rightBoosterEngine, VESSEL_TYPE_FALCON_BOOSTER). 
    Set leftBoosterCpu to Processor(LEFT_BOOSTER_CPU_NAME).
    Set rightBoosterCpu to Processor(RIGHT_BOOSTER_CPU_NAME).
    Set leftBoosterAvionicsCpu to Processor(LEFT_BOOSTER_AVIONICS_CPU_NAME).
    Set rightBoosterAvionicsCpu to Processor(RIGHT_BOOSTER_AVIONICS_CPU_NAME).
}

Set coreBoosterAvionicsCpu to Processor(CORE_BOOSTER_AVIONICS_CPU_NAME).

Local coreBoosterTank to Ship:PartsTagged("TANK_BOOSTER_CORE")[0].
Local coreRcsUnits to Ship:PartsTagged("RCS_CORE").

Local upperstageCpu to Processor(FALCON_UPPERSTAGE_CPU_NAME).
Local coreEngineController to EngineManager(coreEngine, VESSEL_TYPE_FALCON_BOOSTER).

Local BoosterMaxPitchOver to 75.

Local launchProfileInitial to LaunchProfileModel(1.8, 9, 3, BoosterMaxPitchOver).
Local launchProfileSecondary to LaunchProfileModel(2.45, 10, 9.7, BoosterMaxPitchOver).
Local launchProfile to launchProfileInitial.
Local launchProfileTransitionAltitude to 4_000.

Local launchHeading to 42.
Local targetRoll to -180.
Local sideBoosterSeparationAtFuelAmount to 2400.
Local upperstageSeparationAtFuelAmount to 2650. 
// Local upperstageSeparationAtFuelAmount to 1700. 

If not hasSideBoosters { 
    Set upperstageSeparationAtFuelAmount to sideBoosterSeparationAtFuelAmount.
}

Local vesselType to (Choose VESSEL_TYPE_FALCON_HEAVY If hasSideBoosters Else VESSEL_TYPE_FALCON_9).
Local coreThrustLimit to 100.

Local flightStatus to FlightStatusModel("FALCON LAUNCH CONTROL", "PRELAUNCH").
flightStatus:AddField("Configuration", vesselType). // TODO: check this on fh
flightStatus:AddField("Target Pitch", launchProfileInitial:PitchTarget@).
flightStatus:AddField("dPA", launchProfileInitial:DynamicPressue@).
flightStatus:AddField("Alt Scaled", launchProfileInitial:AltitudeScaled@).
flightStatus:AddField("Core Thrust Limit", { Return coreThrustLimit. }). 
flightStatus:AddField("Side booster separation at Fuel Amount", sideBoosterSeparationAtFuelAmount).
flightStatus:AddField("Upperstage separation at Fuel Amount", upperstageSeparationAtFuelAmount).

If hasSideBoosters { 
    Set coreThrustLimit to 75. 
    coreEngineController:SetThrustLimit(coreThrustLimit).

    flightStatus:Update("NOTIFYING SIDE BOOSTERS").
    leftBoosterCpu:Connection:SendMessage(INDICATOR_BOOSTER_LEFT).
    rightBoosterCpu:Connection:SendMessage(INDICATOR_BOOSTER_RIGHT).
}
Else { 
    Set coreThrustLimit to 100.
    coreEngineController:SetThrustLimit(coreThrustLimit).
    coreEngineController:SetGimbalLimit(100).
}

If hasSideBoosters { 
    Wait 0.5. 
    flightStatus:Update("ASSIGNING SIDE BOOSTER AVIONICS").
    leftBoosterAvionicsCpu:Connection:SendMessage(AVIONICS_CPU_ASSIGN + "|" + LEFT_BOOSTER_CPU_NAME).
    rightBoosterAvionicsCpu:Connection:SendMessage(AVIONICS_CPU_ASSIGN + "|" + RIGHT_BOOSTER_CPU_NAME).
}

upperstageCpu:Connection:SendMessage(Lexicon(
    KEY_LAUNCH_HEADING, launchHeading
)).

Wait 0.5.
flightStatus:Update("ASSIGNING CORE BOOSTER AVIONICS").
coreBoosterAvionicsCpu:Connection:SendMessage(AVIONICS_CPU_ASSIGN + "|" + CORE_BOOSTER_CPU_NAME).

Local payload to PayloadModel(flightStatus, vesselType).
Local expend to false.

payload:CalculatePayloadMass().
payload:Review().
payload:WritePayloadConfigToDisk().
payload:AddFlightStatus().
upperstageCpu:Connection:SendMessage(payload:GetPayloadConfig()).

Local maxAscentPitch to 40.
Local ascent to AscentModel(payload:PayloadMass(), payload:PayloadCapacity(), 15, maxAscentPitch).
Local minAscentPitch to ascent:GetMinAscentPitch().
flightStatus:AddField("Min Ascent Pitch", minAscentPitch).

launchProfileSecondary:SetMaxPitchOver(90 - minAscentPitch).

Local physicsRangeController to PhysicsRangeModel(). 
physicsRangeController:SetPhysicsRangesForRecoveryLaunch().
physicsRangeController:GetLoadDistanceDescriptions().

GetLaunchConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.3).

flightStatus:Update("LAUNCH SEQUENCE INITIATED").

Local altBootParams to Lexicon().
altBootParams:Add(KEY_BOOSTERSIDE, INDICATOR_BOOSTER_CORE).
altBootParams:Add(KEY_EXPEND_OPTION, expend).
altBootParams:Add(KEY_VESSEL_TYPE, vesselType).
SetAlternateBootFileWithParams("boosterland", altBootParams).  
flightStatus:AddField("Landing boot file set", "true").

Lock PitchTarget to launchProfile:PitchTarget().
When Altitude > launchProfileTransitionAltitude Then { 
    Set launchProfile to launchProfileSecondary.
    flightStatus:Update("SECONDARY PROFILE").
}

Lock Steering to Heading(launchHeading, 90, 90).
Lock Throttle to 0.5.
Stage. 
Wait Until Stage:Ready. 
Lock Throttle to 1. 
Stage. 

Wait Until Alt:Radar > 200.
Lock Steering to Heading(launchHeading, PitchTarget - 1.8).

Wait Until Altitude > 6_000. 

If hasSideBoosters { 
    Set coreThrustLimit to 50.    
    coreEngineController:SetThrustLimit(coreThrustLimit).

    Local leftBoosterLiquidFuelResource to FindInList(sideBoosterTank:Resources, { Parameter it. return it:Name = RESOURCE_LIQUID_FUEL. }).
    flightStatus:AddField("Side Booster Liquid Fuel", { return leftBoosterLiquidFuelResource:Amount. }).
    
    Local boosterSeparation to false. 
    Until boosterSeparation { 
        If leftBoosterLiquidFuelResource:Amount <= sideBoosterSeparationAtFuelAmount { 
            Set boosterSeparation to true.
        }
        Wait 0.01.
    }
    // Unlock Steering. 
    coreEngineController:SetGimbalLimit(0).
    RCS ON.
    Wait 0.
    leftBoosterCpu:Connection:SendMessage(SIDE_BOOSTER_LANDING_INIT_MESSAGE).
    rightBoosterCpu:Connection:SendMessage(SIDE_BOOSTER_LANDING_INIT_MESSAGE).
    leftBoosterEngineController:SetThrustLimit(0).
    rightBoosterEngineController:SetThrustLimit(0).
    Stage.

    Set coreThrustLimit to 100.
    coreEngineController:SetThrustLimit(coreThrustLimit).
    coreEngineController:SetGimbalLimit(100).
}

RCS OFF.
Local coreBoosterLiquidFuel to FindInList(coreBoosterTank:Resources, { parameter it. return it:Name = RESOURCE_LIQUID_FUEL. }).
Lock Steering to Heading(launchHeading, PitchTarget, targetRoll).

When Ship:Altitude > 35_000 Then { 
    flightStatus:Update("Fairing Jettison").
    AG4 ON. // todo: this only works if active, if watching booster not going to
}

When Ship:Altitude > 36_000 Then { 
    flightStatus:Update("AWAITING SEPARATION").
}

flightStatus:Update("AWAITING SEPARATION").
flightStatus:AddField("Core Booster Liquid Fuel", { Return coreBoosterLiquidFuel:Amount. }).

Local upperstageSeparation to false. 
Until upperstageSeparation { 
    If coreBoosterLiquidFuel:Amount < upperstageSeparationAtFuelAmount { 
        Set upperstageSeparation to true.
    }
    Wait 0.001.
}

coreEngineController:SetThrustLimit(0).
Wait 0.

RCS ON.
upperstageCpu:Connection:SendMessage(FALCON_UPPERSTAGE_HANDOFF).

Wait 4.
Reboot. 

Wait Until False. 


