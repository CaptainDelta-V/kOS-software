@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/launch/ascentModel").
RUNONCEPATH("../../../common/booting/bootUtils").

ClearScreen.
ClearVecDraws().

Local RequiredApoapsisEtaMargin to 60 * 3.5.
Set Ship:Name to ACTIVE_STARSHIP_VESSEL_NAME.

Local ascent to AscentModel().
Local flightStatus to FlightStatusModel("STARSHIP ORBITAL ASCENT Control","UNKNOWN").

flightStatus:AddField("ETA Apoapsis", ascent:TimeToApoapsis@).
flightStatus:AddField("REQUIRED Time MARGIN", RequiredApoapsisEtaMargin).

Local targetPitch to -1.5.
Local targetRoll to 180.

RunFlightStatusScreen(flightStatus, 0.75).

If Ship:Orbit:ETA:Apoapsis > RequiredApoapsisEtaMargin {    
    flightStatus:Update("Orbit: IDLE").
    Set Core:BootFilename to "".
}
Else { 
   AscendToOrbit().
}

Wait Until false.

Function AscendToOrbit { 
    RCS ON.
    ResetTorque(). 
    Set SteeringManager:YawTorqueFactor to 0.5.
    Set SteeringManager:PitchTorqueFactor to 0.5.
    Set SteeringManager:RollTorqueFactor to 0.5.

    Lock Throttle to 1.    
    Lock targetHeading to HeadingOfVector(Ship:Velocity:Orbit).
    Lock Steering to Heading(targetHeading, targetPitch, targetRoll).        
    
    flightStatus:Update("ASCENT").        

    Wait 4.
    Local Booster to Vessel(ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME).         
    flightStatus:AddField("Booster Time to Apoapsis", { Return Booster:Orbit:ETA:Apoapsis.}).
    flightStatus:AddField("Booster Connection", { Return Booster:Connection:IsConnected. }).

    When ascent:TimeToApoapsis() > RequiredApoapsisEtaMargin - 30 Then { 
        Booster:Connection:SendMessage(INITIATE_LANDING_SEQUENCE_MESSAGE).
        flightStatus:Update("Orbit: SENDING Booster LAND MESSAGE").
    }

    When ascent:TimeToApoapsis() > RequiredApoapsisEtaMargin Then { 
        Lock Throttle to 0.
        flightStatus:Update("Orbit: PREPARING to SWITCH to Booster").
        Set Core:BootFilename to "".         
        
        Wait 1.
                   
        Set KUniverse:ActiveVessel to Vessel(ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME).
    }
}
