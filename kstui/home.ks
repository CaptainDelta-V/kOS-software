@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.

RUNONCEPATH("0:kstui/screen").
RUNONCEPATH("0:kstui/menu").
RUNONCEPATH("0:kstui/orbit").
RUNONCEPATH("0:kstui/aircraft").

Terminal:Input:Clear().

Local orbitMenu to TuiMenu(
    "ORBIT",
    List(
        TuiMenuItem("Hohmann Rendezvous",     TUI_MENU_KIND_ACTION, TuiOrbitHohmannRendezvousAction@),
        TuiMenuItem("Station Keeping (hold)", TUI_MENU_KIND_ACTION, TuiOrbitStationKeepingAction@),
        TuiMenuItem("Station Keeping (align)",TUI_MENU_KIND_ACTION, TuiOrbitStationKeepingAlignAction@),
        TuiMenuItem("(back)",                 TUI_MENU_KIND_BACK)
    )
).

Local launchMenu to TuiMenu(
    "LAUNCH",
    List(
        TuiMenuItem("(no actions yet)", TUI_MENU_KIND_BACK)
    )
).

Local landingMenu to TuiMenu(
    "LANDING",
    List(
        TuiMenuItem("(no actions yet)", TUI_MENU_KIND_BACK)
    )
).

Local systemsMenu to TuiMenu(
    "SYSTEMS",
    List(
        TuiMenuItem("(no actions yet)", TUI_MENU_KIND_BACK)
    )
).

Local aircraftMenu to TuiMenu(
    "AIRCRAFT",
    List(
        TuiMenuItem("Helicopter Hover", TUI_MENU_KIND_ACTION, TuiAircraftHeliHoverAction@),
        TuiMenuItem("(back)",           TUI_MENU_KIND_BACK)
    )
).

Local rootMenu to TuiMenu(
    "KSTUI :: MAIN MENU",
    List(
        TuiMenuItem("Orbit",    TUI_MENU_KIND_SUBMENU, orbitMenu),
        TuiMenuItem("Launch",   TUI_MENU_KIND_SUBMENU, launchMenu),
        TuiMenuItem("Landing",  TUI_MENU_KIND_SUBMENU, landingMenu),
        TuiMenuItem("Aircraft", TUI_MENU_KIND_SUBMENU, aircraftMenu),
        TuiMenuItem("Systems",  TUI_MENU_KIND_SUBMENU, systemsMenu),
        TuiMenuItem("Exit",     TUI_MENU_KIND_BACK)
    )
).

TuiRunMenu(rootMenu).
TuiClear().
Print "KSTUI exited.".
