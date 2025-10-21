# FitForm AI - Your AI-Powered Personal Trainer 💪

<div align="center">

![FitForm AI](https://img.shields.io/badge/Platform-iOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green)
![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4o-purple)

*Transform your fitness journey with AI-powered workout plans and real-time form analysis*

</div>

---

## 🌟 Features

### 🎯 AI-Powered Workout Plans
- **Personalized Programs**: Custom workout plans based on your fitness level, goals, and available equipment
- **Smart Adaptation**: Plans that adapt to your restrictions and preferences
- **Multiple Disciplines**: Support for weightlifting, cardio, HIIT, yoga, sports training, and more

### 📹 Form Analysis with Computer Vision
- **Real-time Analysis**: Upload or record videos of your exercises
- **Intelligent Camera Positioning**: AI suggests optimal camera angles and positions for each exercise
- **Visual Setup Guides**: AI-generated diagrams showing exactly where to place your camera
- **Detailed Feedback**: Comprehensive analysis with strengths, improvements, and specific corrections
- **Safety First**: Focus on injury prevention and proper biomechanics

### 🎨 Modern, Elegant UI
- **Sleek Design**: Professional dark theme with gradient accents
- **Intuitive Navigation**: Easy-to-use tab-based interface
- **Smooth Animations**: Polished interactions throughout
- **Progress Tracking**: Visual stats and achievement tracking

---

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+**
- **iOS 17.0+** deployment target
- **OpenAI API Key** (required for all AI features)

### Installation

1. **Clone the Repository**
   ```bash
   cd FitFormAI
   ```

2. **Get Your OpenAI API Key**
   - Visit [OpenAI Platform](https://platform.openai.com/api-keys)
   - Create a new API key
   - Copy the key (you won't be able to see it again!)

3. **Configure API Key (IMPORTANT!)**

   🔐 **Your API key is protected** - `Config.swift` is gitignored and won't be committed.

   **Setup:**
   ```bash
   # Copy the template file
   cp Config.swift.example FitFormAI/FitFormAI/Config.swift
   ```

   Then open `FitFormAI/FitFormAI/Config.swift` and replace:
   ```swift
   static let openAIAPIKey = "YOUR_OPENAI_API_KEY_HERE"
   ```
   
   With your actual key:
   ```swift
   static let openAIAPIKey = "sk-proj-xxxxxxxxxxxxxxxxxxxxx"
   ```

   ⚠️ **Security Note**: 
   - `Config.swift` is gitignored and will NOT be committed
   - Only `Config.swift.example` (without your real key) is tracked
   - See [SECURITY.md](SECURITY.md) for detailed security instructions
   - **NEVER commit your actual API key to GitHub!**

4. **Open in Xcode**
   ```bash
   open FitFormAI.xcodeproj
   ```

5. **Select Target Device**
   - Choose an iOS simulator or connected device
   - iPhone 14 Pro or newer recommended for best experience

6. **Build and Run**
   - Press `⌘ + R` or click the Run button
   - The app will launch on your selected device

---

## 📱 App Structure

```
FitFormAI/
├── FitFormAI/
│   ├── FitFormAIApp.swift          # App entry point
│   ├── ContentView.swift            # Root view controller
│   ├── Config.swift                 # Configuration & API keys
│   ├── Info.plist                   # App configuration
│   │
│   ├── Models/
│   │   ├── AppState.swift           # Global app state
│   │   ├── UserProfile.swift        # User data models
│   │   ├── WorkoutPlan.swift        # Workout & exercise models
│   │   └── FormAnalysis.swift       # Form analysis models
│   │
│   ├── Services/
│   │   └── OpenAIService.swift      # OpenAI API integration
│   │
│   ├── Views/
│   │   ├── Onboarding/
│   │   │   ├── OnboardingView.swift      # Multi-step onboarding
│   │   │   └── OnboardingComponents.swift # Reusable components
│   │   │
│   │   ├── Main/
│   │   │   ├── MainTabView.swift         # Tab navigation
│   │   │   └── HomeView.swift            # Dashboard
│   │   │
│   │   ├── Workout/
│   │   │   └── WorkoutPlanView.swift     # Workout plan display
│   │   │
│   │   ├── FormCheck/
│   │   │   ├── FormCheckView.swift       # Form analysis entry
│   │   │   ├── FormAnalysisResultView.swift  # Results display
│   │   │   └── VideoRecorderView.swift   # Video recording
│   │   │
│   │   └── Profile/
│   │       └── ProfileView.swift         # User profile & settings
│   │
│   └── Utilities/
│       └── ColorExtension.swift          # UI helpers
│
└── README.md
```

---

## 🎯 How It Works

### 1. Onboarding Flow

When you first launch the app, you'll go through a beautiful onboarding experience:

- **Welcome Screen**: Introduction to FitForm AI
- **Personal Info**: Name and age
- **Fitness Level**: Beginner to Athlete
- **Goals Selection**: Weight loss, muscle gain, endurance, etc.
- **Workout Preferences**: Types and available equipment
- **Restrictions**: Any injuries or limitations

### 2. Workout Plan Generation

The AI analyzes your profile and generates a personalized workout plan:

```swift
// The AI considers:
- Your fitness level
- Your goals
- Available equipment
- Any restrictions or injuries
- Preferred workout types

// It creates:
- Custom exercises
- Appropriate sets, reps, and rest periods
- Proper progression over time
- Rest day scheduling
```

### 3. Form Analysis Process

#### Step 1: Select Exercise
Choose the exercise you want to analyze from a comprehensive list.

#### Step 2: Get Camera Setup Guide
The AI determines the **optimal camera position**:
- Best angle (front, side, 45°, etc.)
- Ideal distance from camera
- Proper camera height
- Step-by-step setup instructions

#### Step 3: Visual Guide Generation
Using **DALL-E 3**, the app generates a custom diagram showing:
- Stick figure performing the exercise
- Camera position indicator
- Field of view visualization
- Labeled measurements

#### Step 4: Record or Upload Video
- **Record**: Use the in-app recorder with the suggested setup
- **Upload**: Select a video from your photo library

#### Step 5: AI Analysis
The system:
1. Extracts key frames from your video
2. Sends frames to **GPT-4 Vision**
3. Analyzes form across multiple aspects
4. Generates comprehensive feedback

#### Step 6: Review Results
You receive:
- **Overall Score**: 0-100 rating
- **Strengths**: What you're doing well
- **Improvements**: Areas to work on
- **Detailed Feedback**: Specific corrections for each body part/movement aspect

---

## 🔧 Technical Details

### APIs Used

#### GPT-4o (Chat Completions)
- **Workout Plan Generation**: Creates personalized training programs
- **Camera Position Analysis**: Determines optimal recording angles
- **Form Analysis**: Evaluates exercise technique from video frames

#### GPT-4 Vision
- **Video Frame Analysis**: Analyzes exercise form from images
- **Multi-frame Processing**: Evaluates movement patterns across time

#### DALL-E 3
- **Camera Setup Diagrams**: Generates visual positioning guides
- **Style**: Clean, technical illustrations with clear annotations

### Key Technologies

- **SwiftUI**: Modern, declarative UI framework
- **AVFoundation**: Video recording and frame extraction
- **Combine**: Reactive programming for state management
- **PhotosUI**: Media library integration
- **URLSession**: Async/await API calls

### Performance Optimizations

- **Frame Sampling**: Extracts 8-12 key frames instead of processing entire video
- **Image Compression**: JPEG compression (70% quality) reduces upload size
- **Async/Await**: Non-blocking API calls maintain UI responsiveness
- **Local State Caching**: Stores user data and workout plans locally

---

## 💡 Best Practices

### For Best Form Analysis Results:

1. **Lighting**: Ensure good, even lighting on your body
2. **Background**: Use a plain background for better visibility
3. **Clothing**: Wear form-fitting clothes so movement is visible
4. **Camera Stability**: Use a tripod or stable surface
5. **Full Range**: Perform the complete movement (2-3 reps)
6. **Follow AI Guidance**: Use the suggested camera angle and distance

### For Safety:

- Always start with lighter weights
- Focus on form before adding weight
- Consult a healthcare professional for injuries
- Use the AI feedback as guidance, not medical advice

---

## 🎨 Design Philosophy

### Visual Identity

- **Color Scheme**: 
  - Primary: Blue (#007AFF)
  - Secondary: Purple (#5856D6)
  - Accent: Pink (#FF2D55)
  - Background: Dark Navy (#0A0E27, #1A1F3A)

- **Typography**: SF Pro (System Font)
  - Headlines: Bold, 36-48pt
  - Body: Regular, 16-17pt
  - Captions: Regular, 12-14pt

- **Components**:
  - Rounded corners (12-20pt radius)
  - Subtle shadows and glows
  - Gradient overlays
  - Glass morphism effects

### UX Principles

1. **Progressive Disclosure**: Show information as needed
2. **Clear Feedback**: Visual confirmation for all actions
3. **Error Prevention**: Validation before API calls
4. **Consistency**: Unified design language throughout
5. **Accessibility**: High contrast, clear labels

---

## 🔐 Privacy & Security

- **Local Storage**: User data stored on device
- **No Analytics**: No tracking or third-party analytics
- **API Security**: Secure HTTPS connections
- **Video Privacy**: Videos processed temporarily, not stored on servers
- **User Control**: Easy profile deletion and logout

---

## 📊 API Costs Estimation

OpenAI API costs (approximate):

| Feature | Model | Cost per Use |
|---------|-------|-------------|
| Workout Plan | GPT-4o | ~$0.01-0.03 |
| Camera Position | GPT-4o | ~$0.01 |
| Position Image | DALL-E 3 | ~$0.04 |
| Form Analysis | GPT-4o Vision | ~$0.10-0.20 |

**Tips to Reduce Costs**:
- Cache workout plans locally
- Reuse camera position guides
- Limit form analysis to final attempts
- Use shorter videos (15-30 seconds)

---

## 🚧 Future Enhancements

### Planned Features

- [ ] **Progress Photos**: Track physical transformation
- [ ] **Workout History**: Log and review past workouts
- [ ] **Social Features**: Share achievements with friends
- [ ] **Voice Coaching**: Real-time audio guidance during workouts
- [ ] **Wearable Integration**: Apple Watch support
- [ ] **Nutrition Tracking**: AI-powered meal planning
- [ ] **AR Form Overlay**: Real-time form correction with AR
- [ ] **Offline Mode**: Basic functionality without internet

### Technical Improvements

- [ ] **Video Compression**: Reduce upload size and time
- [ ] **Background Processing**: Analyze videos in background
- [ ] **CoreML Integration**: On-device form analysis
- [ ] **CloudKit Sync**: Sync data across devices
- [ ] **Widget Support**: Quick workout access from home screen

---

## 🤝 Contributing

This is currently a demonstration project. If you'd like to contribute or build upon it:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📝 License

This project is available as a reference implementation. Feel free to use it as inspiration for your own projects.

**Note**: You are responsible for:
- Compliance with OpenAI's terms of service
- API usage and associated costs
- User data privacy and security
- App Store guidelines (if publishing)

---

## 🆘 Troubleshooting

### Common Issues

**Problem**: "OpenAI API key not found" error
- **Solution**: Check that you've added your API key to `Config.swift` or `Info.plist`

**Problem**: Form analysis fails
- **Solution**: Ensure video is under 30 seconds and properly formatted

**Problem**: Camera permission denied
- **Solution**: Go to Settings > FitForm AI > Enable Camera and Photo Library

**Problem**: Workout plan generation slow
- **Solution**: OpenAI API can take 5-15 seconds; this is normal

**Problem**: Build errors in Xcode
- **Solution**: Clean build folder (Shift + Cmd + K) and rebuild

---

## 📧 Support

For questions or issues:
- Check the troubleshooting section above
- Review OpenAI API documentation
- Check iOS development documentation

---

## 🙏 Acknowledgments

- **OpenAI**: For powerful AI capabilities
- **Apple**: For excellent development tools
- **Fitness Community**: For exercise knowledge and best practices

---

## ⚠️ Disclaimer

This app is for educational and informational purposes. The AI-generated workout plans and form analysis should not replace professional advice from certified trainers, physical therapists, or medical professionals. Always consult with qualified professionals before starting any fitness program, especially if you have existing health conditions or injuries.

---

<div align="center">

**Built with ❤️ using SwiftUI and OpenAI**

*Start your fitness journey with AI-powered guidance today!*

</div>

