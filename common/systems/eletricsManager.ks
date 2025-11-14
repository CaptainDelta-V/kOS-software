Function ElectricalManager { 

    Function RetractSolarArrays { 

    }

    Function ExtendSolarArrays { 
        For p in Ship:PartsTagged("SOLAR_ARRAY") { 
            // get the solar module and retract
        }
    }
}