local ExplosionMatrix = require('ExplosionMatrix')
local SquaresInExplosion = ExplosionMatrix.getExplosionMatrix()

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
