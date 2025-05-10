// ## Me
// Explain this kOS kerboscript code, try to give more descriptive variable names. It is a vessel rendezvous script for KSP vessels. 

// ## AI Assistant
// Okay, let's break down this kOS Kerboscript code. The script is designed to initiate a rendezvous sequence between your currently controlled vessel (`ship`) and a designated `target` vessel in Kerbal Space Program.

// It appears to be focused on the initial steps, specifically calculating and setting up the first major maneuver node to start phasing the orbits.

// Here's an explanation of the script, along with suggestions for more descriptive variable names:

// **Overall Goal:**

// The script aims to calculate and create the first maneuver node needed to begin synchronizing the orbit of the player's ship with a target vessel. It focuses on:

// 1.  Calculating the relative inclination between the two orbits.
// 2.  Finding the time until the ship reaches the Ascending Node (AN) or Descending Node (DN) relative to the target's orbit.
// 3.  Creating a maneuver node at that AN/DN.
// 4.  Calculating the necessary prograde burn at that node to adjust the ship's orbital period, so it catches up to or waits for the target correctly over subsequent orbits (phasing).

// **Code Breakdown & Variable Renaming:**


// rendezvous

// [Comments describing the full planned sequence - good!]

// Initialization
set executionMode to 1. // Was: runmode. Represents the current stage or mode of the script. 1 seems to be the initial calculation phase.
set errorFlag to 0.     // Was: errors. Tracks if any errors occurred. 0 = no errors, 1 = error.
clearvecdraws().        // Clears any previously drawn debug vectors in the flight scene.

// Main loop - continues as long as executionMode is not 0
until executionMode = 0 {

  // Pre-check: Ensure a target is selected
  if hastarget = false {
    print "Target not set!".
    set errorFlag to 1.     // Set the error flag
    set executionMode to 0. // Stop the script
  }

  // --- Phase 1: Calculate Initial Phasing Burn ---
  if executionMode = 1 {
    // --- Calculate Relative Inclination and Ascending/Descending Node ---
    // Get position vectors relative to the central body
    set shipPositionRelativeToBody to ship:position - body:position.      // Was: pMe
    set targetPositionRelativeToBody to target:position - body:position. // Was: pTgt

    // Calculate orbital momentum vectors (proportional to angular momentum)
    // The cross product of position and orbital velocity gives a vector normal to the orbital plane.
    set shipMomentumVector to vcrs(shipPositionRelativeToBody, ship:velocity:orbit).     // Was: hMe
    set targetMomentumVector to vcrs(targetPositionRelativeToBody, target:velocity:orbit). // Was: hTgt

    // Calculate the angle between the two orbital planes (relative inclination)
    set relativeInclination to vang(shipMomentumVector, targetMomentumVector). // Was: relAng

    // Calculate the Ascending/Descending Node vector.
    // This vector points along the line where the orbital planes intersect.
    set nodeVector to vcrs(shipMomentumVector, targetMomentumVector). // Was: vAN
    // Draw the node vector in the flight scene for visualization
    set nodeVectorArrow to vecdraw(body:position, nodeVector, RGB(1, 1, 1), "Node Vector"). // Was: anArr
    set nodeVectorArrow:show to true. // Was: anArr:show

    print "Relative inclination: " + relativeInclination.
    // Calculate the current angle between the ship's position and the Node vector
    print "Angle to Node: " + vang(shipPositionRelativeToBody, nodeVector).

    // --- Find Time to Next Node Crossing ---
    // Search forward in time to find when the ship is closest to the node line.
    set timeStepSeconds to 60.                  // Was: td. How far to step forward in time for each check.
    set timeOffsetSeconds to timeStepSeconds. // Was: toff. The current time offset being checked.
    // set previousAngleToNode to vang(shipPositionRelativeToBody, nodeVector). // Was: angLast (Seems unused in the loop logic below)
    set shipOrbitalPeriod to ship:orbit:period. // Was: tme. Used as a limit for the search.
    set minimumAngleToNode to 999.              // Was: minAng. Stores the smallest angle found so far.
    set timeOfMinimumAngle to -1.               // Was: tMinAng. Stores the time corresponding to the minimum angle.

    // Loop to check future positions
    until false { // This loop relies on the 'break' condition inside
      // Predict ship's position at the future time
      set futureShipPosition to positionat(ship, time:seconds + timeOffsetSeconds). // Was: pf
      // Calculate the angle between the future position and the node vector
      set angleAtFutureTime to vang(futureShipPosition - body:position, nodeVector). // Was: ang

      // If this angle is the smallest found so far, store it and the time
      if angleAtFutureTime < minimumAngleToNode {
        set minimumAngleToNode to angleAtFutureTime.
        set timeOfMinimumAngle to time:seconds + timeOffsetSeconds.
      }

      // Stop searching if we've checked beyond one full orbit of the ship
      if timeOffsetSeconds > shipOrbitalPeriod {
        break.
      }

      // set previousAngleToNode to angleAtFutureTime. // Update for next iteration (if it were used)
      set timeOffsetSeconds to timeOffsetSeconds + timeStepSeconds. // Increment the time offset
    }
    // timeOfMinimumAngle now holds the predicted time of the next node crossing (AN or DN).

    // --- Create Maneuver Node at the Node Crossing ---
    // Assumption: Script assumes relative inclination is low enough that this first burn
    // primarily handles phasing, not the inclination change yet.
    print "Creating node at time: " + timeOfMinimumAngle.
    set phasingManeuverNode to node(timeOfMinimumAngle, 0, 0, 0). // Was: tn. Creates an empty node.
    add phasingManeuverNode. // Adds the node to the flight plan.

    // --- Calculate Required Period Change for Phasing ---
    // Determine the relative angle (phase angle) between ship and target AT the maneuver time.
    set shipPositionAtNodeTime to positionat(ship, timeOfMinimumAngle) - body:position.      // Was: pf
    set targetPositionAtNodeTime to positionat(target, timeOfMinimumAngle) - body:position. // Was: tf
    set phaseAngleDegrees to vang(shipPositionAtNodeTime, targetPositionAtNodeTime).       // Was: taRel

    local phaseAngleRatio. // Was: taPerc. Represents the fraction of an orbit the ship needs to gain/lose.
    // Determine if the ship is leading or lagging the target
    if vcrs(shipPositionAtNodeTime, targetPositionAtNodeTime):z < 0 {
      // Ship is lagging the target (cross product Z component is negative in KSP's coordinate system)
      // Need a shorter period to catch up. The ratio is (360 - phaseAngle) / 360.
      print "Lagging target by " + phaseAngleDegrees + " degrees."
      set phaseAngleRatio to 1 - phaseAngleDegrees / 360.
    }
    else {
      // Ship is leading the target
      // Need a longer period to let the target catch up. The ratio is phaseAngle / 360.
      print "Leading target by " + phaseAngleDegrees + " degrees."
      set phaseAngleRatio to phaseAngleDegrees / 360.
    }
    // Calculate the desired orbital period after the burn.
    // This uses Hohmann transfer principles: change the period by a fraction related
    // to the phase angle to ensure rendezvous after a certain number of orbits.
    set targetOrbitalPeriod to target:orbit:period.
    set desiredPostBurnPeriod to targetOrbitalPeriod * (1 + phaseAngleRatio). // Was: adjPeriod
    print "Target Period: " + targetOrbitalPeriod.
    print "Desired Period: " + desiredPostBurnPeriod.

    // --- Iteratively Adjust Prograde Burn to Achieve Desired Period ---
    // Lock the calculation of the period error to the node's predicted orbit period
    lock periodCalculationError to phasingManeuverNode:orbit:period - desiredPostBurnPeriod. // Was: periodError
    set adjustmentGain to 0.05. // Was: periodGain. A tuning factor for how quickly to adjust the burn.
    print "Adjusting node prograde burn...".
    // Loop until the predicted period is very close (within 1 second) to the desired period
    until abs(periodCalculationError) < 1 {
      // Adjust the prograde component of the node.
      // If periodError is positive (period too long), subtract from prograde (reduce apoapsis).
      // If periodError is negative (period too short), add to prograde (increase apoapsis).
      set phasingManeuverNode:prograde to phasingManeuverNode:prograde - periodCalculationError * adjustmentGain.
      // Print intermediate values for debugging
      // print "Node Prograde: " + phasingManeuverNode:prograde + ", Period Error: " + periodCalculationError.
      wait 0. // Wait a physics tick to allow KSP to recalculate the node's orbit
    }
    unlock periodCalculationError. // Release the lock
    print "Node prograde set to: " + phasingManeuverNode:prograde.
    print "Predicted period after burn: " + phasingManeuverNode:orbit:period.

    // --- End of Phase 1 ---
    print "Initial phasing node created.".
    set executionMode to 0. // Move to the next state (or end the script in this case)
  }
} // End of main loop

