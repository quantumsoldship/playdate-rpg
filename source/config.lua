-- Configuration file for easy game customization
-- Edit these values to change game behavior

local config = {}

-- Game Settings
config.GAME_TITLE = "Basic RPG"
config.SCREEN_WIDTH = 400
config.SCREEN_HEIGHT = 240

-- Map Settings
config.MAP_WIDTH = 20
config.MAP_HEIGHT = 20
config.TILE_SIZE = 16

-- Enemy Settings
config.INITIAL_ENEMY_COUNT = 3
config.RANDOM_ENCOUNTER_CHANCE = 10  -- Percentage (0-100)

-- Player Settings
config.PLAYER_START_X = 5
config.PLAYER_START_Y = 5
config.PLAYER_START_LEVEL = 1
config.PLAYER_START_HP = 20
config.PLAYER_START_ATTACK = 5
config.PLAYER_START_DEFENSE = 2
config.PLAYER_XP_TO_LEVEL = 100

-- Level Up Bonuses
config.LEVEL_UP_HP_BONUS = 5
config.LEVEL_UP_ATTACK_BONUS = 2
config.LEVEL_UP_DEFENSE_BONUS = 1
config.LEVEL_UP_XP_MULTIPLIER = 1.5

-- Combat Settings
config.ESCAPE_CHANCE = 50  -- Percentage (0-100)
config.DAMAGE_VARIANCE = 0.2  -- ±20% damage variance

-- Enemy Templates (easy to add more!)
config.ENEMY_TEMPLATES = {
    slime = {
        name = "Slime",
        level = 1,
        maxHP = 10,
        attack = 3,
        defense = 1,
        xpReward = 20,
        goldReward = 5
    },
    
    goblin = {
        name = "Goblin",
        level = 2,
        maxHP = 15,
        attack = 7,
        defense = 2,
        xpReward = 35,
        goldReward = 12
    },
    
    wolf = {
        name = "Wolf",
        level = 2,
        maxHP = 18,
        attack = 8,
        defense = 1,
        xpReward = 40,
        goldReward = 8
    },
    
    orc = {
        name = "Orc",
        level = 3,
        maxHP = 25,
        attack = 12,
        defense = 4,
        xpReward = 60,
        goldReward = 20
    },
    
    dragon = {
        name = "Dragon",
        level = 5,
        maxHP = 50,
        attack = 20,
        defense = 8,
        xpReward = 200,
        goldReward = 100
    }
}

-- Item Templates (for future expansion)
config.ITEM_TEMPLATES = {
    potion = {
        name = "Health Potion",
        type = "consumable",
        effect = "heal",
        value = 20,
        price = 10
    },
    
    sword = {
        name = "Iron Sword",
        type = "weapon",
        attackBonus = 5,
        price = 50
    },
    
    shield = {
        name = "Wooden Shield",
        type = "armor",
        defenseBonus = 3,
        price = 40
    }
}

return config
