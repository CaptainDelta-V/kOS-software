SWITCH to 1.
RUNONCEPATH("0:common/booting/bootUtils").

Global ALTERNATE_BOOT_INDICATOR_FILE to "1:ALT_BOOT.txt".

Parameter DefaultBootDirectory.
Parameter DefaultBootFilename.
Parameter bootParam0 is "".
Parameter bootParam1 is "".
Parameter bootParam2 is "".

Print "UPDATING SOFTWARE For: " + DefaultBootDirectory + " . . . ".

SWITCH to 1.
DeletePath("common").
DeletePath("vehicles").
DeletePath("uipanels").
SWITCH to 0. 
CopyPath("common", "1:common").
CopyPath("uipanels", "1:uipanels").
CopyPath(DefaultBootDirectory, "1:" + DefaultBootDirectory).
SWITCH to 1.
CD(DefaultBootDirectory).

CheckAltBootFile().

RunWithParams(DefaultBootFilename, bootParam0, bootParam1, bootParam2).
