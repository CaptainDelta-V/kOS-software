// Wait Until Ship:Unpacked.
// DeletePath("common").
// DeletePath("uipanels").
// SWITCH to 0. 
// CopyPath("common", "1:").
// CopyPath("uipanels", "1:uipanels").
// SWITCH to 1.
// CD("uipanels").
// RUNPATH("home").

Wait Until Ship:Unpacked.
RUNONCEPATH("0:/common/booting/commonboot", "uipanels", "home").

