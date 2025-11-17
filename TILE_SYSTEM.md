# Tile System Guide

## Overview

The Playdate RPG now features a comprehensive tile-based system that allows you to create custom tilesets, define hitboxes, and build your own maps. This guide will walk you through the process of creating and using custom tiles.

## Tile System Architecture

The tile system consists of three main components:

1. **Tileset** - Manages tile definitions, properties, and rendering
2. **Map** - Manages tile placement and world layout
3. **Custom Tiles** - Your custom tile images and definitions

## Creating a Custom Tileset

### 1. Tileset JSON Format

Create a JSON file (e.g., `data/tileset.json`) with the following structure:

```json
{
  "tileSize": 32,
  "tiles": [
    {
      "id": 0,
      "name": "Grass",
      "walkable": true,
      "category": "terrain",
      "image": "images/tiles/grass.png",
      "hitbox": {
        "x": 0,
        "y": 0,
        "width": 32,
        "height": 32
      }
    }
  ]
}
```

### 2. Tile Properties

Each tile can have the following properties:

- **id** (required): Unique numeric identifier for the tile
- **name** (optional): Human-readable name
- **walkable** (optional): Boolean, defaults to true
- **category** (optional): Category for organization (terrain, obstacle, wall, special, interactive)
- **image** (optional): Path to tile image file (relative to project root)
- **hitbox** (optional): Collision box definition

### 3. Hitbox Format

Hitboxes define the collision area for a tile:

```json
{
  "x": 8,
  "y": 8,
  "width": 16,
  "height": 16
}
```

- **x, y**: Offset from top-left corner of tile
- **width, height**: Size of collision box

This allows for tiles that are partially walkable (e.g., a tree with walkable space around it).

## Creating Custom Tile Images

### Image Requirements

1. **Format**: PNG format (Playdate SDK will convert to 1-bit)
2. **Size**: Should match your tileSize (default 32x32 pixels)
3. **Color**: Can be full color; SDK converts to 1-bit black/white
4. **Location**: Place in a directory like `source/images/tiles/`

### Example Tile Structure

```
source/
  images/
    tiles/
      grass.png
      water.png
      tree.png
      rock.png
      wall.png
      door.png
```

## Loading Custom Tilesets

### Method 1: Automatic Loading

Place your tileset JSON at `data/tileset.json`. The game will automatically load it on startup:

```lua
-- In main.lua, this is already set up:
tileset = Tileset()
tileset:createDefaultTileset()

if playdate.file.exists("data/tileset.json") then
    tileset:loadFromJSON("data/tileset.json")
end
```

### Method 2: Manual Loading

```lua
-- Create a new tileset
local myTileset = Tileset()

-- Load from JSON
myTileset:loadFromJSON("data/my_custom_tileset.json")

-- Create map with custom tileset
local map = Map(myTileset)
```

## Creating Custom Maps

### Map JSON Format

Create a JSON file with your map layout:

```json
{
  "width": 15,
  "height": 12,
  "goal": {
    "x": 13,
    "y": 2
  },
  "tiles": [
    [4, 4, 4, 4, 4],
    [4, 0, 0, 0, 4],
    [4, 0, 2, 0, 4],
    [4, 0, 0, 0, 4],
    [4, 4, 4, 4, 4]
  ]
}
```

- **width, height**: Map dimensions in tiles
- **goal**: Position of the exit/goal tile
- **tiles**: 2D array of tile IDs

### Loading Custom Maps

```lua
-- Load map from JSON
currentMap:loadFromJSON("data/my_map.json")
```

## Tile Categories

Organize your tiles using categories:

- **terrain**: Walkable ground tiles (grass, sand, etc.)
- **obstacle**: Blocking objects (trees, rocks, etc.)
- **wall**: Solid barriers
- **special**: Goal tiles, doors, etc.
- **interactive**: Items that can be interacted with (chests, NPCs, etc.)

## Advanced: Programmatic Tiles

You can also define tiles programmatically without images:

```lua
tileset:defineTile(10, {
    name = "Lava",
    walkable = false,
    category = "hazard",
    drawFunc = function(x, y, size)
        -- Custom drawing code
        local gfx = playdate.graphics
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(x, y, size, size)
        -- Add animation, effects, etc.
    end
})
```

## Tile ID Reference

Default tile IDs (0-5 are reserved):

- **0**: Grass (walkable)
- **1**: Water (non-walkable)
- **2**: Tree (non-walkable)
- **3**: Rock (non-walkable)
- **4**: Wall (non-walkable)
- **5**: Goal/Door (walkable, triggers level transition)

You can add custom tiles starting from ID 6 and up.

## Best Practices

1. **Keep tile IDs consistent** - Document your tile ID scheme
2. **Use meaningful categories** - Makes tiles easier to find and organize
3. **Define hitboxes carefully** - Test collision with player movement
4. **Optimize images** - Keep tile images simple for 1-bit rendering
5. **Use tileset templates** - Start with the example tileset and modify

## Example Workflow

1. Create your tile images (32x32 PNG)
2. Create a tileset JSON file defining each tile
3. Test tiles in-game with default map
4. Create custom map JSON with your tiles
5. Load custom map in game
6. Iterate and refine

## Exporting Tilesets and Maps

You can export your current tileset or map to JSON:

```lua
-- Export tileset
tileset:exportToJSON("data/my_tileset.json")

-- Export map
currentMap:exportToJSON("data/my_map.json")
```

This is useful for creating templates or backing up your work.

## Troubleshooting

### Tiles not loading
- Check file paths are correct (relative to project root)
- Verify JSON syntax is valid
- Check console output for error messages

### Collision issues
- Review hitbox definitions
- Test with different hitbox sizes
- Verify walkable property is set correctly

### Images not displaying
- Ensure images are in correct format (PNG)
- Check image dimensions match tileSize
- Verify image paths in tileset JSON

## Next Steps

- See `data/tileset_example.json` for a complete tileset template
- See `data/map_example.json` for a map layout template
- Check `source/tileset.lua` for the full API
- Experiment with custom tiles and maps!

---

For more information on extending the game, see [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)
