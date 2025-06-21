@LAZYGLOBAL OFF.
RUNONCEPATH("0:common/constants").

Function FlightStatusModel {
    
    Parameter ScreenTitle to "FLIGHT OPERATION".
    Parameter FlightStatus to "UNKNOWN".    
    Parameter RecordLogs to true.

    Local _logFilePath is "0:logs/flight_" + ScreenTitle.
    Local _tempFields to List().

    If (RecordLogs) { 
        DeletePath(_logFilePath).    
        Log "[" + Timestamp(Time:Seconds):Full + "] " + "INIT: " + ScreenTitle To LogFilePath.
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
            Log "[" + Timestamp(Time:Seconds):Full + "] " + FlightStatus To LogFilePath.
        }
    }    

    Function AddField { 
        Parameter fieldName.
        Parameter fieldValue.
        Parameter logOnly to false.
        Parameter noLog to false.
        
        If not logOnly { // this is dumb, why do
            Set _flightStatusFields[fieldName] to fieldValue.        
        }

        // If RecordLogs and not noLog { 
        //     Local printValue to fieldValue.
        //     If fieldValue:HasSuffix("Call") { 
        //         Set printValue to fieldValue:Call().
        //     }
        //     Log "[" + Timestamp(Time:Seconds):Full + "] " + fieldName + " set to " + printValue To LogFilePath.
        // }
    }

    Function AddTempField { 
        Parameter fieldName.
        Parameter fieldValue.
        Set _flightStatusFields[fieldName] to fieldValue.        
        _tempFields:Add(fieldName).        
    }

    Function RemoveTempFields { 

        For temper in _tempFields { 
            RemoveField(temper).
        }

        Set _tempFields to List().
    }

    Function LogMessage { 
        Parameter msg. 
 
        Log "[" + Timestamp(Time:Seconds):Full + "] (LOG) " + msg To LogFilePath.
    }

    Function RemoveField { 
        Parameter fieldName.

        Set _flightStatusFields[fieldName] to NONE.
    }

    Function UpdateField { 
        Parameter fieldName. 
        Parameter fieldValue. 

        Set _flightStatusFields[fieldName] to fieldValue.
        If (RecordLogs) { 
            Log "[" + Time:Seconds + "] " + fieldName + " updated to " + fieldValue To LogFilePath.
        }
    }

    Function PrintStatusScreen { 
        ClearScreen.
        Print GetTitle().
        Print "STATUS: " + FlightStatus.
                
        For key In _flightStatusFields:Keys { 
            
            Local statusField to _flightStatusFields[key].
            Local outputValue to statusField.            
                            
            If not (outputValue = NONE) { 
                If statusField:HasSuffix("Call") {
                    // can only call getters with no params
                    Set outputValue to statusField:Call().
                }

                Print key + ": " + outputValue.
            }
        }

        Function GetCurrentTimeFormatted { 
            // Local Time:Seconds.
            Return "Y" + Time:Year + " D" + Time:Day + " " + Time:Hour + ":" + Time:Minute + Time:Second + ":".
        }
    }
    
    Return Lexicon(
        "GetFlightStatus", GetFlightStatus@,
        "GetTitle", GetTitle@,
        "SetTitle", SetTitle@,
        "PrintStatusScreen", PrintStatusScreen@, 
        "AddField", AddField@, 
        "AddTempField", AddTempField@, 
        "RemoveTempFields", RemoveTempFields@,
        "LogMessage", LogMessage@,
        "Update", Update@,
        "RemoveField", RemoveField@,
        "UpdateField", UpdateField@
    ).
}

Local stopRunningFlightStatusScreen to false.

Global Function RunFlightStatusScreen { 
    Parameter flightStatus.
    Parameter delay to 0.05. // deprecated, remove

    Set stopRunningFlightStatusScreen to false.  // this has  MASSIVE PERF IMPACT, but the faster the screen goes, the faster it prints

    When not stopRunningFlightStatusScreen Then {         
        flightStatus:PrintStatusScreen().

        // DropPriority().
        
        // Wait delay. // this was a bad idea
        Preserve.        
    }
}

Global Function StopRunFlightStatusScreen { 
    Set stopRunningFlightStatusScreen to true.
}