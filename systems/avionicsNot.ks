
SWITCH TO 0. 
RUNPATH("0:common/flightStatus/flightStatusModel").
RUNPATH("0:common/landing/ccatManager").
RUNPATH("0:common/constants").

ClearScreen.

Local flightStatus to FlightStatusModel("AVIONICS SYSTEM", "AWAITING INITIATION").
Local ccatController to CCATManager().

flightStatus:AddField("SOLVER RUNNING", ccatController:IsRunning@).
flightStatus:AddField("TARGET CPU", ccatController:GetTargetCpuName@).

RunFlightStatusScreen(flightStatus).