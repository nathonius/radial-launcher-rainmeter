function Initialize()
    local phi = SELF:GetNumberOption("Phi")
    local radius = tonumber(SKIN:GetVariable("Radius"))
    local originX = radius/2
    local originY = radius/2
    local coords = GetEnds(phi, radius, originX, originY)
end

function SetAngles(count, mode)
    --[[
    Given a number of subdivisions and a mode, return a table of angles
    Valid Modes: radial (default), topright, topleft, bottomleft, bottomright
    --]]
    local angles = {}
    local start = 0
    local subdiv = math.pi/count
    --[[
    if mode == "topright" then
        start = math.pi
        subdiv = (math.pi/2)/count
    elseif mode == "topleft" then
        start = (3*math.pi/2)
        subdiv = (math.pi/2)/count
    elseif mode == "bottomleft" then
        start = 0
        subdiv = (math.pi/2)/count
    elseif mode == "bottomright" then
        start = (math.pi/2)
        subdiv = (math.pi/2)/count
    end
    --]]
    for i=2,count do
        if i == 1 then
            angles[i] = start
        else
            angles[i] = angles[i-1] + subdiv
        end
        SKIN:Bang("[!SetOption App" .. i .. " Phi " .. angles[i] .."]")
    end
end

function GetEnds(phi, radius, originX, originY)
    local theta
    local coords = {}
    -- Determine quadrant, calculate angle and x/y coords
    -- Quadrant I (+X, +Y)
    if (phi < (math.pi)/2) then
        theta = phi
        coords["x"] = math.floor(originX + (math.cos(theta) * radius))
        coords["y"] = math.floor(originY + (math.sin(theta) * radius))
    -- Quadrant II (-X, +Y)
    elseif (phi < (math.pi)) then
        theta = (math.pi-phi)
        coords["x"] = math.floor(originX - (math.cos(theta) * radius))
        coords["y"] = math.floor(originY + (math.sin(theta) * radius))
    -- Quadrant III (-X, -Y)
    elseif (phi < 3*(math.pi)/2) then
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