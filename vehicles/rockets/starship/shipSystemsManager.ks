@LAZYGLOBAL OFF.
Declare Global SS_FLAP_MAX_ANGLE to 78. 
Declare Global SS_FLAP_MIN_ANGLE to 0.

Function ShipSystemsManager { 
    Parameter frontFlaps.
    Parameter rearFlaps.

    Function DeployFrontFlaps { 
        Parameter state.
        If state { 
            AG6 OFF.
        } Else {
            AG6 ON.
        }
    }

    Function DeployRearFlaps { 
        Parameter state.
        If state { 
            AG5 OFF.
        } Else {
            AG5 ON.
        }
    } 

    Function SetFrontFlapsDeployAngle { 
        Parameter angle. 
        _setFlapDeployAngle(frontFlaps, angle).
    }

    Function SetRearFlapsDeployAngle { 
        Parameter angle.
        _setFlapDeployAngle(rearFlaps, angle).
    }

    Function _setFlapDeployAngle { 
        Parameter flaps.
        Parameter angle.

        For flap in flaps {
            Local controlSurfaceModule to flap:GetModuleByIndex(0).
              // Deployed is full in, extended is out
            controlSurfaceModule:SetField("deploy angle", angle).
        }     
    }

    Function SetFrontFlapsControlActive { 
        Parameter state. 
        _setFlapsControlActive(frontFlaps, state).
    }

    Function SetRearFlapsControlActive { 
        Parameter state.
       _setFlapsControlActive(rearFlaps, state).
    }

    Function _setFlapsControlActive { 
        Parameter flaps. 
        Parameter state.

         For flap in flaps { 
            Local controlModule to flap:GetModule("ModuleSEPControlSurface").
            If state { 
                controlModule:DoAction("activate all controls", true).
            } Else { 
                controlModule:DoAction("deactivate all controls", true).
            }
        }
    }

    Function EngageVacEngines { 
        Parameter state. 

        Local engines to Ship:PartsTagged("RVAC").
        _engageEngines(engines, state).
    }

    Function EngageSeaEngines { 
        Parameter state. 
        Local engines to Ship:PartsTagged("RSEA").
        _engageEngines(engines, state).
    }

    Function _engageEngines {
        Parameter engines.
        Parameter state.

        For eng in engines { 

            If state { 
                eng:GetModule("ModuleEnginesFX"):DoAction("activate engine", true).
            } Else { 
                eng:GetModule("ModuleEnginesFX"):DoAction("shutdown engine", true).
            }
        }
    }

    Function FuelToBalance { 
        Local sourceParts to Ship:PartsDubbed("Procedural Liquid Tank").
        sourceParts:Add(Ship:PartsTagged("SHIP_BODY_TANK")).

        Local destinationParts to Ship:PartsTagged("BALANCE_TANK").

        Local oxiTransfer to TransferAll("OXIDIZER", sourceParts, destinationParts).
        Local methaneTransfer to TransferAll(RESOURCE_LIQUID_METHANE, sourceParts, destinationParts).
        Set oxiTransfer:Active to true.
        Set methaneTransfer:Active to true.
    }

    Function FuelToRear { 
        Local sourceParts to Ship:PartsDubbed("Procedural Liquid Tank").
        Local destinationParts to Ship:PartsTagged("SHIP_BODY_TANK").
        Print "source parts: " + sourceParts:length + " destination parts: " + destinationParts:length.
        
        Local oxiTransfer to TransferAll("OXIDIZER", sourceParts, destinationParts).
        Local methaneTransfer to TransferAll(RESOURCE_LIQUID_METHANE, sourceParts, destinationParts).
        Set oxiTransfer:Active to true.
        Set methaneTransfer:Active to true.
    }

    Return Lexicon(
        "DeployFrontFlaps", DeployFrontFlaps@,
        "DeployRearFlaps", DeployRearFlaps@,
        "SetFrontFlapsDeployAngle", SetFrontFlapsDeployAngle@,
        "SetRearFlapsDeployAngle", SetRearFlapsDeployAngle@, 
        "SetFrontFlapsControlActive", SetFrontFlapsControlActive@,
        "SetRearFlapsControlActive", SetRearFlapsControlActive@,
        "EngageVacEngines", EngageVacEngines@,
        "EngageSeaEngines", EngageSeaEngines@, 
        "FuelToBalance", FuelToBalance@,
        "FuelToRear", FuelToRear@
    ).
}