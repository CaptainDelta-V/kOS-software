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
RUNONCEPATH("../../../common/utils/listutils").
RUNONCEPATH("../../../common/exceptions").
RUNONCEPATH("../../../common/utils/physicsRangeModel").
RUNONCEPATH("constants").

ClearScreen.

Local BoosterMaxPitchOver to 75.
Local GS2Cpu to Processor(NEWGLENN_CPU_NAME).

Local launchProfileInitial to LaunchProfileModel(3, 6, 3, BoosterMaxPitchOver).
Local launchProfileSecondary to LaunchProfileModel(3, 8, 4, BoosterMaxPitchOver).
Local launchProfile to launchProfileInitial.
Local launchProfileTransitionAltitude to 4_000.

Local launchHeading to 90.
Local targetRoll to 0.

Local vesselType to VESSEL_TYPE_NEWGLENN.
Local boosterTank to Ship:PartsTagged("BOOSTER_TANK")[0].
Local landingSite to LANDING_SITES[KEY_KSC_LNDG_ZONE_NORTH].

Local physicsRangeController to PhysicsRangeModel(). 
physicsRangeController:SetPhysicsRangesForRecoveryLaunch(false).

Local flightStatus to FlightStatusModel("NEW GLENN LAUNCH", "PRELAUNCH").
flightStatus:AddField("TARGET Pitch", launchProfileInitial:PitchTarget@).
flightStatus:AddField("DYNAMIC PRESSURE", launchProfileInitial:DynamicPressue@).
flightStatus:AddField("Alt Scaled", launchProfileInitial:AltitudeScaled@).

Local sendSuccess to GS2Cpu:Connection:SendMessage(Lexicon(
    KEY_LAUNCH_HEADING, launchHeading
)).

flightStatus:AddField("LaunchHeadingSentToShip", sendSuccess + " " + launchHeading).
GetConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus).


Wait 0.01.
Lock Throttle to 0.
flightStatus:Update("APU STARTUP").
AG10 on.
AG1 ON.

Wait 6.

AG4 on.
RCS OFF.
SAS OFF.

Wait 0.01.
Lock Throttle to 1.
Wait 0.5.
Stage.
flightStatus:Update("IGNITION").
Wait 1.
Stage.
flightStatus:Update("LIFTOFF").
Wait 2.5.

Lock pitchTarget to launchProfile:PitchTarget().
When Altitude > launchProfileTransitionAltitude Then { 
    Set launchProfile to launchProfileSecondary.
    flightStatus:Update("SECONDARY PROFILE").
}

Lock Steering to Heading(launchHeading, pitchTarget - 2, targetRoll).
Wait Until Altitude > 400.
Lock Steering to Heading(launchHeading, pitchTarget, targetRoll). 

flightStatus:Update("ASCENT").


Local stageSeparationAtFuelAmount to 8_500.

Local boosterFuelResource to FindInList(boosterTank:Resources, { Parameter it. return it:Name = RESOURCE_OXIDIZER. }).
flightStatus:AddField("BOOSTER FUEL", { return boosterFuelResource:Amount. }).

Local stageSeparation to false. 
Until stageSeparation { 

    If Addons:TR:HasImpact { 
      Set stageSeparation to boosterFuelResource:Amount < stageSeparationAtFuelAmount 
      or (Addons:TR:ImpactPos:Position - landingSite:Position):Mag > 140_000.
.
    }
    Wait 0.01.
}

Unlock steering.
Wait 0.
Lock throttle to 0.

Wait 0.5.        
GS2Cpu:Connection:SendMessage(NEWGLENN_ASCENT_HANDOFF_MESSAGE).



SetAlternateBootFile("boosterland").  
Wait 2.  
Reboot.   



Wait Until False.