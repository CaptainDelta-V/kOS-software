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
RUNONCEPATH("0:common/orbit/manueverNodeManager"). // Do not use for any function other than RemoveAllNodes
RUNONCEPATH("0:common/orbit/rendezvousModel").

ClearScreen.
ClearVecDraws(). 
// RemoveAllNodes().

Local flightStatus to FlightStatusModel("ORBITAL RENDEZVOUS", "AWAITING INITIATION").
RunFlightStatusScreen(flightStatus).

Local rdvs to RendezvousModel(flightStatus).

Local maxWaitOrbits to 60.

Local timeStart to Time:Seconds.
Local timeStop to timeStart + (Ship:Orbit:Period * maxWaitOrbits).

flightStatus:Update("Getting closest apprach").
Local closest to rdvs:ClosestApproach(timeStart, timeStop, 1).

flightStatus:AddField("Closest was", closest).

Wait Until False. 