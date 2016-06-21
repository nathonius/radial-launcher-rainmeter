dofile("saveTable.lua")
function Initialize()
	--[[
	Calculates each frame of the animations beforehand. Frames are saved in a 
	text file using the saveTable.lua script.
	where each row represents one frame for each line/application, the first
	column is the length of the line, and the other columns represent each
	application launcher
	--]]
	local mode = SKIN:GetVariable("AnimationMode")
	local speed = tonumber(SKIN:GetVariable("AnimationSpeed"))
	local count = tonumber(SKIN:GetVariable("Applications"))
	local radius = tonumber(SKIN:GetVariable("Radius"))
	local padding = tonumber(SKIN:GetVariable("Padding"))
	local origin = {}
    origin["x"] = radius + (padding)
    origin["y"] = radius + (padding)
    -- Clear the animation frame reference file
    local framePath = SKIN:MakePathAbsolute(SELF:GetOption("FrameFile"))
    local frameFile = io.open(framePath, "w")
    frameFile:close()
    CalculateFrames(mode, speed, count, radius, padding, origin, framePath)
end

function CalculateFrames(mode, speed, count, radius, padding, origin, path)
	--[[
	First, calculate the number of frames needed based on the speed as well as
	the step on each frame based on the mode
	--]]
	-- We want this to be a float for the step
	local DEFAULT_NUM_FRAMES = 1000.0
	local numFrames = DEFAULT_NUM_FRAMES / speed
	-- Calculate line lengths
	frames = {}
	local step = radius/numFrames
	-- Now we need this to be an int
	numFrames = math.floor(numFrames)
	-- Write the number of frames to the frames table
	frames["count"] = numFrames
	local total = 0
	for i=1,numFrames do
		frames[i] = {}
		frames[i][1] = math.floor(total)
		total = total + step
	end
	-- Change the lengths if using a log scale
	if mode == "logarithmic" then
		-- TODO
	elseif mode == "logreverse" then
		-- TODO
	end
	-- Make sure we reach the full length, even if we have to fudge the last
	-- step a bit
	frames[numFrames][1] = radius
	--[[
	Now, for each application, figure out where it should be each frame. We
	retrieve the angle from the skin and do some trig.
	--]]
	for i=1,count do
		local lineMeasure = SKIN:GetMeter("App" .. i .. "Measure")
		local angle = lineMeasure:GetOption("Formula")
		for j=1,numFrames do
			local r = frames[j]["r"]
			local coords = GetLauncherXY(angle, r, origin["x"], origin["y"])
			frames[j][i] = coords
		end
	end
	-- Save the frames to a file
	assert(table.save(frames, path) == nil)
end

function GetLauncherXY(phi, radius, originX, originY)
    --[[
    Translate the real angle into a useful right triangle angle in quadrant I, 
    called theta, then use that to calcuate the x,y values in quadrant I.
    Then, based on the original angle, add or subtract the x and y values from
    the origin point to get the real position.
    --]]
    -- phi = actual angle
    -- theta = effective angle
    phi = phi - math.pi/2
    local theta
    local coords = {}
    -- the 35 is the width/height of the icons im using. need to fix this.
    originX = originX - 35
    originY = originY - 35
    -- Determine quadrant, calculate angle and x/y coords
    -- Quadrant I (+X, +Y)
    if (phi <= (math.pi)/2) then
        theta = phi
        coords["x"] = math.floor(originX + (math.cos(theta) * radius))
        coords["y"] = math.floor(originY + (math.sin(theta) * radius))
    -- Quadrant II (-X, +Y)
    elseif (phi <= (math.pi)) then
        theta = (math.pi-phi)
        coords["x"] = math.floor(originX - (math.cos(theta) * radius))
        coords["y"] = math.floor(originY + (math.sin(theta) * radius))
    -- Quadrant III (-X, -Y)
    elseif (phi <= 3*(math.pi)/2) then
        theta = (phi-math.pi)
        coords["x"] = math.floor(originX - (math.cos(theta) * radius))
        coords["y"] = math.floor(originY - (math.sin(theta) * radius))
    -- Quadrant IV (+X, -Y)
    else
        theta = ((2*math.pi)-phi)
        coords["x"] = math.floor(originX + (math.cos(theta) * radius))
        coords["y"] = math.floor(originY - (math.sin(theta) * radius))
    end
    return coords
end

function Update()
	--[[
	For each frame, load the line length and x/y coords of each application, set
	them, then redraw.
	--]]
	local apps = tonumber(SKIN:GetOption("Applications"))
	local framePath = SKIN:MakePathAbsolute(SELF:GetOption("FrameFile"))
	local frames,err = table.load(framePath)
	local count = frames["count"]
	for i=1,count do
		local r = frames[i]["r"]
		-- Set new params
		for j=1,apps do
			local appMeter = "App" .. j
			local lineMeter = appMeter .. "Line"
			SKIN:Bang("!SetVariable", lineMeter, "LineLength", r)
			SKIN:Bang("!SetVariable", appMeter, "X", frames[i][j]["x"])
			SKIN:Bang("!SetVariable", appMeter, "Y", frames[i][j]["y"])
		end
		-- Redraw all
		-- SKIN:Bang("!RedrawGroup")
	end
end