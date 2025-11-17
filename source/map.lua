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
    self.tileSize = 32
    
    -- Tile types
    self.TILE_GRASS = 0
    self.TILE_WATER = 1
    self.TILE_TREE = 2
    self.TILE_ROCK = 3
    self.TILE_WALL = 4
end

-- Generate a room-based map (Undertale-style)
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
    
    -- Create room boundaries (walls around the edges)
    for x = 1, width do
        self.tiles[1][x] = self.TILE_WALL
        self.tiles[height][x] = self.TILE_WALL
    end
    for y = 1, height do
        self.tiles[y][1] = self.TILE_WALL
        self.tiles[y][width] = self.TILE_WALL
    end
    
    -- Add interior decorations (fewer, more purposeful)
    -- Add some water features
    for i = 1, math.floor(width * height * 0.03) do
        local x = math.random(2, width - 1)
        local y = math.random(2, height - 1)
        self.tiles[y][x] = self.TILE_WATER
    end
    
    -- Add some trees
    for i = 1, math.floor(width * height * 0.08) do
        local x = math.random(2, width - 1)
        local y = math.random(2, height - 1)
        if self.tiles[y][x] == self.TILE_GRASS then
            self.tiles[y][x] = self.TILE_TREE
        end
    end
    
    -- Add some rocks
    for i = 1, math.floor(width * height * 0.04) do
        local x = math.random(2, width - 1)
        local y = math.random(2, height - 1)
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
    
    -- Water, trees, rocks, and walls are not walkable
    if tile == self.TILE_WATER or tile == self.TILE_TREE or tile == self.TILE_ROCK or tile == self.TILE_WALL then
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
        for i = 1, 3 do
            local dx = math.random(2, self.tileSize - 2)
            local dy = math.random(2, self.tileSize - 2)
            gfx.fillRect(x + dx, y + dy, 1, 1)
        end
        
    elseif tileType == self.TILE_WATER then
        -- Draw water (dark with waves)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(x, y, self.tileSize, self.tileSize)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawLine(x + 4, y + self.tileSize / 2, x + self.tileSize - 4, y + self.tileSize / 2)
        gfx.drawLine(x + 4, y + self.tileSize / 2 + 4, x + self.tileSize - 4, y + self.tileSize / 2 + 4)
        
    elseif tileType == self.TILE_TREE then
        -- Draw tree
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(x, y, self.tileSize, self.tileSize)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(x, y, self.tileSize, self.tileSize)
        gfx.fillCircleAtPoint(x + self.tileSize / 2, y + self.tileSize / 2, 8)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(x + self.tileSize / 2, y + self.tileSize / 2, 3)
        
    elseif tileType == self.TILE_ROCK then
        -- Draw rock
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(x, y, self.tileSize, self.tileSize)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(x, y, self.tileSize, self.tileSize)
        gfx.fillRect(x + 8, y + 8, 16, 16)
        
    elseif tileType == self.TILE_WALL then
        -- Draw wall (solid black)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(x, y, self.tileSize, self.tileSize)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRect(x + 2, y + 2, self.tileSize - 4, self.tileSize - 4)
    end
end
