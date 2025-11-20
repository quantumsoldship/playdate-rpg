-- UI class
-- Manages heads-up display and menus

import "CoreLibs/object"
import "CoreLibs/graphics"
import "config"

local config = import "config"

class('UI').extends()

function UI:init(player, roomNumber)
    UI.super.init(self)
    
    if not player then
        error("UI requires a player instance")
    end
    
    self.player = player
    self.roomNumber = roomNumber or 1
end

-- Draw the HUD during exploration
function UI:draw()
    local gfx <const> = playdate.graphics
    
    -- Draw polished panel at top with shadow effect (use config value)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, config.SCREEN_WIDTH, config.HUD_HEIGHT)
    
    -- Inner panel with border
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(2, 2, config.SCREEN_WIDTH - 4, config.HUD_HEIGHT - 4)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(2, 2, config.SCREEN_WIDTH - 4, config.HUD_HEIGHT - 4)
    
    -- Draw player stats with improved layout
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantBold))
    
    -- Left side: Level
    local levelText = string.format("LV %d", self.player.level)
    gfx.drawText(levelText, 8, 10)
    
    -- HP bar (visual)
    local hpBarX = 50
    local hpBarY = 10
    local hpBarWidth = 100
    local hpBarHeight = 12
    local hpPercent = self.player.currentHP / math.max(1, self.player.maxHP)
    
    -- HP bar background
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(hpBarX, hpBarY, hpBarWidth, hpBarHeight)
    
    -- HP bar fill (white for health)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(hpBarX + 2, hpBarY + 2, (hpBarWidth - 4) * hpPercent, hpBarHeight - 4)
    
    -- HP text on bar
    gfx.setColor(gfx.kColorBlack)
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantNormal))
    local hpText = string.format("%d/%d", self.player.currentHP, self.player.maxHP)
    local hpTextWidth = gfx.getTextSize(hpText)
    gfx.drawText(hpText, hpBarX + (hpBarWidth - hpTextWidth) / 2, hpBarY + 2)
    
    -- Center: Floor number
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantBold))
    local centerText = string.format("FLOOR %d", self.roomNumber)
    local centerTextWidth = gfx.getTextSize(centerText)
    gfx.drawText(centerText, (config.SCREEN_WIDTH - centerTextWidth) / 2, 10)
    
    -- Right side: XP bar (visual)
    local xpBarX = config.SCREEN_WIDTH - 110
    local xpBarY = 10
    local xpBarWidth = 100
    local xpBarHeight = 12
    local xpPercent = self.player.xp / math.max(1, self.player.xpToNextLevel)
    
    -- XP bar background
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(xpBarX, xpBarY, xpBarWidth, xpBarHeight)
    
    -- XP bar fill (black)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(xpBarX + 2, xpBarY + 2, (xpBarWidth - 4) * xpPercent, xpBarHeight - 4)
    
    -- XP text on bar
    gfx.setColor(gfx.kColorWhite)
    gfx.setFont(gfx.getSystemFont(gfx.font.kVariantNormal))
    local xpText = string.format("XP %d/%d", self.player.xp, self.player.xpToNextLevel)
    local xpTextWidth = gfx.getTextSize(xpText)
    gfx.drawText(xpText, xpBarX + (xpBarWidth - xpTextWidth) / 2, xpBarY + 2)
end

-- Draw mini health bar
function UI:drawMiniHealthBar(x, y, width)
    local gfx <const> = playdate.graphics
    local height = 6
    local percent = self.player.currentHP / math.max(1, self.player.maxHP)
    
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
