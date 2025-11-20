-- Basic RPG Game for Playdate
-- Main game loop and initialization

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Import game modules
import "config"
import "utils"
import "player"
import "tileset"
import "map"
import "dungeon"
import "enemy"
import "combat"
import "ui"

local gfx <const> = playdate.graphics
local config = import "config"
local utils = import "utils"

-- Game state
local gameState = "explore" -- States: explore, combat, menu
local player = nil
local currentMap = nil
local tileset = nil
local dungeonGenerator = nil
local currentDungeon = nil
local currentRoom = nil
local currentRoomEnemies = {}
local roomCleared = false
local enemies = {}
local currentEnemy = nil
local combatSystem = nil
local ui = nil
local floorNumber = 1  -- Track dungeon floor
local debugMode = false  -- Toggle with SELECT button

-- Initialize game
function initialize()
    -- Set up graphics
    gfx.setBackgroundColor(gfx.kColorWhite)
    
    -- Create tileset
    tileset = Tileset()
    tileset:createDefaultTileset()
    
    -- Try to load custom tileset if available
    local customTilesetPath = "data/tileset.json"
    if playdate.file.exists(customTilesetPath) then
        print("Loading custom tileset...")
        tileset:loadFromJSON(customTilesetPath)
    end
    
    -- Load enemy sprites if available
    local enemySpritesPath = "data/enemy_sprites.json"
    if playdate.file.exists(enemySpritesPath) then
        print("Loading custom enemy sprites...")
        Enemy.loadSpritesFromJSON(enemySpritesPath)
    end
    
    -- Create player
    player = Player()
    
    -- Create dungeon generator
    dungeonGenerator = DungeonGenerator()
    
    -- Create UI
    ui = UI(player, floorNumber)
    
    -- Generate first floor
    generateNewFloor()
    
    print("RPG Game Initialized!")
    print("Defeat all enemies to unlock doors!")
end

-- Generate a new dungeon floor
function generateNewFloor()
    print("Generating Floor " .. floorNumber .. "...")
    
    -- Generate dungeon (use config value)
    currentDungeon = dungeonGenerator:generate(config.DUNGEON_ROOMS_PER_FLOOR)
    
    if not currentDungeon or #currentDungeon == 0 then
        error("Failed to generate dungeon floor")
    end
    
    -- Start in first room
    currentRoom = currentDungeon[1]
    loadRoom(currentRoom)
    
    -- Place player at spawn point (center of room, in pixels)
    local spawnX = currentRoom.width * config.TILE_SIZE / 2
    local spawnY = currentRoom.height * config.TILE_SIZE / 2
    player:setPosition(spawnX, spawnY)
end

-- Load a room
function loadRoom(room)
    currentRoom = room
    roomCleared = false
    
    -- Create map from room data
    currentMap = Map(tileset)
    currentMap.width = room.width
    currentMap.height = room.height
    currentMap.tiles = room.tiles
    
    -- Find goal position if this is exit room
    if room.type == "exit" then
        for y = 1, room.height do
            for x = 1, room.width do
                if room.tiles[y][x] == 5 then
                    currentMap.goalX = x
                    currentMap.goalY = y
                end
            end
        end
    end
    
    -- Spawn enemies in room (if not already cleared)
    if not room.cleared then
        spawnEnemiesInRoom(room)
    else
        currentRoomEnemies = {}
        roomCleared = true
    end
    
    -- Update UI
    ui.roomNumber = floorNumber
end

