local explosionsList = {
    { -- muldraugh https://map.projectzomboid.com/#10753x9943x1145
        x = 10749,
        y = 9944,
        r = 50
    }
}

local function BurnMax(square)
    local floor = square:getFloor();
    square:Burn(true)
    square:ClearTileObjectsExceptFloor()
    if not floor or square:getZ() > 0 then
        return
    end
    floor:setSpriteFromName("floors_burnt_01_0");
end

local function BurnSimple(square)
    -- Use square:getContainerItem() to roll the dice and maybe save the tile
    square:Burn(true)
end

local function normalize(val, max, min)
    return (val - min) / (max - min)
end

local function squareDistanceFromExplosion(x, y, cx, cy)
    local xCalc = (x - cx) ^ 2
    local yCalc = (y - cy) ^ 2
    return math.sqrt(xCalc + yCalc);
end

local function calcSquareMark(normalizeDistance)
    local rand50 = ZombRand(2) == 0
    if normalizeDistance <= 0.3 then
        return BurnMax
    end
    if normalizeDistance <= 0.4 then
        return rand50 and BurnMax or BurnSimple
    end
    if normalizeDistance <= 0.75 then
        return BurnSimple
    end
    if normalizeDistance >= 0.75 then
        return rand50 and BurnSimple or nil
    end
end

local SquaresInExplosion = {}
local function markSquareRow(x0, x1, y, cx, cy, r)
    -- {x1: 7.5, x0: 11.5}
    SquaresInExplosion[y] = SquaresInExplosion[y] or {}

    local squares = SquaresInExplosion[y]
    for i = x1, x0, 1 do
        local distance = squareDistanceFromExplosion(i, y, cx, cy)
        local normalizeDistance = normalize(distance, r, 0)
        -- print('distance: ' .. distance .. ' normalizeDistance: ' .. normalizeDistance)

        squares[i] = calcSquareMark(normalizeDistance)
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
        markSquareRow(cx + y, cx - y, cy - x, cx, cy, radius)
        markSquareRow(cx + x, cx - x, cy - y, cx, cy, radius)
        markSquareRow(cx + x, cx - x, cy + y, cx, cy, radius)
        markSquareRow(cx + y, cx - y, cy + x, cx, cy, radius)

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

local function BurnSquare(square, explosionEffect)
    square:getModData()[ModDataIgnoreKey] = true;

    -- Apprently it's needed because of Java shitting itself and randomly dumping "local2" error
    if not IsoFire.CanAddFire(square, true) then
        return 
    end

    explosionEffect(square)
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
