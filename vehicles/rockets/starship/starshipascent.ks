@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("0:vehicles/rockets/starship/constants").
RUNONCEPATH("0:common/infos").
RUNONCEPATH("0:common/engineManager").
RUNONCEPATH("0:common/flightStatus/flightStatusModel").
RUNONCEPATH("0:common/control").
RUNONCEPATH("0:common/nav").
RUNONCEPATH("0:common/launch/ascentModel").
RUNONCEPATH("0:common/booting/bootUtils").
RUNONCEPATH("0:common/launch/payloadModel").
RUNONCEPATH("0:common/flight/upperAscent").

Parameter Params to Lexicon(
    KEY_LAUNCH_HEADING, 90,
    KEY_VESSEL_TYPE, VESSEL_TYPE_STARSHIP
).

ClearScreen.
ClearVecDraws().
ResetTorque().

Local RequiredApoapsisEtaMargin to 60 * 3.
Set Ship:Name to ACTIVE_STARSHIP_VESSEL_NAME.

Local vesselType to Params[KEY_VESSEL_TYPE].
Local flightStatus to FlightStatusModel("STARSHIP ORBITAL ASCENT CONTROL","UNKNOWN").

// Local payload to PayloadModel(flightStatus, vesselType).  
// payload:ReadPayloadConfigFromDisk().
// payload:AddFlightStatus().

// Local ascent to AscentModel(payload:PayloadMass(), payload:PayloadCapacity(), 0, 35).
// Local ascentPitch to ascent:GetMinAscentPitch().

// Local ascent to AscentModel().

// flightStatus:AddField("ETA Apoapsis", ascent:TimeToApoapsis@).
flightStatus:AddField("ETA APOAPSIS", { Return Ship:Orbit:ETA:Apoapsis. }).
flightStatus:AddField("REQUIRED Time MARGIN", RequiredApoapsisEtaMargin).

Local targetPitch to 15.5.
Local targetRoll to 180.

When Apoapsis > 85_100 Then { 
    Set targetPitch to 0.
}

// When Apoapsis > 87_128 Then { 
//     Set targetPitch to 0.
// }

// When Apoapsis > 90_000 Then { 
//     Set targetPitch to -8.
// }

RunFlightStatusScreen(flightStatus, 0.75).

If Ship:Orbit:ETA:Apoapsis > RequiredApoapsisEtaMargin {    
    flightStatus:Update("Orbit: IDLE").
}
Else { 
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
    // Lock targetHeading to HeadingOfVector(Ship:Velocity:Orbit).
    Lock targetHeading to 90.
    Lock Steering to Heading(targetHeading, targetPitch, targetRoll).        
    
    flightStatus:Update("ASCENT").        

    Wait 4.
    Local Booster to Vessel(ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME).         
    flightStatus:AddField("Booster Time to Apoapsis", { Return Booster:Orbit:ETA:Apoapsis.}).
    flightStatus:AddField("Booster Connection", { Return Booster:Connection:IsConnected. }).
    
    flightStatus:Update("UPPER ASCENT APOAPSIS TARGETING"). 

    // Set KUniverse:ForceActiveVessel to Vessel(ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME).

    // When ascent:TimeToApoapsis() > RequiredApoapsisEtaMargin - 30 Then { 
    //     Booster:Connection:SendMessage(INITIATE_LANDING_SEQUENCE_MESSAGE).
    //     flightStatus:Update("Orbit: SENDING Booster LAND MESSAGE").
    // }

    //ascent:TimeToApoapsis()
    When Ship:Orbit:ETA:Apoapsis > RequiredApoapsisEtaMargin  Then {         
        Lock Throttle to 0.
        flightStatus:Update("COAST TO APOAPSIS").  
        
        Set Ship:Name to "STARSHIP COASTING".
        Wait 1.
        Shutdown.                           
    }
}
