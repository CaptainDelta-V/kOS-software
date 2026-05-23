@LAZYGLOBAL OFF.

Global TUI_WIDTH to 40.
Global TUI_HEIGHT to 20.

Global TUI_ALIGN_LEFT to 0.
Global TUI_ALIGN_CENTER to 1.
Global TUI_ALIGN_RIGHT to 2.

Global Function TuiClear {
    ClearScreen.
}

Global Function TuiPrintAt {
    Parameter text.
    Parameter line.
    Parameter alignment is TUI_ALIGN_LEFT.

    Local col to 0.
    If alignment = TUI_ALIGN_CENTER {
        Set col to Max(0, Floor((TUI_WIDTH - text:Length) / 2)).
    }
    Else If alignment = TUI_ALIGN_RIGHT {
        Set col to Max(0, TUI_WIDTH - text:Length).
    }

    Print text At (col, line).
}

Global Function TuiClearLine {
    Parameter line.
    Print " ":PadRight(TUI_WIDTH) At (0, line).
}

Local TuiHRuleString to "".
From {Local i is 0.} Until i = TUI_WIDTH Step {Set i to i + 1.} Do {
    Set TuiHRuleString to TuiHRuleString + "-".
}

Global Function TuiHRule {
    Parameter line.
    Print TuiHRuleString At (0, line).
}

Global Function TuiWaitAnyKey {
    Terminal:Input:Clear().
    Wait Until Terminal:Input:HasChar.
    Terminal:Input:GetChar().
}
