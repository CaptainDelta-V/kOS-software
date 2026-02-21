@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
RUNONCEPATH("0:common/constants").
RUNONCEPATH("0:common/landing/sites").
RUNONCEPATH("0:common/infos").
RUNONCEPATH("0:common/control").
RUNONCEPATH("0:common/nav").
RUNONCEPATH("0:common/booting/bootUtils").
RUNONCEPATH("0:common/launch/payloadModel").
RUNONCEPATH("0:common/flightStatus/flightStatusModel").




ClearScreen.

Local vesselType to VESSEL_TYPE_VULCAN.
Local flightStatus to FlightStatusModel("VULCAN LAUNCH", "BOOSTER RIDE").

Local launchHeading to 90.

RunFlightStatusScreen(flightStatus).

When not Core:Messages:Empty Then { 
    Local message to Core:Messages:Pop:Content.

    flightStatus:AddField("ReceivedMessage", message).

    If message = VULCAN_ASCENT_HANDOFF_MESSAGE {     
        Wait Until Stage:Ready.
        Stage.     
        Wait 0.       
        flightStatus:Update("BOOTING INTO ASCENT MODE").

        Local params to Lexicon(
            KEY_LAUNCH_HEADING, launchHeading,
            KEY_VESSEL_TYPE, vesselType
        ).

        SetAlternateBootFileWithParams("upperstageascent", params).
        Wait 0.
        Reboot. 
    }
    Else If message:HasSuffix("HasKey") and message:HasKey(KEY_LAUNCH_HEADING) { 
        Set launchHeading to message[KEY_LAUNCH_HEADING].        
        flightStatus:AddField("Launch heading", launchHeading).
    }
    Else {    
        flightStatus:Update("Unhandled message").
    }

    Preserve.
}

Wait Until Ship:Altitude > 200.
flightStatus:Update("WAITING FOR ASCENT HANDOFF . . .").

Wait Until False.