-- Spawn enemies in the current room
function spawnEnemiesInRoom(room)
    currentRoomEnemies = {}
    
    if not room then
        print("Warning: Cannot spawn enemies in nil room")
        return
    end
    
    -- Don't spawn enemies in start room
    if room.type == "start" then
        roomCleared = true
        return
    end
    
    -- Spawn enemies based on room type and floor
    local enemyCount = config.INITIAL_ENEMY_COUNT
    if room.type == "large" then
        enemyCount = 3
    elseif room.type == "exit" then
        enemyCount = 4 -- Boss room
    end
    
    -- Scale with floor number
    enemyCount = enemyCount + math.floor(floorNumber / 2)
    
    for i = 1, enemyCount do
        local enemy = Enemy("Slime", floorNumber)
        
        -- Random pixel position in room (not on walls, not too close to player)
        local x, y
        local attempts = 0
        repeat
            x = math.random(3, room.width - 2) * config.TILE_SIZE
            y = math.random(3, room.height - 2) * config.TILE_SIZE
            attempts = attempts + 1
        until (checkWalkablePixel(x, y) and 
               math.abs(x - player.pixelX) + math.abs(y - player.pixelY) > config.MIN_ENEMY_SPAWN_DISTANCE) or
              attempts > config.ENEMY_SPAWN_ATTEMPTS
        
        if attempts <= config.ENEMY_SPAWN_ATTEMPTS then
            enemy.pixelX = x
            enemy.pixelY = y
            enemy.x = math.floor(x / config.TILE_SIZE) + 1
            enemy.y = math.floor(y / config.TILE_SIZE) + 1
            table.insert(currentRoomEnemies, enemy)
        end
    end
    
    print("Spawned " .. #currentRoomEnemies .. " enemies in room")
end

-- Check if a pixel position is walkable
function checkWalkablePixel(pixelX, pixelY)
    if not currentMap then
        return false
    end
    
    local tileX = math.floor(pixelX / config.TILE_SIZE) + 1
    local tileY = math.floor(pixelY / config.TILE_SIZE) + 1
    return currentMap:isWalkable(tileX, tileY)
end

-- Check if room is cleared
function checkRoomCleared()
    if roomCleared then
        return true
    end
    
    -- Check if all enemies are defeated
    local allDefeated = true
    for _, enemy in ipairs(currentRoomEnemies) do
        if enemy:isAlive() then
            allDefeated = false
            break
        end
    end
    
    if allDefeated then
        roomCleared = true
        currentRoom.cleared = true
        print("Room cleared! Doors unlocked!")
        return true
    end
    
    return false
end

-- Update function called every frame
function playdate.update()
    playdate.timer.updateTimers()
    
    if gameState == "explore" then
        updateExplore()
    elseif gameState == "combat" then
        updateCombat()
    end
    
    -- Draw everything
    draw()
end

-- Update during exploration
function updateExplore()
    -- Handle smooth movement (continuous, not just on button press)
    local dx, dy = 0, 0
    
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        dy = -player.speed
    elseif playdate.buttonIsPressed(playdate.kButtonDown) then
        dy = player.speed
    end
    
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        dx = -player.speed
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then
        dx = player.speed
    end
    
    -- Normalize diagonal movement (use config value)
    if dx ~= 0 and dy ~= 0 then
        dx = dx * config.DIAGONAL_MOVEMENT_FACTOR
        dy = dy * config.DIAGONAL_MOVEMENT_FACTOR
    end
    
    -- Try to move
    if dx ~= 0 or dy ~= 0 then
        tryMovePlayerSmooth(dx, dy)
    end
    
    -- Toggle debug mode with SELECT button
    if playdate.buttonJustPressed(playdate.kButtonSelect) then
        debugMode = not debugMode
        print("Debug mode: " .. (debugMode and "ON" or "OFF"))
    end
end

-- Try to move player with smooth pixel-based movement
function tryMovePlayerSmooth(dx, dy)
    local newX = player.pixelX + dx
    local newY = player.pixelY + dy
    
    -- Check collision with walls and obstacles
    if checkCollision(newX, newY) then
        return -- Can't move, blocked
    end
    
    -- Move player
    player:movePixels(dx, dy)
    
    -- Check for door transitions
    local doorTile = getTileAtPixel(player.pixelX, player.pixelY)
    if doorTile == 9 then
        if not roomCleared then
            -- Can't use door yet
            -- Push player back
            player:movePixels(-dx, -dy)
            return
        else
            -- Transition through door
            transitionThroughDoorPixel()
            return
        end
    end
    
    -- Check for goal
    if doorTile == 5 then
        if roomCleared then
            advanceToNextFloor()
        end
        return
    end
    
    -- Check for enemy encounters (on same tile)
    checkEnemyEncounter()
end

-- Check collision at pixel position
function checkCollision(pixelX, pixelY)
    if not player or not currentMap then
        return true -- Block movement if critical data missing
    end
    
    local playerBounds = {
        x = pixelX - player.size / 2,
        y = pixelY - player.size / 2,
        width = player.size,
        height = player.size
    }
    
    -- Check multiple points around player
    local checkPoints = {
        {x = playerBounds.x, y = playerBounds.y}, -- Top-left
        {x = playerBounds.x + playerBounds.width, y = playerBounds.y}, -- Top-right
        {x = playerBounds.x, y = playerBounds.y + playerBounds.height}, -- Bottom-left
        {x = playerBounds.x + playerBounds.width, y = playerBounds.y + playerBounds.height}, -- Bottom-right
        {x = pixelX, y = pixelY} -- Center
    }
    
    for _, point in ipairs(checkPoints) do
        local tileX = math.floor(point.x / config.TILE_SIZE) + 1
        local tileY = math.floor(point.y / config.TILE_SIZE) + 1
        
        if not currentMap:isWalkable(tileX, tileY) then
            -- Check if it's a door (doors are walkable when room is cleared)
            local tile = currentMap:getTile(tileX, tileY)
            if tile == 9 and roomCleared then
                -- Door is unlocked, allow passage
            else
                return true -- Collision detected
            end
        end
    end
    
    return false -- No collision
end

-- Get tile at pixel position
function getTileAtPixel(pixelX, pixelY)
    if not currentMap then
        return nil
    end
    
    local tileX = math.floor(pixelX / config.TILE_SIZE) + 1
    local tileY = math.floor(pixelY / config.TILE_SIZE) + 1
    return currentMap:getTile(tileX, tileY)
end

-- Check for enemy encounters
function checkEnemyEncounter()
    if not currentRoomEnemies then
        return
    end
    
    for i, enemy in ipairs(currentRoomEnemies) do
        if enemy:isAlive() then
            -- Check if player is close to enemy (use utility function)
            local distance = utils.distance(player.pixelX, player.pixelY, enemy.pixelX, enemy.pixelY)
            
            if distance < config.ENEMY_ENCOUNTER_DISTANCE then
                startCombat(enemy)
                return
            end
        end
    end
end

-- Get player spawn position at opposite door based on entry direction
-- @param room: Room to spawn player in
-- @param entryDirection: Direction player entered from {dx, dy}
-- @return: pixelX, pixelY coordinates for player spawn
local function getOppositeDoorPosition(room, entryDirection)
    local centerX = room.width * config.TILE_SIZE / 2
    local centerY = room.height * config.TILE_SIZE / 2
    
    if entryDirection.dx == 1 then
        -- Entered from left, spawn at left side
        return config.TILE_SIZE, centerY
    elseif entryDirection.dx == -1 then
        -- Entered from right, spawn at right side
        return (room.width - 1) * config.TILE_SIZE, centerY
    elseif entryDirection.dy == 1 then
        -- Entered from top, spawn at top
        return centerX, config.TILE_SIZE
    else
        -- Entered from bottom, spawn at bottom
        return centerX, (room.height - 1) * config.TILE_SIZE
    end
end

-- Transition through door (pixel-based)
function transitionThroughDoorPixel()
    if not currentRoom then
        print("Warning: Cannot transition - no current room")
        return
    end
    
    -- Determine which wall we're closest to
    local direction = nil
    local roomWidth = currentRoom.width * config.TILE_SIZE
    local roomHeight = currentRoom.height * config.TILE_SIZE
    
    -- Check distances to each wall
    local distLeft = player.pixelX
    local distRight = roomWidth - player.pixelX
    local distTop = player.pixelY
    local distBottom = roomHeight - player.pixelY
    
    local minDist = math.min(distLeft, distRight, distTop, distBottom)
    
    if minDist == distLeft then
        direction = {dx = -1, dy = 0}
    elseif minDist == distRight then
        direction = {dx = 1, dy = 0}
    elseif minDist == distTop then
        direction = {dx = 0, dy = -1}
    else
        direction = {dx = 0, dy = 1}
    end
    
    if direction then
        -- Find connected room
        local nextRoom = dungeonGenerator:getRoomAt(
            currentRoom.gridX + direction.dx,
            currentRoom.gridY + direction.dy
        )
        
        if nextRoom then
            print("Entering new room...")
            loadRoom(nextRoom)
            
            -- Place player at opposite door using helper function
            local spawnX, spawnY = getOppositeDoorPosition(nextRoom, direction)
            player:setPosition(spawnX, spawnY)
        end
    end
end

-- Old tile-based movement function (kept for compatibility)
function tryMovePlayer(dx, dy)
    -- Convert to pixel movement (use config for tile size)
    tryMovePlayerSmooth(dx * config.TILE_SIZE, dy * config.TILE_SIZE)
end

-- Transition through a door to another room
-- Advance to next floor
function advanceToNextFloor()
    floorNumber = floorNumber + 1
    print("Entering Floor " .. floorNumber .. "!")
    
    -- Heal player slightly as reward
    player:heal(10)
    
    -- Generate new floor
    generateNewFloor()
    
    -- Update UI with new floor number
    ui.roomNumber = floorNumber
end

-- Start combat
function startCombat(enemy)
    gameState = "combat"
    currentEnemy = enemy
    combatSystem = Combat(player, enemy)
    print("Combat started with " .. enemy.name .. "!")
end

-- Update during combat
function updateCombat()
    if combatSystem then
        -- Handle combat input
        if playdate.buttonJustPressed(playdate.kButtonA) then
            local result = combatSystem:playerAttack()
            
            if result == "victory" then
                print("Victory! Gained " .. combatSystem.rewardXP .. " XP")
                player:gainXP(combatSystem.rewardXP)
                
                -- Remove defeated enemy from room
                for i, enemy in ipairs(currentRoomEnemies) do
                    if enemy == currentEnemy then
                        table.remove(currentRoomEnemies, i)
                        break
                    end
                end
                
                -- Check if room is cleared
                checkRoomCleared()
                
                endCombat()
            elseif result == "continue" then
                -- Enemy's turn
                local enemyResult = combatSystem:enemyAttack()
                if enemyResult == "defeat" then
                    print("Game Over!")
                    -- Reset game
                    playdate.timer.performAfterDelay(2000, function()
                        floorNumber = 1
                        initialize()
                    end)
                end
            end
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            -- Try to run (use config value)
            if math.random(100) <= config.ESCAPE_CHANCE then
                print("Escaped!")
                endCombat()
            else
                print("Can't escape!")
                combatSystem:enemyAttack()
            end
        end
    end
end

-- End combat
function endCombat()
    gameState = "explore"
    currentEnemy = nil
    combatSystem = nil
end

-- Draw everything
function draw()
    gfx.clear()
    
    if gameState == "explore" then
        -- Draw map
        currentMap:draw(player.pixelX, player.pixelY)
        
        -- Draw enemies
        for _, enemy in ipairs(currentRoomEnemies) do
            if enemy:isAlive() then
                enemy:draw(player.pixelX, player.pixelY, currentMap.tileSize)
            end
        end
        
        -- Draw player
        player:draw()
        
        -- Draw UI
        ui:draw()
        
        -- Draw locked door indicators
        if not roomCleared then
            drawLockedDoorIndicators()
        end
        
        -- Check if player is near goal and show prompt
        if currentRoom and currentRoom.type == "exit" then
            local goalPixelX = (currentMap.goalX - 1) * 32 + 16
            local goalPixelY = (currentMap.goalY - 1) * 32 + 16
            local distX = math.abs(player.pixelX - goalPixelX)
            local distY = math.abs(player.pixelY - goalPixelY)
            
            if distX <= 32 and distY <= 32 then
                gfx.setColor(gfx.kColorBlack)
                gfx.setFont(gfx.getSystemFont(gfx.font.kVariantBold))
                local promptText = roomCleared and "→ NEXT FLOOR" or "→ DEFEAT ENEMIES"
                local promptWidth = gfx.getTextSize(promptText)
                local screenWidth = 400
                local screenHeight = 240
                
                -- Draw prompt with shadow and background
                local promptX = (screenWidth - promptWidth) / 2
                local promptY = screenHeight - 50
                
                -- Shadow
                gfx.fillRect(promptX - 6, promptY - 6, promptWidth + 12, 24)
                
                -- Background
                gfx.setColor(gfx.kColorWhite)
                gfx.fillRect(promptX - 5, promptY - 5, promptWidth + 10, 22)
                
                -- Border
                gfx.setColor(gfx.kColorBlack)
                gfx.drawRect(promptX - 5, promptY - 5, promptWidth + 10, 22)
                
                -- Text
                gfx.drawText(promptText, promptX, promptY - 2)
            end
        end
        
    elseif gameState == "combat" then
        -- Draw combat screen
        if combatSystem then
            combatSystem:draw()
        end
    end
end

-- Draw locked door indicators
function drawLockedDoorIndicators()
    local gfx <const> = playdate.graphics
    local screenWidth = 400
    local screenHeight = 240
    
    -- Find door tiles in viewport
    for y = 1, currentRoom.height do
        for x = 1, currentRoom.width do
            if currentMap:getTile(x, y) == 9 then
                -- Calculate screen position (pixel-based)
                local doorPixelX = (x - 1) * 32 + 16
                local doorPixelY = (y - 1) * 32 + 16
                
                local offsetX = (screenWidth / 2) - player.pixelX
                local offsetY = (screenHeight / 2) - player.pixelY
                
                local drawX = offsetX + doorPixelX
                local drawY = offsetY + doorPixelY
                
                -- Draw lock icon if on screen
                if drawX >= 0 and drawX < screenWidth and drawY >= 0 and drawY < screenHeight then
                    gfx.setColor(gfx.kColorBlack)
                    gfx.fillCircleAtPoint(drawX, drawY, 6)
                    gfx.setColor(gfx.kColorWhite)
                    gfx.fillCircleAtPoint(drawX, drawY, 4)
                    gfx.setColor(gfx.kColorBlack)
                    gfx.fillRect(drawX - 2, drawY, 4, 4)
                end
            end
        end
    end
end

-- Start the game
initialize()
