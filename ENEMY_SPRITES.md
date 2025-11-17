# Enemy Sprite System Guide

## Overview

The Playdate RPG now supports custom enemy sprites, allowing you to upload your own enemy images and customize the look of your game.

## Creating Custom Enemy Sprites

### 1. Image Requirements

- **Format**: PNG (Playdate SDK converts to 1-bit)
- **Size**: 32x32 pixels (to match tile size)
- **Color**: Any color depth (converted to black/white)
- **Style**: Simple, high-contrast designs work best

### 2. File Structure

Create your enemy sprite images and place them in:

```
source/
  images/
    enemies/
      slime.png
      goblin.png
      skeleton.png
      boss.png
```

### 3. Configuration File

Create `data/enemy_sprites.json`:

```json
{
  "enemies": [
    {
      "spriteKey": "slime",
      "name": "Slime",
      "image": "source/images/enemies/slime.png"
    },
    {
      "spriteKey": "goblin",
      "name": "Goblin",
      "image": "source/images/enemies/goblin.png"
    }
  ]
}
```

### 4. Using Sprites in Code

When creating enemies, specify the sprite key:

```lua
-- Create enemy with custom sprite
local enemy = Enemy("Slime", level, "slime")

-- Or from template
local enemy = Enemy.fromTemplate({
    name = "Goblin",
    level = 2,
    spriteKey = "goblin",
    maxHP = 30,
    attack = 8
})
```

## Configuration Properties

### Enemy Sprite Definition

- **spriteKey** (required): Unique identifier for the sprite
- **name** (optional): Display name for the enemy
- **image** (required): Path to the sprite image file

## Design Tips

### 1. Keep It Simple
- Use bold, clear shapes
- High contrast between elements
- Avoid fine details (they may be lost in 1-bit conversion)

### 2. Consider the Playdate Screen
- Design for 1-bit black and white
- Test how colors convert to black/white
- Use dithering patterns for shading if needed

### 3. Animation Frames (Advanced)
While the current system uses static sprites, you can create multiple sprites for animation:

```json
{
  "enemies": [
    {
      "spriteKey": "slime_idle",
      "image": "source/images/enemies/slime_1.png"
    },
    {
      "spriteKey": "slime_attack",
      "image": "source/images/enemies/slime_2.png"
    }
  ]
}
```

## Default Behavior

If no custom sprite is specified or the sprite fails to load:
- The enemy will render using the default triangle shape
- The game will print an error message to the console
- Gameplay continues normally

## Enemy Health Bars

All enemies automatically display a health bar above them:
- Black border
- White background
- Black fill indicating current HP
- Updates in real-time during combat

## Loading Process

The game automatically loads enemy sprites at startup:

1. Checks for `data/enemy_sprites.json`
2. Loads each sprite image specified
3. Stores sprites in `Enemy.sprites` registry
4. Associates sprites with enemies via spriteKey

## Example Workflow

1. **Design your sprites** in an image editor (32x32 PNG)
2. **Export as PNG** and place in `source/images/enemies/`
3. **Create configuration** in `data/enemy_sprites.json`
4. **Test in game** to see how they look
5. **Iterate** on design based on 1-bit conversion results

## Troubleshooting

### Sprite not showing
- Check file path is correct (relative to project root)
- Verify image file exists
- Check console for error messages
- Ensure spriteKey matches between JSON and code

### Image looks wrong
- Remember: Playdate converts to 1-bit
- Test your PNG through Playdate SDK's image converter
- Adjust contrast and simplify design
- Use dithering patterns for gradients

### Performance issues
- Keep sprite count reasonable
- Use consistent image sizes (32x32)
- Optimize PNG files before adding

## Advanced: Dynamic Sprite Selection

You can select sprites based on enemy level or type:

```lua
function spawnEnemy(level)
    local spriteKey
    if level <= 2 then
        spriteKey = "slime"
    elseif level <= 5 then
        spriteKey = "goblin"
    else
        spriteKey = "skeleton"
    end
    
    return Enemy("Enemy", level, spriteKey)
end
```

## Integration with Templates

Combine with enemy templates for complete enemy definitions:

```lua
-- Define in config.lua or separate file
local enemyTemplates = {
    slime = {
        name = "Green Slime",
        spriteKey = "slime",
        maxHP = 15,
        attack = 4,
        xpReward = 20
    },
    boss = {
        name = "Dungeon Lord",
        spriteKey = "boss",
        maxHP = 100,
        attack = 20,
        xpReward = 500
    }
}
```

## Best Practices

1. **Name sprites consistently** - Use lowercase, descriptive names
2. **Organize by type** - Group similar enemies together
3. **Document your sprites** - Keep notes on what each represents
4. **Test frequently** - Check sprites on actual Playdate if possible
5. **Backup originals** - Keep high-res versions before converting

## See Also

- [TILE_SYSTEM.md](TILE_SYSTEM.md) - For custom tile sprites
- [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) - For general game expansion
- Example: `data/enemy_sprites_example.json`

---

*Tip: The Playdate Simulator converts images automatically. Use the SDK's image preview tools to see how your sprites will look in 1-bit!*
