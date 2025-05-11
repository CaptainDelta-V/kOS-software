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

Local payload to PayloadModel(flightStatus, VESSEL_TYPE_FALCON_HEAVY).  

When not Core:Messages:Empty Then { 
    Local message to Core:Messages:Pop:Content.

    If message = FALCON_UPPERSTAGE_HANDOFF { 

        flightStatus:Update("RECIEVED HANDOFF. REBOOTING FOR STAGING").    
        SetAlternateBootFile("upperstageascent").
        Reboot.
    }       
    Else { 
        Local payloadParams to message.
        Local massRecd to payloadParams[KEY_PAYLOAD_MASS].
        flightStatus:AddField("Mass reced was", massRecd).
        payload:SetPayloadMass(massRecd).
        payload:WritePayloadConfigToDisk().
        flightStatus:Update("RECEIVED PAYLOAD MASS").
        payload:AddFlightStatus().        
    }

    Preserve. 
}

Wait Until False.