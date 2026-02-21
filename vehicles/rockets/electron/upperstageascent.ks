@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
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
    KEY_LAUNCH_HEADING, 90
).

ClearScreen.
ClearVecDraws().
ResetTorque().

Local RequiredApoapsisEtaMargin to 130.
Set Ship:Name to ACTIVE_ELECTRON_VESSEL_NAME.

Local vesselType to VESSEL_TYPE_ELECTRON.
Local flightStatus to FlightStatusModel("ES2 ORBITAL ASCENT CONTROL").

When altitude > 75_000 Then{
    AG2 on.
}




// flightStatus:AddField("ETA Apoapsis", ascent:TimeToApoapsis@).
flightStatus:AddField("ETA APOAPSIS", { Return Ship:Orbit:ETA:Apoapsis. }).
flightStatus:AddField("REQUIRED Time MARGIN", RequiredApoapsisEtaMargin).

// Local targetPitch to Choose 35 If isTanker Else 15.5.
Local targetPitch to 45.

Local targetRoll to 180.


When Apoapsis > 89_000 Then { Set targetPitch to 20.}.

RunFlightStatusScreen(flightStatus).

If Ship:Orbit:ETA:Apoapsis > RequiredApoapsisEtaMargin {    
    flightStatus:Update("Orbit: IDLE").
}
Else { 
   AscendToOrbit().
}

Wait Until false.

Function AscendToOrbit { 

    Set Core:BootFilename to "".       

    SAS OFF.
    Wait 0.

    RCS ON.
    ResetTorque(). 
   
    Lock Throttle to 1.        
    Local targetHeading to Params[KEY_LAUNCH_HEADING].
    Lock Steering to Heading(targetHeading, targetPitch, targetRoll).        
    
    flightStatus:Update("ASCENT").        

    Wait 3.
    AG3 on.
    
    flightStatus:AddField("TargetPitch", { Return targetPitch. }).
    
    flightStatus:Update("UPPER ASCENT APOAPSIS TARGETING"). 
   
    When Ship:Orbit:ETA:Apoapsis > RequiredApoapsisEtaMargin and Ship:Apoapsis > 85_000  Then {         
        Lock Throttle to 0.
        flightStatus:Update("COAST TO APOAPSIS").  

        
        Set Ship:Name to "ES2 COASTING".
        Wait 1.
        Shutdown.                           
    }

   
    
}
