# 🚀 Initial Setup for GitHub

## For First-Time Setup on Your MacBook

Since you're pushing this to GitHub, follow these steps to set up the project securely:

### Step 1: Prepare the Repository

The current `Config.swift` file in `FitFormAI/FitFormAI/` contains placeholder text and should be gitignored:

```bash
# Make sure you're in the project root
cd RepRight

# Remove Config.swift from git tracking (if it was added)
git rm --cached FitFormAI/FitFormAI/Config.swift

# The .gitignore is already set up to ignore it going forward
```

### Step 2: Set Up Your Local Config

On your MacBook, create your actual config file:

```bash
# Copy the example template
cp Config.swift.example FitFormAI/FitFormAI/Config.swift

# Open it and add your real API key
open FitFormAI/FitFormAI/Config.swift
```

Edit the file and replace `YOUR_OPENAI_API_KEY_HERE` with your actual OpenAI API key.

### Step 3: Verify Security

Before pushing to GitHub:

```bash
# Check git status
git status

# Config.swift should NOT appear in the list
# If it does, something is wrong with .gitignore
```

### Step 4: Initial Commit

```bash
# Stage all files EXCEPT Config.swift (which is gitignored)
git add .

# Commit
git commit -m "Initial commit: FitForm AI - iOS fitness app with OpenAI integration"

# Push to GitHub
git push origin main
```

### Step 5: Verify on GitHub

1. Go to: https://github.com/rajveer-gill/RepRight
2. Browse the files
3. **Verify:** `Config.swift` should NOT be visible
4. **Verify:** `Config.swift.example` SHOULD be visible

✅ If you only see `Config.swift.example`, you're secure!

---

## What Gets Committed vs. What Doesn't

### ✅ Files That WILL Be Committed (Safe):

- `Config.swift.example` - Template with placeholder
- `.env.example` - Environment template
- `README.md` - Documentation
- `SECURITY.md` - Security guide
- All source code files
- `.gitignore` - Protection rules

### ❌ Files That WON'T Be Committed (Protected):

- `FitFormAI/FitFormAI/Config.swift` - Your actual API key
- `.env` - Any environment files with real keys
- `xcuserdata/` - Xcode user settings
- `build/` - Build artifacts

---

## For Team Members Cloning the Repo

When someone else clones your repo:

1. They clone it:
   ```bash
   git clone https://github.com/rajveer-gill/RepRight.git
   cd RepRight
   ```

2. They see `Config.swift` is missing (expected!)

3. They follow setup instructions:
   ```bash
   cp Config.swift.example FitFormAI/FitFormAI/Config.swift
   # Then add their own API key
   ```

4. They can now build and run the app

---

## Quick Checklist

Before your first push:

- [ ] `Config.swift.example` exists in root directory
- [ ] `FitFormAI/FitFormAI/Config.swift` has your real API key
- [ ] `.gitignore` includes `FitFormAI/FitFormAI/Config.swift`
- [ ] Run `git status` - Config.swift should NOT appear
- [ ] `SECURITY.md` and `README.md` are updated
- [ ] App builds and runs with your API key

---

## 🆘 Help! I Already Committed My API Key!

If you already pushed Config.swift with your real API key:

### 1. **IMMEDIATELY Revoke the Key**
- Go to: https://platform.openai.com/api-keys
- Find the key and click "Revoke"
- Generate a new key

### 2. **Remove from Git**
```bash
git rm --cached FitFormAI/FitFormAI/Config.swift
git commit -m "Remove Config.swift with API key"
git push origin main
```

### 3. **Clean History** (if needed)
If the key is in git history, see [SECURITY.md](SECURITY.md) for advanced cleanup.

---

You're all set! Your API keys are now protected. 🔐

