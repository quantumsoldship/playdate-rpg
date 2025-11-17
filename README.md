# Playdate RPG

A basic, easily expandable RPG game for the [Playdate](https://play.date/) handheld console.

## Features

- **Turn-based combat system** with random encounters
- **Advanced tile-based system** with custom tile support and hitboxes
- **Character progression** - gain XP, level up, and increase stats
- **Enemy system** with customizable templates
- **Polished UI** with visual health/XP bars and improved layout
- **Custom map support** - load your own maps and tilesets
- **Clean, modular architecture** designed for easy expansion

## Quick Start

### Requirements
- [Playdate SDK](https://play.date/dev/) (for building and running)

### Building
```bash
pdc source BasicRPG.pdx
```

### Running
- Drag `BasicRPG.pdx` to the Playdate Simulator
- Or upload to your Playdate device

## Gameplay

- **Move**: D-Pad
- **Attack** (in combat): A Button
- **Run** (in combat): B Button

Explore the randomly generated world, encounter enemies, and level up your character!

## How to Expand

This game is designed to be a foundation for your own RPG. Check out [`DEVELOPER_GUIDE.md`](DEVELOPER_GUIDE.md) for detailed information on:

- Adding new enemy types
- Creating custom maps
- Implementing inventory and equipment systems
- Adding NPCs and dialogue
- Building quests and story elements
- And much more!

## Project Structure

```
source/
├── main.lua       # Game loop and state management
├── player.lua     # Player character and stats
├── enemy.lua      # Enemy system
├── map.lua        # Map generation and rendering
├── tileset.lua    # Tile management and custom tile support
├── combat.lua     # Combat system
├── ui.lua         # User interface
└── pdxinfo        # Project metadata

data/
├── tileset_example.json  # Example tileset configuration
└── map_example.json      # Example custom map
```

## What You Can Build

Starting from this foundation, you can create:
- Classic JRPGs
- Roguelikes
- Dungeon crawlers
- Story-driven adventures
- Action RPGs
- And more!

## Documentation

- **[Tile System Guide](TILE_SYSTEM.md)** - Complete guide to creating custom tiles and maps
- **[Developer Guide](DEVELOPER_GUIDE.md)** - Comprehensive guide to expanding the game
- **[Playdate SDK Docs](https://sdk.play.date/)** - Official Playdate documentation

## License

Free to use and modify for your own projects!

---

*Built for Playdate by quantumsoldship*