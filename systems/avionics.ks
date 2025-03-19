@LAZYGLOBAL OFF. 
SWITCH TO 0. 
RUNPATH("0:common/flightStatus/flightStatusModel").
RUNPATH("0:common/landing/ccatManager").
RUNPATH("0:common/constants").


Local flightStatus to FlightStatusModel("AVIONICS SYSTEM", "AWAITING INITIATION").
Local ccatController to CCATManager().

flightStatus:AddField("SOLVER", ccatController:GetRunStatus@).
flightStatus:AddField("TARGET CPU", ccatController:GetTargetCpuName@).

RunFlightStatusScreen(flightStatus, 0.5).


When not Core:Messages:Empty Then { 
    Local message to Core:Messages:Pop:Content.

    If message:StartsWith(AVIONICS_CPU_ASSIGN) {         
        ccatController:SetTargetCpuName(message:Split("|")[1]).
    }
    Else If message = AVIONICS_CPU_RUN { 
        
        // ccatController:RunContinous().
       
    }
    Else If message = AVIONICS_CPU_STOP { 
        Throw("not implemnted").
    }

    Preserve.
}

Local c to Terminal:Input:GetChar().
if c = "y" { 
    // ccatController:RunContinous().
    // Local calcCat to ccatController:GetCCAT().
    // calcCat:continuousIteration().
    // print ccatController:GetCCAT():GetFinalPosition().

    print ccatController:RunContinous():getFinalPosition().
}

// Function RunContinousUpdating { 
//     Parameter interval.

//     ccatController:RunContinous().
//     Until not ccatController:IsRunning() { 


//         Wait interval.
//     }
// }

Wait Until False. 