RUNONCEPATH("1:common/infos").
RUNONCEPATH("1:common/control").
RUNONCEPATH("1:common/nav").

Global Function RunUpperAscent { 
    Parameter targetApoapsis. 
    Parameter targetHeading.    
    Parameter targetRoll.
    Parameter kP to 0. 
    Parameter kI to 0. 
    Parameter kD to 0.
    Parameter minValue to 0. 
    Parameter maxValue to 1.
    Parameter maxPitchDeltaOffPrograde to 10.
    Parameter terminator to { Return false. }. 

    Declare Local calcPitch to PitchOfVector(Ship:Velocity:Orbit).
    Declare Local pid to PidLoop(kP, kI, kD, minValue, maxValue).

    pid:SetPoint(targetApoapsis).
    Lock Steering to Heading(targetHeading, calcPitch, targetRoll).    

    Until Ship:Oribit:Periapsis > targetApoapsis or terminator:Call() { 

        Local deltaCalc to maxPitchDeltaOffPrograde * pid:Update(Time:Seconds, Ship:Orbit:Apoapsis).                
        Set calcPitch to deltaCalc + PitchOfVector(Ship:Velocity:Orbit).

        Wait 0.01.
    }
}