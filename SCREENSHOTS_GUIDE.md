# Screenshots Guide for RepRight App Store Submission

## Required Screenshot Sizes

You need screenshots in these specific sizes for App Store Connect:

1. **6.7" (1290 x 2796)** - iPhone 14 Pro Max, 15 Pro Max, 12 Pro Max
2. **6.5" (1242 x 2688)** - iPhone 11 Pro Max, XS Max  
3. **5.5" (1242 x 2208)** - iPhone 8 Plus

## How to Take Screenshots in Simulator

### Step 1: Launch Simulator
1. Open Xcode
2. Open `FitFormAI.xcodeproj`
3. Click the device selector (top bar) → **iPhone 14 Pro Max**
4. Click **Run** (⌘ + R)

### Step 2: Navigate to Screens
Take these screenshots in this order:

**1. Home Screen with Workout Card**
- Shows: Plan name, "Today's Workout" card, streak counter
- **How to capture:**
  - Once app loads to home screen
  - Press **⌘ + S** (or Device → Screenshots)
  - File saves to your Desktop

**2. Workout Plan Overview**
- Shows: Weekly schedule, workout list, exercise details
- **How to capture:**
  - Tap the "Workout" tab at bottom
  - Should show your workout plan details
  - Press **⌘ + S**

**3. Active Set View (Workout in Progress)**
- Shows: Pulsating "YOU GOT THIS" message, timers
- **How to capture:**
  - Start a workout from home screen
  - Pick any exercise
  - Should show the pulsating workout screen
  - Press **⌘ + S**

**4. Rest Period View**
- Shows: Cool colors, rest timer, "Start Next Set" button
- **How to capture:**
  - After completing a set, rest screen appears
  - Press **⌘ + S**

**5. Profile Screen**
- Shows: Your avatar, profile info, Edit Profile button
- **How to capture:**
  - Tap "Profile" tab at bottom
  - Press **⌘ + S**

### Step 3: Find Your Screenshots

Screenshots are saved to: `/Users/raj/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Media/Library/Screenshots/`

Or just press **⌘ + Shift + 4** and drag a selection on the simulator window.

### Step 4: Alternative Method (Device Photos)

You can also:
1. Click the simulator window
2. Press **⌘ + Shift + 4**
3. Select the entire simulator window
4. Screenshot saves to your Desktop

## Uploading to App Store Connect

1. Go to App Store Connect
2. Select your app
3. Go to "Version Information"
4. Scroll to "App Screenshots"
5. Upload screenshots to the correct size slots:
   - Drag 6.7" screenshots to the 6.7" slot
   - Drag 6.5" screenshots to the 6.5" slot
   - Drag 5.5" screenshots to the 5.5" slot

## Tips

- **Landscape screenshots:** Not required (app is portrait only)
- **Device frames:** Not needed (Apple adds frames automatically)
- **Image quality:** PNG format preferred, highest quality
- **No status bar issues:** Simulator screenshots don't show real status bars

## Quick Workflow

```bash
# 1. Launch app in iPhone 14 Pro Max simulator
# 2. Navigate through app to each screen
# 3. Press ⌘ + S for each screenshot
# 4. Find screenshots in simulator's screenshot folder
# 5. Upload to App Store Connect
```

---

**Ready to take screenshots?** Open Xcode and let's go! 📸

