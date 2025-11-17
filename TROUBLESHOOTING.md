# Troubleshooting Guide

Common issues and solutions for the Playdate RPG game.

## Building Issues

### "pdc: command not found"

**Problem**: The Playdate compiler is not in your PATH.

**Solution**:
1. Install the Playdate SDK from https://play.date/dev/
2. Add the SDK to your PATH:

**macOS/Linux**:
```bash
export PATH="$PATH:/path/to/PlaydateSDK/bin"
```

**Windows**:
Add `C:\path\to\PlaydateSDK\bin` to your System PATH environment variable.

### Build Fails with Syntax Error

**Problem**: Lua syntax error in code.

**Solution**:
1. Check the error message for file and line number
2. Common issues:
   - Missing `end` statement
   - Mismatched parentheses or quotes
   - Incorrect function definitions
3. Verify with a Lua syntax checker online

### "import" Not Found

**Problem**: Missing dependency file.

**Solution**:
Ensure all required files are in the `source/` directory:
- main.lua
- player.lua
- enemy.lua
- map.lua
- combat.lua
- ui.lua
- config.lua
- pdxinfo

## Runtime Issues

### Game Crashes on Startup

**Problem**: Error during initialization.

**Solutions**:

1. **Check Console Output**: Open the Simulator console (Cmd+Shift+K on Mac) to see error messages

2. **Verify CoreLibs**: Ensure imports are correct:
   ```lua
   import "CoreLibs/object"
   import "CoreLibs/graphics"
   ```

3. **Check Random Seed**: If map generation fails, add:
   ```lua
   math.randomseed(playdate.getSecondsSinceEpoch())
   ```

### Player Can't Move

**Problem**: Movement input not working.

**Solutions**:

1. **Check if in Combat**: Movement only works in exploration mode
2. **Verify Button Detection**: Add debug print:
   ```lua
   if playdate.buttonJustPressed(playdate.kButtonUp) then
       print("Up pressed!")
   end
   ```
3. **Check Map Boundaries**: Ensure player isn't at edge of map

### Combat Never Ends

**Problem**: Combat loop doesn't exit.

**Solutions**:

1. **Check HP Values**: Verify enemy HP reaches 0
2. **Check Victory Condition**: Ensure `enemy:isAlive()` returns false
3. **Add Debug Output**:
   ```lua
   print("Enemy HP: " .. enemy.currentHP)
   ```

### Random Encounters Too Frequent/Rare

**Problem**: Encounter rate not as expected.

**Solution**:
Edit `config.lua`:
```lua
config.RANDOM_ENCOUNTER_CHANCE = 10  -- Change this value (0-100)
```

### Game Over Doesn't Restart

**Problem**: Stuck on defeat screen.

**Solution**:
Check the timer callback:
```lua
playdate.timer.performAfterDelay(2000, function()
    initialize()
end)
```

Ensure `playdate.timer.updateTimers()` is called in the update loop.

## Display Issues

### HUD Not Showing

**Problem**: UI elements missing.

**Solutions**:

1. **Check Drawing Order**: UI should be drawn last in `draw()`
2. **Verify UI Creation**: Ensure `ui = UI(player)` in initialize()
3. **Check Graphics Context**: Make sure colors are set:
   ```lua
   gfx.setColor(gfx.kColorBlack)
   ```

### Map Not Visible

**Problem**: Black/white screen with no map.

**Solutions**:

1. **Check Map Generation**: Verify `currentMap:generate()` was called
2. **Verify Tile Drawing**: Add debug output in `Map:drawTile()`
3. **Check Camera Offset**: Ensure player position is set

### Player/Enemies Not Drawing

**Problem**: Entities invisible.

**Solutions**:

1. **Check Z-Order**: Entities should draw after map
2. **Verify Positions**: Print entity coordinates:
   ```lua
   print("Player at: " .. player.x .. ", " .. player.y)
   ```
3. **Check Color Settings**: Ensure draw colors are set correctly

## Gameplay Issues

### Damage Always the Same

**Problem**: No damage variance.

**Solution**:
Check that variance is applied:
```lua
return math.floor(basePower * (0.8 + math.random() * 0.4))
```

If using `math.random()` without seed, add:
```lua
math.randomseed(playdate.getSecondsSinceEpoch())
```

### Level Up Not Working

**Problem**: XP gained but no level up.

**Solutions**:

1. **Check XP Threshold**: Print values:
   ```lua
   print("XP: " .. player.xp .. " / " .. player.xpToNextLevel)
   ```

2. **Verify Level Up Logic**:
   ```lua
   while self.xp >= self.xpToNextLevel do
       self:levelUp()
   end
   ```

### Can Walk Through Walls

**Problem**: Collision detection not working.

**Solutions**:

