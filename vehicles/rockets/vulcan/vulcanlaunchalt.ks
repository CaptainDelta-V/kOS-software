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

Local BoosterMaxPitchOver to 65.
Local CENTAURCpu to Processor(VULCAN_CPU_NAME).

Local launchProfileInitial to LaunchProfileModel(3, 6, 3, BoosterMaxPitchOver).
Local launchProfileSecondary to LaunchProfileModel(3, 12, 4, BoosterMaxPitchOver).
Local launchProfile to launchProfileInitial.
Local launchProfileTransitionAltitude to 3_500.

Local launchHeading to 90.
Local targetRoll to 0.

Local vesselType to VESSEL_TYPE_ELECTRON.
Local boosterTank to Ship:PartsTagged("BOOSTER_TANK")[0].
Local landingSite to LANDING_SITES[KEY_DS_OCEAN_LONG].

Local physicsRangeController to PhysicsRangeModel(). 
physicsRangeController:SetPhysicsRangesForRecoveryLaunch(false).

Local flightStatus to FlightStatusModel("VULCAN LAUNCH", "PRELAUNCH").
flightStatus:AddField("TARGET Pitch", launchProfileInitial:PitchTarget@).
flightStatus:AddField("DYNAMIC PRESSURE", launchProfileInitial:DynamicPressue@).
flightStatus:AddField("Alt Scaled", launchProfileInitial:AltitudeScaled@).

Local sendSuccess to CENTAURCpu:Connection:SendMessage(Lexicon(
    KEY_LAUNCH_HEADING, launchHeading
)).

flightStatus:AddField("LaunchHeadingSentToShip", sendSuccess + " " + launchHeading).
GetConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus).


Wait 0.01.
Lock Throttle to 0.
flightStatus:Update("GO VULCAN GO CENTUAR").
AG10 on.
Wait 4.

RCS OFF.
SAS OFF.

Wait 0.01.
Lock Throttle to 1.
Wait 0.5.
Stage.
flightStatus:Update("IGNITION").
Wait 1.5.
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


Local stageSeparationAtFuelAmount to 0.

Local boosterFuelResource to FindInList(boosterTank:Resources, { Parameter it. return it:Name = RESOURCE_OXIDIZER. }).
flightStatus:AddField("BOOSTER FUEL", { return boosterFuelResource:Amount. }).

Local stageSeparation to false. 
Until stageSeparation { 

    If Addons:TR:HasImpact { 
      Set stageSeparation to boosterFuelResource:Amount = stageSeparationAtFuelAmount. 
    }
    Wait 0.01.
}

Unlock steering.
Wait 0.
AG8 on.
Wait 2.
Lock throttle to 0.

Wait 0.5.        
CENTAURCpu:Connection:SendMessage(VULCAN_ASCENT_HANDOFF_MESSAGE).


SetAlternateBootFile("boosterland").  
Wait 2.  
Reboot.   



Wait Until False.