@LAZYGLOBAL OFF.
RUNONCEPATH("0:kstui/screen").
RUNONCEPATH("0:kstui/menu").
RUNONCEPATH("0:common/orbit/stationKeeping").
RUNONCEPATH("0:common/orbit/docking").
RUNONCEPATH("0:common/orbit/rendezvousModel").
RUNONCEPATH("0:common/utils/dockingPortUtils").

// Assumes the player has right-clicked a docking port in the KSP UI and chosen
// "Set as Target". Shows a warning and returns ok=False if no target is set or the
// target is not a docking port — caller returns to the menu cleanly.
Local Function GetTargetDockingPort {
    Parameter title.

    If not HasTarget {
        TuiClear().
        TuiPrintAt(title, 0, TUI_ALIGN_CENTER).
        TuiHRule(1).
        TuiPrintAt("No target set.", 5, TUI_ALIGN_CENTER).
        TuiPrintAt("Set a docking port as target in KSP first.", 7, TUI_ALIGN_CENTER).
        TuiPrintAt("Press any key.", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
        TuiWaitAnyKey().
        Return Lexicon("ok", False).
    }

    Local tgt to Target.
    If not tgt:HasSuffix("PortFacing") {
        TuiClear().
        TuiPrintAt(title, 0, TUI_ALIGN_CENTER).
        TuiHRule(1).
        TuiPrintAt("Target is not a docking port.", 5, TUI_ALIGN_CENTER).
        TuiPrintAt("(type: " + tgt:TypeName + ")", 6, TUI_ALIGN_CENTER).
        TuiPrintAt("Right-click a docking port in KSP and 'Set as Target'.", 8, TUI_ALIGN_CENTER).
        TuiPrintAt("Press any key.", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
        TuiWaitAnyKey().
        Return Lexicon("ok", False).
    }

    Return Lexicon("ok", True, "port", tgt).
}

// Plans and drops a Hohmann transfer node to TARGET (vessel) using the analytical solver in
// rendezvousModel.ks. Does not execute the burn — leaves the node for the user to review.
Global Function TuiOrbitHohmannRendezvousAction {
    If not HasTarget {
        TuiClear().
        TuiPrintAt("HOHMANN RENDEZVOUS", 0, TUI_ALIGN_CENTER).
        TuiHRule(1).
        TuiPrintAt("No target set.", 5, TUI_ALIGN_CENTER).
        TuiPrintAt("Press any key.", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
        TuiWaitAnyKey().
        Return.
    }

    Local plan to CreateHohmannInterceptNode().

    TuiClear().
    TuiPrintAt("HOHMANN RENDEZVOUS", 0, TUI_ALIGN_CENTER).
    TuiHRule(1).

    If not plan:ok {
        TuiPrintAt("PLAN FAILED:", 3, TUI_ALIGN_CENTER).
        TuiPrintAt(plan:error, 5, TUI_ALIGN_CENTER).
        TuiPrintAt("Press any key.", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
        TuiWaitAnyKey().
        Return.
    }

    Local tgtName to Target:Name.
    If tgtName:Length > 28 { Set tgtName to tgtName:Substring(0, 28). }

    TuiPrintAt(("Target: " + tgtName):PadRight(TUI_WIDTH), 3).
    TuiPrintAt(("r1:     " + Round(plan:r1, 0) + " m"):PadRight(TUI_WIDTH), 5).
    TuiPrintAt(("r2:     " + Round(plan:r2, 0) + " m"):PadRight(TUI_WIDTH), 6).
    TuiPrintAt(("Phase:  " + Round(plan:phaseNowDeg, 1) + " / " + Round(plan:phaseReqDeg, 1) + " deg"):PadRight(TUI_WIDTH), 7).
    TuiPrintAt(("Synod:  " + Round(plan:synodicPeriod, 0) + " s"):PadRight(TUI_WIDTH), 9).
    TuiPrintAt(("Wait:   " + Round(plan:wait, 0) + " s"):PadRight(TUI_WIDTH), 10).
    TuiPrintAt(("TOF:    " + Round(plan:tof, 0) + " s"):PadRight(TUI_WIDTH), 11).
    TuiPrintAt(("Burn dv:" + Round(plan:deltaV, 2) + " m/s"):PadRight(TUI_WIDTH), 13).
    TuiHRule(15).
    TuiPrintAt("Node placed. Execute manually.", 16, TUI_ALIGN_CENTER).
    TuiPrintAt("Press any key.", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
    TuiWaitAnyKey().
}

Local Function RunStationKeepingLoop {
    Parameter port.
    Parameter alignToAxis.
    Parameter title.

    Local sk to StationKeepingModel(port).
    sk:Start(alignToAxis).

    TuiClear().
    TuiHRule(1).
    Local headerId to DockingPortDisplayName(port).
    TuiPrintAt("[Enter] exit", 4).

    Terminal:Input:Clear().
    Local stopRequested to False.
    Local docking to False.
    Local dockedExit to False.

    Until stopRequested {
        sk:Update().

        Local stat to sk:GetStatus().
        Local dockReady to ReadyToDock(sk).
        Local portState to port:State.

        // Auto-exit cleanly when the target port reports Docked — magnetic capture has
        // completed and the parts have fused. sk:Stop() runs after the loop and releases
        // RCS control claims so the player can fly normally post-dock.
        If portState = "Docked" {
            Set stopRequested to True.
            Set dockedExit to True.
        }

        // Dynamic title — shows [DOCKING] suffix once the approach has been initiated.
        Local displayTitle to title.
        If docking { Set displayTitle to title + " [DOCKING]". }
        TuiPrintAt(displayTitle:PadRight(TUI_WIDTH), 0, TUI_ALIGN_CENTER).

        TuiPrintAt(("Port: " + headerId + " [" + portState + "]"):PadRight(TUI_WIDTH), 3).

        // Dynamic help line — reflects current state and docking readiness.
        Local helpLine to "H/N: axial 1m".
        If docking {
            Set helpLine to "DOCKING @ " + DOCKING_APPROACH_VEL + " m/s".
        } Else If stat:aligning And dockReady {
            Set helpLine to "H/N: axial 1m   D: DOCK NOW".
        } Else If stat:aligning {
            Set helpLine to "H/N: axial 1m   D: dock (need <0.5m)".
        }
        TuiPrintAt(helpLine:PadRight(TUI_WIDTH), 5).

        TuiPrintAt(("Range:   " + Round(stat:rangeToPort, 2) + " m"):PadRight(TUI_WIDTH), 7).
        TuiPrintAt(("Axial:   " + Round(Abs(stat:axial), 2) + " / " + Round(Abs(stat:axialSetpoint), 2) + " m"):PadRight(TUI_WIDTH), 8).
        TuiPrintAt(("AxV:     " + Round(stat:axVelMag, 2) + " / " + Round(stat:axialVelMax, 2) + " m/s"):PadRight(TUI_WIDTH), 9).
        TuiPrintAt(("Lateral: " + Round(stat:lateralMag, 2) + " / " + Round(stat:lateralSetpointMag, 2) + " m"):PadRight(TUI_WIDTH), 10).
        TuiPrintAt(("LatV:    " + Round(stat:latVelMag, 2) + " / " + Round(stat:lateralVelMax, 2) + " m/s"):PadRight(TUI_WIDTH), 11).

        If Terminal:Input:HasChar {
            Local ch to Terminal:Input:GetChar().
            If ch = Terminal:Input:Enter Or ch = Terminal:Input:Return {
                Set stopRequested to True.
            } Else If ch = "h" Or ch = "H" {
                sk:SetAxialDistance(Max(0.5, Abs(stat:axialSetpoint) - 1)).
            } Else If ch = "n" Or ch = "N" {
                sk:SetAxialDistance(Abs(stat:axialSetpoint) + 1).
            } Else If (ch = "d" Or ch = "D") And dockReady And not docking {
                BeginDocking(sk).
                Set docking to True.
            }
        }

        Wait 0.
    }

    sk:Stop().

    If dockedExit {
        TuiClear().
        TuiPrintAt(title, 0, TUI_ALIGN_CENTER).
        TuiHRule(1).
        TuiPrintAt("DOCKED", 8, TUI_ALIGN_CENTER).
        TuiPrintAt("Press any key.", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
        TuiWaitAnyKey().
    }
}

Global Function TuiOrbitStationKeepingAction {
    Local resolved to GetTargetDockingPort("STATION KEEPING").
    If not resolved:ok { Return. }
    RunStationKeepingLoop(resolved:port, False, "STATION KEEPING").
}

Global Function TuiOrbitStationKeepingAlignAction {
    Local resolved to GetTargetDockingPort("STATION KEEPING (ALIGN)").
    If not resolved:ok { Return. }
    RunStationKeepingLoop(resolved:port, True, "STATION KEEPING (ALIGN)").
}
