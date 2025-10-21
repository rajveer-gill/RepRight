# 📍 API Key Locations Reference

## Where API Keys Are Stored

This document shows you exactly where API keys are used in the FitForm AI codebase.

---

## 🔐 Files That Store API Keys (Gitignored - Local Only)

These files should contain your **REAL** API key and are **gitignored**:

### 1. **`FitFormAI/FitFormAI/Config.swift`** ⭐ (Primary Method)
```swift
struct Config {
    static let openAIAPIKey = "YOUR_ACTUAL_KEY_HERE"
    
    static func getAPIKey() -> String {
        // Tries Info.plist first, then falls back to openAIAPIKey
    }
}
```

**Status:** ✅ Gitignored  
**Setup:** Copy from `Config.swift.example`

### 2. **`FitFormAI/FitFormAI/Info.plist`** (Alternative Method)
```xml
<key>OPENAI_API_KEY</key>
<string>YOUR_ACTUAL_KEY_HERE</string>
```

**Status:** ✅ Gitignored  
**Setup:** Copy from `Info.plist.example`

---

## 📄 Template Files (Committed to Git - Safe)

These are safe to commit - they contain **placeholder** text only:

### 1. **`Config.swift.example`**
```swift
static let openAIAPIKey = "YOUR_OPENAI_API_KEY_HERE"
```

### 2. **`FitFormAI/FitFormAI/Info.plist.example`**
```xml
<string>YOUR_OPENAI_API_KEY_HERE</string>
```

### 3. **`.env.example`**
```bash
OPENAI_API_KEY=your_openai_api_key_here
```

---

## 💻 Files That USE API Keys (Code - Safe to Commit)

These files **use** the API key but don't store it:

### 1. **`FitFormAI/FitFormAI/Services/OpenAIService.swift`**

**Line 12:** Loads the key
```swift
self.apiKey = Config.getAPIKey()
```

**Lines 14-16:** Validates the key
```swift
if apiKey.isEmpty || apiKey == "YOUR_OPENAI_API_KEY_HERE" {
    print("⚠️ WARNING: OpenAI API key not found. Please add it to Config.swift")
}
```

**Line 186:** Checks key before API calls
```swift
guard !apiKey.isEmpty else {
    throw APIError.missingAPIKey
}
```

**Line 197:** Sends key in API requests
```swift
request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
```

---

## 🎯 Setup Instructions

### **First Time Setup:**

1. **Copy the config template:**
   ```bash
   cp Config.swift.example FitFormAI/FitFormAI/Config.swift
   ```

2. **Add your API key to Config.swift:**
   ```swift
   static let openAIAPIKey = "sk-proj-YOUR_ACTUAL_KEY"
   ```

3. **Verify it's gitignored:**
   ```bash
   git status
   # Config.swift should NOT appear
   ```

### **Alternative: Using Info.plist:**

1. **Copy the plist template:**
   ```bash
   cp FitFormAI/FitFormAI/Info.plist.example FitFormAI/FitFormAI/Info.plist
   ```

2. **Add your key to Info.plist:**
   ```xml
   <key>OPENAI_API_KEY</key>
   <string>sk-proj-YOUR_ACTUAL_KEY</string>
   ```

---

## 🔍 How to Check for Exposed Keys

Run these commands to search for API keys:

```bash
# Search for any actual API keys (should find NONE after cleanup)
grep -r "sk-proj-" .

# Search for placeholder text (should find several - that's OK)
grep -r "YOUR_OPENAI_API_KEY_HERE" .

# Check what git will commit (API key files should NOT appear)
git status
```

---

## ✅ Security Checklist

Before pushing to GitHub:

- [ ] `Config.swift` is gitignored
- [ ] `Info.plist` is gitignored
- [ ] Run `git status` - neither file appears
- [ ] Run `grep -r "sk-proj-" .` - finds NO real keys
- [ ] Only `.example` files are tracked by git

---

## 🚨 If You Find an Exposed Key

1. **Immediately revoke it:** https://platform.openai.com/api-keys
2. **Generate a new key**
3. **Remove from git history** (see SECURITY.md)
4. **Update local Config.swift with new key**

---

## 📊 Summary

| File | Purpose | Contains Real Key? | Gitignored? | Committed? |
|------|---------|-------------------|-------------|------------|
| `FitFormAI/FitFormAI/Config.swift` | Store key | ✅ Yes | ✅ Yes | ❌ No |
| `FitFormAI/FitFormAI/Info.plist` | Store key (alt) | ✅ Yes | ✅ Yes | ❌ No |
| `Config.swift.example` | Template | ❌ No | ❌ No | ✅ Yes |
| `Info.plist.example` | Template | ❌ No | ❌ No | ✅ Yes |
| `OpenAIService.swift` | Uses key | ❌ No | ❌ No | ✅ Yes |

---

**Remember:** Your API key = Your money. Keep it secret, keep it safe! 🔐

