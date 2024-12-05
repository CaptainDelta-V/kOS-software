@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("../../../common/constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/landing/landingStatusModel"). 
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/engineManager").
// RUNONCEPATH("../../../common/launch/launch").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("constants").

Parameter BoosterSide. // north/south
Parameter LandingSiteKey. 

Local landingSite to LANDING_SITES[LANDING_SITES].

Set Ship:Name to "FH_SIDE_BOOSTER_" + BoosterSide.
Local ENGINE to Ship:PartsTagged("MERLINS")[0].
Local ENGINE_MODULE to ENGINE:GetModule(TUNDRA_ENGINE_MODULE_NAME).
Local EngineManager to EngineManager(ENGINE_MODULE, VESSEL_TYPE_FALCON_BOOSTER).

Local flightStatus to FlightStatusModel("FALCON HEAVY SIDE Booster LANDING", "INITIALIZATION").

flightStatus:Update("WAITING For LANDING INITIALIZATION MESSAGE").

Local startBoosterLanding to false. 
Until startBoosterLanding { 

    If Not Ship:Messages:Empty { 
        Local message to Ship:Messages:Pop:Content.
        If message = SIDE_BOOSTER_LANDING_INIT_MESSAGE { 
            Set startBoosterLanding to true. 
        }   
        Else {
            flightStatus:Update("RECEIVED INVALID MESSAGE").
        }
    }
    
    Wait 0. 
}

flightStatus:Update("Booster LANDING Engage").

Wait Until false. 









