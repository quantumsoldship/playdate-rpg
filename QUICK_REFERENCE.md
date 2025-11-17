# Quick Reference Card

## Game Controls

### Exploration Mode
- **↑ ↓ ← →** : Move character
- **A** : Interact/Confirm
- **B** : Menu/Cancel

### Combat Mode
- **A** : Attack
- **B** : Run Away

## Game Mechanics

### Combat
- Turn-based system
- Attack damage: Base attack ± 20% variance
- Damage reduction: Damage - Defense (minimum 1)
- Running: 50% success rate

### Leveling
- Gain XP from defeating enemies
- Level up increases: HP +5, Attack +2, Defense +1
- Full heal on level up
- Next level XP: Current × 1.5

### Exploration
- Walk on grass tiles
- Cannot walk through water, trees, or rocks
- Random encounters: 10% chance per move
- Enemies visible on map (triangles)

## Stats Explained

### Player Stats
- **Level**: Character level (affects all stats)
- **HP**: Health points (0 = game over)
- **Attack**: Base damage dealt
- **Defense**: Damage reduction
- **XP**: Experience points to next level

### Enemy Stats
- **Level**: Difficulty indicator
- **HP**: Health (varies by enemy type)
- **Attack**: Base damage
- **Defense**: Damage reduction

## Visual Guide

### Map Symbols
- **●** : Player (you)
- **▲** : Enemy
- **White squares** : Grass (walkable)
- **Black squares with line** : Water (blocked)
- **Circles** : Trees (blocked)
- **Solid squares** : Rocks (blocked)

## Starting Stats

**Player (Level 1)**
- HP: 20/20
- Attack: 5
- Defense: 2
- XP: 0/100

**Slime (Level 1)**
- HP: 10
- Attack: 3
- Defense: 1
- Reward: 20 XP, 5 Gold

## Tips for Success

1. **Engage enemies early** - The initial enemies are weaker
2. **Watch your HP** - Avoid fighting when low on health
3. **Running is OK** - 50% chance to escape if needed
4. **Level up strategy** - Level ups fully restore HP
5. **Map awareness** - Use terrain to avoid unwanted fights

## Expansion Quick Start

### Add a New Enemy
1. Open `source/config.lua`
2. Add entry to `ENEMY_TEMPLATES`
3. Spawn with `Enemy.fromTemplate(config.ENEMY_TEMPLATES.yourEnemy)`

### Change Starting Stats
1. Open `source/config.lua`
2. Modify `PLAYER_START_*` values
3. Save and rebuild

### Modify Map Size
1. Open `source/config.lua`
2. Change `MAP_WIDTH` and `MAP_HEIGHT`
3. Save and rebuild

### Adjust Difficulty
- `RANDOM_ENCOUNTER_CHANCE` - Higher = more fights
- `ESCAPE_CHANCE` - Lower = harder to run
- `LEVEL_UP_*_BONUS` - Higher = faster progression
- `DAMAGE_VARIANCE` - Higher = more randomness

## Building & Running

```bash
# Build
pdc source BasicRPG.pdx

# Run in Simulator
# Drag BasicRPG.pdx to Playdate Simulator

# Upload to Device
# Use Playdate website or USB connection
```

## Need Help?

- Check `DEVELOPER_GUIDE.md` for detailed information
- See `EXAMPLES.md` for code examples
- Visit https://sdk.play.date/ for SDK documentation
