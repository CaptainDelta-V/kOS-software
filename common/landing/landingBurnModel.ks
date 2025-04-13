
Function LandingBurnModel { 

    Parameter RadarOffset.

    Local _radarOffset to RadarOffset.

    Lock _trueRadar to Alt:Radar - _radarOffset.
    Lock _g to Constant:G * Body:Mass / Body:Radius^2.			
    Lock _maxThrustActual to Ship:AvailableThrust.
    Lock _maxDecel to (_maxThrustActual / Ship:Mass) - _g.	
    Lock _velocityMagnitude to Ship:Velocity:Surface:Mag.
    Lock _stopDistance to _velocityMagnitude^2 / (2 * _maxDecel).		
    Lock _idealThrottle to _stopDistance / _trueRadar.					
    Lock _impactTime to _trueRadar / Abs(Ship:VerticalSpeed).	

    Function SetRadarOffset { 
        Parameter offset. 

        Set _radarOffset to offset.
    }

    Function GetRadarOffset { 
        Return _radarOffset.
    }

    Function TrueRadar { 
        Return _trueRadar.
    }

    Function Gravity { 
        Return _g.
    }

    Function MaxThrustActual { 
        Return Ship:AvailableThrust.
    }

    Function MaxDecel { 
        Return _maxDecel.
    }

    Function VelocityMagnitude { 
        Return _velocityMagnitude.
    }

    Function GetStopDistance { 
        Return _stopDistance.
    }

    Function GetSuicideBurnAltitude { 
        Return Addons:Ke:SuicideBurnAltitude().
    }

    Function LinearLandingThrottle { 
        Return _idealThrottle.
    }

    Function ImpactTime { 
        Return _impactTime.
    }
    
    Return Lexicon( 
        "SetRadarOffset", SetRadarOffset@,
        "GetRadarOffset", GetRadarOffset@,
        "TrueRadar", TrueRadar@,
        "Gravity", Gravity@, 
        "MaxThrustActual", MaxThrustActual@,
        "MaxDecel", MaxDecel@,
        "VelocityMagnitude", VelocityMagnitude@,
        "GetStopDistance", GetStopDistance@, 
        "GetSuicideBurnAltitude", GetSuicideBurnAltitude@,
        "LinearLandingThrottle", LinearLandingThrottle@,        
        "ImpactTime", ImpactTime@
    ).
}