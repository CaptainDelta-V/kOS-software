Function WaitUntilOriented { 
    Parameter ANGLE_ERR_THRESHOLD is 2.25.
    Parameter ANGULAR_MAG_THRESHOLD is 2.
    Wait Until Abs(SteeringManager:ANGLEERROR) < ANGLE_ERR_THRESHOLD AND Ship:ANGULARVEL:Mag < ANGULAR_MAG_THRESHOLD.
}

Global Function ResetTorque { 
    Local TORQUE_FACTOR to 1.

    Set SteeringManager:YawTorqueFactor to TORQUE_FACTOR.
    Set SteeringManager:PitchTorqueFactor to TORQUE_FACTOR.
    Set SteeringManager:RollTorqueFactor to TORQUE_FACTOR.
}

Global Function SET_TORQUE { 
    Parameter TORQUE_FACTOR. 

    Set SteeringManager:YawTorqueFactor to TORQUE_FACTOR.
    Set SteeringManager:PitchTorqueFactor to TORQUE_FACTOR.
    Set SteeringManager:RollTorqueFactor to TORQUE_FACTOR.
}

// Global Function MAX_STOPPING