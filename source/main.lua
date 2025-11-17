-- Basic RPG Game for Playdate
-- Main game loop and initialization

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Import game modules
import "player"
import "tileset"
import "map"
import "dungeon"
import "enemy"
import "combat"
import "ui"

local gfx <const> = playdate.graphics

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
    
    -- Generate first floor
    generateNewFloor()
    
    -- Create UI
    ui = UI(player, floorNumber)
    
    print("RPG Game Initialized!")
    print("Defeat all enemies to unlock doors!")
end

-- Generate a new dungeon floor
function generateNewFloor()
    print("Generating Floor " .. floorNumber .. "...")
    
    -- Generate dungeon
    currentDungeon = dungeonGenerator:generate(6) -- 6 rooms per floor
    
    -- Start in first room
    currentRoom = currentDungeon[1]
    loadRoom(currentRoom)
    
    -- Place player at spawn point
    player:setPosition(math.floor(currentRoom.width / 2), math.floor(currentRoom.height / 2))
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
    
    -- Don't spawn enemies in start room
    if room.type == "start" then
        roomCleared = true
        return
    end
    
    -- Spawn enemies based on room type and floor
    local enemyCount = 2
    if room.type == "large" then
        enemyCount = 3
    elseif room.type == "exit" then
        enemyCount = 4 -- Boss room
    end
    
    -- Scale with floor number
    enemyCount = enemyCount + math.floor(floorNumber / 2)
    
    for i = 1, enemyCount do
        local enemy = Enemy("Slime", floorNumber)
        
        -- Random position in room (not on player, not on walls)
        local x, y
        local attempts = 0
        repeat
            x = math.random(3, room.width - 2)
            y = math.random(3, room.height - 2)
            attempts = attempts + 1
        until (currentMap:isWalkable(x, y) and 
               (x ~= player.x or y ~= player.y) and
               math.abs(x - player.x) + math.abs(y - player.y) > 3) or
              attempts > 50
        
        if attempts <= 50 then
            enemy:setPosition(x, y)
            table.insert(currentRoomEnemies, enemy)
        end
    end
    
    print("Spawned " .. #currentRoomEnemies .. " enemies in room")
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
    -- Handle input
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        tryMovePlayer(0, -1)
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        tryMovePlayer(0, 1)
    elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
        tryMovePlayer(-1, 0)
    elseif playdate.buttonJustPressed(playdate.kButtonRight) then
        tryMovePlayer(1, 0)
    end
    
    -- Toggle debug mode with SELECT button
    if playdate.buttonJustPressed(playdate.kButtonSelect) then
        debugMode = not debugMode
        print("Debug mode: " .. (debugMode and "ON" or "OFF"))
    end
end

-- Try to move player
function tryMovePlayer(dx, dy)
    local newX = player.x + dx
    local newY = player.y + dy
    
    -- Check if it's a door tile
    if currentMap:getTile(newX, newY) == 9 then
        -- Check if room is cleared
        if not roomCleared then
            print("Defeat all enemies to unlock the door!")
            return
        end
        
        -- Find which door this is and transition to connected room
        transitionThroughDoor(newX, newY)
        return
    end
    
    -- Check if goal tile (floor exit)
    if currentMap:getTile(newX, newY) == 5 then
        if roomCleared then
            advanceToNextFloor()
        else
            print("Defeat all enemies first!")
        end
        return
    end
    
    -- Check if walkable
    if currentMap:isWalkable(newX, newY) then
        player:move(dx, dy)
        
        -- Check for enemy encounter
        for i, enemy in ipairs(currentRoomEnemies) do
            if enemy.x == player.x and enemy.y == player.y and enemy:isAlive() then
                startCombat(enemy)
                return
            end
        end
    end
end

-- Transition through a door to another room
function transitionThroughDoor(doorX, doorY)
    -- Find the door and determine direction
    local direction = nil
    
    if doorX == 1 then
        direction = {dx = -1, dy = 0}
    elseif doorX == currentRoom.width then
        direction = {dx = 1, dy = 0}
    elseif doorY == 1 then
        direction = {dx = 0, dy = -1}
    elseif doorY == currentRoom.height then
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
            
            -- Place player at opposite door
            if direction.dx == 1 then
                player:setPosition(2, math.floor(nextRoom.height / 2))
            elseif direction.dx == -1 then
                player:setPosition(nextRoom.width - 1, math.floor(nextRoom.height / 2))
            elseif direction.dy == 1 then
                player:setPosition(math.floor(nextRoom.width / 2), 2)
            else
                player:setPosition(math.floor(nextRoom.width / 2), nextRoom.height - 1)
            end
        end
    end
end

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
            -- Try to run
            if math.random(100) <= 50 then
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
        currentMap:draw(player.x, player.y)
        
        -- Draw enemies
        for _, enemy in ipairs(currentRoomEnemies) do
            if enemy:isAlive() then
                enemy:draw(player.x, player.y, currentMap.tileSize)
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
            local distX = math.abs(player.x - currentMap.goalX)
            local distY = math.abs(player.y - currentMap.goalY)
            if distX <= 1 and distY <= 1 then
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
                -- Calculate screen position
                local offsetX = (screenWidth / 2) - (player.x * currentMap.tileSize) + (currentMap.tileSize / 2)
                local offsetY = (screenHeight / 2) - (player.y * currentMap.tileSize) + (currentMap.tileSize / 2)
                local drawX = offsetX + (x - 1) * currentMap.tileSize
                local drawY = offsetY + (y - 1) * currentMap.tileSize
                
                -- Draw lock icon if on screen
                if drawX >= 0 and drawX < screenWidth and drawY >= 0 and drawY < screenHeight then
                    gfx.setColor(gfx.kColorBlack)
                    gfx.fillCircleAtPoint(drawX + 16, drawY + 16, 6)
                    gfx.setColor(gfx.kColorWhite)
                    gfx.fillCircleAtPoint(drawX + 16, drawY + 16, 4)
                    gfx.setColor(gfx.kColorBlack)
                    gfx.fillRect(drawX + 14, drawY + 16, 4, 4)
                end
            end
        end
    end
end

-- Start the game
initialize()
