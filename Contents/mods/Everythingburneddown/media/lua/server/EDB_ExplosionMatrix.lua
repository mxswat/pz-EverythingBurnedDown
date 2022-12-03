local utils = require('EBD_Utils')

local table_bininsert = utils.table_bininsert
local normalize = utils.normalize
local distanceFromCenterOfCircle = utils.distanceFromCenterOfCircle
local lshift = utils.lshift

local TempEmptySquares = {}
local BurntVehicleScripts = {}

local scripts = getScriptManager():getAllVehicleScripts()
for i = 1, scripts:size() do
    local script = scripts:get(i - 1)
    if script:getPartCount() == 0 then
        table.insert(BurntVehicleScripts, script:getFullName())
    end
end

local function setRandomBurntVehicleScript(vehicle)
    local scriptName = BurntVehicleScripts[ZombRand(#BurntVehicleScripts) + 1]
    vehicle:setScriptName(scriptName)
    vehicle:scriptReloaded()
    vehicle:setSkinIndex(ZombRand(vehicle:getSkinCount()))
    vehicle:repair() -- so engine loudness/power/quality are recalculated
end

local function burnAndDestroy(square)
    square:getObjects():clear();
    square:getSpecialObjects():clear();

    local building = square:getBuilding()
    if building then
        building:setAllExplored(true);
        -- setRoomID -> Remove room to avoid black square in the map where a building was
        square:setRoomID(-1);
    end

    square:Burn(true)

    if square:getZ() > 0 then
        return
    end

    square:addFloor("floors_burnt_01_0")

    local vehicle = square:getVehicleContainer()
    if not vehicle then
        return
    end

    setRandomBurntVehicleScript(vehicle)
end

local function BurnSimple(square)
    -- Use square:getContainerItem() to roll the dice and maybe save the tile
    square:Burn(true)

    -- Remove Grass
    -- TODO Check ISRemoveGrass:perform()
    for i = square:getObjects():size(), 1, -1 do
        local object = square:getObjects():get(i - 1)
        if object:getProperties() and object:getProperties():Is(IsoFlagType.canBeRemoved) then
            square:transmitRemoveItemFromSquare(object)
            -- Save loops, asusme it's grass and return
            return
        end
    end
end

local function patchEmptySquares()
    for _, square in ipairs(TempEmptySquares) do
        print('square.d: '..square.d)        
    end
end

local ExplosionMatrix = {
    SquaresInExplosion = {},
}

function ExplosionMatrix:getSquaresInExplosion()
    return self.SquaresInExplosion
end

function ExplosionMatrix:calcSquareMark(normalizeDistance)
    local destroyedRange = 0.20 -- Everything burned down
    local destroyedOrBurnedRange = 0.55 -- Gradient between all destroyed, and vanilla burn
    local burnedRange = 0.75 -- Just burn
    local burnedOrIntactRange = 1
    if normalizeDistance <= destroyedRange then
        return burnAndDestroy -- Destroy all
    end
    if normalizeDistance <= destroyedOrBurnedRange then
        local chanceNormalize = normalize(normalizeDistance, destroyedOrBurnedRange, destroyedRange) * 100
        return chanceNormalize <= ZombRand(100) and burnAndDestroy or BurnSimple
    end
    if normalizeDistance <= burnedRange then
        return BurnSimple
    end
    if normalizeDistance <= burnedOrIntactRange then
        local chanceNormalize = normalize(normalizeDistance, burnedOrIntactRange, burnedRange) * 100
        return chanceNormalize <= ZombRand(100) and BurnSimple or nil
    end
end

function ExplosionMatrix:markSquareRow(x0, x1, y, cx, cy, r)
    self.SquaresInExplosion[y] = self.SquaresInExplosion[y] or {}

    local squares = self.SquaresInExplosion[y]
    for i = x1, x0, 1 do
        local distance = distanceFromCenterOfCircle(i, y, cx, cy)
        local normalizeDistance = normalize(distance, r, 0)

        squares[i] = self:calcSquareMark(normalizeDistance)

        if squares[i] == nil then
            table_bininsert(TempEmptySquares, {
                x = i,
                y = y,
                d = normalizeDistance
            }, function(a, b) return a.d < b.d end)
        end
    end
end

function ExplosionMatrix:generateExplosionCircle(cx, cy, radius)
    local x = radius - 1
    local y = 0
    local dx = 1
    local dy = 1
    local err = dx - lshift(radius, 1)

    while x >= y do
        self:markSquareRow(cx + y, cx - y, cy - x, cx, cy, radius)
        self:markSquareRow(cx + x, cx - x, cy - y, cx, cy, radius)
        self:markSquareRow(cx + x, cx - x, cy + y, cx, cy, radius)
        self:markSquareRow(cx + y, cx - y, cy + x, cx, cy, radius)

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

    patchEmptySquares()
end

return ExplosionMatrix