# Testing Guide

This document explains how to test the Basic RPG game and verify expansions work correctly.

## Prerequisites

- Playdate SDK installed
- Playdate Simulator available
- Built game (`pdc source BasicRPG.pdx`)

## Core Systems Testing

### 1. Player Movement
**Test**: Character movement and collision detection

**Steps**:
1. Launch the game in simulator
2. Press D-pad in all four directions
3. Try to walk into water, trees, and rocks
4. Observe the position in the HUD

**Expected Results**:
- Player moves in response to D-pad
- Player stops at water tiles
- Player stops at tree tiles
- Player stops at rock tiles
- Player can walk on grass
- Position updates in HUD (top bar)

### 2. Enemy Encounters
**Test**: Random encounters and visible enemies

**Steps**:
1. Walk around the map for 20-30 moves
2. Walk directly into a visible enemy (triangle)
3. Note when random encounters trigger

**Expected Results**:
- Random encounters occur approximately every 10 moves
- Walking into visible enemies starts combat
- Combat screen appears with enemy info

### 3. Combat System
**Test**: Attack mechanics and damage calculation

**Steps**:
1. Start a combat encounter
2. Press A to attack
3. Note the damage dealt
4. Let enemy attack (automatic after player attack)
5. Continue until enemy is defeated or player dies

**Expected Results**:
- Damage varies slightly each attack
- Enemy HP decreases with each attack
- Player HP decreases when enemy attacks
- Combat log shows all actions
- Victory gives XP reward
- Defeat restarts the game after 2 seconds

### 4. Leveling System
**Test**: XP gain and level progression

**Steps**:
1. Defeat multiple enemies (3-5)
2. Watch for level up message
3. Check stats after level up

**Expected Results**:
- XP increases after each victory
- Level up occurs when XP reaches threshold
- HP increases by 5
- Attack increases by 2
- Defense increases by 1
- HP fully restored on level up
- XP threshold increases (×1.5)

### 5. Escape Mechanism
**Test**: Running from combat

**Steps**:
1. Start a combat encounter
2. Press B to attempt escape
3. Try multiple times if it fails

**Expected Results**:
- Approximately 50% success rate
- Success returns to exploration mode
- Failure causes enemy to attack
- Message indicates success or failure

### 6. Game Over and Restart
**Test**: Death and automatic restart

**Steps**:
1. Intentionally lose all HP in combat
2. Wait for restart

**Expected Results**:
- "Game Over!" message appears
- Game automatically restarts after 2 seconds
- Player reset to level 1
- Map regenerated
- New enemies spawned

## Visual Testing

### HUD Display
**Check**:
- Level displayed correctly
- Current/Max HP visible
- XP progress shown
- Player position (X, Y) accurate
- Mini health bar updates

### Map Rendering
**Check**:
- Grass tiles render as white with dots
- Water tiles render as black with wave line
- Tree tiles render as circles
- Rock tiles render as filled squares
- Player renders as black circle
- Enemies render as triangles

### Combat Screen
**Check**:
- Player stats on left
- Enemy stats on right
- Health bars for both
- Combat log shows recent actions
- Control hints at bottom
- Clear visual hierarchy

## Configuration Testing

### Modifying Game Parameters
**Test**: Config file changes take effect

**Steps**:
1. Edit `source/config.lua`
2. Change `PLAYER_START_HP = 50` (instead of 20)
3. Rebuild with `pdc source BasicRPG.pdx`
4. Run game

**Expected Results**:
- Player starts with 50 HP
- HUD shows 50/50 HP

### Enemy Templates
**Test**: Custom enemy creation

**Steps**:
1. Add new enemy to config.lua:
```lua
test_monster = {
    name = "Test Monster",
    level = 10,
    maxHP = 100,
    attack = 30,
    defense = 10,
    xpReward = 500,
    goldReward = 100
}
```
2. In main.lua, spawn the enemy:
```lua
local testMonster = Enemy.fromTemplate(config.ENEMY_TEMPLATES.test_monster)
```
3. Rebuild and test encounter

**Expected Results**:
- Monster has correct stats
- Monster is very difficult to defeat
- Large XP reward on victory

## Expansion Testing

### Adding Items
**Test**: Item system integration

**Steps**:
1. Import item.lua in main.lua: `import "item"`
2. Create and add item to player:
```lua
local potion = Item.fromTemplate(config.ITEM_TEMPLATES.potion)
player:addItem(potion)
```
3. Verify inventory contains item

### Map Modifications
**Test**: Custom map generation

**Steps**:
1. Modify `Map:generate()` to create specific pattern
2. Rebuild and observe map layout
3. Test walkability of custom tiles

## Performance Testing

### Frame Rate
**Check**:
- Smooth movement (no stuttering)
- Combat transitions are instant
- No lag when drawing many enemies

### Memory Usage
**Monitor in Simulator**:
- Check simulator console for warnings
- Watch for memory leaks during gameplay
- Test extended play sessions (5+ minutes)

## Bug Testing Checklist

- [ ] Can move in all four directions
- [ ] Collision detection works on all tiles
- [ ] Combat starts correctly
- [ ] Combat ends correctly (victory and defeat)
- [ ] Level up calculations are correct
- [ ] XP requirements scale properly
- [ ] Escape from combat works
- [ ] Game over restarts properly
- [ ] HUD updates in real-time
- [ ] Enemy AI attacks properly
- [ ] Damage variance is within ±20%
- [ ] Health bars display correctly
- [ ] Combat log scrolls properly
- [ ] Random encounters at ~10% rate
- [ ] Map generation includes all terrain types
- [ ] No crashes during normal gameplay

## Automated Testing Notes

Since Playdate doesn't have a built-in unit testing framework, testing is primarily manual. However, you can add debug functions:

```lua
-- In main.lua
function testCombatSystem()
    print("Testing combat system...")
    local testPlayer = Player()
    local testEnemy = Enemy("Test", 1)
    
    assert(testPlayer:isAlive(), "Player should start alive")
    assert(testEnemy:isAlive(), "Enemy should start alive")
    
    testEnemy.currentHP = 0
    assert(not testEnemy:isAlive(), "Enemy should be dead")
    
    print("Combat system tests passed!")
end

-- Call during initialization for testing
-- testCombatSystem()
```

## Regression Testing

When making changes, always verify:
1. Core movement still works
2. Combat still functions
3. Leveling system works
4. Game doesn't crash on startup
5. HUD displays correctly

## Reporting Issues

When finding bugs, document:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Game state when bug occurred
- Playdate SDK version
- Any console error messages

## Testing New Features

When adding new features:
1. Test the feature in isolation
2. Test integration with existing systems
3. Test edge cases
4. Test with different config values
5. Verify no regressions in core systems

---

**Happy Testing!** 🎮
