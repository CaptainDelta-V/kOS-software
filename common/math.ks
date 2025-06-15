Function LinearFallOff {
    Parameter Rate.
    Parameter Amt.    
    Parameter MinErr is 0.        

    Return Rate * (Amt - MinErr).
}

Global Function LinearFunction { 
    Parameter M.
    Parameter X.
    Parameter B.

    Return (M * X) + B.
}

Global Function LogarithmicFunction { 
    Parameter a.
    Parameter x.
    Parameter r0.

    Return a * LN(x - r0).
}

Global Function QuadFunction { 
    Parameter a.
    Parameter m1.
    Parameter x. 
    Parameter r1.
    Parameter m2.
    Parameter r2.

    Return a * ((m1 * x) - r1) * ((m2 * x) - r2).
}