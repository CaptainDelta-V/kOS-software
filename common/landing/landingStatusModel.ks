@LAZYGLOBAL OFF.
RUNONCEPATH("1:common/nav").


Function LandingStatusModel {    
    Parameter TargetLandingSite is Ship:GeoPosition.    
    Parameter TargetAltitude is 0.
    Parameter UsePositionOverTrajectory is false.  
    Parameter UseCCAT is false. 

    Local _landingSite to TargetLandingSite.
    Local _targetAltitude to TargetAltitude.
    Local _usePositionOverTrajectory to UsePositionOverTrajectory.
    Local _ccat to Lexicon().

    Local _mostRecentTrajectory to LatLnt(0,0).

    Local _metersPerDegree to Ship:Body:Radius * 2 * Constant:Pi / 360.        

    Function SetUsePositionOverTrajectory { 
        Parameter state. 
        Set _usePositionOverTrajectory to state. 
    }
    
    Function GetImpact {        
        If _usePositionOverTrajectory {
            // Return Ship:GeoPosition:AltitudePosition(POSITION_ALTITUDE).
            Local lat to Ship:GeoPosition:Lat.
            Local lng to Ship:GeoPosition:Lng .            
            Return LatLng(lat, lng).
        }
        If UseCCAT { 
            // Throw("got here").?

            // check for latest trajectory message
            // _ccat:SingleIteration().
            // Return _ccat:GetFinalPosition():GeoPosition().
            Return _mostRecentTrajectory.
        }
        If Addons:TR:HasImpact { 
            Return Addons:TR:ImpactPos. 
        }

        Return Ship:GeoPosition.
    }

    Function GetTargetAltitude { 
        Return _targetAltitude.
    }

    Function SetTargetAltitude { 
        Parameter newTargetAltitude. 
        Set _targetAltitude to newTargetAltitude.
    }
    
    Function LongitudeError {
        Return GetImpact():Lng - _landingSite:Lng.
    }
    
    Function LatitudeError {
        Return GetImpact():Lat - _landingSite:Lat.
    }

    Function TrajectoryErrorMeters { 
        Return ErrorVector():Mag.
    }

    Function PositionErrorMeters { 
        Local lat to Ship:GeoPosition:Lat.
        Local lng to Ship:GeoPosition:Lng.            
        Return (LatLng(Lat, Lng):Position - _landingSite:Position):Mag.
    }

    Function SpeedLatitude { 
        Return Ship:Velocity:Surface:Z.
    }

    Function SpeedLongitude { 
        Return Ship:Velocity:Surface:Y.
    }

    Function RetrogradeHeading { 
        Return HeadingOfVector(-Ship:Velocity:Surface).
    }

    Function RetrogradePitch { 
        Return PitchOfVector(-Ship:Velocity:Surface).
    }

    Function ErrorVector {        
        Return GetImpact():AltitudePosition(_targetAltitude) - _landingSite:AltitudePosition(_targetAltitude).        
    }

    Function ErrorVectorAtHorizon { 
        Local radialOut to (Ship:Body:Position - Ship:Position):Normalized. 
        Local targetVector to ErrorVector():Normalized().        

        Local projectionOntoRadialOut to (VectorDotProduct(targetVector, radialOut)) * radialOut.
        Return (targetVector - projectionOntoRadialOut):Normalized.
    }

    Function HeadingFromImpactToTarget { Return HeadingOfVector(-ErrorVector()). }

    Function Eccentricity { Return Ship:Orbit:Eccentricity. }

    Function Overshoot {
        Parameter meters is 0.
        Local overshootUnitVector is VectorExclude(Up:Vector, _landingSite:AltitudePosition(_targetAltitude)):Normalized.
        Local overshootPosition is _landingSite:Position + meters * overshootUnitVector.

        Return LandingStatusModel(Body:GeoPositionOf(overshootPosition), _targetAltitude).
    }

    Function Offset { 
        Parameter latMeters. 
        Parameter lngMeters.

        Local latOffsetMeters to latMeters / _metersPerDegree.
        Local lngOffsetMeters to lngMeters / _metersPerDegree.

        Local latOffsetDegrees to _landingSite:lat + latOffsetMeters.
        Local lngOffsetDegrees to _landingSite:lng + lngOffsetMeters.    
        Local offsetPosition to LatLng(latOffsetDegrees, lngOffsetDegrees):Position.        

        Return LandingStatusModel(Body:GeoPositionOf(offsetPosition), _targetAltitude).
    }
    
    Function GetLandingSite { 
        Parameter useAltitudePosition to false.          
        If useAltitudePosition {
            Return _landingSite:AltitudePosition(_targetAltitude).
        }
        Return _landingSite.
    }

    Function SetLandingSite { 
        Parameter newLandingSite.
        Set _landingSite to newLandingSite.
    }

    Return Lexicon(
        "SetUsePositionOverTrajectory", SetUsePositionOverTrajectory@,
        "GetImpact", GetImpact@,
        "GetTargetAltitude", GetTargetAltitude@, 
        "SetTargetAltitude", SetTargetAltitude@,
        "LongitudeError", LongitudeError@,
        "LatitudeError", LatitudeError@,
        "TrajectoryErrorMeters", TrajectoryErrorMeters@,
        "PositionErrorMeters", PositionErrorMeters@,
        "SpeedLatitude", SpeedLatitude@,
        "SpeedLongitude", SpeedLongitude@,
        "RetrogradeHeading", RetrogradeHeading@, 
        "RetrogradePitch", RetrogradePitch@,
        "ErrorVector", ErrorVector@,
        "ErrorVectorAtHorizon", ErrorVectorAtHorizon@,
        "HeadingFromImpactToTarget", HeadingFromImpactToTarget@,
        "ECCENTRICITY", Eccentricity@,
        "Overshoot", Overshoot@,
        "Offset", Offset@,
        "GetLandingSite", GetLandingSite@,
        "SetLandingSite", SetLandingSite@
    ).
}