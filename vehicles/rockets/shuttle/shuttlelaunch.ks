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

ClearScreen. 


Local BoosterMaxPitchOver to 75.

Local launchProfileInitial to LaunchProfileModel(1.8, 9, 3, BoosterMaxPitchOver).
Local launchProfileSecondary to LaunchProfileModel(2.45, 10, 9.7, BoosterMaxPitchOver).
Local launchProfile to launchProfileInitial.
Local launchProfileTransitionAltitude to 4_000.

Local hydrogenTank to Ship:PartsDubbed("Olympus-ET-STS-90K 5m External Cryogenic Tank")[0].
Local hydrogenResource to FindInList(hydrogenTank:Resources, { parameter it. return it:Name = RESOURCE_LH2. }).

Local launcherBase to Ship:PartsDubbed("Shuttle Launcher Platform Base")[0].
Local generator to launcherBase:GetModuleByIndex(1).
Local fueler to launcherBase:GetModuleByIndex(2).
Local intertankLine to Ship:PartsDubbed("Shuttle Tower Arm: Intertank Access")[0]:GetModuleByIndex(1).

Local flightStatus to FlightStatusModel("SHUTTLE LAUNCH CONTROL", "PRELAUNCH").
RunFlightStatusScreen(flightStatus).

StopRunFlightStatusScreen().
If not GetConfirmation("Start Generator?") { 
    Scrub().
}

RunFlightStatusScreen(flightStatus).

generator:DoAction("activate generator", true).
flightStatus:AddField("Generator", "Active").

StopRunFlightStatusScreen().
If not GetConfirmation("Begin Fueling?") { 
    Scrub().
}

RunFlightStatusScreen(flightStatus).

flightStatus:AddField("Fueling Started", "Confirmed.").
flightStatus:Update("PROPELLANT LOAD").

fueler:DoAction("start fueling", true).

Wait Until (hydrogenResource:Amount / hydrogenResource:Capacity) > 0.99.
flightStatus:Update("PROPELLANT LOAD COMPLETE").

flightStatus:AddField("Propellant", "Loaded").

StopRunFlightStatusScreen().
If (not GetConfirmation("Begin T - 30?")) { 
    Scrub().
}
RunFlightStatusScreen(flightStatus). 

Local liftOffTime to Time:Seconds + 30.
flightStatus:AddField("T", { 
    Local delta to liftOffTime - Time:Seconds. 
    Local timeDisplay to "+".
    If (delta > 0) { 
        Set timeDisplay to "-".
    }

    return timeDisplay + " " + Abs(Round(delta)).
}).


Wait Until false. 


