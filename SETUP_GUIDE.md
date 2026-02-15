# Vitality Setup Guide

This guide will walk you through setting up the Vitality iOS app from the generated file structure.

## Prerequisites

Before you begin, make sure you have:

- **macOS Sequoia or later**
- **Xcode 16.0+** installed from the Mac App Store
- **iOS 26 Simulator** or physical device running iOS 26+
- **Claude API Key** from Anthropic (sign up at https://console.anthropic.com/)

## Step-by-Step Setup

### 1. Create the Xcode Project

Since the files are already generated, you need to create an Xcode project to contain them:

1. **Open Xcode**

2. **Create New Project**:
   - File > New > Project...
   - Select **iOS** > **App**
   - Click **Next**

3. **Configure Project**:
   - **Product Name**: `Vitality`
   - **Team**: Select your Apple Developer account (free account is fine for testing)
   - **Organization Identifier**: `com.yourname.vitality` (use your own)
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: **SwiftData**
   - **Include Tests**: ✓ (recommended)
   - Click **Next**

4. **Save Location**:
   - Navigate to: `/Users/markksantos/Documents/Programming Projects/Vitality`
   - **Important**: Save the Xcode project in the root `Vitality` folder
   - Click **Create**

### 2. Replace Default Files

Xcode creates some default files we don't need:

1. **Delete** these files from Xcode (Move to Trash):
   - `VitalityApp.swift` (in the root of the target)
   - `ContentView.swift`
   - `Item.swift` (if present)

2. **In Finder**, open the `Vitality` project folder

3. **Drag and drop** the `Vitality` subfolder into Xcode's Project Navigator:
   - Make sure to check **"Copy items if needed"**
   - Select **"Create groups"** (not folder references)
   - Ensure your target is checked

Your Project Navigator should now look like:
```
Vitality (project)
├── Vitality (group)
│   ├── App
│   ├── Models
│   ├── Views
│   ├── ViewModels
│   ├── Services
│   ├── Components
│   ├── Utilities
│   └── Resources
├── VitalityTests
└── Assets.xcassets
```

### 3. Configure App Capabilities

#### 3.1 Add HealthKit

1. Select your project in the Project Navigator
2. Select the **Vitality** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Search for and add **HealthKit**

#### 3.2 Add Privacy Descriptions

1. Still in your target, go to the **Info** tab
2. Add these keys by clicking **+** in the Custom iOS Target Properties section:

| Key | Type | Value |
|-----|------|-------|
| `NSCameraUsageDescription` | String | `"Vitality needs camera access to scan meals and nutrition labels for accurate nutrition tracking."` |
| `NSPhotoLibraryUsageDescription` | String | `"Vitality needs photo access to save meal photos for your nutrition log."` |
| `NSHealthShareUsageDescription` | String | `"Vitality reads your health data to provide personalized insights and track your fitness progress."` |
| `NSHealthUpdateUsageDescription` | String | `"Vitality saves workout data to keep your fitness history in sync."` |

### 4. Add Color Assets

1. Select `Assets.xcassets` in the Project Navigator
2. For each color below, click **+** > **Color Set**:

**Required Colors:**

| Name | Light Mode (Hex) | Dark Mode (Hex) |
|------|------------------|-----------------|
| `SageGreen` | `#8FBC8F` | `#8FBC8F` |
| `WarmCream` | `#FFF8DC` | `#2C2C2E` |
| `NavyBlue` | `#1E3A5F` | `#3A5A7F` |
| `HealthGreen` | `#4CAF50` | `#4CAF50` |
| `GentleAmber` | `#FFB74D` | `#FFB74D` |
| `AppBackground` | System: `Background` | System: `Background` |
| `CardBackground` | System: `Secondary Background` | System: `Secondary Background` |

To add a color:
1. Right-click in Assets.xcassets
2. Select **New Color Set**
3. Name it (e.g., `SageGreen`)
4. In Attributes Inspector, set **Appearances** to "Any, Dark" if you want dark mode support
5. Click the color well and enter the hex value

### 5. Configure API Keys

1. Open `Vitality/Utilities/Constants.swift`
2. Replace the placeholder API key:

```swift
enum APIKeys {
    static let claudeAPIKey = "sk-ant-api03-..." // Your actual Claude API key
}
```

**How to get a Claude API Key:**
1. Go to https://console.anthropic.com/
2. Sign up or log in
3. Navigate to API Keys
4. Create a new key
5. Copy and paste it into Constants.swift

⚠️ **Important**: Never commit your API key to version control!

### 6. Fix SwiftData Schema

Open `Vitality/App/VitalityApp.swift` and verify the schema includes all models:

```swift
let schema = Schema([
    UserProfile.self,
    Meal.self,
    FoodEntry.self,
    PantryItem.self,
    Workout.self,
    HealthGoalProgress.self,
    DailySummary.self,
    WorkoutPlan.self
])
```

### 7. Build the Project

1. Select a simulator: **iPhone 16 Pro (iOS 26.0)** or higher
2. Press **Cmd + B** to build
3. Fix any compilation errors (there shouldn't be any if you followed the steps)

### 8. Run the App

1. Press **Cmd + R** or click the Play button
2. The app should launch in the simulator
3. You'll see the onboarding flow on first launch

## Common Issues & Solutions

### Issue: "Cannot find type 'ModelContext' in scope"

**Solution**: Make sure you imported SwiftData at the top of the file:
```swift
import SwiftData
```

### Issue: "No such module 'HealthKit'"

**Solution**:
1. Verify HealthKit capability is added (Step 3.1)
2. Clean build folder: **Product > Clean Build Folder** (Cmd + Shift + K)
3. Rebuild

### Issue: Colors not showing up

**Solution**:
1. Verify color assets are created in Assets.xcassets (Step 4)
2. The app uses fallback colors if assets aren't found
3. Check Attributes Inspector for each color set

### Issue: "API key not configured" error

**Solution**:
1. Add your Claude API key to Constants.swift (Step 5)
2. Make sure there are no extra spaces or quotes
3. Rebuild the project

### Issue: Liquid Glass effects not showing

**Note**: Liquid Glass (`glassEffect`) is an iOS 26+ feature. If running on iOS 25 or earlier:
- The app automatically falls back to `.ultraThinMaterial`
- Update your simulator to iOS 26+ for the full experience

### Issue: "Could not create ModelContainer"

**Solution**:
1. Reset simulator: **Device > Erase All Content and Settings...**
2. Clean build folder
3. Rebuild and run

## Testing the App

### Onboarding
1. On first launch, you'll go through 5 onboarding steps
2. Enter your information (use realistic test data)
3. Complete all steps to reach the main app

### Home Dashboard
- View today's nutrition snapshot (will be empty initially)
- Try quick actions (camera features are placeholders for now)
- Check HealthKit integration (may need to authorize in Settings)

### Meals Tab
- Tap + to open meal scanner (placeholder view)
- Log sample meals manually
- View meals by date

### Pantry Tab
- Switch between Pantry/Fridge/Freezer
- Scan pantry (placeholder for now)
- Add items manually

### Fitness Tab
- View activity rings from HealthKit
- Log workouts
- Generate AI workout plan (requires API key)

## Next Steps

### Enable AI Features

The following features require implementation:

1. **Camera Integration**: Add `AVFoundation` camera capture
2. **AI Analysis**: Connect Vision + Claude API for meal recognition
3. **Barcode Scanning**: Implement barcode detection with Vision framework
4. **Recipe Suggestions**: Call AI service with pantry contents

### Recommended Development Order

1. ✅ **Setup** (you just did this!)
2. 🔨 **Camera Integration** - Get the camera working
3. 🤖 **AI Meal Analysis** - Connect photo → AI → nutrition data
4. 📊 **Data Visualization** - Charts and progress tracking
5. 🎨 **Polish** - Animations, haptics, edge cases

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [Claude API Docs](https://docs.anthropic.com/)
- [Open Food Facts API](https://world.openfoodfacts.org/data)

## Need Help?

If you encounter issues not covered here:

1. Check the main README.md for architecture details
2. Review the code comments in each file
3. Search Apple Developer Forums
4. Check the Claude API documentation

---

**You're all set! 🎉**

Run the app and explore the UI. The foundation is solid – now it's time to bring the AI features to life!
