@LAZYGLOBAL OFF.
RUNONCEPATH("0:kstui/screen").
RUNONCEPATH("0:kstui/menu").
RUNONCEPATH("0:common/orbit/stationKeeping").
RUNONCEPATH("0:common/orbit/docking").
RUNONCEPATH("0:common/orbit/rendezvousModel").
RUNONCEPATH("0:common/utils/dockingPortUtils").

// Resolves the player's KSP target into a docking port. If the target IS a port (player
// right-clicked one and Set As Target), use it directly. If it's a vessel, show a picker
// over its Ready ports, labeled by DockingPortDisplayName (tag → parent part friendly
// name → UID) and distance. If no target / unrecognized target, warn and return cleanly.
Local Function GetTargetDockingPort {
    Parameter title.

    If not HasTarget {
        TuiClear().
        TuiPrintAt(title, 0, TUI_ALIGN_CENTER).
        TuiHRule(1).
        TuiPrintAt("No target set.", 5, TUI_ALIGN_CENTER).
        TuiPrintAt("Set a docking port or vessel as target in KSP first.", 7, TUI_ALIGN_CENTER).
        TuiPrintAt("Press any key.", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
        TuiWaitAnyKey().
        Return Lexicon("ok", False).
    }

    Local tgt to Target.

    If tgt:HasSuffix("PortFacing") {
        Return Lexicon("ok", True, "port", tgt).
    }

    If not tgt:HasSuffix("DockingPorts") {
        TuiClear().
        TuiPrintAt(title, 0, TUI_ALIGN_CENTER).
        TuiHRule(1).
        TuiPrintAt("Target is not a docking port or vessel.", 5, TUI_ALIGN_CENTER).
        TuiPrintAt("(type: " + tgt:TypeName + ")", 6, TUI_ALIGN_CENTER).
        TuiPrintAt("Press any key.", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
        TuiWaitAnyKey().
        Return Lexicon("ok", False).
    }

    Local ports to tgt:DockingPorts.
    Local labels to List().
    Local values to List().

    From {Local i is 0.} Until i = ports:Length Step {Set i to i + 1.} Do {
        Local prt to ports[i].
        If prt:State = "Ready" {
            Local dist to prt:NodePosition:Mag.
            Local friendlyName to DockingPortDisplayName(prt).
            If friendlyName:Length > 22 { Set friendlyName to friendlyName:Substring(0, 22). }
            Local distStr to ("" + Round(dist)):PadLeft(5) + "m".
            labels:Add(friendlyName:PadRight(22) + " " + distStr).
            values:Add(prt).
        }
    }

    If labels:Length = 0 {
        TuiClear().
        TuiPrintAt(title, 0, TUI_ALIGN_CENTER).
        TuiHRule(1).
        TuiPrintAt("No Ready ports on target vessel.", 5, TUI_ALIGN_CENTER).
        TuiPrintAt("Press any key.", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
        TuiWaitAnyKey().
        Return Lexicon("ok", False).
    }

    Local pickedPrt to TuiPickFromList("PICK PORT (part           dist)", labels, values).
    If pickedPrt = 0 { Return Lexicon("ok", False). }
    Return Lexicon("ok", True, "port", pickedPrt).
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

        // Auto-exit cleanly when the target port reports a Docked state — magnetic capture
        // has completed and the parts have fused. kOS reports this as either "Docked (docker)"
        // or "Docked (dockee)" depending on which side initiated, never just "Docked", so
        // we match by prefix. sk:Stop() runs after the loop and releases RCS control claims
        // so the player can fly normally post-dock.
        If portState:StartsWith("Docked") {
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
            Set helpLine to "H/N: axial 1m   D: dock (need <1m)".
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
