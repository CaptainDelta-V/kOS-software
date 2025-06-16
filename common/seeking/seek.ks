RUNONCEPATH("0:common/exceptions").


Function Seeker { 
    Parameter flightStatus.

    Function To { 
        Parameter targetVal. 
        Parameter getActual.
        Parameter adjuster. 
        Parameter useTerminator to false.
        Parameter terminator to { Return false. }.

        Local getError to { Return Abs(Abs(targetVal) - Abs(getActual:Call())). }.
        Local previousError to getError:Call() + 1.

        Local targetReached to false. 
        Until targetReached { 

            Local actual to getActual:Call(). 
            adjuster:Call().

            Local currentError to Abs(Abs(targetVal) - Abs(getActual:Call())).

            If useTerminator { 
                Set targetReached to terminator().
            }
            Else { 
                Set targetReached to previousError < currentError.
            }

            flightStatus:AddField("ACTUAL", actual, false, true).
            flightStatus:AddField("TARGET", targetVal, false, true).
            Set previousError to currentError.
            // Wait 0.001.
        }

        flightStatus:RemoveField("ACTUAL").
        flightStatus:RemoveField("TARGET").
    }

    Return Lexicon(
        "To", To@
    ).
}
