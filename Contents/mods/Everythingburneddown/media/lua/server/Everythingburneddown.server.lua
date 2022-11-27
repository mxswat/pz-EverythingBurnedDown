local EDB_ModDataKey = "EBD_BuildingKeyIds"
local EBD = {
    RBBurntDef = nil,
}

function EBD:getBurnedDownStory()
    if self.RBBurntDef ~= nil then
        return self.RBBurntDef
    end

    for i = 0, getWorld():getRandomizedBuildingList():size() - 1 do
        local rb = getWorld():getRandomizedBuildingList():get(i);
        if rb and rb:getName() == "Burnt" then
            return rb
        end
    end
end

function EBD:isSquareInTownZone(square)
    local zone = square:getZone() and square:getZone():getType()
    return zone == "TownZone"
end

function EBD:burnItAllDown(square)

    local buildingKeyIDs = ModData.getOrCreate(EDB_ModDataKey)
    if isClient() then
        return -- Must return on client!
    end

    if not square then
        return
    end

    local squareId = square:getX() .. ',' .. square:getY()
    -- Ignore if it's cached
    if buildingKeyIDs[squareId] then
        return
    end

    if not self:isSquareInTownZone(square) then
        return
    end

    square:Burn(false)

    buildingKeyIDs[squareId] = true
    ModData.add(EDB_ModDataKey, buildingKeyIDs)

    local aboveCell = getCell():getGridSquare(square:getX(), square:getY(), square:getZ() + 1);
    if aboveCell then
        self:burnItAllDown(aboveCell)
    end
end

function EBD:LoadGridsquare(square)
    self.RBBurntDef = self:getBurnedDownStory()
    self:burnItAllDown(square)
end

Events.LoadGridsquare.Add(function(square)
    EBD:LoadGridsquare(square)
end);
