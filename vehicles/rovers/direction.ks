
Print "DIRECTION TEST PROGRAM".



Until false {    

    Set TARGET_LNGD_SITE to TARGET:GeoPosition:Position.
    Set CURR_LNDG_SITE to Ship:GeoPosition:Position. // tragectory
    
    Set DIFF to TARGET_LNGD_SITE - CURR_LNDG_SITE.

    Set DIST to DIFF:Mag.
    Set DIRECT to DIFF:DIRECTION.    

    ClearScreen.

    Print "CURRENT Position: " + CURR_LNDG_SITE.
    Print "TARGET COORDS: " + TARGET_LNGD_SITE.

    Print "From Ship:".
    Print "    Diff Raw: " + DIFF.
    Print "    Distance : " + DIST.
    Print "    Direction: " + DIRECT.
    Print "        Pitch: " + DIRECT:Pitch.
    Print "   DIFF X: " + DIFF:X + " Y: " + DIFF:Y + " Z: " + DIFF:Z.

    Wait 0.25.
}


