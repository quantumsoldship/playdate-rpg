-- Map class
-- Manages tile-based map generation and rendering

import "CoreLibs/object"
import "CoreLibs/graphics"
import "tileset"

class('Map').extends()

function Map:init(tileset)
    Map.super.init(self)
    
    self.width = 0
    self.height = 0
    self.tiles = {}
    
    -- Use provided tileset or create default one
    self.tileset = tileset or Tileset()
    if not tileset then
        self.tileset:createDefaultTileset()
    end
    
    self.tileSize = self.tileset.tileSize
    
    -- Tile types (for backward compatibility)
    self.TILE_GRASS = 0
    self.TILE_WATER = 1
    self.TILE_TREE = 2
    self.TILE_ROCK = 3
    self.TILE_WALL = 4
    self.TILE_GOAL = 5  -- Exit/Door tile for progression
    
    -- Goal position
    self.goalX = 0
    self.goalY = 0
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
    
    -- Add goal/exit door at opposite side from spawn (top-right)
    self.goalX = width - 1
    self.goalY = 2
    self.tiles[self.goalY][self.goalX] = self.TILE_GOAL
end

-- Load map from JSON file
function Map:loadFromJSON(jsonPath)
    local json = playdate.file.readJSON(jsonPath)
    
    if not json then
        print("Error: Could not load map from " .. jsonPath)
        return false
    end
    
    self.width = json.width or 12
    self.height = json.height or 10
    
    -- Load tiles
    if json.tiles then
        self.tiles = json.tiles
    end
    
    -- Load goal position
    if json.goal then
        self.goalX = json.goal.x
        self.goalY = json.goal.y
    end
    
    return true
end

-- Export map to JSON
function Map:exportToJSON(jsonPath)
    local exportData = {
        width = self.width,
        height = self.height,
        tiles = self.tiles,
        goal = {
            x = self.goalX,
            y = self.goalY
        }
    }
    
    return playdate.file.writeJSON(jsonPath, exportData)
end

-- Check if a tile is walkable
function Map:isWalkable(x, y)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return false
    end
    
    local tile = self.tiles[y][x]
    return self.tileset:isWalkable(tile)
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
    self.tileset:drawTile(tileType, x, y)
end
