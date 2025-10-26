# 🔐 Security Guide - RepRight

## ⚠️ CRITICAL: Protecting Your API Keys

**NEVER commit API keys to GitHub!** Anyone can see them and use your credits.

---

## 🛡️ Setup Instructions

### Step 1: Create Your Config File

The actual `Config.swift` file is **gitignored** to protect your API key.

**On your MacBook, run these commands:**

```bash
# Navigate to the project directory
cd FitFormAI/FitFormAI

# Copy the example file
cp ../../Config.swift.example Config.swift

# Open it for editing
open Config.swift
```

Or manually:
1. Copy `Config.swift.example` from the root directory
2. Paste it to `FitFormAI/FitFormAI/Config.swift`
3. Open `Config.swift` in Xcode

### Step 2: Add Your API Key

In `FitFormAI/FitFormAI/Config.swift`, replace this line:

```swift
static let openAIAPIKey = "YOUR_OPENAI_API_KEY_HERE"
```

With your actual key:

```swift
static let openAIAPIKey = "sk-proj-xxxxxxxxxxxxxxxxxxxxx"
```

### Step 3: Verify It's Protected

Check that `Config.swift` appears grayed out in Xcode or marked as ignored:

```bash
# This should show Config.swift as ignored
git status

# Config.swift should NOT appear in untracked files
```

---

## 🔍 What's Protected

These files are **automatically ignored** by `.gitignore`:

- `FitFormAI/FitFormAI/Config.swift` - Contains your actual API key
- `FitFormAI/FitFormAI/APIKeys.swift` - If you create one
- `.env` - Environment variables
- `*.xcconfig` - Xcode configuration files

These files are **safe to commit**:

- `Config.swift.example` - Template with no real keys
- `.env.example` - Template with no real keys
- `.gitignore` - Protects your secrets

---

## 📋 Before Pushing to GitHub

**Checklist:**

- [ ] `Config.swift` is in `FitFormAI/FitFormAI/` directory
- [ ] Your real API key is in `Config.swift`
- [ ] Run `git status` - Config.swift should NOT appear
- [ ] Only `Config.swift.example` is tracked by git
- [ ] Test the app works with your API key

---

## 🚨 If You Accidentally Committed Your API Key

**Act immediately:**

### 1. Revoke the API Key
- Go to https://platform.openai.com/api-keys
- Find the exposed key
- Click "Revoke" or "Delete"
- Generate a new key

### 2. Remove from Git History

```bash
# Remove the file from git (keeps local copy)
git rm --cached FitFormAI/FitFormAI/Config.swift

# Commit the removal
git commit -m "Remove Config.swift with exposed API key"

# Push to GitHub
git push origin main
```

### 3. Clean Git History (if key was already pushed)

If the key is in your git history, you need to remove it:

```bash
# This is more complex - consider these options:

# Option A: Use BFG Repo Cleaner (easier)
# Download from: https://rtyley.github.io/bfg-repo-cleaner/

# Option B: Use git filter-branch (advanced)
# See: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
```

---

## 🔐 Alternative: Using Info.plist (Less Secure)

If you prefer using `Info.plist`:

**⚠️ WARNING:** This is less secure because Info.plist is often committed to git.

If you use this method:
1. Add `Info.plist` to `.gitignore`
2. Create `Info.plist.example` as a template
3. Document this in your README

**We recommend using `Config.swift` instead.**

---

## 👥 Team Setup

When a teammate clones the repo:

1. They won't have `Config.swift` (it's gitignored)
2. They follow the setup instructions above
3. They add their own API key
4. Everyone has their own key (better for tracking usage)

---

## 📊 Monitoring API Usage

Keep your API key secure AND monitor usage:

1. **Set Spending Limits**
   - https://platform.openai.com/account/limits
   - Set a monthly maximum (e.g., $10)

2. **Check Usage Regularly**
   - https://platform.openai.com/usage
   - Review daily/weekly

3. **Enable Email Alerts**
   - OpenAI can email you when you hit thresholds
   - Set up in your account settings

---

## ✅ Best Practices

### DO:
- ✅ Keep API keys in gitignored files
- ✅ Use different keys for development and production
- ✅ Set spending limits on your OpenAI account
- ✅ Monitor usage regularly
- ✅ Revoke keys you're not using
- ✅ Use team/organization keys when working with others

### DON'T:
- ❌ Commit API keys to GitHub
- ❌ Share API keys in Slack/Discord/email
- ❌ Screenshot API keys
- ❌ Hard-code keys in committed files
- ❌ Use the same key across multiple projects
- ❌ Give keys to untrusted parties

---

## 🆘 Need Help?

If you're unsure about security:

1. Check OpenAI's security best practices: https://platform.openai.com/docs/guides/safety-best-practices
2. Review GitHub's guide on removing sensitive data: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
3. Consider using secrets management tools for production apps

---

## 📝 Summary

```bash
# Quick setup:
cp Config.swift.example FitFormAI/FitFormAI/Config.swift
# Add your API key to the copied file
# Verify git status doesn't show Config.swift
# You're secure! 🎉
```

**Remember:** Your API key = Your money. Protect it like a password!

