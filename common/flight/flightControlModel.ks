
Function FLIGHT_CONTROL_MODEL { 
    
    // Function GET_ { 

    // }
}

Global Function FalloffThrottle {
    parameter currentError, startFalloff, minThrottle.
    
    // Full throttle if error is at or above startFalloff
    if currentError >= startFalloff {
        return 1.
    }
    
    // Zero throttle if error is at or below minThrottle
    // if currentError <= minThrottle {
    //     return 0.
    // }
    
    // Linearly scale throttle from 1 to 0 as error drops from startFalloff to minThrottle
    local scaledThrottle is (currentError) / (startFalloff).
    return Max(scaledThrottle, minThrottle).
}