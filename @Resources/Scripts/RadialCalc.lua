function GetTheta(phi)
	if (phi < (math.pi)/2) then
		return phi
	else if (phi < (math.pi)) then
		return (math.pi-phi)
	else if (phi < 3*(math.pi)/2) then
		return (phi-math.pi)
	else
		return ((2*math.pi)-phi)
	end
end

function Initialize()
	local phi = SELF:GetNumberOption("Phi")
	local LauncherMeter = SKIN:GetMeter("LauncherButton")
	local radius = tonumber(SKIN:GetVariable("Radius"))
	local originX = Radius/2
	local originY = Radius/2
end