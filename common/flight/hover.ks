@LAZYGLOBAL OFF. 

Global Function RunAltitudeHold { 
    Parameter TargetAltitude.
    Parameter Duration.  
    Parameter kP to 0.
    Parameter kI to 0.
    Parameter kD to 0.
    Parameter minVal to 0.     
    Parameter maxVal to 1.
    Parameter Terminator to { false. }.

    Declare Local calcThrottle to .5.
    Lock Throttle to calcThrottle.                                  

    Declare Local pid to PidLoop(kP, kI, kD, minVal, maxVal).
    Set pid:SetPoint to TargetAltitude. 
     
    Local timeEnd to Time:Seconds + Duration.
    
    Set calcThrottle to pid:Update(Time:Seconds, Ship:Altitude).         
    Until Time:Seconds > timeEnd OR Terminator:Call() { 

        Set calcThrottle to pid:Update(Time:Seconds, Ship:Altitude).         
        Wait 0.01.
    }
}

Global Function RunVerticalSpeedHold { 
    Parameter GetVsTarget.
    Parameter Duration.  
    Parameter kP to 0.
    Parameter kI to 0.
    Parameter kD to 0.       
    Parameter MinVal to 0.
    Parameter MaxVal to 1.
    Parameter GetActual to { Return Ship:VerticalSpeed. }.
    Parameter Terminator to { Return false. }.    
    
    Declare Local calcThrottle to .5.
    Lock Throttle to calcThrottle.                                  

    Declare Local pid to PidLoop(kP, kI, kD, MinVal, MaxVal).    
    Set pid:SetPoint to GetVsTarget(). 
     
    Local TimeEnd to Time:Seconds + Duration.    
    
    Set calcThrottle to pid:Update(Time:Seconds, GetActual:Call()).         
    Until Time:Seconds > TimeEnd OR Terminator:Call() {                         

        Set pid:SetPoint to GetVsTarget(). 
        
        Set calcThrottle to pid:Update(Time:Seconds, GetActual:Call()).         
        Wait 0.01.
    }
}

