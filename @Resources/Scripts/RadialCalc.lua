function Initialize()
    --[[
    For each application, set the angle, endpoints, images
    --]]
    print("Initializing...")
    -- radius is the length of the line
    local radius = tonumber(SKIN:GetVariable("Radius"))
    local padding = tonumber(SKIN:GetVariable("Padding"))
    local width = tonumber(SKIN:GetVariable("Width"))
    local color = SKIN:GetVariable("Color")
    -- 
    local originX = radius + (padding/2)
    local originY = radius + (padding/2)
    local count = tonumber(SKIN:GetVariable("Applications"))
    local mode = SKIN:GetVariable("RadialMode")
    print("\tGot variables.")
    -- startSub contains both the starting angle and radias to add for each app
    print("\tGetting start/sub...")
    local startSub = GetStartSub(count, mode)
    local currentAngle = startSub["start"]
    print("\t\tGot start/sub.")
    print("\tSetting options...")
    for i=1,count do
        SetOptions(i, radius, currentAngle, originX, originY, width, color)
        currentAngle = currentAngle + startSub["subdiv"]
        print("\t\tSet app " .. i ..".")
    end
    print("\t\tDone.")
end

function SetOptions(i, radius, angle, originX, originY, width, color)
    local appCoords = GetLauncherXY(angle, radius, originX, originY)
    local lineWH = "(2*" .. radius ..")"
    local lineX = "(" .. originX .. "-" .. radius ..")"
    local lineY = "(" .. originY .. "-" .. radius ..")"
    local write = "!WriteKeyValue"
    local appMeter = "App" .. i
    local execVar = SKIN:GetVariable("App" .. i .. "Exec")
    local imagePath = "#@#\\Apps\\" .. appMeter .. "\\button.png"
    local lineMeter = appMeter .. "Line"
    local angleMeasure = appMeter .. "Measure"
    -- Set App button
    SKIN:Bang(write, appMeter, "Meter", "Button")
    SKIN:Bang(write, appMeter, "ButtonImage", imagePath)
    SKIN:Bang(write, appMeter, "ButtonCommand", execVar)
    SKIN:Bang(write, appMeter, "X", appCoords["x"])
    SKIN:Bang(write, appMeter, "Y", appCoords["y"])
    SKIN:Bang(write, appMeter, "Group", "1")
    SKIN:Bang(write, appMeter, "Hidden", "0")
    -- Set Angle measure
    SKIN:Bang(write, angleMeasure, "Measure", "Calc")
    SKIN:Bang(write, angleMeasure, "Formula", angle)
    SKIN:Bang(write, angleMeasure, "MinValue", "0")
    SKIN:Bang(write, angleMeasure, "MaxValue", "(2*PI)")
    -- Set lineMeter
    -- Hardcoded Values
    SKIN:Bang(write, lineMeter, "Meter", "Roundline")
    SKIN:Bang(write, lineMeter, "LineStart", "0")
    SKIN:Bang(write, lineMeter, "StartAngle", "(-PI/2)")
    SKIN:Bang(write, lineMeter, "RotationAngle", "(PI*2)")
    SKIN:Bang(write, lineMeter, "Solid", "0")
    SKIN:Bang(write, lineMeter, "AntiAlias", "1")
    SKIN:Bang(write, lineMeter, "Group", "1")
    SKIN:Bang(write, lineMeter, "Hidden", "0")
    -- Variable Values
    SKIN:Bang(write, lineMeter, "X", lineX)
    SKIN:Bang(write, lineMeter, "Y", lineY)
    SKIN:Bang(write, lineMeter, "W", lineWH)
    SKIN:Bang(write, lineMeter, "H", lineWH)
    SKIN:Bang(write, lineMeter, "MeasureName", angleMeasure)
    SKIN:Bang(write, lineMeter, "LineWidth", width)
    SKIN:Bang(write, lineMeter, "LineLength", radius)
    SKIN:Bang(write, lineMeter, "LineColor", color)
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
    local theta
    local coords = {}
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
    print("\t\t\tX: " .. coords["x"])
    print("\t\t\tY: " .. coords["y"])
    return coords
    --[[
    local coords = {}
    coords["y"] = math.floor((originY + radius) * math.sin(phi))
    coords["x"] = math.floor((originX + radius) * math.cos(phi))
    return coords
    --]]
end