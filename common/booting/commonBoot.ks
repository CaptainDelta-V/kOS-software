SWITCH to 1.
RUNONCEPATH("0:common/booting/bootUtils").

// Local Beeper is GETVOICE(1).
// Set Beeper:Volume to 0.

Parameter DefaultBootDirectory.
Parameter DefaultBootFilename.

Local bootLogFileName to "0:logs/bootlog_" + DefaultBootFilename + "_" + Ship:Name + ".txt".
DeletePath(bootLogFileName).

Local bootDescription to "UPDATING SOFTWARE For: " + DefaultBootDirectory + " . . . ".
Log bootDescription to bootLogFileName.
Print bootDescription.

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

RunBootFile(DefaultBootFilename, bootLogFileName).