-- Combat class
-- Manages turn-based combat system

import "CoreLibs/object"
import "CoreLibs/graphics"

class('Combat').extends()

function Combat:init(player, enemy)
    Combat.super.init(self)
    
    self.player = player
    self.enemy = enemy
    
    -- Combat log
    self.log = {}
    self.maxLogLines = 8
    
    -- Rewards
    self.rewardXP = enemy.xpReward
    self.rewardGold = enemy.goldReward
    
    self:addLog("Combat started with " .. enemy.name .. "!")
    self:addLog("Enemy Level: " .. enemy.level .. " HP: " .. enemy.currentHP)
end

-- Add message to combat log
function Combat:addLog(message)
    table.insert(self.log, message)
    
    -- Keep only last N messages
    while #self.log > self.maxLogLines do
        table.remove(self.log, 1)
    end
end

-- Player attacks
function Combat:playerAttack()
    local damage = self.player:getAttackPower()
    local actualDamage = self.enemy:takeDamage(damage)
    
    self:addLog("You attack for " .. actualDamage .. " damage!")
    
    if not self.enemy:isAlive() then
        self:addLog(self.enemy.name .. " defeated!")
        return "victory"
    end
    
    return "continue"
end

-- Enemy attacks
function Combat:enemyAttack()
    local damage = self.enemy:getAttackPower()
    local actualDamage = self.player:takeDamage(damage)
    
    self:addLog(self.enemy.name .. " attacks for " .. actualDamage .. " damage!")
    
    if not self.player:isAlive() then
        self:addLog("You have been defeated!")
        return "defeat"
    end
    
    return "continue"
end

-- Draw combat screen
function Combat:draw()
    local gfx <const> = playdate.graphics
    local screenWidth = 400
    local screenHeight = 240
    
    -- Draw background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, screenWidth, screenHeight)
    
    -- Draw border
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(5, 5, screenWidth - 10, screenHeight - 10)
    
    -- Draw title
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantBold))
    gfx.drawText("*COMBAT*", screenWidth / 2 - 40, 15)
    
    -- Draw player info
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantNormal))
    gfx.drawText("YOU", 20, 40)
    gfx.drawText("HP: " .. self.player.currentHP .. "/" .. self.player.maxHP, 20, 55)
    gfx.drawText("ATK: " .. self.player.attack, 20, 70)
    gfx.drawText("DEF: " .. self.player.defense, 20, 85)
    
    -- Draw player sprite
    gfx.fillCircle(70, 110, 15)
    
    -- Draw enemy info
    gfx.drawText(self.enemy.name, screenWidth - 120, 40)
    gfx.drawText("HP: " .. self.enemy.currentHP .. "/" .. self.enemy.maxHP, screenWidth - 120, 55)
    gfx.drawText("LVL: " .. self.enemy.level, screenWidth - 120, 70)
    
    -- Draw enemy sprite
    gfx.fillTriangle(
        screenWidth - 70, 95,
        screenWidth - 90, 125,
        screenWidth - 50, 125
    )
    
    -- Draw health bars
    self:drawHealthBar(20, 100, 80, self.player.currentHP, self.player.maxHP)
    self:drawHealthBar(screenWidth - 120, 100, 80, self.enemy.currentHP, self.enemy.maxHP)
    
    -- Draw combat log
    gfx.drawRect(10, 140, screenWidth - 20, 70)
    local y = 145
    for i = math.max(1, #self.log - 5), #self.log do
        gfx.drawText(self.log[i], 15, y)
        y = y + 12
    end
    
    -- Draw controls
    gfx.drawText("A: Attack  B: Run", screenWidth / 2 - 70, screenHeight - 20)
end

-- Draw health bar
function Combat:drawHealthBar(x, y, width, current, max)
    local gfx <const> = playdate.graphics
    local height = 8
    local percent = current / max
    
    -- Border
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(x, y, width, height)
    
    -- Background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x + 1, y + 1, width - 2, height - 2)
    
    -- Health
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x + 1, y + 1, (width - 2) * percent, height - 2)
end
