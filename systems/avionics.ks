@LAZYGLOBAL OFF. 
SWITCH TO 0. 
RUNPATH("0:common/flightStatus/flightStatusModel").
RUNPATH("0:common/landing/ccatManager").
RUNPATH("0:common/constants").

ClearScreen.

Local flightStatus to FlightStatusModel("AVIONICS SYSTEM", "AWAITING INITIATION").
Local ccatController to CCATManager().

flightStatus:AddField("SOLVER RUNNING", ccatController:IsRunning@).
flightStatus:AddField("TARGET CPU", ccatController:GetTargetCpuName@).

RunFlightStatusScreen(flightStatus, 0.25).


// ccatController:SetTargetCpuName(CORE_BOOSTER_CPU_NAME).

ccatController:LogMessage("init").

Local startCCAT to false. 
Until startCCAT { 
    If not Core:Messages:Empty { 
        Local message to Core:Messages:Pop:Content.
        If message:StartsWith(AVIONICS_CPU_ASSIGN) {         
            Local targetCpuName to message:Split("|")[1].
            ccatController:SetTargetCpuName(targetCpuName).  
            flightStatus:SetTitle("AVIONICS | " + targetCpuName).

            If targetCpuName:Contains("CORE") { 
                Shutdown.
            }
        }
        Else If message = AVIONICS_CPU_RUN {     
            Set startCCAT to true.
        }
        Else If message = AVIONICS_CPU_STOP { 
            Shutdown.
        }
    }

    // If Alt:Radar > 200 { 
    //     Set startCCAT to true.
    // }

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

Function onBeforeTrajectoryCalculated { 
    ccatController:LogMessage("Iteration start").
}.

Function onTrajectoryCalculated  { 
    Parameter traj.

    // ccatController:LogMessage("Iteration end").

    ClearScreen.
    Print "==== SOLVER ACTIVE ====".
    Print "TRAJ: " + traj.
    Print "dT: " + dt.    
    
    targetCpu:Connection:SendMessage(traj).    
    Wait 0.001.

    Local messageBody to Lexicon().
    messageBody:Add("impact", traj).
    Local trajLat to Round(traj:Lat, comparisonDecimals).
    Local trajLng to Round(traj:Lng, comparisonDecimals).

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
    

//     Wait 5.
// }

Wait Until False. 