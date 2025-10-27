# App Store Submission Guide for RepRight

## ✅ Completed
- [x] App icon (RR logo design)
- [x] Privacy Policy created and hosted at: https://rajveer-gill.github.io/RepRight/PRIVACY_POLICY
- [x] Debug code removed
- [x] App tested on physical iPhone

## 📋 Next Steps: Archive & Submit

### Step 1: Archive the App in Xcode

1. **Open Xcode** and open `FitFormAI.xcodeproj`
2. **Select "Any iOS Device"** in the scheme selector (top bar)
3. Go to **Product → Archive**
4. Wait for archive to complete
5. When done, the **Organizer** window will open

### Step 2: Create App Store Connect Record

You need an **Apple Developer Account** ($99/year):

1. Go to https://appstoreconnect.apple.com
2. Log in with your Apple Developer account
3. Click **"My Apps"** → **"+"** → **"New App"**
4. Fill in:
   - **Platform:** iOS
   - **Name:** RepRight
   - **Primary Language:** English
   - **Bundle ID:** com.novatra.RepRight (already exists)
   - **SKU:** repright-001 (internal ID)
   - **User Access:** Full Access
5. Click **"Create"**

### Step 3: Fill Out App Information

In App Store Connect, complete these sections:

#### App Information
- **Category:** Health & Fitness
- **Privacy Policy URL:** https://rajveer-gill.github.io/RepRight/PRIVACY_POLICY
- **Subtitle:** AI-Powered Fitness Training
- **Promotional Text:** Transform your fitness journey with personalized AI workout plans
- **Keywords:** fitness, workout, AI, strength training, gym, exercise, training, health
- **Support URL:** https://github.com/rajveer-gill/RepRight
- **Marketing URL:** (optional)

#### App Description (up to 4000 characters)
```
RepRight is your AI-powered personal trainer, designed to help you achieve your fitness goals with personalized workout plans and real-time form analysis.

🎯 KEY FEATURES:

• AI-Generated Workout Plans
Create personalized workout routines tailored to your fitness level, goals, and available equipment. Whether you're a beginner or advanced athlete, our AI crafts the perfect program for you.

• Smart Workout Customization
Modify your workout plans with AI-powered safety checks. Want to replace an exercise? Our AI ensures your changes are safe and effective.

• Real-Time Workout Tracking
Track your progress with streak counters and workout completion. Stay motivated and consistent with daily reminders and progress tracking.

• Secure & Private
Your workout data is stored locally on your device and protected with Face ID/Touch ID. No cloud storage, complete privacy.

• Multiple Workout Types
Supports weightlifting, cardio, HIIT, yoga, sports training, calisthenics, and more.

• Goal-Based Training
Target specific goals: muscle gain, weight loss, strength building, endurance, flexibility, or general fitness.

• Equipment-Aware Plans
Works with any equipment you have - from full gyms to bodyweight-only exercises.

WHO IS THIS FOR?
• Beginners looking for structured workout guidance
• Experienced athletes wanting optimized programs
• Anyone seeking personalized fitness plans
• Users who want privacy-first fitness tracking

DOWNLOAD TODAY and start your fitness journey with AI-powered precision.
```

#### Age Rating
Answer the questionnaire:
- **Medical/Treatment Information:** No
- **Alcohol, Tobacco, Drugs:** No
- **Horror/Fear Themes:** No
- **Contests:** No
- **Unrestricted Web Access:** No
- **Gambling/Contests:** No
- **Mature/Suggestive Themes:** No

#### Pricing & Availability
- **Price:** Free
- **Availability:** All territories

### Step 4: Upload from Xcode

1. In Xcode **Organizer**, select your archive
2. Click **"Distribute App"**
3. Select **"App Store Connect"**
4. Click **"Upload"**
5. Follow the prompts:
   - **Automatically manage signing** ✅
   - Include bitcode: No
   - Upload symbols: Yes
6. Click **"Upload"** and wait for completion

### Step 5: Add Screenshots (Required)

In App Store Connect, go to **"Version Information"**:

#### Screenshots Needed:
- **iPhone 6.7"** (iPhone 14 Pro Max, 15 Pro Max) - 1290 x 2796 pixels
- **iPhone 6.5"** (iPhone 11 Pro Max, XS Max) - 1242 x 2688 pixels
- **iPhone 5.5"** (iPhone 8 Plus) - 1242 x 2208 pixels

**How to take screenshots:**
1. In Xcode, run your app in simulator
2. Use iPhone 14 Pro Max simulator
3. Go through key screens:
   - Home screen with workout card
   - Workout plan view
   - Active workout screen
   - Profile screen
4. Take screenshots (⌘ + S) or (Device → Screenshots)
5. Upload to App Store Connect

### Step 6: Submit for Review

Once everything is complete:
1. Click **"Submit for Review"**
2. Answer export compliance questions
3. Wait for review (typically 1-7 days)

## 📝 Important Notes

### Before Submission
- [ ] Test the app thoroughly on a physical device
- [ ] Verify all features work
- [ ] Check that app icon displays correctly
- [ ] Ensure Privacy Policy link works
- [ ] Test Face ID/Touch ID functionality

### Common Rejection Reasons to Avoid
- ❌ Crash on launch
- ❌ Privacy Policy URL doesn't work
- ❌ Missing functionality described in app description
- ❌ Inappropriate content
- ❌ Copyright violations

### Monitoring Submission
- Check App Store Connect daily for updates
- If rejected, read review notes carefully
- Fix issues and resubmit

## 🎉 After Approval

Once approved:
1. App will go live within 24 hours
2. Share on social media
3. Monitor reviews and respond to users
4. Plan updates based on feedback

## 💰 Future Enhancements

Consider adding:
- App Store subscriptions for API costs
- In-app purchases for premium features
- Analytics to track usage
- Crash reporting (Firebase Crashlytics)

---

**Good luck with your App Store submission!** 🚀

