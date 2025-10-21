# Contributing to FitForm AI

Thank you for your interest in contributing to FitForm AI! 🎉

## Getting Started

### 1. Fork and Clone

```bash
# Fork the repo on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/RepRight.git
cd RepRight
```

### 2. Set Up Your Environment

```bash
# Copy the config template
cp Config.swift.example FitFormAI/FitFormAI/Config.swift

# Add your OpenAI API key to FitFormAI/FitFormAI/Config.swift
# See SECURITY.md for details
```

### 3. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

## 🔐 Security Rules

**NEVER commit these files:**
- `FitFormAI/FitFormAI/Config.swift` (contains your API key)
- `.env` files with real keys
- Any file with actual API keys or secrets

**Always:**
- Use `Config.swift.example` as a template
- Keep your API keys in gitignored files
- Review your changes before committing: `git diff`

## Code Style

### Swift Code
- Use SwiftLint recommendations
- Follow Apple's Swift API Design Guidelines
- Use meaningful variable names
- Add comments for complex logic

### File Organization
```
FitFormAI/
├── Models/          # Data models
├── Views/           # SwiftUI views
├── Services/        # API and business logic
├── Utilities/       # Helpers and extensions
└── Assets.xcassets/ # Images and colors
```

## Pull Request Process

### Before Submitting

1. **Test your changes**
   - Run the app on simulator
   - Test on physical device if possible
   - Verify all features work

2. **Check for API keys**
   ```bash
   # Make sure Config.swift is not in your commit
   git status
   
   # Review your changes
   git diff
   ```

3. **Update documentation**
   - Update README.md if needed
   - Add comments to new code
   - Update CHANGELOG.md

### Submitting

1. Push to your fork
   ```bash
   git push origin feature/your-feature-name
   ```

2. Open a Pull Request on GitHub
   - Use a clear title
   - Describe what you changed and why
   - Reference any related issues

3. Wait for review
   - Address any feedback
   - Keep the conversation constructive

## Types of Contributions

### 🐛 Bug Fixes
- Fix crashes or errors
- Improve error handling
- Fix UI issues

### ✨ Features
- Add new workout types
- Improve AI prompts
- Enhance UI/UX
- Add analytics

### 📚 Documentation
- Improve README
- Add code comments
- Create tutorials
- Fix typos

### 🎨 Design
- Improve UI components
- Add animations
- Enhance color schemes
- Improve accessibility

## Development Tips

### Testing AI Features

To avoid excessive API costs during development:

1. **Use mock responses** for initial testing
2. **Cache API responses** during development
3. **Use shorter videos** for form analysis testing
4. **Set OpenAI spending limits** on your account

### Debugging

- Use Xcode's debugger: Set breakpoints with `⌘ + \`
- Print statements: `print("Debug: \(variable)")`
- View console: `⇧ + ⌘ + C`

### Common Issues

**"OpenAI API key not found"**
- Check that `Config.swift` exists in `FitFormAI/FitFormAI/`
- Verify your API key is set correctly

**Build errors**
- Clean build folder: `⇧ + ⌘ + K`
- Rebuild: `⌘ + B`

## Code Review Checklist

Before requesting review, ensure:

- [ ] Code builds without errors
- [ ] No API keys in committed files
- [ ] Code follows Swift conventions
- [ ] Documentation is updated
- [ ] Changes are tested
- [ ] Git history is clean
- [ ] PR description is clear

## Questions?

- Check existing issues on GitHub
- Review [SECURITY.md](SECURITY.md) for security questions
- Review [README.md](README.md) for general information

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing! 🙏

