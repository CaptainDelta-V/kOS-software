@LAZYGLOBAL OFF. 
SWITCH TO 0. 
RUNPATH("0:common/flightStatus/flightStatusModel").
RUNPATH("0:common/landing/ccatManager").
RUNPATH("0:common/constants").

ClearScreen.

Local flightStatus to FlightStatusModel("AVIONICS SYSTEM", "AWAITING INITIATION").
Local ccatController to CCATManager().

// flightStatus:AddField("SOLVER RUNNING", ccatController:IsRunning@).
// flightStatus:AddField("TARGET CPU", ccatController:GetTargetCpuName@).

// RunFlightStatusScreen(flightStatus).

// Local startCCAT to false. 
// Until startCCAT { 
//     If not Core:Messages:Empty { 
//         Local message to Core:Messages:Pop:Content.
//         If message:StartsWith(AVIONICS_CPU_ASSIGN) {         
//             Local targetCpuName to message:Split("|")[1].
//             ccatController:SetTargetCpuName(targetCpuName).  
//             flightStatus:SetTitle("AVIONICS | " + targetCpuName).

//             // If targetCpuName:Contains("CORE") { 
//             //     Shutdown.
//             // }
//         }
//         Else If message = AVIONICS_CPU_RUN {     
//             Set startCCAT to true.
//         }
//         Else If message = AVIONICS_CPU_STOP { 
//             Shutdown.
//         }
//     }

//     // For debugging during flight:
//     If Alt:Radar > 200 { 
//         Set startCCAT to true.
//     }

//     Wait 0.
// }

// flightStatus:Update("CCAT Starting . . . ").
// flightStatus:AddField("Target CPU", ccatController:GetTargetCpuName@).

// Local targetCpu to Processor(ccatController:GetTargetCpuName()).
Local dT to 0.01.
Local cTraj to LatLng(0,0).

Function onBeforeTrajectoryCalculated { 
    flightStatus:LogMessage("Iteration start ").
}.

Function onTrajectoryCalculated  { 
    Parameter traj.

    Set cTraj to traj.

    flightStatus:LogMessage("Iteration end").

    ClearScreen.
    flightStatus:Update("SOLVER ACTIVE ").    

}.

Clearscreen.
Print "Manual iteratio mode".

Until False { 

    Clearscreen.
    Print "Enter a thing: ".    
    Local inputStr to "".
    Wait Until Terminal:Input:GetChar() = Terminal:Input:Enter.

    If Terminal:Input:HasChar() {         
        Until not Terminal:Input:HasChar() { 
            Set inputStr to inputStr + Terminal:Input:GetChar().
        }
    }

    print "Whoel string: " + inputStr.

    // Local currString to "".
    // Local lastChar to NONE.    
    // Until lastChar = Terminal:Input:Enter { 
    //     Set lastChar to Terminal:Input:GetChar().
    //     print "typed: " + lastChar.
    // }

    

    Terminal:Input:GetChar(). 


    // Print "dT: ".
    // Local strBuff to "".
    // Until Terminal:Input:Enter {         
    //     Set strBuff to strBuff + Terminal:Input:GetChar().
    // }
    // Set dT to strBuff:ToNumber().

    // Local start to Time:Seconds.
    // ccatController:RunCCAT(true, dT, 
    //         onBeforeTrajectoryCalculated@, onTrajectoryCalculated@):singleIteration().
    // Local end to Time:Seconds. 

    // Local duration to end - start.
    // Print "Calculated with dT: " + dT.
    // Print "Duration: " + duration.
    // Print "Impact: " + cTraj.
    // Local trPos to Addons:TR:ImpactPos. 
    // Print "TR: " + trPos.
    // Print "TR Delta: " + (cTraj:AltitudePosition(100) - trPos:AltitudePosition(100)):Mag + "m".    
    
    // Print "any key to clear.".
    // Terminal:Input:GetChar().    
}


    
Wait Until False. 