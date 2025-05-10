@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/orbit/hohmannTransferController").
RUNONCEPATH("../../../common/orbit/rendezvousModel").


ClearScreen.
ClearVecDraws(). 

Local flightStatus to FlightStatusModel("STARSHIP ORBITAL RENDEZVOUS", "AWAITING INITIATION").

flightStatus:AddField("ETA APOAPSIS", { return Ship:Orbit:ETA:Apoapsis. }).
flightStatus:AddField("ETA PERIAPSIS", { return Ship:Orbit:ETA:Periapsis. }).

// GetLaunchConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.2).

Local rdvsModel to RendezvousModel(flightStatus).

rdvsModel:CheckClosestApproach().
// Until false { 
//     // rdvsModel:TimeToANDN().
//     // rdvsModel:GetInfo().
    
//     Wait 1.
// }



Wait Until False. 