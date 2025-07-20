@LAZYGLOBAL OFF.
Wait Until Ship:Unpacked.
RUNONCEPATH("constants").
RUNONCEPATH("../../../common/exceptions").
RUNONCEPATH("../../../common/constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/landing/landingStatusModel").
RUNONCEPATH("../../../common/landing/landingSteeringModel").
RUNONCEPATH("../../../common/landing/landingBurnModel").
RUNONCEPATH("../../../common/landing/gridFinManager").
RUNONCEPATH("../../../common/landing/boostbackBurnController").
RUNONCEPATH("../../../common/flight/hover").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/systems/drainValveManager").




Local radarOffset to 25. 
Local towerCatchAltitude to 150. // ASL reference
Local altitudePositionTarget to towerCatchAltitude - 90.

// tower positions need recalculated once in air
Local towerVessel to Vessel(TOWER_CPU_NAME).
Local towerBaseGeoPosition to towerVessel:GeoPosition.
Local olmGeoPosition to LandingStatusModel(towerBaseGeoPosition, altitudePositionTarget):Overshoot(olmTowerBaseOffsetMeters):GetLandingSite().
Local olmLandRefGeoPosition to LandingStatusModel(towerBaseGeoPosition, altitudePositionTarget):Overshoot(-2):GetLandingSite(). // Inner point towards tower

Local landingStatus to LandingStatusModel(towerBaseGeoPosition, altitudePositionTarget):Overshoot(undershootMeters).
Local flightStatus to FlightStatusModel("STARSHIP HOP").

flightStatus:AddField("TOWER CONNECTION", { Return towerVessel:Connection:IsConnected.}).
flightStatus:AddField("TARGET COORDS", { 
    Local site to landingStatus:GetLandingSite().
    Return site:lat + "," + site:lng.
}).
flightStatus:AddField("LATITUDE ERROR", landingStatus:LatitudeError@).
flightStatus:AddField("LONGITUDE ERROR", landingStatus:LongitudeError@).
flightStatus:AddField("TRAJECTORY ERROR (m)", landingStatus:TrajectoryErrorMeters@).
flightStatus:AddField("POSITION ERROR (m)", landingStatus:PositionErrorMeters@).