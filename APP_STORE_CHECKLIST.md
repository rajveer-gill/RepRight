# App Store Submission Checklist for RepRight

## ✅ Completed
- [x] App renamed to RepRight throughout codebase
- [x] OpenAI API key configured and gitignored
- [x] App runs on physical iPhone
- [x] Workout customization feature implemented
- [x] Face ID/Touch Lean implemented for app security
- [x] Workout save slots (3 max)
- [x] Workout flow with timers and progress tracking
- [x] Edit profile functionality
- [x] Simplified profile screen

## 🔴 Critical Issues (Must Fix Before Submission)

### 1. OpenAI API Key Architecture ⚠️ **MAJOR ISSUE**
**Problem:** Your API key is hardcoded in the client app (`Config.swift`).
- **Each user would need their own API key** (not user-friendly)
- **You can't monetize** or control usage
- **Security risk** if key is exposed

**Solutions:**
**Option A (Recommended):** Build a backend service
- Create a simple Node.js/Python backend
- Store your API key on the server
- App makes requests to your backend → backend calls OpenAI
- You control costs, can add subscriptions, rate limiting

**Option B:** Make it free with usage limits
- Users enter their own API key in-app
- Add warning that it requires a paid OpenAI account
- Not ideal for App Store

### 2. Privacy Policy Required 🔐
**Required for:** Camera, Photo Library, Microphone permissions

Create a privacy policy covering:
- What data you collect (workout videos, user profiles)
- How you use it (local storage only, OpenAI API)
- Third-party services (OpenAI's policies)
- Host it online and add URL to App Store Connect

### 3. Debug Code Removal 🧹
Remove all debug print statements:
- 7 prints in `AppState.swift` ✅ (Done)
- 15 prints in `OpenAIService.swift` (partial - need to finish)
- 2 prints in `WorkoutPlanView.swift`
- 2 prints in `FormCheckView.swift`

## 📱 Required App Assets

### App Icon
- [ ] Create 1024x1024 PNG app icon
- [ ] Add to `Assets.xcassets/AppIcon.appiconset`
- [ ] Test on device to verify

### Launch Screen
- [ ] Design launch screen
- [ ] Add to `Info.plist` UILaunchScreen section
- [ ] Current uses placeholder assets

## 📋 App Store Connect Setup

### Metadata Required
- [ ] App Name: "RepRight"
- [ ] Subtitle: "AI-Powered Fitness Training"
- [ ] Description (up to 4000 characters)
- [ ] Keywords (100 characters max)
- [ ] Category: Health & Fitness
- [ ] Age Rating: Complete questionnaire
- [ ] App Preview (optional but recommended)
- [ ] Screenshots:
  - [ ] 6.7" iPhone (iPhone 14 Pro Max, 15 Pro Max)
  - [ ] 6.5" iPhone (iPhone XS Max, 11 Pro Max)
  - [ ] 5.5" iPhone (iPhone 8 Plus)

### Required Documents
- [ ] Privacy Policy URL (hosted online)
- [ ] Support URL (can be GitHub repo or website)
- [ ] Marketing URL (optional)

### Pricing
- [ ] Set as Free or Paid
- [ ] If you want to monetize, set up In-App Purchases
- [ ] Subscription model recommended for covering API costs

## 🔧 Technical Checks

### Build Settings
- [x] Bundle ID: `com.novatra.RepRight`
- [x] Version: 1.0
- [x] Build: 1
- [ ] Signing Certificate (App Store distribution)
- [ ] Provisioning Profile (App Store)

### Info.plist
- [x] Camera permission description ✅
- [x] Photo Library permission description ✅
- [x] Microphone permission description ✅
- [ ] Privacy policy URL (add before submission)

### Required Capabilities
- [x] Camera Usage ✅
- [x] Photo Library Usage ✅
- [x] Microphone Usage ✅
- [x] Face ID/Touch ID ✅

## 🧪 Testing

### Pre-Submission Testing
- [ ] Test on multiple iPhone models/sizes
- [ ] Test workout generation
- [ ] Test workout flow completion
- [ ] Test saving/loading workout slots
- [ ] Test face ID unlocking
- [ ] Test edit profile
- [ ] Test form analysis (if submitting with that feature)
- [ ] Verify all features work offline (local storage)

## 📝 Legal & Compliance

### Required for Submission
- [ ] Privacy Policy (hosted URL)
- [ ] Terms of Service (recommended)
- [ ] Export Compliance documentation (if applicable)
- [ ] Content Rights (ensure you own/use AI-generated content legally)

### App Store Guidelines
- [ ] Review [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [ ] Ensure all features comply
- [ ] Health claims compliance (fitness apps category)

## 🚀 Submission Process

### Before You Upload
1. [ ] Remove all debug prints
2. [ ] Add app icon
3. [ ] Add launch screen
4. [ ] Create privacy policy
5. [ ] Complete App Store Connect setup
6. [ ] Archive app in Xcode (Product → Archive)
7. [ ] Export for App Store submission
8. [ ] Upload via Xcode or Transporter

### After Upload
1. [ ] Complete App Store Connect questionnaire
2. [ ] Submit for review
3. [ ] Respond to any review feedback
4. [ ] Handle approvals/rejections

## 💰 Monetization Strategy (Future)

### Option 1: Free with In-App Purchases
- Free: Limited workouts per month
- Premium ($4.99/month): Unlimited workouts, advanced features

### Option 2: One-Time Purchase
- App costs $2.99 upfront
- User adds their own OpenAI API key

### Option 3: Freemium with Subscription
- Free tier: Basic workouts
- Pro ($9.99/month): AI-powered customization, form analysis

## 📊 Estimated Timeline

- **Fix critical issues:** 1-2 days
- **Create assets:** 2-3 days
- **App Store Connect setup:** 1 day
- **Review waiting:** 1-7 days
- **Total:** ~1-2 weeks

## 🎯 Next Steps (Priority Order)

1. **Fix OpenAI API architecture** (Choose Option A or B)
2. **Create Privacy Policy** and host it
3. **Remove all debug prints** (complete the remaining ones)
4. **Create app icon** (1024x1024)
5. **Set up App Store Connect** account and app record
6. **Archive and upload** the app
7. **Submit for review**

---

**Need Help?**
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

