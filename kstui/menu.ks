@LAZYGLOBAL OFF.
RUNONCEPATH("0:kstui/screen").

Global TUI_MENU_KIND_SUBMENU to "submenu".
Global TUI_MENU_KIND_ACTION  to "action".
Global TUI_MENU_KIND_BACK    to "back".

Global Function TuiMenuItem {
    Parameter label.
    Parameter kind.
    Parameter target is 0.   // submenu Lexicon, function delegate, or unused for BACK

    Return Lexicon(
        "label", label,
        "kind", kind,
        "target", target
    ).
}

Global Function TuiMenu {
    Parameter title.
    Parameter items.

    Return Lexicon(
        "title", title,
        "items", items
    ).
}

// Show a flat picker. Returns the selected value, or 0 on back / empty list.
Global Function TuiPickFromList {
    Parameter title.
    Parameter labels.   // List of strings
    Parameter values.   // parallel List

    If labels:Length = 0 {
        Return 0.
    }

    Local selected to 0.
    Local dirty to True.
    Terminal:Input:Clear().

    Until False {
        If dirty {
            TuiClear().
            TuiPrintAt(title, 0, TUI_ALIGN_CENTER).
            TuiHRule(1).

            From {Local i is 0.} Until i = labels:Length Step {Set i to i + 1.} Do {
                Local marker to "  ".
                If i = selected {
                    Set marker to "> ".
                }
                TuiPrintAt((marker + labels[i]):PadRight(TUI_WIDTH), 3 + i).
            }

            TuiHRule(TUI_HEIGHT - 2).
            TuiPrintAt("[Up/Dn] move  [Enter] sel  [Left] back", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
            Set dirty to False.
        }

        If Terminal:Input:HasChar {
            Local ch to Terminal:Input:GetChar().
            If ch = Terminal:Input:UpCursorOne {
                Set selected to Max(0, selected - 1).
                Set dirty to True.
            }
            Else If ch = Terminal:Input:DownCursorOne {
                Set selected to Min(labels:Length - 1, selected + 1).
                Set dirty to True.
            }
            Else If ch = Terminal:Input:LeftCursorOne {
                Return 0.
            }
            Else If ch = Terminal:Input:Enter Or ch = Terminal:Input:Return {
                Return values[selected].
            }
        }

        Wait 0.
    }
}

// Render menu, take input, dispatch. Returns when the user picks BACK or Left arrow.
Global Function TuiRunMenu {
    Parameter menu.

    Local items to menu:items.
    Local selected to 0.
    Local dirty to True.

    Terminal:Input:Clear().

    Until False {
        If dirty {
            TuiClear().
            TuiPrintAt(menu:title, 0, TUI_ALIGN_CENTER).
            TuiHRule(1).

            From {Local i is 0.} Until i = items:Length Step {Set i to i + 1.} Do {
                Local marker to "  ".
                If i = selected {
                    Set marker to "> ".
                }
                Local suffix to "".
                If items[i]:kind = TUI_MENU_KIND_SUBMENU {
                    Set suffix to "  >".
                }
                TuiPrintAt(marker + items[i]:label + suffix, 3 + i).
            }

            TuiHRule(TUI_HEIGHT - 2).
            TuiPrintAt("[Up/Dn] move  [Enter] sel  [Left] back", TUI_HEIGHT - 1, TUI_ALIGN_CENTER).
            Set dirty to False.
        }

        If Terminal:Input:HasChar {
            Local ch to Terminal:Input:GetChar().

            If ch = Terminal:Input:UpCursorOne {
                Set selected to Max(0, selected - 1).
                Set dirty to True.
            }
            Else If ch = Terminal:Input:DownCursorOne {
                Set selected to Min(items:Length - 1, selected + 1).
                Set dirty to True.
            }
            Else If ch = Terminal:Input:LeftCursorOne {
                Return.
            }
            Else If ch = Terminal:Input:Enter Or ch = Terminal:Input:Return {
                Local item to items[selected].

                If item:kind = TUI_MENU_KIND_SUBMENU {
                    TuiRunMenu(item:target).
                    Set dirty to True.
                }
                Else If item:kind = TUI_MENU_KIND_ACTION {
                    item:target:Call().
                    Terminal:Input:Clear().
                    Set dirty to True.
                }
                Else If item:kind = TUI_MENU_KIND_BACK {
                    Return.
                }
            }
        }

        Wait 0.
    }
}
