Function WaitUntilOriented { 
    Parameter angleErrorThreshold is 2.25.
    Parameter angularMagThreshold is 2.
    Wait Until Abs(SteeringManager:ANGLEERROR) < angleErrorThreshold AND Ship:ANGULARVEL:Mag < angularMagThreshold.
}

Global Function ResetTorque { 
    Local torquefactor to 1.

    Set SteeringManager:YawTorqueFactor to torquefactor.
    Set SteeringManager:PitchTorqueFactor to torquefactor.
    Set SteeringManager:RollTorqueFactor to torquefactor.
}

Global Function SetTorque { 
    Parameter torqueFactor. 

    Set SteeringManager:YawTorqueFactor to torqueFactor.
    Set SteeringManager:PitchTorqueFactor to torqueFactor.
    Set SteeringManager:RollTorqueFactor to torqueFactor.
}

// Global Function MAX_STOPPING