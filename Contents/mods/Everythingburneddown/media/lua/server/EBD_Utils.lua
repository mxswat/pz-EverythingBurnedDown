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
    end
}


return utils