RUNONCEPATH("1:common/utils/listutils").

Function DrainValveManager { 
    Parameter drainValves.

    Function DrainToAmount { 
        Parameter amount. 
        Parameter resourceName.

        // todo: options for ship/part        

        For valve in drainValves { 
            Local drainModule to valve:GetModule("ModuleResourceDrain").
            drainModule:SetField("drain rate", 1).
            drainModule:DoAction("drain", true).
        }

        Local resource to FindInList(Ship:Resources, { Parameter it. return it:Name = resourceName. }). 
        If resource = "None" { 
            Print("Resource not found.").
            Return.
        }        

        Local amountReached to false.
        Until amountReached { 
            If resource:Amount < amount { 
                For valve in drainValves { 
                    Local drainModule to valve:GetModule("ModuleResourceDrain").
                    drainModule:DoAction("stop draining", true).
                }
                Set amountReached to true.
            }
            Wait 0.01.
        }
    }

    Return Lexicon ( 
        "DrainToAmount", DrainToAmount@
    ).
}