Local TARGET_LNG to -63.6. //-62.33.
Local TARGET_LAT to 0.

Local METERS_PER_DEGREE to Ship:Body:Radius * 2 * Constant:Pi / 360.

Local AVERAGESPEED to 0.
Local SPEEDLOOP to PidLoop(0.01, 0.01, 0.005, 0, 1).
Set SPEEDLOOP:SetPoint to 50.
Until false
{
	Local POS to Ship:GeoPosition.
	Local DX to (TARGET_LNG - POS:lng) * METERS_PER_DEGREE.
	Local DY to (TARGET_LAT - POS:lat) * METERS_PER_DEGREE.
	Local DS to SQRT(DX * DX + DY * DY).
	Set SPEEDLOOP:SetPoint to Min(50, DS / 100).
	Lock Throttle to SPEEDLOOP:Update(Time:Seconds, Ship:GRoundSPEED).
	Local SPEED to Ship:GRoundSPEED.
	Set AVERAGESPEED to (AVERAGESPEED * 99 + SPEED) / 100.
	Local TTA to DS / (AVERAGESPEED + 0.01).
	
	If DS / (Ship:GRoundSPEED + 0.01) < 20
		Break.
		
	Local YAXIS to NORTH:Vector().
	Local XAXIS to VectorCrossProduct(Up:Vector(), YAXIS).
	Local STEER to (XAXIS * DX + YAXIS * DY):Normalized().
	Lock Steering to STEER.
	
	// Set AXIS1 to VecDraw(V(0, 0, 0), XAXIS, RGB(255, 0, 0), "X-AXIS", 50, true, 0.1).
	// Set AXIS2 to VecDraw(V(0, 0, 0), YAXIS, RGB(0, 255, 0), "Y-AXIS", 50, true, 0.1).
	// Set AXIS3 to VecDraw(V(0, 0, 0), STEER, RGB(0, 0, 255), "STEER", 50, true, 0.1).
	
	ClearScreen.
	
	Local MINUTES to Round(TTA / 60 - 0.5, 0).
	Local Seconds to Round(TTA - MINUTES * 60, 0).
	Local MSTR to "".
	Local SSTR to "".
	If MINUTES < 10
		Set MSTR to "0".
	If Seconds < 10
		Set SSTR to "0".
	Print "Time to ARRIVAL: " + MSTR + MINUTES + ":" + SSTR + Seconds.
}

Wait 1.
BRAKES ON.
Lock Throttle to 0.
Set Ship:Control:PilotMainThrottle to 0.
Wait 1.
SAS OFF.