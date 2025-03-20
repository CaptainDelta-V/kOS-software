@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.

RUNONCEPATH("../../../common/exceptions").
RUNONCEPATH("../../../common/constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/landing/landingStatusModel").
RUNONCEPATH("../../../common/landing/landingSteeringModel").
RUNONCEPATH("../../../common/landing/landingBurnModel").
RUNONCEPATH("../../../common/landing/gridFinManager").
RUNONCEPATH("../../../common/landing/boostbackBurnController").
RUNONCEPATH("../../../common/flight/hover").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/launch/ascentModel").
RUNONCEPATH("../../../common/booting/bootUtils").

ClearScreen. 

Local RequiredApoapsisEtaMargin to 60 * 5.
Set Ship:Name to ACTIVE_FALCON_BOOSTER_VESSEL_NAME.

Local ascent to AscentModel().
Local flightStatus to FlightStatusModel("FALCON UPPER STAGE ASCENT CONTROL","UNKNOWN").

flightStatus:AddField("ETA Apoapsis", ascent:TimeToApoapsis@).
flightStatus:AddField("REQUIRED Time MARGIN", RequiredApoapsisEtaMargin).

Local targetPitch to 0.
Local targetRoll to 180.

RunFlightStatusScreen(flightStatus, 0.75).

If Ship:Orbit:ETA:Apoapsis > RequiredApoapsisEtaMargin {    
    flightStatus:Update("Orbit: IDLE").
}
Else { 
    Ship:PartsTagged(FALCON_ENG_UPPERSTAGE)[0]:GetModule("ModuleEnginesFX"):DoEvent("activate engine").

    Lock throttle to 0.2.
    Wait 2.
    Lock Throttle to 1.

    AscendToOrbit().
}

Wait Until false.

Function AscendToOrbit { 

    Set Core:BootFilename to "".       

    RCS ON.
    ResetTorque(). 
    Set SteeringManager:YawTorqueFactor to 0.5.
    Set SteeringManager:PitchTorqueFactor to 0.5.
    Set SteeringManager:RollTorqueFactor to 0.5.

    Lock Throttle to 1.    
    Lock targetHeading to HeadingOfVector(Ship:Velocity:Orbit).
    Lock Steering to Heading(targetHeading, targetPitch, targetRoll).        
    
    flightStatus:Update("ASCENT").        

    // Set KUniverse:ForceActiveVessel to Vessel(ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME).

    // When ascent:TimeToApoapsis() > RequiredApoapsisEtaMargin - 30 Then { 
    //     Booster:Connection:SendMessage(INITIATE_LANDING_SEQUENCE_MESSAGE).
    //     flightStatus:Update("Orbit: SENDING Booster LAND MESSAGE").
    // }

    When ascent:TimeToApoapsis() > RequiredApoapsisEtaMargin  Then {         
        Lock Throttle to 0.
        flightStatus:Update("COAST TO APOAPSIS").  
        
        Wait 1.
        Shutdown.                           
    }
}
