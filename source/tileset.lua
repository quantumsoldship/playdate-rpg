-- Tileset class
-- Manages tile definitions, images, and hitboxes

import "CoreLibs/object"
import "CoreLibs/graphics"

class('Tileset').extends()

function Tileset:init()
    Tileset.super.init(self)
    
    self.tiles = {}
    self.tileSize = 32
    self.images = {}
end

-- Define a tile with properties
function Tileset:defineTile(id, properties)
    self.tiles[id] = {
        id = id,
        name = properties.name or "Unnamed",
        walkable = properties.walkable ~= false, -- Default to walkable
        image = properties.image, -- Can be nil for programmatic drawing
        hitbox = properties.hitbox or {x = 0, y = 0, width = self.tileSize, height = self.tileSize},
        drawFunc = properties.drawFunc, -- Custom drawing function
        category = properties.category or "terrain"
    }
end

-- Load a tile image
function Tileset:loadTileImage(id, imagePath)
    local gfx <const> = playdate.graphics
    local image = gfx.image.new(imagePath)
    
    if image then
        self.images[id] = image
        if self.tiles[id] then
            self.tiles[id].image = image
        end
    end
    
    return image ~= nil
end

-- Get tile definition
function Tileset:getTile(id)
    return self.tiles[id]
end

-- Check if tile is walkable
function Tileset:isWalkable(id)
    local tile = self.tiles[id]
    return tile and tile.walkable
end

-- Draw a tile
function Tileset:drawTile(id, x, y)
    local tile = self.tiles[id]
    if not tile then
        return
    end
    
    -- If tile has an image, draw it
    if tile.image then
        tile.image:draw(x, y)
    -- Otherwise use custom draw function
    elseif tile.drawFunc then
        tile.drawFunc(x, y, self.tileSize)
    -- Fallback to default drawing
    else
        self:drawDefaultTile(id, x, y)
    end
end

-- Default tile drawing (fallback)
function Tileset:drawDefaultTile(id, x, y)
    local gfx <const> = playdate.graphics
    
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x, y, self.tileSize, self.tileSize)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(x, y, self.tileSize, self.tileSize)
    
    -- Draw tile ID for debugging
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantNormal))
    gfx.drawText(tostring(id), x + 4, y + 8)
end

-- Load tileset from JSON configuration
function Tileset:loadFromJSON(jsonPath)
    local json = playdate.file.readJSON(jsonPath)
    
    if not json then
        print("Error: Could not load tileset JSON from " .. jsonPath)
        return false
    end
    
    -- Load tile size if specified
    if json.tileSize then
        self.tileSize = json.tileSize
    end
    
    -- Load tile definitions
    if json.tiles then
        for _, tileData in ipairs(json.tiles) do
            self:defineTile(tileData.id, {
                name = tileData.name,
                walkable = tileData.walkable,
                image = tileData.image,
                hitbox = tileData.hitbox,
                category = tileData.category
            })
            
            -- Load image if path is specified
            if tileData.image then
                self:loadTileImage(tileData.id, tileData.image)
            end
        end
    end
    
    return true
end

-- Create default tileset with programmatic drawing
function Tileset:createDefaultTileset()
    local gfx <const> = playdate.graphics
    
    -- Grass (0)
    self:defineTile(0, {
        name = "Grass",
        walkable = true,
        category = "terrain",
        drawFunc = function(x, y, size)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(x, y, size, size)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(x, y, size, size)
            
            -- Add grass texture
            for i = 1, 3 do
                local dx = math.random(2, size - 2)
                local dy = math.random(2, size - 2)
                gfx.fillRect(x + dx, y + dy, 1, 1)
            end
        end
    })
    
    -- Water (1)
    self:defineTile(1, {
        name = "Water",
        walkable = false,
        category = "terrain",
        drawFunc = function(x, y, size)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(x, y, size, size)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawLine(x + 4, y + size / 2, x + size - 4, y + size / 2)
            gfx.drawLine(x + 4, y + size / 2 + 4, x + size - 4, y + size / 2 + 4)
        end
    })
    
    -- Tree (2)
    self:defineTile(2, {
        name = "Tree",
        walkable = false,
        category = "obstacle",
        hitbox = {x = 8, y = 8, width = 16, height = 16},
        drawFunc = function(x, y, size)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(x, y, size, size)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(x, y, size, size)
            gfx.fillCircleAtPoint(x + size / 2, y + size / 2, 8)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillCircleAtPoint(x + size / 2, y + size / 2, 3)
        end
    })
    
    -- Rock (3)
    self:defineTile(3, {
        name = "Rock",
        walkable = false,
        category = "obstacle",
        hitbox = {x = 8, y = 8, width = 16, height = 16},
        drawFunc = function(x, y, size)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(x, y, size, size)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(x, y, size, size)
            gfx.fillRect(x + 8, y + 8, 16, 16)
        end
    })
    
    -- Wall (4)
    self:defineTile(4, {
        name = "Wall",
        walkable = false,
        category = "wall",
        drawFunc = function(x, y, size)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(x, y, size, size)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawRect(x + 2, y + 2, size - 4, size - 4)
        end
    })
    
    -- Goal/Door (5)
    self:defineTile(5, {
        name = "Goal",
        walkable = true,
        category = "special",
        drawFunc = function(x, y, size)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(x, y, size, size)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(x, y, size, size)
            
            -- Draw star/diamond shape
            local centerX = x + size / 2
            local centerY = y + size / 2
            gfx.fillTriangle(
                centerX, centerY - 8,
                centerX - 8, centerY,
                centerX + 8, centerY
            )
            gfx.fillTriangle(
                centerX, centerY + 8,
                centerX - 8, centerY,
                centerX + 8, centerY
            )
        end
    })
    
    -- Door (9) - for room transitions
    self:defineTile(9, {
        name = "Door",
        walkable = true,
        category = "special",
        drawFunc = function(x, y, size)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(x, y, size, size)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(x, y, size, size)
            
            -- Draw door frame
            gfx.fillRect(x + 8, y, 16, size)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(x + 10, y + 4, 12, size - 8)
            
            -- Door handle
            gfx.setColor(gfx.kColorBlack)
            gfx.fillCircleAtPoint(x + 18, y + size / 2, 2)
        end
    })
end

-- Get all tiles in a category
function Tileset:getTilesByCategory(category)
    local result = {}
    for id, tile in pairs(self.tiles) do
        if tile.category == category then
            table.insert(result, tile)
        end
    end
    return result
end

-- Export tileset to JSON
function Tileset:exportToJSON(jsonPath)
    local exportData = {
        tileSize = self.tileSize,
        tiles = {}
    }
    
    for id, tile in pairs(self.tiles) do
        table.insert(exportData.tiles, {
            id = id,
            name = tile.name,
            walkable = tile.walkable,
            hitbox = tile.hitbox,
            category = tile.category
        })
    end
    
    return playdate.file.writeJSON(jsonPath, exportData)
end
