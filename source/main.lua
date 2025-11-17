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
import "enemy"
import "combat"
import "ui"

local gfx <const> = playdate.graphics

-- Game state
local gameState = "explore" -- States: explore, combat, menu
local player = nil
local currentMap = nil
local tileset = nil
local enemies = {}
local currentEnemy = nil
local combatSystem = nil
local ui = nil
local roomNumber = 1  -- Track progression through rooms
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
    
    -- Create player
    player = Player()
    player:setPosition(3, 3)
    
    -- Create map with tileset
    currentMap = Map(tileset)
    currentMap:generate(12, 10) -- 12x10 room-based map
    
    -- Create UI
    ui = UI(player, roomNumber)
    
    -- Spawn some enemies
    spawnEnemies(2)
    
    print("RPG Game Initialized!")
    print("Use D-Pad to move, find the goal!")
end

-- Spawn enemies on the map
function spawnEnemies(count)
    enemies = {}
    for i = 1, count do
        local enemy = Enemy("Slime", 1)
        -- Random position on map
        local x = math.random(1, currentMap.width)
        local y = math.random(1, currentMap.height)
        
        -- Make sure not to spawn on player
        while (x == player.x and y == player.y) or not currentMap:isWalkable(x, y) do
            x = math.random(1, currentMap.width)
            y = math.random(1, currentMap.height)
        end
        
        enemy:setPosition(x, y)
        table.insert(enemies, enemy)
    end
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
    
    -- Check if goal tile
    if currentMap:getTile(newX, newY) == currentMap.TILE_GOAL then
        -- Advance to next room
        advanceToNextRoom()
        return
    end
    
    -- Check if walkable
    if currentMap:isWalkable(newX, newY) then
        player:move(dx, dy)
        
        -- Check for enemy encounter
        for i, enemy in ipairs(enemies) do
            if enemy.x == player.x and enemy.y == player.y and enemy:isAlive() then
                startCombat(enemy)
                return
            end
        end
        
        -- Random encounter chance (5%)
        if math.random(100) <= 5 then
            local encounter = Enemy("Wild " .. math.random(1, 5) .. " Slime", 1)
            startCombat(encounter)
        end
    end
end

-- Advance to next room
function advanceToNextRoom()
    roomNumber = roomNumber + 1
    print("Entering Room " .. roomNumber .. "!")
    
    -- Generate new map
    currentMap:generate(12, 10)
    
    -- Reset player position to start
    player:setPosition(3, 3)
    
    -- Heal player slightly as reward
    player:heal(10)
    
    -- Spawn new enemies (scale with room number)
    spawnEnemies(math.min(2 + math.floor(roomNumber / 3), 4))
    
    -- Update UI with new room number
    ui.roomNumber = roomNumber
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
                
                -- Remove defeated enemy from map
                for i, enemy in ipairs(enemies) do
                    if enemy == currentEnemy then
                        table.remove(enemies, i)
                        break
                    end
                end
                
                endCombat()
            elseif result == "continue" then
                -- Enemy's turn
                local enemyResult = combatSystem:enemyAttack()
                if enemyResult == "defeat" then
                    print("Game Over!")
                    -- Reset game
                    playdate.timer.performAfterDelay(2000, function()
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
        for _, enemy in ipairs(enemies) do
            if enemy:isAlive() then
                enemy:draw(player.x, player.y, currentMap.tileSize)
            end
        end
        
        -- Draw player
        player:draw()
        
        -- Draw UI
        ui:draw()
        
        -- Check if player is near goal and show prompt
        local distX = math.abs(player.x - currentMap.goalX)
        local distY = math.abs(player.y - currentMap.goalY)
        if distX <= 1 and distY <= 1 then
            gfx.setColor(gfx.kColorBlack)
            gfx.setFont(gfx.getSystemFont(gfx.font.kVariantBold))
            local promptText = "→ ENTER GOAL"
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
        
    elseif gameState == "combat" then
        -- Draw combat screen
        if combatSystem then
            combatSystem:draw()
        end
    end
end

-- Start the game
initialize()
