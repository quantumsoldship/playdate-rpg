-- DungeonGenerator class
-- Generates procedural dungeon layouts with rooms and corridors
-- Inspired by Enter the Gungeon

import "CoreLibs/object"
import "CoreLibs/graphics"

class('DungeonGenerator').extends()

function DungeonGenerator:init()
    DungeonGenerator.super.init(self)
    
    -- Grid-based room placement
    self.gridWidth = 5
    self.gridHeight = 5
    self.roomGrid = {}
    
    -- Room templates
    self.roomTemplates = {
        -- Small rooms
        {width = 8, height = 6, type = "small"},
        {width = 6, height = 8, type = "small"},
        {width = 7, height = 7, type = "small"},
        
        -- Medium rooms
        {width = 10, height = 8, type = "medium"},
        {width = 8, height = 10, type = "medium"},
        {width = 9, height = 9, type = "medium"},
        
        -- Large rooms
        {width = 12, height = 10, type = "large"},
        {width = 10, height = 12, type = "large"},
        {width = 11, height = 11, type = "large"},
    }
end

-- Generate a dungeon floor
function DungeonGenerator:generate(roomCount)
    roomCount = roomCount or 6
    
    -- Initialize grid
    self.roomGrid = {}
    for y = 1, self.gridHeight do
        self.roomGrid[y] = {}
        for x = 1, self.gridWidth do
            self.roomGrid[y][x] = nil
        end
    end
    
    -- Place rooms using random walk
    local rooms = {}
    local startX = math.floor(self.gridWidth / 2) + 1
    local startY = math.floor(self.gridHeight / 2) + 1
    
    -- Place starting room
    local startRoom = self:createRoom(startX, startY, "start")
    table.insert(rooms, startRoom)
    self.roomGrid[startY][startX] = startRoom
    
    -- Place additional rooms
    local attempts = 0
    local maxAttempts = roomCount * 10
    
    while #rooms < roomCount and attempts < maxAttempts do
        attempts = attempts + 1
        
        -- Pick a random existing room
        local baseRoom = rooms[math.random(#rooms)]
        
        -- Try to place a room adjacent to it
        local directions = {
            {dx = 1, dy = 0},  -- right
            {dx = -1, dy = 0}, -- left
            {dx = 0, dy = 1},  -- down
            {dx = 0, dy = -1}  -- up
        }
        
        -- Shuffle directions
        for i = #directions, 2, -1 do
            local j = math.random(i)
            directions[i], directions[j] = directions[j], directions[i]
        end
        
        -- Try each direction
        for _, dir in ipairs(directions) do
            local newX = baseRoom.gridX + dir.dx
            local newY = baseRoom.gridY + dir.dy
            
            if self:canPlaceRoom(newX, newY) then
                local roomType = (#rooms == roomCount - 1) and "exit" or "normal"
                local newRoom = self:createRoom(newX, newY, roomType)
                table.insert(rooms, newRoom)
                self.roomGrid[newY][newX] = newRoom
                
                -- Connect to base room
                self:connectRooms(baseRoom, newRoom, dir)
                break
            end
        end
    end
    
    return rooms
end

-- Check if we can place a room at grid position
function DungeonGenerator:canPlaceRoom(x, y)
    if x < 1 or x > self.gridWidth or y < 1 or y > self.gridHeight then
        return false
    end
    
    return self.roomGrid[y][x] == nil
end

-- Create a room at grid position
function DungeonGenerator:createRoom(gridX, gridY, roomType)
    -- Pick random template
    local template = self.roomTemplates[math.random(#self.roomTemplates)]
    
    -- Modify size for special rooms
    if roomType == "start" then
        template = {width = 10, height = 8, type = "start"}
    elseif roomType == "exit" then
        template = {width = 12, height = 10, type = "exit"}
    end
    
    local room = {
        gridX = gridX,
        gridY = gridY,
        width = template.width,
        height = template.height,
        type = roomType,
        tiles = {},
        doors = {}, -- Doors to other rooms
        enemies = {},
        items = {}
    }
    
    -- Generate room layout
    self:generateRoomLayout(room)
    
    return room
end

-- Generate the tile layout for a room
function DungeonGenerator:generateRoomLayout(room)
    local width = room.width
    local height = room.height
    
    -- Initialize with grass
    for y = 1, height do
        room.tiles[y] = {}
        for x = 1, width do
            room.tiles[y][x] = 0 -- Grass
        end
    end
    
    -- Create walls around perimeter
    for x = 1, width do
        room.tiles[1][x] = 4 -- Wall
        room.tiles[height][x] = 4 -- Wall
    end
    for y = 1, height do
        room.tiles[y][1] = 4 -- Wall
        room.tiles[y][width] = 4 -- Wall
    end
    
    -- Add interior obstacles based on room type
    if room.type == "normal" then
        self:addNormalRoomObstacles(room)
    elseif room.type == "exit" then
        -- Place exit door
        room.tiles[2][width - 1] = 5 -- Goal tile
    end
end

-- Add obstacles to normal rooms
function DungeonGenerator:addNormalRoomObstacles(room)
    local width = room.width
    local height = room.height
    
    -- Add some random obstacles (trees, rocks, water)
    local obstacleCount = math.random(2, 5)
    
    for i = 1, obstacleCount do
        local x = math.random(2, width - 1)
        local y = math.random(2, height - 1)
        
        -- Skip center area for player spawn
        if math.abs(x - width/2) > 2 or math.abs(y - height/2) > 2 then
            local obstacleType = math.random(1, 3)
            room.tiles[y][x] = obstacleType
        end
    end
end

-- Connect two rooms with a door
function DungeonGenerator:connectRooms(room1, room2, direction)
    -- Add door to room1
    local door1 = {
        room = room2,
        direction = direction
    }
    table.insert(room1.doors, door1)
    
    -- Add door to room2 (opposite direction)
    local door2 = {
        room = room1,
        direction = {dx = -direction.dx, dy = -direction.dy}
    }
    table.insert(room2.doors, door2)
    
    -- Place door tiles in rooms
    self:placeDoorInRoom(room1, direction)
    self:placeDoorInRoom(room2, {dx = -direction.dx, dy = -direction.dy})
end

-- Place a door tile in a room
function DungeonGenerator:placeDoorInRoom(room, direction)
    local width = room.width
    local height = room.height
    local doorX, doorY
    
    if direction.dx == 1 then
        -- Right wall
        doorX = width
        doorY = math.floor(height / 2)
    elseif direction.dx == -1 then
        -- Left wall
        doorX = 1
        doorY = math.floor(height / 2)
    elseif direction.dy == 1 then
        -- Bottom wall
        doorX = math.floor(width / 2)
        doorY = height
    else
        -- Top wall
        doorX = math.floor(width / 2)
        doorY = 1
    end
    
    -- Replace wall with door (tile 9)
    room.tiles[doorY][doorX] = 9
    
    -- Store door position
    table.insert(room.doors, {x = doorX, y = doorY, direction = direction})
end

-- Get room at grid position
function DungeonGenerator:getRoomAt(gridX, gridY)
    if gridY < 1 or gridY > self.gridHeight or gridX < 1 or gridX > self.gridWidth then
        return nil
    end
    return self.roomGrid[gridY][gridX]
end
