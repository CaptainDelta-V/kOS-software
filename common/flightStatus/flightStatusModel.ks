@LAZYGLOBAL OFF.

Function FlightStatusModel {
    
    Parameter ScreenTitle to "FLIGHT OPERATION".
    Parameter FlightStatus to "UNKNOWN".    
    Parameter RecordLogs to true.

    Local LogFilePath is "0:logs/flight-" + ScreenTitle.

    If (RecordLogs) { 
        DeletePath(LogFilePath).    
        Log "[" + Time:Seconds + "]" + "INIT: " + ScreenTitle To LogFilePath.
    }

    Local _flightStatusFields to Lexicon().

    Function GetFlightStatus { 
        Return FlightStatus.
    }

    Function GetTitle { 
        Return "==== " + ScreenTitle + " ====". 
    }

    Function SetTitle {
        Parameter newTitle. 
        Set ScreenTitle to newTitle.
    }

    Function Update { 
        Parameter newStatus.
        Set FlightStatus to newStatus.

        If (RecordLogs) { 
            Log "[" + Time:Seconds + "]" + FlightStatus To LogFilePath.
        }
    }    

    Function AddField { 
        Parameter fieldName.
        Parameter fieldValue.
        
        Set _flightStatusFields[fieldName] to fieldValue.        
        If (RecordLogs) { 
            Local printValue to fieldValue.
            // If fieldValue:HasSuffix("Call") { 
            //     Set printValue to fieldValue:Call().
            // }
            Log "[" + Time:Seconds + "]" + fieldName + " set to " + fieldValue To LogFilePath.
        }
    }

    Function UpdateField { 
        Parameter fieldName. 
        Parameter fieldValue. 

        Set _flightStatusFields[fieldName] to fieldValue.
        If (RecordLogs) { 
            Log "[" + Time:Seconds + "]" + fieldName + " updated to " + fieldValue To LogFilePath.
        }
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
        "SetTitle", SetTitle@,
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

    When not stopRunningFlightStatusScreen Then {         
        flightStatus:PrintStatusScreen().
        
        Wait delay.
        Preserve.        
    }
}

Global Function StopRunFlightStatusScreen { 
    Set stopRunningFlightStatusScreen to true.
}