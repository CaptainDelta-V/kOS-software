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
RUNONCEPATH("../../../common/utils/listutils").
RUNONCEPATH("../../../common/exceptions").

Local coreEngine to Ship:PartsTagged("MERLIN_9_CORE")[0]. 
Local sideBoosterEngines to Ship:PartsTagged("MERLIN_9").
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

Local coreBoosterTank to Ship:PartsTagged("TANK_BOOSTER_CORE")[0].
Local coreRcsUnits to Ship:PartsTagged("RCS_CORE").

Local upperstageCpu to Processor(FALCON_UPPERSTAGE_CPU_NAME).
Local coreEngineController to EngineManager(coreEngine, VESSEL_TYPE_FALCON_BOOSTER).

Local launchProfileInitial to LaunchProfileModel(1.15, 6, 8, 75).
Local launchProfileSecondary to LaunchProfileModel(2.2, 8, 9, 80).
Local launchProfile to launchProfileInitial.
Local launchProfileTransitionAltitude to 28_000.

Local launchHeading to 90.
Local targetApoapsis to 60_000.
Local targetRoll to -180.
Local sideBoosterSeparationAtFuelAmount to 2400.
Local upperstageSeparationAtFuelAmount to 2400. 

Local coreThrustLimit to 100.

Local flightStatus to FlightStatusModel("FALCON HEAVY LAUNCH CONTROL", "PRELAUNCH").
flightStatus:AddField("TARGET Pitch", launchProfileInitial:PitchTarget@).
flightStatus:AddField("DYNAMIC PRESSURE", launchProfileInitial:DynamicPressue@).
flightStatus:AddField("Alt SCALED", launchProfileInitial:AltitudeScaled@).

If hasSideBoosters { 
    
    Set coreThrustLimit to 75. 
    flightStatus:AddField("CORE THRUST LIMIT", coreThrustLimit). 
    coreEngineController:SetThrustLimit(coreThrustLimit).

    flightStatus:Update("NOTIFYING SIDE BOOSTERS").
    leftBoosterCpu:Connection:SendMessage(INDICATOR_BOOSTER_LEFT).
    rightBoosterCpu:Connection:SendMessage(INDICATOR_BOOSTER_RIGHT).
}
Else { 
    Set coreThrustLimit to 100.
    flightStatus:AddField("CORE THRUST LIMIT", coreThrustLimit). 
    coreEngineController:SetThrustLimit(coreThrustLimit).
    coreEngineController:SetGimbalLimit(100).
}

If hasSideBoosters { 
    Wait 0.5. 
    flightStatus:Update("ASSIGNING SIDE BOOSTER AVIONICS").
    leftBoosterAvionicsCpu:Connection:SendMessage(AVIONICS_CPU_ASSIGN + "|" + LEFT_BOOSTER_CPU_NAME).
    rightBoosterAvionicsCpu:Connection:SendMessage(AVIONICS_CPU_ASSIGN + "|" + RIGHT_BOOSTER_CPU_NAME).
}

GetLaunchConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.5).

flightStatus:Update("LAUNCH SEQUENCE INITIATED").

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

Set Core:BootFilename to "".

Wait Until Altitude > 100.
Lock Steering to Heading(launchHeading, PitchTarget, targetRoll). 

Wait Until Altitude > 6_000. 

If hasSideBoosters { 
    Set coreThrustLimit to 50.
    flightStatus:AddField("CORE THRUST LIMIT", coreThrustLimit). 
    coreEngineController:SetThrustLimit(coreThrustLimit).

    Local leftBoosterLiquidFuelResource to FindInList(sideBoosterTank:Resources, { Parameter it. return it:Name = RESOURCE_LIQUID_FUEL. }).
    flightStatus:AddField("BOOSTER LQD FUEL", { return leftBoosterLiquidFuelResource:Amount. }).
    
    Local boosterSeparation to false. 
    Until boosterSeparation { 
        If leftBoosterLiquidFuelResource:Amount < sideBoosterSeparationAtFuelAmount { 
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
    flightStatus:AddField("CORE THRUST LIMIT", coreThrustLimit). 
    coreEngineController:SetThrustLimit(coreThrustLimit).
    coreEngineController:SetGimbalLimit(100).
}

Local coreBoosterLiquidFuel to FindInList(coreBoosterTank:Resources, { parameter it. return it:Name = RESOURCE_LIQUID_FUEL. }).

Lock Steering to Heading(launchHeading, 5, targetRoll).

flightStatus:Update("AWAITING SEPARATION").
Local upperstageSeparation to false. 
Until upperstageSeparation { 
    If coreBoosterLiquidFuel:Amount < upperstageSeparationAtFuelAmount { 
        Set upperstageSeparation to true.
    }
    Wait 0.01.
}

Lock Throttle to 0.

Local upperstageDecoupler to Ship:PartsTagged(FALCON_DECOUPLER_UPPERSTAGE)[0].
upperstageDecoupler:GetModule("ModuleTundraDecoupler"):DoAction("decouple", true).
flightStatus:Update("COASTING FOR UPPER SEPARATION").

upperstageCpu:Connection:SendMessage("GO").
Wait 10.

flightStatus:Update("LANDING SEQUENCE INITIATED").
For nozzle in coreRcsUnits { 
    nozzle:GetModule("ModuleRCSFX"):DoAction("toggle rcs thrust", TRUE).
}

Local altBootParams to Lexicon().
altBootParams:Add(KEY_BOOSTERSIDE, INDICATOR_BOOSTER_CORE).
SetAlternateBootFileWithParams("boosterland", altBootParams).  
Reboot. 

Wait Until False. 


