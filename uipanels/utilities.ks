@LAZYGLOBAL OFF.

Global TERM_WIDTH to 40.
Global TERM_HEIGHT to 20.

Global LAST_PRESSED_BTN_NUM to 0.
Global LAST_PRESSED_BUTTON_MONITOR to -1.

Global UP_BTN_IDX to -3.
Global DOWN_BTN_IDX to -4.
Global RIGHT_BTN_IDX to -6.
Global LEFT_BTN_IDX to -5.
Global CONFIRM_BTN_IDX to -1.
Global REJECT_BTN_IDX to -2.

Global UI_ALIGN_HORIZ_CENTER to 0.
Global UI_ALIGN_LEFT to 2. 
Global UI_ALIGN_RIGHT to 3.
Global UI_ALIGN_VERT_CENTER_LINE to (TERM_HEIGHT / 2) - 3.

Global MONITORS to Addons:KPM:GETMONITORCOUNT().
Global BUTTONS to Addons:KPM:BUTTONS.
Global LABELS to Addons:KPM:LABELS.

Global LABEL_WIDTH to 8.

Local HOME_BTN_IDX to 0.
Local TERMINATE_BTN_IDX to 13.
Local NO_OP_BTN_IDX to 12.

Global Function ITERATE_MONITORS { 
    Parameter DO_AT_EACH.

    FROM {Local MONITOR_IDX is 0.} Until MONITOR_IDX = MONITORS STEP {Set MONITOR_IDX to MONITOR_IDX+1.} DO {
        DO_AT_EACH:Call(MONITOR_IDX).
    }
}

Global Function SET_DEFAULT_BUTTONS {        

    FROM {Local MONITOR_IDX is 0.} Until MONITOR_IDX = MONITORS STEP {Set MONITOR_IDX to MONITOR_IDX+1.} DO {
        Set BUTTONS:CURRENTMONITOR to MONITOR_IDX. 
        Set LABELS:CURRENTMONITOR to MONITOR_IDX.      

        // Set ALL LABELS to BLANK BY DEFAULT. 
        FROM {Local BTN_IDX is -6.} Until BTN_IDX=14 STEP {Set BTN_IDX to BTN_IDX+1.} DO {
                  
            LABELS:SETLABEL(BTN_IDX, BTN_IDX + "":PADRIGHT(LABEL_WIDTH * 0.9)).
            BUTTONS:SETDELEGATE(BTN_IDX, SET_LAST_PRESSED_BTN_NUM@:BIND(BTN_IDX, MONITOR_IDX)).
        }                

        // Only default behavior of this button goes back to the other UIs.
        LABELS:SETLABEL(TERMINATE_BTN_IDX, "[#FF0000]TERMINATE":PADRIGHT(LABEL_WIDTH):PADLEFT(LABEL_WIDTH)).
        BUTTONS:SETDELEGATE(TERMINATE_BTN_IDX, EXIT@).                 
    }
}

Global Function SET_IVA_BUTTON { 
    Parameter BTN_IDX.
    Parameter TEXT. 
    Parameter FUNC_DELEGATE.

    LABELS:SETLABEL(BTN_IDX, TEXT:PADRIGHT(LABEL_WIDTH):PADLEFT(LABEL_WIDTH)).
    BUTTONS:SETDELEGATE(BTN_IDX, FUNC_DELEGATE).
}

Function SET_LAST_PRESSED_BTN_NUM {
    Parameter NUM is 0.
    Parameter MONITOR_IDX is -1.
    Set LAST_PRESSED_BTN_NUM to NUM.
    Set LAST_PRESSED_BUTTON_MONITOR to MONITOR_IDX.
}

Global Function UI_PRINT {
    Parameter TEXT.
    Parameter LINE.
    Parameter ALIGNMENT is "".
    Parameter NO_RECOLOR to true.
    Parameter COLOR_INDC is "[#00ff0d]".

    If NO_RECOLOR { 
        Set COLOR_INDC to "".
    }
        
    If ALIGNMENT = UI_ALIGN_HORIZ_CENTER { 
        Print COLOR_INDC + TEXT AT ((TERM_WIDTH / 2) - ((TEXT:Length / 2)), LINE).
    }    
    Else If ALIGNMENT = UI_ALIGN_RIGHT {
        Print COLOR_INDC + TEXT AT (TERM_WIDTH - TEXT:Length, LINE).
    }    
    Else { 
        Print COLOR_INDC + TEXT AT (0, LINE).
    }
    

    // Print "PAGE" AT (17,0).
}

