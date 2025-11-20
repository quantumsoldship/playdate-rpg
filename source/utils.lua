-- Utility functions
-- Common helper functions used across the codebase

local utils = {}

-- Clamp a value between min and max
function utils.clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    end
    return value
end

-- Calculate distance between two points
function utils.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Linear interpolation between two values
function utils.lerp(a, b, t)
    return a + (b - a) * utils.clamp(t, 0, 1)
end

-- Check if a value is within a range
function utils.inRange(value, min, max)
    return value >= min and value <= max
end

-- Convert tile coordinates to pixel coordinates
function utils.tileToPixel(tileX, tileY, tileSize)
    return (tileX - 1) * tileSize + tileSize / 2, 
           (tileY - 1) * tileSize + tileSize / 2
end

-- Convert pixel coordinates to tile coordinates
function utils.pixelToTile(pixelX, pixelY, tileSize)
    return math.floor(pixelX / tileSize) + 1,
           math.floor(pixelY / tileSize) + 1
end

-- Safe division (returns 0 if denominator is 0)
function utils.safeDivide(numerator, denominator)
    if denominator == 0 then
        return 0
    end
    return numerator / denominator
end

-- Get percentage value
function utils.percentage(current, max)
    return utils.safeDivide(current, max)
end

-- Round a number to specified decimal places
function utils.round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Apply damage variance to a base power value
-- Uses the configured DAMAGE_VARIANCE to add randomness (default ±20%)
function utils.applyDamageVariance(basePower, variance)
    variance = variance or 0.2
    local minPower = basePower * (1 - variance)
    local maxPower = basePower * (1 + variance)
    return math.floor(minPower + math.random() * (maxPower - minPower))
end

-- Check if a table contains a value
function utils.tableContains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Shuffle a table in place (Fisher-Yates algorithm)
function utils.shuffleTable(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

-- Deep copy a table
function utils.deepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in pairs(original) do
            copy[utils.deepCopy(key)] = utils.deepCopy(value)
        end
    else
        copy = original
    end
    return copy
end

return utils
