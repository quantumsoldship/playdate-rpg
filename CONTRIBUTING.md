# Contributing to Playdate RPG

Thank you for your interest in contributing to this project! This is a starter template designed to be easily expandable, and contributions are welcome.

## Project Philosophy

This project is designed as a **foundation template** for creating RPG games on the Playdate console. The goal is to provide:

1. **Clean, readable code** - Easy to understand and modify
2. **Modular architecture** - Systems that work independently
3. **Comprehensive documentation** - Clear guides and examples
4. **Beginner-friendly** - Accessible to developers new to game development

## Ways to Contribute

### 1. Bug Reports
- Use GitHub Issues to report bugs
- Include steps to reproduce
- Mention your Playdate SDK version
- Include any error messages or console output

### 2. Feature Suggestions
- Suggest new core features that would benefit all users
- Explain the use case
- Consider if it fits the "basic RPG template" scope

### 3. Documentation Improvements
- Fix typos or unclear explanations
- Add more examples to EXAMPLES.md
- Improve the Developer Guide
- Add tutorials or walkthroughs

### 4. Code Contributions
- Bug fixes
- Performance improvements
- New modular systems (that maintain simplicity)
- Code quality improvements

## Contribution Guidelines

### Code Style

**Lua Conventions**:
- Use 4 spaces for indentation (not tabs)
- Use descriptive variable names
- Add comments for complex logic
- Keep functions focused and small
- Use local variables when possible

**Example**:
```lua
-- Good
function Player:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.defense)
    self.currentHP = self.currentHP - actualDamage
    return actualDamage
end

-- Avoid
function Player:td(d)
    local ad = math.max(1, d - self.def)
    self.hp = self.hp - ad
    return ad
end
```

### Project Structure

When adding new features:

1. **Create new files for new systems**
   - Don't bloat existing files
   - Example: `magic.lua` for magic system

2. **Update config.lua for new parameters**
   - Keep configuration centralized
   - Add sensible defaults

3. **Document in DEVELOPER_GUIDE.md**
   - Explain how to use the new system
   - Show integration examples

4. **Add examples to EXAMPLES.md**
   - Provide practical code samples
   - Show common use cases

### Commit Messages

Use clear, descriptive commit messages:

```
Good:
- "Add magic system with spell casting and mana"
- "Fix combat bug where defense was applied twice"
- "Update DEVELOPER_GUIDE.md with quest system examples"

Avoid:
- "Fixed stuff"
- "Update"
- "Changes"
```

### Pull Request Process

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow code style guidelines
   - Test your changes
   - Update documentation

4. **Commit your changes**
   ```bash
   git commit -m "Add feature: your feature description"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Describe what you changed and why
   - Reference any related issues
   - Include testing notes

### Testing

Before submitting:

1. **Build the game** - Ensure it compiles without errors
2. **Test in simulator** - Verify functionality works
3. **Check for regressions** - Ensure core features still work
4. **Test edge cases** - Try to break your feature

See TESTING.md for comprehensive testing guidelines.

## What We're Looking For

### High Priority
- Bug fixes
- Performance improvements
- Documentation improvements
- Better code examples
- Test coverage improvements

### Medium Priority
- New modular systems (magic, quests, etc.)
- Additional enemy/item templates
- Map generation improvements
- UI/UX enhancements

### Consider Carefully
- Breaking changes to existing APIs
- Features that significantly increase complexity
- Platform-specific code
- Dependencies on external libraries

## What Doesn't Fit This Project

- Complete game implementations (this is a template)
- Highly specific features (better as examples)
- Changes that make the code harder to understand
- Removal of documentation or examples

## Questions?

- Open a GitHub Issue for questions
- Check existing documentation first
- Be respectful and patient

## Recognition

Contributors will be acknowledged in the project. Significant contributions may be highlighted in the README.

## License

By contributing, you agree that your contributions will be licensed under the MIT License that covers this project.

---

Thank you for helping make this project better! 🎮✨
