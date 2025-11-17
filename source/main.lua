-- Basic RPG Game for Playdate
-- Main game loop and initialization

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Import game modules
import "player"
import "map"
import "enemy"
import "combat"
import "ui"

local gfx <const> = playdate.graphics

-- Game state
local gameState = "explore" -- States: explore, combat, menu
local player = nil
local currentMap = nil
local enemies = {}
local currentEnemy = nil
local combatSystem = nil
local ui = nil

-- Initialize game
function initialize()
    -- Set up graphics
    gfx.setBackgroundColor(gfx.kColorWhite)
    
    -- Create player
    player = Player()
    player:setPosition(5, 5)
    
    -- Create map
    currentMap = Map()
    currentMap:generate(20, 20) -- 20x20 tile map
    
    -- Create UI
    ui = UI(player)
    
    -- Spawn some enemies
    spawnEnemies(3)
    
    print("RPG Game Initialized!")
    print("Use D-Pad to move, A to interact")
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
end

-- Try to move player
function tryMovePlayer(dx, dy)
    local newX = player.x + dx
    local newY = player.y + dy
    
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
        
        -- Random encounter chance (10%)
        if math.random(100) <= 10 then
            local encounter = Enemy("Wild " .. math.random(1, 5) .. " Slime", 1)
            startCombat(encounter)
        end
    end
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
        
    elseif gameState == "combat" then
        -- Draw combat screen
        if combatSystem then
            combatSystem:draw()
        end
    end
end

-- Start the game
initialize()
