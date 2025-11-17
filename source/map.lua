-- Map class
-- Manages tile-based map generation and rendering

import "CoreLibs/object"
import "CoreLibs/graphics"

class('Map').extends()

function Map:init()
    Map.super.init(self)
    
    self.width = 0
    self.height = 0
    self.tiles = {}
    self.tileSize = 16
    
    -- Tile types
    self.TILE_GRASS = 0
    self.TILE_WATER = 1
    self.TILE_TREE = 2
    self.TILE_ROCK = 3
end

-- Generate a random map
function Map:generate(width, height)
    self.width = width
    self.height = height
    self.tiles = {}
    
    -- Fill with grass
    for y = 1, height do
        self.tiles[y] = {}
        for x = 1, width do
            self.tiles[y][x] = self.TILE_GRASS
        end
    end
    
    -- Add some water
    for i = 1, math.floor(width * height * 0.05) do
        local x = math.random(1, width)
        local y = math.random(1, height)
        self.tiles[y][x] = self.TILE_WATER
    end
    
    -- Add some trees
    for i = 1, math.floor(width * height * 0.1) do
        local x = math.random(1, width)
        local y = math.random(1, height)
        if self.tiles[y][x] == self.TILE_GRASS then
            self.tiles[y][x] = self.TILE_TREE
        end
    end
    
    -- Add some rocks
    for i = 1, math.floor(width * height * 0.05) do
        local x = math.random(1, width)
        local y = math.random(1, height)
        if self.tiles[y][x] == self.TILE_GRASS then
            self.tiles[y][x] = self.TILE_ROCK
        end
    end
end

-- Check if a tile is walkable
function Map:isWalkable(x, y)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return false
    end
    
    local tile = self.tiles[y][x]
    
    -- Water, trees, and rocks are not walkable
    if tile == self.TILE_WATER or tile == self.TILE_TREE or tile == self.TILE_ROCK then
        return false
    end
    
    return true
end

-- Get tile at position
function Map:getTile(x, y)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return nil
    end
    return self.tiles[y][x]
end

-- Set tile at position
function Map:setTile(x, y, tileType)
    if x >= 1 and x <= self.width and y >= 1 and y <= self.height then
        self.tiles[y][x] = tileType
    end
end

-- Draw the map centered on player
function Map:draw(playerX, playerY)
    local gfx <const> = playdate.graphics
    local screenWidth = 400
    local screenHeight = 240
    
    -- Calculate which tiles are visible
    local tilesWide = math.ceil(screenWidth / self.tileSize) + 2
    local tilesHigh = math.ceil(screenHeight / self.tileSize) + 2
    
    local startX = playerX - math.floor(tilesWide / 2)
    local startY = playerY - math.floor(tilesHigh / 2)
    
    local offsetX = (screenWidth / 2) - (playerX * self.tileSize) + (self.tileSize / 2)
    local offsetY = (screenHeight / 2) - (playerY * self.tileSize) + (self.tileSize / 2)
    
    -- Draw tiles
    for ty = 0, tilesHigh do
        for tx = 0, tilesWide do
            local mapX = startX + tx
            local mapY = startY + ty
            
            if mapX >= 1 and mapX <= self.width and mapY >= 1 and mapY <= self.height then
                local tile = self.tiles[mapY][mapX]
                local drawX = offsetX + (mapX - 1) * self.tileSize
                local drawY = offsetY + (mapY - 1) * self.tileSize
                
                self:drawTile(tile, drawX, drawY)
            end
        end
    end
end

-- Draw a single tile
function Map:drawTile(tileType, x, y)
    local gfx <const> = playdate.graphics
    
    if tileType == self.TILE_GRASS then
        -- Draw grass (light pattern)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(x, y, self.tileSize, self.tileSize)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(x, y, self.tileSize, self.tileSize)
        
        -- Add some dots for texture
        for i = 1, 2 do
            local dx = math.random(2, self.tileSize - 2)
            local dy = math.random(2, self.tileSize - 2)
            gfx.fillRect(x + dx, y + dy, 1, 1)
        end
        
    elseif tileType == self.TILE_WATER then
        -- Draw water (dark with waves)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(x, y, self.tileSize, self.tileSize)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawLine(x + 2, y + self.tileSize / 2, x + self.tileSize - 2, y + self.tileSize / 2)
        
    elseif tileType == self.TILE_TREE then
        -- Draw tree
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(x, y, self.tileSize, self.tileSize)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(x, y, self.tileSize, self.tileSize)
        gfx.fillCircle(x + self.tileSize / 2, y + self.tileSize / 2, 5)
        
    elseif tileType == self.TILE_ROCK then
        -- Draw rock
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(x, y, self.tileSize, self.tileSize)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(x, y, self.tileSize, self.tileSize)
        gfx.fillRect(x + 4, y + 4, 8, 8)
    end
end
