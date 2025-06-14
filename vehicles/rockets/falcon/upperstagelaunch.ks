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

Local receivedPayloadMass to false.
Local flightStatus to FlightStatusModel("FALCON UPPER STAGE LAUNCH CONTROL","AWAITING PAYLOAD MASS").

RunFlightStatusScreen(flightStatus, 0.5). 

Local vesselType to VESSEL_TYPE_FALCON_9.
If Ship:Name:Contains("Heavy") { 
    Set vesselType to VESSEL_TYPE_FALCON_HEAVY.
}

Local payload to PayloadModel(flightStatus, vesselType).  
Local launchHeading to 90.

When not Core:Messages:Empty Then { 
    Local message to Core:Messages:Pop:Content.

    If message = FALCON_UPPERSTAGE_HANDOFF { 

        flightStatus:Update("RECIEVED HANDOFF. REBOOTING FOR STAGING").    
        Local params to Lexicon(
            KEY_LAUNCH_HEADING, launchHeading,
            KEY_VESSEL_TYPE, vesselType
        ).
        SetAlternateBootFileWithParams("upperstageascent", params).
        Wait 0.
        Reboot.
    }       
    Else If message:HasKey(KEY_LAUNCH_HEADING) { 
        
        Local headingRecieved to message[KEY_LAUNCH_HEADING].
        flightStatus:AddField("Heading Received was", headingRecieved).
        Set launchHeading to headingRecieved.    
    }
    Else If message:HasKey(KEY_PAYLOAD_MASS) { 

        Local payloadParams to message.
        Local massRecd to payloadParams[KEY_PAYLOAD_MASS].
        payload:SetPayloadMass(massRecd).
        payload:WritePayloadConfigToDisk().
        flightStatus:Update("RECEIVED PAYLOAD MASS").
        payload:AddFlightStatus().        
    }

    Preserve. 
}

When Alt:Radar > 50 Then { 
    flightStatus:Update("BOOSTER RIDE").
}

Wait Until False.