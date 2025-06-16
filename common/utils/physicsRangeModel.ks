
Function PhysicsRangeModel { 

    Function ResetPhysicsRanges { 
        Parameter alsoIncreaseLanded to false.

        // Escaping
        Set KUniverse:DefaultLoadDistance:Escaping:Load To 2_250.
        Set KUniverse:DefaultLoadDistance:Escaping:Unload To 2_500.
        Wait 0.001.
        Set KUniverse:DefaultLoadDistance:Escaping:Unpack To 200.
        Set KUniverse:DefaultLoadDistance:Escaping:Pack To 350.

        // Flying
        Set KUniverse:DefaultLoadDistance:Flying:Load To 2_250.
        Set KUniverse:DefaultLoadDistance:Flying:Unload To 22_500.
        Wait 0.001.
        Set KUniverse:DefaultLoadDistance:Flying:Unpack To 2_000.
        Set KUniverse:DefaultLoadDistance:Flying:Pack To 25_000.

        If alsoIncreaseLanded {
              // Landed
            Set KUniverse:DefaultLoadDistance:Landed:Load To 2_250.
            Set KUniverse:DefaultLoadDistance:Landed:Unload To 2_500.
            Wait 0.001.
            Set KUniverse:DefaultLoadDistance:Landed:Unpack To 200.
            Set KUniverse:DefaultLoadDistance:Landed:Pack To 350.
        }

        // Orbit
        Set KUniverse:DefaultLoadDistance:Orbit:Load To 2_250.
        Set KUniverse:DefaultLoadDistance:Orbit:Unload To 2_500.
        Wait 0.001.
        Set KUniverse:DefaultLoadDistance:Orbit:Unpack To 200.
        Set KUniverse:DefaultLoadDistance:Orbit:Pack To 350.

        // Prelaunch
        Set KUniverse:DefaultLoadDistance:Prelaunch:Load To 2_250.
        Set KUniverse:DefaultLoadDistance:Prelaunch:Unload To 2_500.
        Set KUniverse:DefaultLoadDistance:Prelaunch:Unpack To 200.
        Set KUniverse:DefaultLoadDistance:Prelaunch:Pack To 350.

        // Splashed
        Set KUniverse:DefaultLoadDistance:Splashed:Load To 2_250.
        Set KUniverse:DefaultLoadDistance:Splashed:Unload To 2_500.
        Wait 0.001.
        Set KUniverse:DefaultLoadDistance:Splashed:Unpack To 200.
        Set KUniverse:DefaultLoadDistance:Splashed:Pack To 350.

        // Suborbital
        Set KUniverse:DefaultLoadDistance:Suborbital:Load To 2_250.
        Set KUniverse:DefaultLoadDistance:Suborbital:Unload To 15_000.
        Wait 0.001.
        Set KUniverse:DefaultLoadDistance:Suborbital:Unpack To 200.
        Set KUniverse:DefaultLoadDistance:Suborbital:Pack To 10_000.
    }

    Function SetPhysicsRangesForRecoveryLaunch { 
        Parameter includeLanded to false.        
        Parameter rangeToSet to 400_000.    

        // Flying
        Set KUniverse:DefaultLoadDistance:Flying:Load To rangeToSet.
        Set KUniverse:DefaultLoadDistance:Flying:Unload To rangeToSet.
        Wait 0.001.
        Set KUniverse:DefaultLoadDistance:Flying:Unpack To rangeToSet.
        Set KUniverse:DefaultLoadDistance:Flying:Pack To rangeToSet.

        // Suborbital
        Set KUniverse:DefaultLoadDistance:Suborbital:Load To rangeToSet.
        Set KUniverse:DefaultLoadDistance:Suborbital:Unload To rangeToSet.
        Wait 0.001.
        Set KUniverse:DefaultLoadDistance:Suborbital:Unpack To rangeToSet.
        Set KUniverse:DefaultLoadDistance:Suborbital:Pack To rangeToSet.

        // Landed 
        If includeLanded { 
            Set KUniverse:DefaultLoadDistance:Landed:Load To rangeToSet.
            Set KUniverse:DefaultLoadDistance:Landed:Unload To rangeToSet.
            Wait 0.001.
            Set KUniverse:DefaultLoadDistance:Landed:Unpack To rangeToSet.
            Set KUniverse:DefaultLoadDistance:Landed:Pack To rangeToSet.
        }
    }

    Function GetLoadDistanceDescriptions { 
        
        Local description to "".
        Local distances TO KUniverse:DefaultLoadDistance.

        Set description to description + "escaping distances:" + Char(10). // Char(10) is a newline character
        Set description to description + "    load: " + distances:ESCAPING:LOAD + "m" + Char(10).
        Set description to description + "  unload: " + distances:ESCAPING:UNLOAD + "m" + Char(10).
        Set description to description + "  unpack: " + distances:ESCAPING:UNPACK + "m" + Char(10).
        Set description to description + "    pack: " + distances:ESCAPING:PACK + "m" + Char(10).
        Set description to description + "flying distances:" + Char(10).
        Set description to description + "    load: " + distances:FLYING:LOAD + "m" + Char(10).
        Set description to description + "  unload: " + distances:FLYING:UNLOAD + "m" + Char(10).
        Set description to description + "  unpack: " + distances:FLYING:UNPACK + "m" + Char(10).
        Set description to description + "    pack: " + distances:FLYING:PACK + "m" + Char(10).
        Set description to description + "landed distances:" + Char(10).
        Set description to description + "    load: " + distances:LANDED:LOAD + "m" + Char(10).
        Set description to description + "  unload: " + distances:LANDED:UNLOAD + "m" + Char(10).
        Set description to description + "  unpack: " + distances:LANDED:UNPACK + "m" + Char(10).
        Set description to description + "    pack: " + distances:LANDED:PACK + "m" + Char(10).   
        Set description to description + "orbit distances:" + Char(10).
        Set description to description + "    load: " + distances:ORBIT:LOAD + "m" + Char(10).
        Set description to description + "  unload: " + distances:ORBIT:UNLOAD + "m" + Char(10).
        Set description to description + "  unpack: " + distances:ORBIT:UNPACK + "m" + Char(10).
        Set description to description + "    pack: " + distances:ORBIT:PACK + "m" + Char(10).
        Set description to description + "prelaunch distances:" + Char(10).
        Set description to description + "    load: " + distances:PRELAUNCH:LOAD + "m" + Char(10).
        Set description to description + "  unload: " + distances:PRELAUNCH:UNLOAD + "m" + Char(10).
        Set description to description + "  unpack: " + distances:PRELAUNCH:UNPACK + "m" + Char(10).
        Set description to description + "    pack: " + distances:PRELAUNCH:PACK + "m" + Char(10).
        Set description to description + "splashed distances:" + Char(10).
        Set description to description + "    load: " + distances:SPLASHED:LOAD + "m" + Char(10).
        Set description to description + "  unload: " + distances:SPLASHED:UNLOAD + "m" + Char(10).
        Set description to description + "  unpack: " + distances:SPLASHED:UNPACK + "m" + Char(10).
        Set description to description + "    pack: " + distances:SPLASHED:PACK + "m" + Char(10).
        Set description to description + "suborbital distances:" + Char(10).
        Set description to description + "    load: " + distances:SUBORBITAL:LOAD + "m" + Char(10).
        Set description to description + "  unload: " + distances:SUBORBITAL:UNLOAD + "m" + Char(10).
        Set description to description + "  unpack: " + distances:SUBORBITAL:UNPACK + "m" + Char(10).
        Set description to description + "    pack: " + distances:SUBORBITAL:PACK + "m" + Char(10).

        Return description.
    }

    Return Lexicon(
        "ResetPhysicsRanges", ResetPhysicsRanges@,
        "SetPhysicsRangesForRecoveryLaunch", SetPhysicsRangesForRecoveryLaunch@, 
        "GetLoadDistanceDescriptions", GetLoadDistanceDescriptions@        
    ).
}