local EBD = {
    RBBurntDef = nil
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

    -- randomizeBuilding(BuildingDef var1) inside RBBurnt, will set building to all explored
    -- maybe use buildingDef:getKeyId() and globbal mod data to store it between restarts instead of isAllExplored
    if building:isAllExplored() then
        return
    end
    
    local buildingDef = building:getDef()
    if not buildingDef:isFullyStreamedIn() then
        return
    end


    print('burn down building in square [x: ' .. x .. ', y:' .. y .. ']')

    self.RBBurntDef:randomizeBuilding(buildingDef);
end

function EBD:LoadGridsquare(square)
    self.RBBurntDef = self:getBurnedDownStory()
    self:burnItAllDown(square)
end

Events.LoadGridsquare.Add(function(square)
    EBD:LoadGridsquare(square)
end);
