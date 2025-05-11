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
RUNONCEPATH("../../../common/launch/payloadModel").
RUNONCEPATH("../../../common/booting/bootUtils").

ClearScreen. 

Local RequiredApoapsisEtaMargin to 60 * 10.
Set Ship:Name to ACTIVE_FALCON_UPPER_VESSEL_NAME.

Local flightStatus to FlightStatusModel("FALCON UPPER STAGE ASCENT CONTROL","UNKNOWN").

flightStatus:AddField("REQUIRED Time MARGIN", RequiredApoapsisEtaMargin).
flightStatus:AddField("Apoapsis", { Return Ship:Orbit:Apoapsis. }).

Local payload to PayloadModel(flightStatus, VESSEL_TYPE_FALCON_HEAVY).  
payload:ReadPayloadConfigFromDisk().
payload:AddFlightStatus().

Local ascent to AscentModel(payload:PayloadMass(), payload:PayloadCapacity(), 0, 15).
Local ascentPitch to ascent:GetMinAscentPitch().
flightStatus:AddField("Ascent Pitch", Min(Max(ascentPitch, 0), 45)).
flightStatus:AddField("ETA Apoapsis", ascent:TimeToApoapsis@).

Local targetPitch to ascentPitch.
Local targetRoll to 180.

When Apoapsis > 85_100 Then { 
    Set targetPitch to 0.
}

// When Apoapsis > 87_128 Then { 
//     Set targetPitch to -5.
// }

RunFlightStatusScreen(flightStatus, 0.3).

If Ship:Orbit:ETA:Apoapsis > RequiredApoapsisEtaMargin {    
    flightStatus:Update("ORBITING").
}
Else { 
    Local upperstageDecoupler to Ship:PartsTagged(FALCON_DECOUPLER_UPPERSTAGE)[0].
    upperstageDecoupler:GetModule("ModuleTundraDecoupler"):DoAction("decouple", true).
    flightStatus:Update("UPPER SEPARATION").
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

    
    When ascent:TimeToApoapsis() > RequiredApoapsisEtaMargin Then {         
        Lock Throttle to 0.
        flightStatus:Update("COAST TO APOAPSIS").  
        Set Core:BootFilename to "".
        
        Wait 1.
        Shutdown.                           
    }
}
