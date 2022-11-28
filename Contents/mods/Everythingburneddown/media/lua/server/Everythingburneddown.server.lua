local explosionsList = {
    { -- muldraugh
        x = 10749,
        y = 9944,
        r = 10
    }
}

local markedSquares = {}

local function markSquares(x0, x1, y)
    -- {x1: 7.5, x0: 11.5}
    markedSquares[y] = markedSquares[y] or {}

    local squares = markedSquares[y]
    for i = x1, x0, 1 do
        squares[i] = false
    end
end

local function lshift(x, by)
    return x * 2 ^ by
end

local ceil = math.ceil
local function generateExplosionCircle(cx, cy, radius)
    local x = radius - 1
    local y = 0
    local dx = 1
    local dy = 1
    local err = dx - lshift(radius, 1)

    while x >= y do
        markSquares(ceil(cx + y), ceil(cx - y), ceil(cy - x))
        markSquares(ceil(cx + x), ceil(cx - x), ceil(cy - y))
        markSquares(ceil(cx + x), ceil(cx - x), ceil(cy + y))
        markSquares(ceil(cx + y), ceil(cx - y), ceil(cy + x))

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

generateExplosionCircle(exp.x, exp.y, exp.r)

Events.LoadGridsquare.Add(function(square)
    if isClient() then
        return -- Must return on client!
    end

    if not square then
        return
    end

    if markedSquares[square:getY()] == nil then
        return
    end

    if markedSquares[square:getY()][square:getX()] == nil then
        return
    end

    square:Burn(false)

    local floor = square:getFloor();
    if not floor then
        return
    end

    floor:setSpriteFromName("floors_burnt_01_0");
end);
