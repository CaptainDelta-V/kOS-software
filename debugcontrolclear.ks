@LAZYGLOBAL OFF.

// Run from the kOS terminal — `runpath("0:debugcontrolclear").` — after a station-keeping
// or other raw-control script crashes/dies without releasing its claim on Ship:Control.
// Symptoms it fixes: pilot H/N (RCS fore/aft), I/K, J/L translation, or W/S/A/D rotation
// ignored even though RCS is on.
// Safe to run anytime; just resets things to pilot-controlled neutral.

Print "Releasing all kOS control claims...".

// Cooked locks (steering, throttle, wheels) — unlock everything that might be held.
// Unlock on an unheld name is a no-op, so this is safe even if nothing was locked.
Unlock Steering.
Unlock Throttle.
Unlock WheelSteering.
Unlock WheelThrottle.

// Raw axes — zeroing each releases that single axis per kOS docs.
Set Ship:Control:Pitch         to 0.
Set Ship:Control:Yaw           to 0.
Set Ship:Control:Roll          to 0.
Set Ship:Control:Fore          to 0.
Set Ship:Control:Starboard     to 0.
Set Ship:Control:Top           to 0.
Set Ship:Control:WheelSteer    to 0.
Set Ship:Control:WheelThrottle to 0.

// Belt-and-suspenders: full neutralize, then a tick boundary so the engine processes the
// release before this script exits (otherwise the claim can persist into the next program).
Set Ship:Control:Neutralize to True.
Wait 0.

Print "Pilot input restored.".
