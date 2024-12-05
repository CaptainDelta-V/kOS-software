Function LinearFallOff {
    Parameter Rate.
    Parameter Amt.    
    Parameter MinErr is 0.        

    Return Rate * (Amt - MinErr).
}

Function LinearFunction { 
    Parameter M.
    Parameter X.
    Parameter B.

    Return (M * X) + B.
}