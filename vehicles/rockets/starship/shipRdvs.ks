@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("0:common/constants").
RUNONCEPATH("0:common/landing/sites").
RUNONCEPATH("0:common/infos").
RUNONCEPATH("0:common/engineManager").
RUNONCEPATH("0:common/flightStatus/flightStatusModel").
RUNONCEPATH("0:common/control").
RUNONCEPATH("0:common/launch/utils").
RUNONCEPATH("0:common/nav").
RUNONCEPATH("0:common/booting/bootUtils").
RUNONCEPATH("0:common/orbit/hohmannTransferController").
RUNONCEPATH("0:common/orbit/rendezvousModel").


ClearScreen.
ClearVecDraws(). 

Local flightStatus to FlightStatusModel("STARSHIP ORBITAL RENDEZVOUS", "AWAITING INITIATION").

flightStatus:AddField("ETA APOAPSIS", { return Ship:Orbit:ETA:Apoapsis. }).
flightStatus:AddField("ETA PERIAPSIS", { return Ship:Orbit:ETA:Periapsis. }).

// GetLaunchConfirmation(flightStatus:GetTitle()).
RunFlightStatusScreen(flightStatus, 0.2).

Local rdvsModel to RendezvousModel(flightStatus).

rdvsModel:GetInfo().
// rdvsModel:CheckClosestApproach().



// Until false { 
//     // rdvsModel:TimeToANDN().
//     // rdvsModel:GetInfo().
    
//     Wait 1.
// }



Wait Until False. 