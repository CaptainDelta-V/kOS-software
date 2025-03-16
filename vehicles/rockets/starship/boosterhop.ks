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

Set Ship:Name to ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME.
Parameter SkipBoostback to false.
Parameter SkipWaitForInitiationMessage to true.
Parameter Debug to true.

Local engines to Ship:PartsTagged("BOOSTER_RAPTORS")[0].
Local gridFins to Ship:PartsTagged("GRID_FIN").

Local engineManagement to EngineManager(engines, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).
Local gridFinManagement to GridFinManager(gridFins, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).
Local drainValves to Ship:PartsTagged("BOOSTER_DRAIN_VALVE").
Local drainValveController to DrainValveManager(drainValves).

Local boosterRadarOffset to 63.4.
Local towerCatchAltitude to 150.
Local towerCatchOffsetAltitude to towerCatchAltitude - boosterRadarOffset.
Local suicideMargin to 222.
Local maxBurnStartAltitude to 2_800.
Local undershootMeters to -40.
Local overshootMeters to 25. // 160 is very steep
Local towerStatus to "Not CONNECTED".

Local towerVessel to Vessel(TOWER_CPU_NAME).
// Local landingSite is towerVessel:GeoPosition.
Local olmGeoPosition to LatLng(-0.0971988972860862,-74.5565400064737). // center of OLM
Local olmLandRefGeoPosition to LatLng(-0.0971957998740445,-74.5570880721982). // Inner point towards tower
Local towerBaseGeoPosition to LatLng(-0.0972415730475416,-74.5585281410506). 
Local landingSite to olmLandRefGeoPosition.
Local targetLandingSite is landingSite.
Local altitudePositionTarget to towerCatchAltitude - 90.
Local approachOvershootSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(overshootMeters):GetLandingSite().
Local rollReferenceOvershootSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(500):GetLandingSite().
Local approachSlightUndershootRefSite is LandingStatusModel(towerBaseGeoPosition, altitudePositionTarget):Overshoot(-25):GetLandingSite().
Local approachUndershootSite is LandingStatusModel(landingSite, altitudePositionTarget):Overshoot(-2_000):GetLandingSite().
Local landingStatus to LandingStatusModel(approachOvershootSite, altitudePositionTarget):Overshoot(undershootMeters).
Local landingSteering to LandingSteeringModel(landingStatus).
Local flightStatus to FlightStatusModel("SUPER HEAVY BOOSTER LANDING GUIDANCE").

