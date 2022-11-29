local explosionsList = {
    { -- muldraugh https://map.projectzomboid.com/#10753x9943x1145
        x = 10749,
        y = 9944,
        r = 50
    }
}

local function normalize(val, max, min)
    return (val - min) / (max - min)
end

local function squareDistanceFromExplosion(x, y, cx, cy)
    local xCalc = (x - cx) ^ 2
    local yCalc = (y - cy) ^ 2
    return math.sqrt(xCalc + yCalc);
end

local SquaresInExplosion = {}
local function markSquares(x0, x1, y, cx, cy, r)
    -- {x1: 7.5, x0: 11.5}
    SquaresInExplosion[y] = SquaresInExplosion[y] or {}

    local squares = SquaresInExplosion[y]
    for i = x1, x0, 1 do
        local distance = squareDistanceFromExplosion(i, y, cx, cy)
        local normalizeDistance = normalize(distance, r, 0)
        -- print('distance: ' .. distance .. ' normalizeDistance: ' .. normalizeDistance)

        squares[i] = normalizeDistance
    end
end

local function lshift(x, by)
    return x * 2 ^ by
end

local function generateExplosionCircle(cx, cy, radius)
    local x = radius - 1
    local y = 0
    local dx = 1
    local dy = 1
    local err = dx - lshift(radius, 1)

    while x >= y do
        markSquares(cx + y, cx - y, cy - x, cx, cy, radius)
        markSquares(cx + x, cx - x, cy - y, cx, cy, radius)
        markSquares(cx + x, cx - x, cy + y, cx, cy, radius)
        markSquares(cx + y, cx - y, cy + x, cx, cy, radius)

        if (err <= 0) then
            y = y + 1
            err = err + dy
            dy = dy + 2
        end

        if (err > 0) then
            x = x - 1
            dx = dx + 2
            err = err + dx - lshift(radius, 1)
        end
    end

    print('generateExplosionCircle')
end

local exp = explosionsList[1]

local ceil = math.ceil
generateExplosionCircle(ceil(exp.x), ceil(exp.y), ceil(exp.r))

local ModDataIgnoreKey = "MxBurnedDown"

local function BurnSquare(square, distance)
    square:getModData()[ModDataIgnoreKey] = true;

    -- Make sprite crispy if on ground floor
    local floor = square:getFloor();
    if not floor or square:getZ() > 0 then
        return
    end
    if distance <= 0.3 then
        square:Burn(false)
        floor:setSpriteFromName("floors_burnt_01_0");
    end
    if distance <= 0.75 then
        square:Burn(false)
    end
    if distance >= 0.75 and ZombRand(2) == 0 then
        square:Burn(false)
    end
end

local function OnLoadGridSquare(square)
    if isClient() then
        return -- Must return on client!
    end

    if not square then
        return
    end

    if SquaresInExplosion[square:getY()] == nil then
        return
    end

    local explosionEffect = SquaresInExplosion[square:getY()][square:getX()]
    if explosionEffect == nil then
        return
    end

    if square:getModData()[ModDataIgnoreKey] then
        return
    end

    BurnSquare(square, explosionEffect)

    -- Burn multi floor buildings
    local upperSquare = getCell():getGridSquare(square:getX(), square:getY(), square:getZ() + 1);
    if upperSquare then
        BurnSquare(upperSquare, explosionEffect)
    end
end

Events.LoadGridsquare.Add(OnLoadGridSquare);
