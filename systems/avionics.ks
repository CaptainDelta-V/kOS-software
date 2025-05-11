@LAZYGLOBAL OFF. 
SWITCH TO 0. 
RUNPATH("0:common/flightStatus/flightStatusModel").
RUNPATH("0:common/landing/ccatManager").
RUNPATH("0:common/constants").

Local flightStatus to FlightStatusModel("AVIONICS SYSTEM", "AWAITING INITIATION").
Local ccatController to CCATManager().

flightStatus:AddField("SOLVER RUNNING", ccatController:IsRunning@).
flightStatus:AddField("TARGET CPU", ccatController:GetTargetCpuName@).

RunFlightStatusScreen(flightStatus, 0.25).

Local startCCAT to false. 
Until startCCAT { 
    If not Core:Messages:Empty { 
        Local message to Core:Messages:Pop:Content.
        If message:StartsWith(AVIONICS_CPU_ASSIGN) {         
            ccatController:SetTargetCpuName(message:Split("|")[1]).        
            flightStatus:SetTitle(AVIONICS_CPU_ASSIGN).
        }
        Else If message = AVIONICS_CPU_RUN {     
            Set startCCAT to true.
        }
        Else If message = AVIONICS_CPU_STOP { 
            Shutdown.
        }
    }

    Wait 0.
}

StopRunFlightStatusScreen().
Print "CCAT Starting . . . ".
Print "Target CPU: " + ccatController:GetTargetCpuName().
Local targetCpu to Processor(ccatController:GetTargetCpuName()).
Local dt to 4.
Local prevTraj to LatLng(0,0).
Local comparisonDecimals to 5.

// Shutdown.

Local onBeforeTrajectoryCalculated to { 
    ccatController:LogMessage("Iteration start").
}.

Local onTrajectoryCalculated to { 
    Parameter traj.

    ccatController:LogMessage("Iteration end").

    ClearScreen.
    Print "==== SOLVER ACTIVE ====".
    Print "TRAJ: " + traj.
    Print "dT: " + dt.    
    ccatController:LogMessage("Send traj start").
    targetCpu:Connection:SendMessage(traj).    
    ccatController:LogMessage("Send traj end, wait 1 second").
    Wait 1.

    // Local messageBody to Lexicon().
    // messageBody:Add("impact", traj).
    // Local trajLat to Round(traj:Lat, comparisonDecimals).
    // Local trajLng to Round(traj:Lng, comparisonDecimals).

    // Only message when changed
    // If (not Round(traj:Lat, comparisonDecimals) = Round(prevTraj:Lng, comparisonDecimals)) 
    //     or (not Round(traj:Lng, comparisonDecimals) = Round(prevTraj:Lng, comparisonDecimals)) { 
    //         Print traj.
            
    //         Set prevTraj to traj.        
    //     }   
    //     Else { 
    //         // print traj.
    //     } 
}.

ccatController:RunCCAT(true, dt, 
    onBeforeTrajectoryCalculated@, onTrajectoryCalculated@)
        :continuousIteration().

Wait Until False. 