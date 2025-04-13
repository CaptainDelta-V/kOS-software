SWITCH to 1.
RUNONCEPATH("0:common/booting/bootUtils").

// Local Beeper is GETVOICE(1).
// Set Beeper:Volume to 0.

Parameter DefaultBootDirectory.
Parameter DefaultBootFilename.

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

RunBootFile(DefaultBootFilename).