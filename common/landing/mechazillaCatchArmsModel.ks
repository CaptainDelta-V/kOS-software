@LAZYGLOBAL OFF.
// RUNONCEPATH("1:common/nav").

Function MechazillaCatchArmsModel { 
    Parameter Mechazilla.
    Parameter MechazillaControllerModule.
    Parameter MaxNorthHeading to 46.
    Parameter MaxNorthTargetAngle to -34.3.
    // Parameter 

    Function ArmForCatch { 
        MechazillaControllerModule:SetField("arms open angle", 35).
        MechazillaControllerModule:SetField("target angle", 7).
        RaiseLandingRails().
    }

    // Function GetHeadingTo

    Function AlignToHeading { 
        Parameter headingToTarget.

        Local slope to 41.3 / 44.
        Local targetAngle to (slope * headingToTarget) - 77.

        MechazillaControllerModule:SetField("target angle", targetAngle).
    }

    Function RaiseLandingRails { 
        Mechazilla:GetModuleByIndex(11):DoAction("raise landing rails", true).        
    }

    Function LowerLandingRails { 
        Mechazilla:GetModuleByIndex(11):DoAction("lower landing rails", true).
    }

    Function OpenPushers { 
        // Mechazilla:
    }

    Return Lexicon( 
        "ArmForCatch", ArmForCatch@,
        "AlignToHeading", AlignToHeading@,
        "RaiseLandingRails", RaiseLandingRails@,
        "LowerLandingRails", LowerLandingRails@
    ).
}