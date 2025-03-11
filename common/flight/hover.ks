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
    Parameter getVsTarget.
    Parameter Duration.  
    Parameter kP to 0.
    Parameter kI to 0.
    Parameter kD to 0.       
    Parameter minVal to 0.
    Parameter getMaxVal to { Return 1. }.
    Parameter getActual to { Return Ship:VerticalSpeed. }.
    Parameter terminator to { Return false. }.    
    
    Declare Local calcThrottle to .5.
    Lock Throttle to calcThrottle.                                  

    Declare Local pid to PidLoop(kP, kI, kD, minVal, getMaxVal()).    
    Set pid:SetPoint to getVsTarget(). 
     
    Local timeEnd to Time:Seconds + Duration.    
    
    Set calcThrottle to pid:Update(Time:Seconds, getActual:Call()).         
    Until Time:Seconds > timeEnd or terminator:Call() {                         

        Set pid:SetPoint to getVsTarget(). 
        Set pid:MaxOutput to getMaxVal().        
        Set calcThrottle to pid:Update(Time:Seconds, getActual:Call()).         

        Wait 0.01.
    }
}

