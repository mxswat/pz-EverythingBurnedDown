local muldraughCenterX = 10749
local muldraughCenterY = 9944
local muldraughRadius = 2

local EBD = {
    ModDataKey = "EBD_BuildingKeyIds"
}

local function normalizeRadius(val, max, min)
    return (val - min) / (max - min)
end

function EBD:squareDistanceFromExplosion(square)
    local x = square:getX();
    local y = square:getY();
    local xCalc = (x - muldraughCenterX) ^ 2
    local yCalc = (y - muldraughCenterY) ^ 2
    return math.sqrt(xCalc + yCalc);
end

function EBD:isSquareInBurnedArea(square)
    return self:squareDistanceFromExplosion(square) <= muldraughRadius;
end

function EBD:burnDownSquare(square, squareDistanceFromExp)
    square:Burn(false)

    local floor = square:getFloor();
    if not floor then
        return
    end

    print('squareDistanceFromExp: '..tostring(squareDistanceFromExp))

    if squareDistanceFromExp == muldraughRadius then
        floor:setSpriteFromName("floors_interior_carpet_01_10");
        return
    end

    floor:setSpriteFromName("floors_burnt_01_0");
end

function EBD:burnItAllDown(square, skipId)
    if not square then
        return
    end

    local buildingKeyIDs = ModData.getOrCreate(self.ModDataKey)

    -- Ignore if it's cached or skipping
    local squareId = square:getX() .. ',' .. square:getY()
    if not skipId and buildingKeyIDs[squareId] then
        return
    end

    local squareDistanceFromExp = math.floor(self:squareDistanceFromExplosion(square))
    if squareDistanceFromExp >= muldraughRadius then
        return
    end

    -- Passed radius check, mark it as checked
    buildingKeyIDs[squareId] = true
    ModData.add(self.ModDataKey, buildingKeyIDs)

    self:burnDownSquare(square, squareDistanceFromExp)

    -- Ignore Z checks if the tile is not in a building
    local aboveCell = getCell():getGridSquare(square:getX(), square:getY(), square:getZ() + 1);
    if aboveCell then
        self:burnItAllDown(aboveCell, true)
    end
end

function EBD:LoadGridsquare(square)
    self:burnItAllDown(square)
end

Events.LoadGridsquare.Add(function(square)
    if isClient() then
        return -- Must return on client!
    end

    EBD:LoadGridsquare(square)
end);
