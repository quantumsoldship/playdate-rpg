# Makefile for Playdate RPG
# Requires Playdate SDK to be installed

# Project name
PROJECT = BasicRPG

# Source directory
SOURCE = source

# Output directory
OUTPUT = $(PROJECT).pdx

# Playdate Compiler
PDC = pdc

# Default target
all: build

# Build the project
build:
	@echo "Building $(PROJECT)..."
	$(PDC) $(SOURCE) $(OUTPUT)
	@echo "Build complete: $(OUTPUT)"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(OUTPUT)
	@echo "Clean complete"

# Rebuild (clean + build)
rebuild: clean build

# Run in simulator (macOS)
run: build
	@echo "Opening in Playdate Simulator..."
	open $(OUTPUT)

# Run in simulator (Windows - requires Playdate SDK in PATH)
run-win: build
	@echo "Opening in Playdate Simulator..."
	start $(OUTPUT)

# Run in simulator (Linux - if available)
run-linux: build
	@echo "Opening in Playdate Simulator..."
	PlaydateSimulator $(OUTPUT)

# Help
help:
	@echo "Playdate RPG Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make          - Build the project (default)"
	@echo "  make build    - Build the project"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make rebuild  - Clean and build"
	@echo "  make run      - Build and run in simulator (macOS)"
	@echo "  make run-win  - Build and run in simulator (Windows)"
	@echo "  make help     - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - Playdate SDK installed"
	@echo "  - pdc command in PATH"

.PHONY: all build clean rebuild run run-win run-linux help
