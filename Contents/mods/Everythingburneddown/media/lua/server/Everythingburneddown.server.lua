local ExplosionMatrix = require('EDB_ExplosionMatrix')
local SquaresInExplosion = ExplosionMatrix:getSquaresInExplosion()

local ModDataIgnoreKey = "MxBurnedDown"

local function BurnSquare(square, explosionEffect)
    square:getModData()[ModDataIgnoreKey] = true;

    -- Apprently it's needed because of Java shitting itself and randomly dumping "local2" error
    -- This should not be necessary anymore
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

    local X = square: getX()
    local Y = square: getY()
    local Z = square: getZ()

    if SquaresInExplosion[Y] == nil then
        return
    end

    local explosionEffect = SquaresInExplosion[Y][X]
    if explosionEffect == nil then
        return
    end

    if square:getModData()[ModDataIgnoreKey] then
        return
    end

    BurnSquare(square, explosionEffect)

    -- Burn multi floor buildings
    local upperSquare = getCell():getGridSquare(X, Y, Z + 1);
    if upperSquare then
        BurnSquare(upperSquare, explosionEffect)
    end
end

Events.LoadGridsquare.Add(OnLoadGridSquare);

local explosionsList = {
    { -- muldraugh https://map.projectzomboid.com/#10753x9943x1145
        x = 10749,
        y = 9944,
        r = 100
    }
}

local exp = explosionsList[1]

local ceil = math.ceil
ExplosionMatrix:generateExplosionCircle(ceil(exp.x), ceil(exp.y), ceil(exp.r))