// Final Status Message
if errorFlag = 1 { // Check the error flag
  print "Script finished with errors.". // Was: "mistakes were made"
}
else {
  print "Script finished successfully.". // Was: "gucci"
}


// **Summary of Changes:**

// *   `runmode` -> `executionMode`: Clearer that it controls the script's execution flow/state.
// *   `errors` -> `errorFlag`: More standard programming term for a boolean-like flag.
// *   `pMe` -> `shipPositionRelativeToBody`: Explicitly states what the vector represents.
// *   `pTgt` -> `targetPositionRelativeToBody`: Same explicitness for the target.
// *   `hMe` -> `shipMomentumVector`: Describes the physical quantity being calculated (proportional to angular momentum).
// *   `hTgt` -> `targetMomentumVector`: Same for the target.
// *   `relAng` -> `relativeInclination`: Standard orbital mechanics term.
// *   `vAN` -> `nodeVector`: Describes the vector pointing along the line of nodes (AN/DN).
// *   `anArr` -> `nodeVectorArrow`: Clarifies it's a visual representation (arrow).
// *   `td` -> `timeStepSeconds`: Specifies the unit and purpose.
// *   `toff` -> `timeOffsetSeconds`: Clearer purpose and unit.
// *   `angLast` -> `previousAngleToNode`: Describes its intended (though seemingly unused) purpose.
// *   `tme` -> `shipOrbitalPeriod`: Explicitly states the value.
// *   `minAng` -> `minimumAngleToNode`: Clearer what minimum value is being tracked.
// *   `tMinAng` -> `timeOfMinimumAngle`: Clearer what time is being stored.
// *   `pf` -> `futureShipPosition` / `shipPositionAtNodeTime`: More descriptive based on context.
// *   `tf` -> `targetPositionAtNodeTime`: More descriptive.
// *   `ang` -> `angleAtFutureTime`: Clearer context.
// *   `tn` -> `phasingManeuverNode`: Describes the node's purpose.
// *   `taRel` -> `phaseAngleDegrees`: Standard term for the angle between two orbiting objects.
// *   `taPerc` -> `phaseAngleRatio`: Describes the calculated ratio used for period adjustment.
// *   `adjPeriod` -> `desiredPostBurnPeriod`: Explains what the calculated period represents.
// *   `periodError` -> `periodCalculationError`: More specific about what error is being calculated.
// *   `periodGain` -> `adjustmentGain`: More general term for the tuning factor.

// This refactoring makes the script significantly easier to understand by clearly stating the purpose of each variable in its name. The core logic remains the same.
