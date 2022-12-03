-- Sauce: http://lua-users.org/wiki/BinaryInsert
local fcomp_default = function(a, b) return a < b end

local utils = {
    table_bininsert = function(t, value, fcomp)
        -- Initialise compare function
        local fcomp = fcomp or fcomp_default
        --  Initialise numbers
        local iStart, iEnd, iMid, iState = 1, #t, 1, 0
        -- Get insert position
        while iStart <= iEnd do
            -- calculate middle
            iMid = math.floor((iStart + iEnd) / 2)
            -- compare
            if fcomp(value, t[iMid]) then
                iEnd, iState = iMid - 1, 0
            else
                iStart, iState = iMid + 1, 1
            end
        end
        table.insert(t, (iMid + iState), value)
        return (iMid + iState)
    end,
    normalize = function(val, max, min)
        return (val - min) / (max - min)
    end,
    distanceFromCenterOfCircle = function(x, y, cx, cy)
        local xCalc = (x - cx) ^ 2
        local yCalc = (y - cy) ^ 2
        return math.sqrt(xCalc + yCalc);
    end,
    lshift = function(x, by)
        return x * 2 ^ by
    end
}


return utils
