
Function PidModel { 
    Parameter kP to 0.
    Parameter kI to 0.
    Parameter kD to 0.       
    Parameter minVal to 0.
    Parameter maxVal to 1.

    Local calcOut to 0.5.
    Local pid to PidLoop(kP, kI, kD, minVal, maxVal).

    Function Update {
        Parameter actual.
        Set calcOut to pid:Update(Time:Seconds, actual).        
    } 

    Function SetMinOutput { 
        Parameter val. 
        Set pid:MinOutput to val.
    }

    Function SetMaxOutput { 
        Parameter val. 
        Set pid:MaxOutput to val.
    }

    Function UpdateSetpoint { 
        Parameter val. 
        Set pid:Setpoint to val.
    }

    Function GetCalcOut {         
        Return calcOut.
    }        

    Return Lexicon(
        "Update", Update@,
        "SetMinOutput", SetMinOutput@, 
        "SetMaxOutput", SetMaxOutput@, 
        "UpdateSetpoint", UpdateSetpoint@,
        "GetCalcOut", GetCalcOut@
    ).
}
