@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("0:common/constants").
RUNONCEPATH("0:common/landing/sites").
RUNONCEPATH("0:common/landing/landingStatusModel").
RUNONCEPATH("0:common/flightStatus/flightStatusModel").
RUNONCEPATH("0:common/infos").
RUNONCEPATH("0:common/control").
RUNONCEPATH("0:common/nav").
RUNONCEPATH("0:common/booting/bootUtils").
RUNONCEPATH("0:common/engineManager").
RUNONCEPATH("0:common/launch/launchProfileModel").
RUNONCEPATH("0:common/launch/utils").

RUNONCEPATH("0:common/utils/listutils").
RUNONCEPATH("0:common/exceptions").
RUNONCEPATH("0:common/utils/timeUtils").

ClearScreen. 

Local BoosterMaxPitchOver to 75.

Local launchProfileInitial to LaunchProfileModel(1.8, 9, 3, BoosterMaxPitchOver).
Local launchProfileSecondary to LaunchProfileModel(4.45, 10, 9.7, BoosterMaxPitchOver).
Local launchProfile to launchProfileInitial.
Local launchProfileTransitionAltitude to 4_000.

Local hydrogenTank to Ship:PartsDubbed("Olympus-ET-STS-90K 5m External Cryogenic Tank")[0].
Local hydrogenResource to FindInList(hydrogenTank:Resources, { parameter it. return it:Name = RESOURCE_LH2. }).

Local launcherBase to Ship:PartsTagged("STA_LBASE")[0].
Local generator to launcherBase:GetModuleByIndex(1).
Local fuelPump to launcherBase:GetModuleByIndex(2).
Local cargoBarDoors to Ship:PartsTagged("STS_MFUS")[0]:GetModuleByIndex(0).
Local intertankLine to Ship:PartsTagged("STA_INTR_ACC")[0]:GetModuleByIndex(1).
Local crewAccessArm to Ship:PartsTagged("STA_CREW_ACC")[0]:GetModuleByIndex(1).
Local loxArm to Ship:PartsTagged("STA_LOX_VENT")[0]:GetModuleByIndex(1).
Local hydroArm to Ship:PartsTagged("STA_HY_VENT")[0]:GetModuleByIndex(0).
Local flameSparkers to Ship:PartsTagged("FLAME_SPARKER").

Local flightStatus to FlightStatusModel("SHUTTLE LAUNCH CONTROL", "PRELAUNCH").
RunFlightStatusScreen(flightStatus).

SuspendRunningFlightStatusScreen().
If not GetConfirmation("Close Cargo Bay Doors") { 
    Scrub().
}
ResumeRunningFlightStatusScreen().

flightStatus:AddField("Close Cargo Doors", "Started.").
Local closeDoorsActionName to "close".
If cargoBarDoors:HasEvent(closeDoorsActionName) { 
    cargoBarDoors:DoEvent(closeDoorsActionName).
} Else { 
    flightStatus:AddField("Close Cargo Doors", "Already Closed.").
}

SuspendRunningFlightStatusScreen().
If not GetConfirmation("Start Generator?") { 
    Scrub().
}

ResumeRunningFlightStatusScreen().

generator:DoAction("activate generator", true).
flightStatus:AddField("Generator", "Active").

SuspendRunningFlightStatusScreen().
If not GetConfirmation("Begin Fueling?") { 
    Scrub().
}

ResumeRunningFlightStatusScreen().

flightStatus:AddField("Fueling Started", "Confirmed.").
flightStatus:Update("PROPELLANT LOAD").

fuelPump:DoAction("start fueling", true).

Wait Until (hydrogenResource:Amount / hydrogenResource:Capacity) > 0.99.
flightStatus:Update("PROPELLANT LOAD COMPLETE").

flightStatus:AddField("Propellant", "Loaded").

SuspendRunningFlightStatusScreen().
Local leadTime to 90.
If (not GetConfirmation("Begin T - " + leadTime + "?")) { 
    Scrub().
}
ResumeRunningFlightStatusScreen().

