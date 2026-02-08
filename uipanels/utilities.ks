@LAZYGLOBAL OFF.
RUNONCEPATH("0:uipanels/color").

Global TERM_WIDTH to 40.
Global TERM_HEIGHT to 20.

Global LastPressedBtnNum to 0.
Global LastPressedButtonMonitor to -1.

Global UpBtnIdx to -3.
Global DownBtnIdx to -4.
Global RIGHT_BTN_IDX to -6.
Global LEFT_BTN_IDX to -5.
Global ConfirmBtnIdx to -1.
Global REJECT_BTN_IDX to -2.

Global UI_ALIGN_HOR_CTR to 0.
Global UI_ALIGN_LEFT to 2. 
Global UI_ALIGN_RIGHT to 3.
Global UI_ALIGN_VERT_CENTER_LINE to (TERM_HEIGHT / 2) - 3.

Global Monitors to Addons:KPM:GETMONITORCOUNT().
Global Buttons to Addons:KPM:BUTTONS.
Global Labels to Addons:KPM:LABELS.

Global LABEL_WIDTH to 8.

Local HomeButtonIdx to 0.
Local TerminateBtnIdx to 13.
Local NoOpButtonIdx to 12.

Global Function IterateMonitors { 
    Parameter doAtEach.

    FROM {Local monitorIdx is 0.} Until monitorIdx = Monitors STEP {Set monitorIdx to monitorIdx+1.} DO {
        doAtEach:Call(monitorIdx).
    }
}

Global Function SetDefaultButtons {        

    FROM {Local monitorIdx is 0.} Until monitorIdx = Monitors STEP {Set monitorIdx to monitorIdx+1.} DO {
        Set Buttons:CurrentMonitor to monitorIdx. 
        Set Labels:CurrentMonitor to monitorIdx.      

        // Set ALL LABELS to BLANK BY DEFAULT. 
        FROM {Local btnIdx is -6.} Until btnIdx=14 STEP {Set btnIdx to btnIdx+1.} DO {
                  
            Labels:SetLabel(btnIdx, btnIdx + "":PadRight(LABEL_WIDTH * 0.9)).
            Buttons:SetDelegate(btnIdx, SetLastPressedBtnNum@:Bind(btnIdx, monitorIdx)).
        }                

        // Only default behavior of this button goes back to the other UIs.
        Labels:SetLabel(TerminateBtnIdx, "[#FF0000]TERMINATE":PadRight(LABEL_WIDTH):PadLeft(LABEL_WIDTH)).
        Buttons:SetDelegate(TerminateBtnIdx, Exit@).                 
    }
}

Global Function SetIvaButton { 
    Parameter BTN_IDX.
    Parameter TEXT. 
    Parameter FUNC_DELEGATE.

    Labels:SetLabel(BTN_IDX, TEXT:PADRIGHT(LABEL_WIDTH):PADLEFT(LABEL_WIDTH)).
    Buttons:SetDelegate(BTN_IDX, FUNC_DELEGATE).
}

Function SetLastPressedBtnNum {
    Parameter num is 0.
    Parameter MonitorIdx is -1.
    Set LastPressedBtnNum to num.
    Set LastPressedButtonMonitor to MonitorIdx.
    Log "Last Pressed " + LastPressedBtnNum to "0:logs/shuttleTest.txt".
}

Global Function UiPrint {
    Parameter text.
    Parameter line.
    Parameter alignment is "".
    Parameter noRecolor to true.
    Parameter colorIndc is "[#00ff0d]".

    If noRecolor { 
        Set colorIndc to "".
    }
        
    If alignment = UI_ALIGN_HOR_CTR { 
        Print colorIndc + text AT ((TERM_WIDTH / 2) - ((text:Length / 2)), line).
    }    
    Else If alignment = UI_ALIGN_RIGHT {
        Print colorIndc + text AT (TERM_WIDTH - text:Length, line).
    }    
    Else { 
        Print colorIndc + text AT (0, line).
    }
    

    // Print "PAGE" AT (17,0).
}

