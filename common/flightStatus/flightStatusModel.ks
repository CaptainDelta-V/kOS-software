@LAZYGLOBAL OFF.

Function FlightStatusModel {
    
    Parameter ScreenTitle to "FLIGHT OPERATION".
    Parameter FlightStatus to "UNKNOWN".        

    Local _flightStatusFields to Lexicon().

    Function GetFlightStatus { 
        Return FlightStatus.
    }

    Function GetTitle { 
        Return "==== " + ScreenTitle + " ====". 
    }

    Function Update { 
        Parameter newStatus.
        Set FlightStatus to newStatus.
    }

    Function AddField { 
        Parameter fieldName.
        Parameter fieldValue.
        
        Set _flightStatusFields[fieldName] to fieldValue.        
    }

    Function UpdateField { 
        Parameter fieldName. 
        Parameter fieldValue. 

        Set _flightStatusFields[fieldName] to fieldValue.
    }

    Function PrintStatusScreen { 
        ClearScreen.
        Print GetTitle().
        Print "STATUS: " + FlightStatus.
                
        For key In _flightStatusFields:KEYS { 

            Local statusField to _flightStatusFields[key].
            Local outputValue to statusField.            
                            
            If statusField:HasSuffix("Call") {
                // can only call getters with no params
                Set outputValue to statusField:Call().
            }

            Print key + ": " + outputValue.
        }
    }
    
    Return Lexicon(
        "GetFlightStatus", GetFlightStatus@,
        "GetTitle", GetTitle@,
        "PrintStatusScreen", PrintStatusScreen@, 
        "AddField", AddField@, 
        "Update", Update@,
        "UpdateField", UpdateField@
    ).
}

Local stopRunningFlightStatusScreen to false.

Global Function RunFlightStatusScreen { 
    Parameter flightStatus.
    Parameter delay to 0.5.

    Set stopRunningFlightStatusScreen to false. 

    When Not stopRunningFlightStatusScreen Then {         
        flightStatus:PrintStatusScreen().
        
        Wait delay.
        Preserve.        
    }
}

Global Function StopRunFlightStatusScreen { 
    Set stopRunningFlightStatusScreen to true.
}