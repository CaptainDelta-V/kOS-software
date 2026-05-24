@LAZYGLOBAL OFF.
RUNONCEPATH("0:kstui/screen").
RUNONCEPATH("0:kstui/menu").
RUNONCEPATH("0:common/flight/heliHoverModel").

Local Function ShowError {
    Parameter title.
    Parameter msg.
    TuiClear().
    TuiPrintAt(title, 0, TUI_ALIGN_CENTER).
    TuiHRule(1).
    TuiPrintAt(msg, 5, TUI_ALIGN_CENTER).
    TuiPrintAt("Press any key.", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
    TuiWaitAnyKey().
}

// Helicopter hover with toggleable manual override. Auto-engages on entry; H toggles
// between HOVER and MANUAL. On release, the computed throttle is written into
// PilotMainThrottle and control is switched back to the cockpit so the player's stick
// resumes flight smoothly (no sudden throttle drop, no inverted control-point axis).
// With no target set on activate, hover holds at the current Ship:GeoPosition.
Global Function TuiAircraftHeliHoverAction {
    Local title to "HELICOPTER HOVER".

    Local cockpitParts to Ship:PartsTagged("COCKPIT").
    Local upParts to Ship:PartsTagged("VERTICAL_CONTROL_POINT").
    If cockpitParts:Length = 0 Or upParts:Length = 0 {
        ShowError(title, "Need COCKPIT + VERTICAL_CONTROL_POINT tags.").
        Return.
    }

    Local cockpitControlModule to cockpitParts[0]:GetModule("ModuleCommand").
    Local upControlModule to upParts[0]:GetModule("ModuleCommand").

    Local model to HeliHoverModel({ Return Target:GeoPosition. }).
    Local hovering to False.

    Function EngageHover {
        // Switch to rotor-aligned control point first so Ship:Facing reflects thrust
        // direction by the time Start() captures initialTopRef.
        upControlModule:DoEvent("control from here").
        model:Start().
        Set hovering to True.
    }

    Function ReleaseHover {
        // Pre-seed PilotMainThrottle with the computer's current output so unlocking
        // Throttle doesn't snap the engine back to whatever stale pilot value was last set.
        Local lastThrottle to model:GetStatus():throttle.
        Set Ship:Control:PilotMainThrottle to lastThrottle.
        model:Stop().
        cockpitControlModule:DoEvent("control from here").
        Set hovering to False.
    }

    EngageHover().

    Terminal:Input:Clear().
    Local stopRequested to False.

    Until stopRequested {
        model:Update().    // no-op when disabled, so safe to call in MANUAL mode
        Local stat to model:GetStatus().

        TuiClear().
        TuiPrintAt(title, 0, TUI_ALIGN_CENTER).
        TuiHRule(1).
        TuiPrintAt("[H] toggle hover  [Enter] exit", 3).
        TuiPrintAt("[I/K] alt +/-1m", 4).

        Local modeStr to "MANUAL".
        If hovering { Set modeStr to "HOVER". }
        TuiPrintAt(("Mode:     " + modeStr):PadRight(TUI_WIDTH), 6).

        Local tgtStr to "(cached)".
        If stat:hasTarget { Set tgtStr to "live". }
        TuiPrintAt(("Target:   " + tgtStr):PadRight(TUI_WIDTH), 7).

        TuiPrintAt(("Pos err:  " + Round(stat:positionErrorMeters, 2) + " m"):PadRight(TUI_WIDTH), 9).

        TuiPrintAt(("Alt:      " + Round(stat:currentAltitude, 2) + " m"):PadRight(TUI_WIDTH), 11).
        TuiPrintAt(("Alt tgt:  " + Round(stat:targetAltitude, 2) + " m"):PadRight(TUI_WIDTH), 12).
        TuiPrintAt(("Radar:    " + Round(stat:currentRadarAlt, 2) + " / " + Round(stat:targetRadarAlt, 2) + " m"):PadRight(TUI_WIDTH), 13).
        TuiPrintAt(("Alt err:  " + Round(stat:altError, 2) + " m"):PadRight(TUI_WIDTH), 14).

        TuiPrintAt(("Vs:       " + Round(stat:verticalSpeed, 2) + " m/s"):PadRight(TUI_WIDTH), 16).
        TuiPrintAt(("Throttle: " + Round(stat:throttle, 3)):PadRight(TUI_WIDTH), 17).

        If Terminal:Input:HasChar {
            Local ch to Terminal:Input:GetChar().
            If ch = Terminal:Input:Enter Or ch = Terminal:Input:Return {
                Set stopRequested to True.
            } Else If ch = "h" Or ch = "H" {
                If hovering { ReleaseHover(). } Else { EngageHover(). }
            } Else If ch = "i" Or ch = "I" {
                model:AdjustTargetAltitude(1).
            } Else If ch = "k" Or ch = "K" {
                model:AdjustTargetAltitude(-1).
            }
        }

        Wait 0.
    }

    // Clean release on exit so we don't leave Steering/Throttle locked behind us.
    If hovering { ReleaseHover(). }
}
