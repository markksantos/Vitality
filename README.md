# Vitality – AI-Powered Health & Nutrition App

<p align="center">
  <img src="https://img.shields.io/badge/iOS-26.0+-blue.svg" alt="iOS 26.0+">
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0">
  <img src="https://img.shields.io/badge/SwiftUI-6.0-green.svg" alt="SwiftUI 6.0">
  <img src="https://img.shields.io/badge/SwiftData-6.0-purple.svg" alt="SwiftData">
</p>

A minimalist, AI-powered health companion that combines meal tracking, pantry management, nutrition planning, and fitness tracking into one seamless experience. Designed with Apple's Liquid Glass design language for iOS 26+.

## 🌟 Features

### 🍽️ AI-Powered Meal Tracking
- **Photo Scanning**: Snap a photo of your meal and let AI identify foods and estimate nutrition
- **Barcode Scanner**: Scan product barcodes for instant nutrition information
- **Nutrition Label Recognition**: Extract nutrition facts from labels with OCR
- **Manual Entry**: Search and add foods manually with fuzzy matching

### 🏠 Smart Pantry Management
- **Pantry Scanning**: Take photos of your pantry/fridge to automatically inventory items
- **Expiration Tracking**: Get notified when items are about to expire
- **Recipe Suggestions**: AI-powered recipe recommendations based on your pantry items and health goals
- **Organization**: Categorize items by storage location (Pantry, Fridge, Freezer)

### 💪 Fitness Tracking
- **HealthKit Integration**: Sync steps, workouts, heart rate, and more
- **Workout Logging**: Quick log walks or detailed workout tracking
- **AI Workout Plans**: Generate personalized workout plans based on your goals, equipment, and fitness level
- **Progress Tracking**: Visualize your activity with beautiful ring charts

### 🧠 Personalized Insights
- **Health-Focused**: Tailored for conditions like high cholesterol, high blood pressure, diabetes
- **AI Recommendations**: Get smart, context-aware suggestions throughout the day
- **Nutrition Analysis**: Track macros, fiber, sodium, cholesterol, and more
- **Trend Visualization**: Weekly and monthly reports on your progress

## 📋 Requirements

- **iOS 26.0+** (Uses Liquid Glass design)
- **Xcode 16.0+**
- **Swift 6.0+**
- **Claude API Key** (for AI features)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
cd "/Users/markksantos/Documents/Programming Projects/Vitality"
```

### 2. Create Xcode Project

Since this is a file structure, you'll need to create an Xcode project:

1. Open Xcode
2. Create a new project: **File > New > Project**
3. Select **iOS > App**
4. Fill in project details:
   - **Product Name**: Vitality
   - **Team**: Select your development team
   - **Organization Identifier**: com.yourname.vitality
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: SwiftData
5. Save it in the `Vitality` directory

### 3. Add Files to Xcode

1. Delete the default `VitalityApp.swift` and `ContentView.swift` created by Xcode
2. In Finder, drag all folders from the `Vitality` directory into your Xcode project
3. Select **Copy items if needed** and **Create groups**

### 4. Configure API Keys

1. Open `Vitality/Utilities/Constants.swift`
2. Replace the placeholder API key:

```swift
enum APIKeys {
    static let claudeAPIKey = "your-actual-claude-api-key-here"
}
```

⚠️ **Security Note**: In production, use the Keychain to store sensitive keys, not hardcoded strings.

### 5. Add Required Capabilities

In Xcode, select your target and add:

1. **HealthKit**:
   - Go to **Signing & Capabilities**
   - Click **+ Capability**
   - Add **HealthKit**

2. **Camera Usage**:
   - Go to **Info** tab
   - Add `NSCameraUsageDescription`: "Vitality needs camera access to scan meals and nutrition labels"

3. **Photo Library**:
   - Add `NSPhotoLibraryAddUsageDescription`: "Vitality needs photo access to save meal photos"

### 6. Add Color Assets

Create a new Color Set in `Assets.xcassets` for each theme color:

- **SageGreen**: #8FBC8F
- **WarmCream**: #FFF8DC
- **NavyBlue**: #1E3A5F
- **HealthGreen**: #4CAF50
- **GentleAmber**: #FFB74D
- **AppBackground**: System Background
- **CardBackground**: System Background Secondary

### 7. Build and Run

1. Select a simulator running **iOS 26.0+** or your physical device
2. Press **Cmd + R** to build and run

## 📁 Project Structure

```
Vitality/
├── App/
│   └── VitalityApp.swift          # Main app entry point
├── Models/
│   ├── UserProfile.swift          # User health profile & goals
│   ├── Meal.swift                 # Meal and food entry models
│   ├── PantryItem.swift           # Pantry inventory
│   ├── Workout.swift              # Fitness tracking
│   └── HealthGoalProgress.swift   # Progress tracking
├── Views/
│   ├── MainTabView.swift          # Tab bar container
│   ├── Onboarding/                # 5-step onboarding flow
│   ├── Home/                      # Dashboard with daily summary
│   ├── Meals/                     # Meal logging & history
│   ├── Pantry/                    # Pantry management
│   └── Fitness/                   # Activity & workout tracking
├── ViewModels/
│   └── (Future: MVVM view models)
├── Services/
│   ├── AIService.swift            # Claude API integration
│   ├── VisionService.swift        # Image processing (Vision framework)
│   ├── HealthKitService.swift     # HealthKit data sync
│   ├── FoodDatabaseService.swift  # Open Food Facts API
│   └── PersistenceService.swift   # SwiftData operations
├── Components/
│   ├── NutritionRing.swift        # Circular progress indicators
│   ├── QuickActionButton.swift    # Home screen quick actions
│   ├── InsightCard.swift          # AI insight display
│   ├── MealCard.swift             # Meal display components
│   └── GlassContainer.swift       # Liquid Glass UI elements
└── Utilities/
    ├── Constants.swift            # Theme, spacing, colors
    └── Extensions.swift           # View, Date, Color extensions
