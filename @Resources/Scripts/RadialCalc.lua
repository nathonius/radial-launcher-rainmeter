function Initialize()
    --[[
    For each application, set the angle, endpoints, images
    --]]
    -- radius is the length of the line
    local radius = tonumber(SKIN:GetVariable("Radius"))
    local padding = tonumber(SKIN:GetVariable("Padding"))/2
    local width = tonumber(SKIN:GetVariable("Width"))
    local color = SKIN:GetVariable("Color")
    local originX = radius + (padding)
    local originY = radius + (padding)
    local count = tonumber(SKIN:GetVariable("Applications"))
    local mode = SKIN:GetVariable("RadialMode")
    -- startSub contains both the starting angle and radial amount to add for each app
    local startSub = GetStartSub(count, mode)
    local currentAngle = startSub["start"]
    -- Now clear out the include file
    local includePath = SELF:GetOption("IncludeFile")
    local includeFile = io.open(SKIN:MakePathAbsolute(includePath), "w")
    includeFile:write("; ************************************************************ ;\n")
    includeFile:write("; THIS FILE IS PROCEDURALLY GENERATED AND WILL BE OVERWRITTEN! ;\n")
    includeFile:write("; ************************************************************ ;\n")
    includeFile:close()
    for i=1,count do
        SetOptions(i, radius, currentAngle, originX, originY, width, color, includePath)
        currentAngle = currentAngle + startSub["subdiv"]
    end
end

function SetOptions(i, radius, angle, originX, originY, width, color, path)
    local appCoords = GetLauncherXY(angle, radius, originX, originY)
    local lineWH = "(2*" .. radius ..")"
    local lineX = "(" .. originX .. "-" .. radius ..")"
    local lineY = "(" .. originY .. "-" .. radius ..")"
    local write = "!WriteKeyValue"
    local appMeter = "App" .. i
    local execVar = SKIN:GetVariable("App" .. i .. "Exec")
    local imagePath = "#@#Apps\\" .. appMeter .. "\\button.png"
    local lineMeter = appMeter .. "Line"
    local angleMeasure = appMeter .. "Measure"
    -- Set Angle measure
    SKIN:Bang(write, angleMeasure, "Measure", "Calc", path)
    SKIN:Bang(write, angleMeasure, "Formula", angle, path)
    SKIN:Bang(write, angleMeasure, "MinValue", "0", path)
    SKIN:Bang(write, angleMeasure, "MaxValue", "(2*PI)", path)
    -- Set lineMeter
    -- Hardcoded Values
    SKIN:Bang(write, lineMeter, "Meter", "Roundline", path)
    SKIN:Bang(write, lineMeter, "LineStart", "0", path)
    SKIN:Bang(write, lineMeter, "StartAngle", "(-PI/2)", path)
    SKIN:Bang(write, lineMeter, "RotationAngle", "(PI*2)", path)
    SKIN:Bang(write, lineMeter, "Solid", "0", path)
    SKIN:Bang(write, lineMeter, "AntiAlias", "1", path)
    SKIN:Bang(write, lineMeter, "Group", "1", path)
    SKIN:Bang(write, lineMeter, "Hidden", "1", path)
    -- Variable Values
    SKIN:Bang(write, lineMeter, "X", lineX, path)
    SKIN:Bang(write, lineMeter, "Y", lineY, path)
    SKIN:Bang(write, lineMeter, "W", lineWH, path)
    SKIN:Bang(write, lineMeter, "H", lineWH, path)
    SKIN:Bang(write, lineMeter, "MeasureName", angleMeasure, path)
    SKIN:Bang(write, lineMeter, "LineWidth", width, path)
    SKIN:Bang(write, lineMeter, "LineLength", radius, path)
    SKIN:Bang(write, lineMeter, "LineColor", color, path)
    -- Set App button
    SKIN:Bang(write, appMeter, "Meter", "Button", path)
    SKIN:Bang(write, appMeter, "ButtonImage", imagePath, path)
    SKIN:Bang(write, appMeter, "ButtonCommand", execVar, path)
    SKIN:Bang(write, appMeter, "X", appCoords["x"], path)
    SKIN:Bang(write, appMeter, "Y", appCoords["y"], path)
    SKIN:Bang(write, appMeter, "Group", "1", path)
    SKIN:Bang(write, appMeter, "Hidden", "1", path)
end

function GetStartSub(count, mode)
    local a = {}
    if mode == "topright" then
        a["start"] = math.pi
        a["subdiv"] = (math.pi/2)/count
    elseif mode == "topleft" then
        a["start"] = (3*math.pi/2)
        a["subdiv"] = (math.pi/2)/count
    elseif mode == "bottomleft" then
        a["start"] = 0
        a["subdiv"] = (math.pi/2)/count
    elseif mode == "bottomright" then
        a["start"] = (math.pi/2)
        a["subdiv"] = (math.pi/2)/count
    else -- radial
        a["start"] = 0
        a["subdiv"] = (2*math.pi)/count
    end
    return a
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