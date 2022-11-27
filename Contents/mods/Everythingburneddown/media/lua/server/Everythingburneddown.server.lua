local EDB_ModDataKey = "EBD_BuildingKeyIds"
local EBD = {
    RBBurntDef = nil,
}

function EBD:getBurnedDownStory()
    if self.RBBurntDef ~= nil then
        -- print('cached RBBurntDef')
        return self.RBBurntDef
    end

    for i = 0, getWorld():getRandomizedBuildingList():size() - 1 do
        local rb = getWorld():getRandomizedBuildingList():get(i);
        if rb and rb:getName() == "Burnt" then
            -- print('rb:getName(): ', rb:getName())
            return rb
        end
    end
end

function EBD:burnItAllDown(square)
    local buildingKeyIDs = ModData.getOrCreate(EDB_ModDataKey)

    if not square then
        return
    end

    local x = square:getX()
    local y = square:getY()


    if isClient() then
        return
    end

    local building = square:getBuilding()
    if not building then
        return
    end

    local buildingDef = building:getDef()
    if not buildingDef:isFullyStreamedIn() then
        return
    end

    -- Ignore if it's cached
    if buildingKeyIDs[buildingDef:getKeyId()] then
        return
    end

    print('burn down building in square [x: ' .. x .. ', y:' .. y .. '], with ID: '..tostring(buildingDef:getKeyId()))

    buildingKeyIDs[buildingDef:getKeyId()] = true
    ModData.add(EDB_ModDataKey, buildingKeyIDs)

    self.RBBurntDef:randomizeBuilding(buildingDef);
end

function EBD:LoadGridsquare(square)
    self.RBBurntDef = self:getBurnedDownStory()
    self:burnItAllDown(square)
end

Events.LoadGridsquare.Add(function(square)
    EBD:LoadGridsquare(square)
end);
