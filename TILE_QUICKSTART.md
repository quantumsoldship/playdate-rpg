# Quick Start: Custom Tiles

This is a quick guide to get you started with custom tiles in under 5 minutes!

## Step 1: Create Your Tile Images

Create 32x32 pixel PNG images for your tiles. For example:
- `grass.png` - A walkable ground tile
- `wall.png` - A solid wall
- `chest.png` - An interactive object

Place them in: `source/images/tiles/`

## Step 2: Create a Tileset JSON

Create `data/tileset.json`:

```json
{
  "tileSize": 32,
  "tiles": [
    {
      "id": 0,
      "name": "Grass",
      "walkable": true,
      "image": "source/images/tiles/grass.png"
    },
    {
      "id": 4,
      "name": "Wall",
      "walkable": false,
      "image": "source/images/tiles/wall.png"
    }
  ]
}
```

## Step 3: Build and Test

```bash
make build
make run
```

The game will automatically load `data/tileset.json` if it exists!

## Step 4: Create a Custom Map (Optional)

Create `data/map.json`:

```json
{
  "width": 10,
  "height": 8,
  "goal": {"x": 8, "y": 2},
  "tiles": [
    [4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
    [4, 0, 0, 0, 0, 0, 0, 0, 5, 4],
    [4, 0, 0, 0, 0, 0, 0, 0, 0, 4],
    [4, 0, 0, 0, 0, 0, 0, 0, 0, 4],
    [4, 0, 0, 0, 0, 0, 0, 0, 0, 4],
    [4, 0, 0, 0, 0, 0, 0, 0, 0, 4],
    [4, 0, 0, 0, 0, 0, 0, 0, 0, 4],
    [4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
  ]
}
```

To load it, add this to `main.lua` after creating the map:

```lua
currentMap:loadFromJSON("data/map.json")
```

## Tips

- **Tile IDs 0-5 are built-in** and work without images
- **Start custom tiles at ID 6+** to avoid conflicts
- **Use hitboxes** to control collision precisely
- **Test frequently** as you add new tiles

## Need Help?

See [TILE_SYSTEM.md](TILE_SYSTEM.md) for the complete guide with:
- Detailed tile properties
- Hitbox configuration
- Advanced techniques
- Troubleshooting

Happy mapping! 🗺️