```

## 🎨 Design Philosophy

### Calm Intelligence
- **Serenity over urgency** – No aggressive red/orange warnings
- **Encouragement over guilt** – Progress, not punishment
- **Simplicity over features** – Every tap should feel meaningful

### Visual Language
- **Liquid Glass**: Used for navigation bars, tab bars, and floating elements
- **Soft Palette**: Sage greens, warm creams, subtle navy
- **SF Symbols**: Friendly, rounded 2pt stroke weight icons
- **Smooth Animations**: Spring physics for all interactions

### One-Thumb Navigation
Every feature is designed to be reachable with one hand for ease of use.

## 🔧 Implementation Status

### ✅ Complete
- [x] SwiftData models and relationships
- [x] Onboarding flow (5 steps)
- [x] Home dashboard layout
- [x] Meals view with date navigation
- [x] Pantry view with category grouping
- [x] Fitness view with HealthKit integration
- [x] AI Service architecture
- [x] Reusable UI components
- [x] Theme system with Liquid Glass support

### 🚧 To Implement
- [ ] Camera integration for meal/pantry scanning
- [ ] Full AI photo analysis pipeline
- [ ] Barcode scanning functionality
- [ ] Recipe suggestion feature
- [ ] AI workout plan generation
- [ ] Detailed nutrition reports
- [ ] Export data to PDF/CSV
- [ ] Push notifications
- [ ] Settings & profile management
- [ ] Data encryption for sensitive info

## 🧪 Testing

### Unit Tests
```bash
# Run tests in Xcode
Cmd + U
```

### Preview Tests
Most views include SwiftUI previews. Use:
```swift
#Preview {
    YourView()
        .modelContainer(for: [YourModel.self], inMemory: true)
}
```

## 🔐 Privacy & Security

### Data Storage
- All health data is stored locally using **SwiftData**
- Encrypted storage for sensitive information (medications, etc.)
- No cloud sync by default (can be added with CloudKit)

### API Usage
- AI analysis happens server-side via Claude API
- Images are sent as base64-encoded data
- No persistent storage of images on servers

### Permissions
- **HealthKit**: Read/write activity, workouts, and health metrics
- **Camera**: Capture meal and pantry photos
- **Photo Library**: Save meal photos (optional)
- **Notifications**: Reminders and insights (optional)

## 📱 App Store Preparation

### Required Assets
1. **App Icon**: 1024x1024px
2. **Screenshots**: All required iPhone sizes
3. **Preview Video**: 30 seconds max
4. **Privacy Policy**: URL to hosted privacy policy

### Keywords
health, nutrition, meal tracking, AI, cholesterol, blood pressure, fitness, pantry, recipes, diet

### App Store Description Example

**Transform Your Health Journey with AI**

Vitality is your intelligent health companion, designed to make nutrition tracking effortless and personalized. Whether you're managing high cholesterol, blood pressure, or simply want to eat healthier, Vitality adapts to your unique needs.

**Key Features:**
• Instant meal logging with AI photo recognition
• Smart pantry management with recipe suggestions
• Personalized nutrition insights
• Fitness tracking with HealthKit integration
• Health condition-specific recommendations

**Your Privacy, Protected**
All your data stays on your device. No cloud sync required.

Download Vitality and start your journey to better health today.

## 🤝 Contributing

This is a personal project, but suggestions and feedback are welcome!

## 📄 License

All rights reserved. This project is for personal/portfolio use.

## 🙏 Acknowledgments

- **Claude AI** by Anthropic for natural language processing
- **Open Food Facts** for nutrition database
- **Apple HealthKit** for fitness integration
- **SF Symbols** for beautiful iconography

## 📞 Support

For questions or issues:
- Email: your-email@example.com
- GitHub Issues: (if you make this public)

---

**Built with ❤️ using SwiftUI, SwiftData, and Claude AI**

*Vitality – Your path to balanced health*