flightStatus:Update("LAUNCH SEQUENCE INITIATED").
Local liftOffTime to Time:Seconds + leadTime.
Lock missionTimeDelta to liftOffTime - Time:Seconds. 
flightStatus:AddField("T", { 
    
    Local timeDisplay to "+".
    If (missionTimeDelta > 0) { 
        Set timeDisplay to "-".
    }

    return timeDisplay + " " + SecondsToTimeDisplay(missionTimeDelta).
}).

Local retractArmEvent to "retract arm".


When Abs(missionTimeDelta) < 85 Then { 
    Local itemName to "Crew Arm Retract".
    flightStatus:AddField(itemName, "Started").

    If (crewAccessArm:HasEvent(retractArmEvent)) { 
        crewAccessArm:DoEvent(retractArmEvent).
    } Else { 
        flightStatus:AddField(itemName, "ERROR!").
    }
}

When Abs(missionTimeDelta) < 42 Then { 
    Local itemName to "Retracting LOX Arm".
    flightStatus:AddField(itemName, "Started").

    If (loxArm:HasEvent(retractArmEvent)) { 
        loxArm:DoEvent(retractArmEvent).
    } Else { 
        flightStatus:AddField(itemName, "ERROR!").
    }
}

When Abs(missionTimeDelta) < 28 Then { 
    Local itemName to "Retracting Intertank".
    flightStatus:AddField(itemName, "Started").

    If (intertankLine:HasEvent(retractArmEvent)) { 
        intertankLine:DoEvent(retractArmEvent).
    } Else {
        flightStatus:AddField(itemName, "ERROR!").
    }
}

When Abs(missionTimeDelta) < 20 Then { 
    Local itemName to "Retracting Hydrogen Arm".
    Local lowerArmEvent to "lower arm".
    flightStatus:AddField(itemName, "Started").

    If (hydroArm:HasEvent(lowerArmEvent)) { 
        hydroArm:DoEvent(lowerArmEvent).
    } Else {
        flightStatus:AddField(itemName, "ERROR!").
    }
}

When Abs(missionTimeDelta) < 10 Then { 
    Local itemName to "Hydro Sparklers".
    Local actionName to "activate engine".
    flightStatus:AddField(itemName, "Started").

    For sparker in flameSparkers { 
        Local module to sparker:GetModuleByIndex(2).
        If module:HasEvent(actionName) { 
            module:DoEvent(actionName).
        } Else { 
            flightStatus:AddField(itemName, "ERROR!").
        }
    }
}

Local launchThrottle to 0.6.

When Abs(missionTimeDelta) < 3 Then { 
    flightStatus:AddField("MAIN ENGINE", "START").
    Lock throttle to launchThrottle.

    Stage.
}

When Abs(missionTimeDelta) < 0.4 Then { 
    flightStatus:AddField("SRB IGNITION", "ENGAGE").

    Stage.
    flightStatus:Update("LIFTOFF").
}


SAS ON.
Set Ship:Control:PilotMainThrottle to launchThrottle.
Local launchHeading to 45.4.
Local targetRoll to 0.

Lock pitchTarget to launchProfile:PitchTarget().
When Altitude > launchProfileTransitionAltitude Then { 
    Set launchProfile to launchProfileSecondary.
    flightStatus:Update("SECONDARY PROFILE").
}

// Lock Steering to LookDirUp(RadialOutVectorNormalized(), LANDING_SITES[KEY_KSC_LNDG_ZONE_SOUTH]).

Wait Until Alt:Radar > 400.
    flightStatus:Update("ROLL PROGRAM").
    Set targetRoll to 180.
    SAS OFF. Wait 0.
    Lock Steering to Heading(launchHeading, pitchTarget - 2, targetRoll).

Wait Until Altitude > 14_000.
    Set Ship:Control:PilotMainThrottle to 1.

Wait Until Altitude > 20_000. 

    SuspendRunningFlightStatusScreen().
    PlayPriorityMessage("PILOT MANUAL CONTROL REQUIRED", MESSAGE_PRIORITY_EMERGENCY).
    ResumeRunningFlightStatusScreen().

    Unlock Steering. 
    Unlock Throttle.


Wait Until false. 


