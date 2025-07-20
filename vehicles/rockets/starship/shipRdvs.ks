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

Local flightStatus to FlightStatusModel("ORBITAL RENDEZVOUS", "AWAITING INITIATION").

flightStatus:AddField("ETA Apoapsis", { return Round(Ship:Orbit:ETA:Apoapsis, 2). }).
flightStatus:AddField("ETA Periapsis", { return Round(Ship:Orbit:ETA:Periapsis, 2). }).
flightStatus:AddField("OBT True Anomaly", { Return Round(Ship:Orbit:TrueAnomaly, 2). }).
flightStatus:AddField("PER", { Return Round(Ship:Orbit:Period, 1) + "s". }).

RunFlightStatusScreen(flightStatus, 0.2).

Local rdvs to RendezvousModel(flightStatus).

flightStatus:AddField("Relative Inc.", { Return Round(rdvs:RelativeInclination(), 4). }).
flightStatus:AddField("Angle to AN", { Return Round(rdvs:AngleToAN(), 4). }).
flightStatus:AddField("Angle to DN", { Return Round(rdvs:AngleToDN(), 4). }).

// Local timeStart to Time:Seconds.
// Local hoursToSeek to 2.
// Local timeStop to timeStart + (SECONDS_PER_HOUR * hoursToSeek).
// Local timeStepSeconds to 2.
// Local closestApproach to rdvs:ClosestApproach(timeStart, timeStop, timeStepSeconds).

// flightStatus:Update("Done Stage 1 Approach Seeking").
// flightStatus:AddField("Closest Approach", Round(closestApproach:MinDist / 1000, 2) + "km").
// flightStatus:AddField("Closest Approach Time", Timestamp(closestApproach:Time):Full).
// flightStatus:RemoveTempFields().

// flightStatus:Update("AN DN").

// todo: eta to the AN/DN
// todo: determine if rel. inc. is up or down -> normal/antinormal


// flightStatus:AddField("REL. INC.", rdvs:RelativeInclination@).
// flightStatus:AddField("ANGLE TO LAN", rdvs:AngleToLAN@).

// rdvsModel:CheckClosestApproach().



// Until false { 
//     // rdvsModel:TimeToANDN().
//     // rdvsModel:GetInfo().
    
//     Wait 1.
// }



Wait Until False. 