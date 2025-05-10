// rendezvous

// perform a sequence of maneuvers to coordinate intercept trajectory between two craft

// 1. find longitude of ascending node
// 2. chart a maneuver at the AN to increase apoapsis
// 3. wait for node
// 4. execute node
// 5. chart a maneuver at apoapsis to align inclination
// 6. wait for apoapsis
// 7. execute node
// 8. chart a maneuver at periapsis to intercept within 2.5km
// 9. wait for periapsis
// 10. execute node
// 11. wait for intercept
// 12. target-relative retrograde burn at 0.5-1km distance to zero relative velocity

// result should be two craft about 100m apart

set runmode to 1.
set errors to 0.
clearvecdraws().

until runmode = 0 {
  // complain if target is not set
  if hastarget = false {
    print "target not set!".
    set errors to 1.
    set runmode to 0.
  }

  if runmode = 1 {
    // compute LAN
    // classy option: compute using angular momentum
    set pMe to ship:position - body:position.
    set pTgt to target:position - body:position.
    set hMe to vcrs(pMe, ship:velocity:orbit).
    set hTgt to vcrs(pTgt, target:velocity:orbit).
//    set hmeArr to vecdraw(body:position, hMe, RGB(1, 1, 1), "hMe").
//    set htgtArr to vecdraw(body:position, hTgt, RGB(1, 1, 1), "hTgt").
    set relAng to vang(hMe, hTgt).
    set vAN to vcrs(hMe, hTgt).
    set anArr to vecdraw(body:position, vAN, RGB(1, 1, 1)).
//    set hmeArr:show to true.
//    set htgtArr:show to true.
    set anArr:show to true.
    print "relative inclination: " + relAng.
    print "angle to LAN " + vang(pMe, vAN).

    // attempt to resolve the time of LAN
    set td to 60.
    set toff to td.
    set angLast to vang(pMe, vAN).
    set tme to ship:orbit:period.
    set minAng to 999.
    set tMinAng to -1.
    until false {
      // compute a position at some future time and evaluate its angle to LAN
      set pf to positionat(ship, time:seconds + toff).
      set tf to positionat(target, time:seconds + toff).
      set ang to vang(pf - body:position, vAN).
      if ang < minAng {
        set minAng to ang.
        set tMinAng to time:seconds + toff.
      }
      if toff > tme {
        break.
      }
      set angLast to ang.
      set toff to toff + td.
    }

    // assumption! relative inclination is low
    // make a node at the AN to compute hohmann transfer
    set tn to node(tMinAng, 0, 0, 0).
    add tn.

    // we want to find a maneuver resulting in an orbit where we can iterate forward in time
    // until the target distance at periapsis is below 10km

    // compute the angle between me and target. use this to make an orbit with a period the same as 1+x
    // where x is the percentage of a target orbital period. wherever we burn becomes the periapsis of
    // the resulting orbit, so chart a point from the AN/DN

    set pf to positionat(ship, tMinAng) - body:position.
    set tf to positionat(target, tMinAng) - body:position.
    set taRel to vang(pf, tf).
    // angle is absolute value, never negative; need to know whether leading or lagging the target
    if vcrs(pf, tf):z < 0 {
      // lagging
      set taPerc to 1 - taRel / 360.
    }
    else {
      // leading
      set taPerc to taRel / 360.
    }
    set adjPeriod to target:orbit:period * (1 + taPerc).

    // increase the prograde delta-v until the resulting orbit has a matching period
    lock periodError to tn:orbit:period - adjPeriod.
    set periodGain to 0.05.
    until abs(periodError) < 1 {
      set tn:prograde to tn:prograde - periodError * periodGain.
      print tn:prograde + ", " + periodError.
      wait 0.1.
    }

    set runmode to 0.
  }
}

if errors {
  print "mistakes were made".
}
else {
  print "gucci".
}