1. **Check `isWalkable()`**: Verify it returns false for obstacles
2. **Check Tile Types**: Ensure obstacles are marked correctly
3. **Verify Movement Logic**: Check `tryMovePlayer()` calls `isWalkable()`

## Performance Issues

### Laggy/Slow Frame Rate

**Problem**: Game runs slowly.

**Solutions**:

1. **Optimize Drawing**: Don't draw off-screen tiles
2. **Reduce Enemy Count**: Modify `INITIAL_ENEMY_COUNT` in config.lua
3. **Simplify Tile Graphics**: Use simpler drawing in `Map:drawTile()`

### Memory Warnings

**Problem**: Running out of memory.

**Solutions**:

1. **Reduce Map Size**: Make maps smaller in config.lua
2. **Clear Unused Data**: Remove defeated enemies from table
3. **Optimize Tables**: Don't store unnecessary data

## Configuration Issues

### Changes to config.lua Not Taking Effect

**Problem**: Modifications ignored.

**Solution**:
1. Save the file
2. Clean and rebuild:
   ```bash
   make clean
   make build
   ```
3. Verify config is imported in main.lua

### Enemy Templates Not Working

**Problem**: Custom enemies don't appear.

**Solution**:
Ensure template format is correct:
```lua
enemy_name = {
    name = "Display Name",
    level = 1,
    maxHP = 10,
    attack = 5,
    defense = 2,
    xpReward = 20,
    goldReward = 5
}
```

And spawn with:
```lua
local enemy = Enemy.fromTemplate(config.ENEMY_TEMPLATES.enemy_name)
```

## Expansion Issues

### New Module Not Loading

**Problem**: Custom module not imported.

**Solution**:
1. Add import to main.lua:
   ```lua
   import "mymodule"
   ```
2. Ensure file is in `source/` directory
3. Check file has `.lua` extension

### Item System Not Working

**Problem**: Items not functioning.

**Solution**:
1. Import item module:
   ```lua
   import "item"
   ```
2. Create items properly:
   ```lua
   local item = Item.fromTemplate(config.ITEM_TEMPLATES.potion)
   ```

## Debugging Tips

### Enable Verbose Logging

Add debug prints throughout your code:

```lua
function Player:takeDamage(damage)
    print("Player taking damage: " .. damage)
    local actualDamage = math.max(1, damage - self.defense)
    print("Actual damage after defense: " .. actualDamage)
    self.currentHP = self.currentHP - actualDamage
    print("New HP: " .. self.currentHP)
    return actualDamage
end
```

### Check Variables

Add this helper function to main.lua:

```lua
function debugPrint(label, value)
    print(label .. ": " .. tostring(value))
end
```

Use it anywhere:
```lua
debugPrint("Player HP", player.currentHP)
debugPrint("Enemy alive", enemy:isAlive())
```

### Simulator Console Commands

In Playdate Simulator:
- **Cmd+Shift+K** (Mac) / **Ctrl+Shift+K** (Windows): Open console
- Look for error messages in red
- Check for print() output

### Common Error Messages

**"attempt to index nil value"**
- Trying to access property of nil object
- Check if object was created/initialized

**"attempt to call nil value"**
- Function doesn't exist or misnamed
- Check spelling and imports

**"stack overflow"**
- Infinite recursion
- Check for circular function calls

## Getting Help

If you're still stuck:

1. **Check Documentation**:
   - DEVELOPER_GUIDE.md
   - EXAMPLES.md
   - QUICK_REFERENCE.md

2. **Review Examples**: Look at existing code patterns

3. **Simplify**: Remove recent changes to isolate the problem

4. **Ask for Help**:
   - Open a GitHub issue
   - Include error messages
   - Describe what you were trying to do
   - Show relevant code

## Useful Resources

- **Playdate SDK Docs**: https://sdk.play.date/
- **Playdate Developer Forum**: https://devforum.play.date/
- **Lua Manual**: https://www.lua.org/manual/5.4/
- **Inside Playdate**: https://sdk.play.date/inside-playdate/

## Prevention

### Best Practices

1. **Test Frequently**: Build and test after each change
2. **Version Control**: Commit working code before major changes
3. **Start Small**: Add features incrementally
4. **Read Errors**: Error messages usually tell you exactly what's wrong
5. **Use Print Statements**: Debug with print() liberally
6. **Follow Examples**: Use EXAMPLES.md as reference

### Code Quality

1. **Check Syntax**: Use a Lua linter if available
2. **Consistent Style**: Follow existing code patterns
3. **Comment Complex Code**: Help your future self
4. **Test Edge Cases**: Try to break your code
5. **Handle Nil Values**: Check before accessing properties

---

**Still having issues?** Open an issue on GitHub with:
- Description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Error messages
- Relevant code snippets
