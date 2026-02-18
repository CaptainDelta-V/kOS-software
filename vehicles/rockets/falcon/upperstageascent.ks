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
RUNONCEPATH("../../../common/utils/physicsRangeModel").
RUNONCEPATH("../../../common/booting/bootUtils").

Parameter Params to Lexicon(
    KEY_LAUNCH_HEADING, 90,
    KEY_VESSEL_TYPE, VESSEL_TYPE_FALCON_9
).

ClearScreen. 

Local RequiredApoapsisEtaMargin to 60 * 3.
Set Ship:Name to ACTIVE_FALCON_UPPER_VESSEL_NAME.

Local flightStatus to FlightStatusModel("FALCON UPPER STAGE ASCENT CONTROL","UNKNOWN").

flightStatus:AddField("REQUIRED Time MARGIN", RequiredApoapsisEtaMargin).
flightStatus:AddField("Apoapsis", { Return Ship:Orbit:Apoapsis. }).

Local vesselType to Params[KEY_VESSEL_TYPE].

Local payload to PayloadModel(flightStatus, vesselType).  
payload:ReadPayloadConfigFromDisk().
payload:AddFlightStatus().

Local ascent to AscentModel(payload:PayloadMass(), payload:PayloadCapacity(), 12, 35).
Local ascentPitch to 15.5.
flightStatus:AddField("Ascent Pitch", ascent:GetMinAscentPitch@).
flightStatus:AddField("Apoapsis", { Return Ship:Orbit:Apoapsis. }).
flightStatus:AddField("ETA Apoapsis", ascent:TimeToApoapsis@).

Local targetPitch to ascentPitch.
Local targetRoll to 180.

When Apoapsis > 87_100 Then { 
    Set targetPitch to 0.
}

When Apoapsis > 92_128 Then { 
    Set targetPitch to -2.
}

RunFlightStatusScreen(flightStatus).

If Ship:Orbit:ETA:Apoapsis > RequiredApoapsisEtaMargin {    
    flightStatus:Update("ORBITING").
}
Else { 
    
    Local upperstageDecoupler to Ship:PartsTagged(FALCON_DECOUPLER_UPPERSTAGE)[0].
    upperstageDecoupler:GetModule("ModuleTundraDecoupler"):DoAction("decouple", true).    
    flightStatus:Update("UPPER SEPARATION").
    Wait 0. 
    RCS ON.
    Lock Throttle to 1.
    WAIT 2.5.
    Lock throttle to 0.2.
    Ship:PartsTagged(FALCON_ENG_UPPERSTAGE)[0]:GetModule("ModuleEnginesFX"):DoEvent("activate engine").
    Wait 1.2.    
    RCS OFF.
    Lock Throttle to 1.

    AscendToOrbit().
}

Wait Until false.

Function AscendToOrbit { 

    Set Core:BootFilename to "".       

    SAS OFF. 
    Wait 0.    

    RCS ON.
    ResetTorque(). 
    // Set SteeringManager:YawTorqueFactor to 0.5.
    // Set SteeringManager:PitchTorqueFactor to 0.5.
    // Set SteeringManager:RollTorqueFactor to 0.5.

    Lock Throttle to 1.        
    Local targetHeading to Params[KEY_LAUNCH_HEADING].
    Lock Steering to Heading(targetHeading, targetPitch, targetRoll).        
    
    flightStatus:Update("ASCENT").        

    // Set KUniverse:ForceActiveVessel to Vessel(ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME).

    // When ascent:TimeToApoapsis() > RequiredApoapsisEtaMargin - 30 Then { 
    //     Booster:Connection:SendMessage(INITIATE_LANDING_SEQUENCE_MESSAGE).
    //     flightStatus:Update("Orbit: SENDING Booster LAND MESSAGE").
    // }
    
    When ascent:TimeToApoapsis() > RequiredApoapsisEtaMargin and Ship:Apoapsis > 85_000 Then {         
        Lock Throttle to 0.
        flightStatus:Update("COAST TO APOAPSIS").              
        Wait 1.    
        // Local physicsRangeController to PhysicsRangeModel(). // BAD IDEA
        // physicsRangeController:ResetPhysicsRanges().        
        Shutdown.                           
    }
}
