# Quick Setup Guide for RepRight

## Step-by-Step Setup

### 1. Get Your OpenAI API Key

1. Go to [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Sign in or create an account
3. Click **"Create new secret key"**
4. Give it a name (e.g., "RepRight")
5. Copy the key immediately (you won't see it again!)

### 2. Add Billing Information

⚠️ **Important**: OpenAI requires a paid account for GPT-4 and DALL-E 3 access.

1. Go to [https://platform.openai.com/account/billing](https://platform.openai.com/account/billing)
2. Add a payment method
3. Add credits ($5-10 is plenty to start)

### 3. Configure the App

🔐 **Important:** Your API key will be protected and NOT committed to git.

**Setup Steps:**

1. **Copy the config template:**
   ```bash
   cp Config.swift.example FitFormAI/FitFormAI/Config.swift
   ```

2. **Add your API key:**
   - Open `FitFormAI/FitFormAI/Config.swift` in Xcode or any text editor
   - Find this line:
     ```swift
     static let openAIAPIKey = "YOUR_OPENAI_API_KEY_HERE"
     ```
   - Replace with your actual key:
     ```swift
     static let openAIAPIKey = "sk-proj-xxxxxxxxxxxxxxxxxxxxx"
     ```
   - Save the file

3. **Verify it's protected:**
   ```bash
   git status
   ```
   - `Config.swift` should NOT appear in the output
   - If it does, check your `.gitignore` file

**Security:** See [SECURITY.md](SECURITY.md) for more details.

### 4. Open in Xcode

```bash
cd FitFormAI
open FitFormAI.xcodeproj
```

### 5. Select Device

- In Xcode, click the device selector at the top
- Choose an iOS Simulator (iPhone 14 Pro or newer recommended)
- Or select your connected iPhone

### 6. Build and Run

- Press `⌘ + R` or click the ▶️ Run button
- Wait for the build to complete
- The app will launch!

---

## First Time Using the App

### 1. Complete Onboarding

You'll be guided through 6 steps:

1. **Welcome**: Introduction
2. **Personal Info**: Name and age
3. **Fitness Level**: Beginner, Intermediate, Advanced, or Athlete
4. **Goals**: Select one or more fitness goals
5. **Workout Preferences**: Types and equipment
6. **Restrictions**: Any injuries or limitations (optional)

### 2. Generate Your First Workout Plan

1. Navigate to the **Workout** tab
2. Tap **"Generate AI Workout Plan"**
3. Wait 10-20 seconds while AI creates your plan
4. Review your personalized program!

### 3. Try Form Analysis

1. Navigate to the **Form Check** tab
2. Select an exercise (e.g., "Squat")
3. Tap **"Get Camera Setup Guide"**
4. View the AI-generated positioning diagram
5. Either **Record** a new video or **Upload** an existing one
6. Wait for AI analysis (30-60 seconds)
7. Review your detailed form feedback!

---

## Testing Tips

### For Quick Testing (Without Recording):

If you want to test the app without actually recording workout videos:

1. Use the **Upload** option instead of Record
2. You can use any short video from your photo library
3. The AI will attempt to analyze it (though results will be limited if it's not an actual workout)

### For Best Results:

1. **Record a proper workout video**:
   - Follow the camera positioning guide
   - Use good lighting
   - Wear form-fitting clothes
   - Perform 2-3 reps of the exercise

2. **Keep videos short**: 10-30 seconds is optimal

3. **Be patient**: AI analysis takes time (it's processing multiple video frames)

---

## Cost Management

### Estimated API Costs:

- **Workout Plan**: $0.01-0.03 per generation
- **Camera Setup Guide**: $0.05 per exercise (includes image generation)
- **Form Analysis**: $0.10-0.20 per video

### Tips to Save Money:

1. **Cache workout plans**: Don't regenerate constantly
2. **Reuse camera guides**: Save the positioning guide image
3. **Limit form checks**: Only analyze your best attempts
4. **Keep videos short**: Shorter videos = fewer frames = lower cost
5. **Test with one exercise**: Master the feature before widespread use

### Monitor Your Usage:

Check your OpenAI dashboard regularly:
- [https://platform.openai.com/usage](https://platform.openai.com/usage)

Set up usage limits:
- [https://platform.openai.com/account/limits](https://platform.openai.com/account/limits)

---

## Troubleshooting

### "OpenAI API key not found"

- Double-check you've added your key to either `Info.plist` or `Config.swift`
- Make sure there are no extra spaces or quotes
- Rebuild the app after adding the key

### "Authentication failed"

- Your API key might be invalid
- Generate a new key from OpenAI dashboard
- Ensure you have a paid OpenAI account

### "Model not found"

- You need GPT-4 access (requires paid account)
- Check your OpenAI account tier
- Add billing information if you haven't

### "Rate limit exceeded"

- You're making too many requests too quickly
- Wait a minute and try again
- Consider upgrading your OpenAI tier

### Camera not working

- Go to iPhone Settings > RepRight
- Enable Camera and Photo Library permissions
- Restart the app

### Video analysis fails

- Make sure video is under 30 seconds
- Check your internet connection
- Verify you have sufficient OpenAI credits

---

## Security Reminder

🔐 **Never commit your API key to version control!**

If you accidentally commit your key:
1. Immediately revoke it in the OpenAI dashboard
2. Generate a new key
3. Update your local configuration
4. Use `.gitignore` to exclude `Config.swift`

---

## Next Steps

Once you're up and running:

1. **Explore all features**: Try each tab and feature
2. **Customize your profile**: Update goals and preferences
3. **Track your progress**: Use the app regularly
4. **Share feedback**: Note any issues or suggestions

---

## Need Help?

- Check the main [README.md](README.md) for detailed documentation
- Review OpenAI API documentation
- Check iOS development resources

---

**Happy training! 💪**

