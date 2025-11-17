-- UI class
-- Manages heads-up display and menus

import "CoreLibs/object"
import "CoreLibs/graphics"

class('UI').extends()

function UI:init(player)
    UI.super.init(self)
    self.player = player
end

-- Draw the HUD during exploration
function UI:draw()
    local gfx <const> = playdate.graphics
    local screenWidth = 400
    local screenHeight = 240
    
    -- Draw semi-transparent panel at top
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, screenWidth, 25)
    
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(2, 2, screenWidth - 4, 21)
    
    -- Draw player stats
    gfx.setColor(gfx.kColorBlack)
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantNormal))
    
    local statText = string.format(
        "LVL:%d  HP:%d/%d  XP:%d/%d  POS:(%d,%d)",
        self.player.level,
        self.player.currentHP,
        self.player.maxHP,
        self.player.xp,
        self.player.xpToNextLevel,
        self.player.x,
        self.player.y
    )
    
    gfx.drawText(statText, 5, 7)
    
    -- Draw mini health bar in corner
    self:drawMiniHealthBar(screenWidth - 62, 5, 60)
end

-- Draw mini health bar
function UI:drawMiniHealthBar(x, y, width)
    local gfx <const> = playdate.graphics
    local height = 6
    local percent = self.player.currentHP / self.player.maxHP
    
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(x, y, width, height)
    
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x + 1, y + 1, width - 2, height - 2)
    
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x + 1, y + 1, (width - 2) * percent, height - 2)
end

-- Draw menu (expandable for inventory, equipment, etc.)
function UI:drawMenu(menuType)
    local gfx <const> = playdate.graphics
    local screenWidth = 400
    local screenHeight = 240
    
    -- Draw menu background
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(50, 30, screenWidth - 100, screenHeight - 60)
    
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(50, 30, screenWidth - 100, screenHeight - 60)
    
    -- Menu title
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantBold))
    gfx.drawText("MENU", screenWidth / 2 - 20, 40)
    
    -- Menu content based on type
    if menuType == "inventory" then
        self:drawInventory()
    elseif menuType == "stats" then
        self:drawStats()
    end
end

-- Draw inventory screen
function UI:drawInventory()
    local gfx <const> = playdate.graphics
    
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantNormal))
    gfx.drawText("Inventory:", 60, 70)
    
    if #self.player.inventory == 0 then
        gfx.drawText("Empty", 70, 90)
    else
        local y = 90
        for i, item in ipairs(self.player.inventory) do
            gfx.drawText(item.name, 70, y)
            y = y + 15
        end
    end
end

-- Draw stats screen
function UI:drawStats()
    local gfx <const> = playdate.graphics
    
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantNormal))
    gfx.drawText("Character Stats:", 60, 70)
    
    local y = 90
    gfx.drawText("Level: " .. self.player.level, 70, y)
    y = y + 15
    gfx.drawText("HP: " .. self.player.currentHP .. "/" .. self.player.maxHP, 70, y)
    y = y + 15
    gfx.drawText("Attack: " .. self.player.attack, 70, y)
    y = y + 15
    gfx.drawText("Defense: " .. self.player.defense, 70, y)
    y = y + 15
    gfx.drawText("XP: " .. self.player.xp .. "/" .. self.player.xpToNextLevel, 70, y)
end
