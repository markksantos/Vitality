# Vitality Architecture Documentation

## Overview

Vitality is built using **SwiftUI** with **SwiftData** for persistence, following a modified MVVM architecture pattern. The app is designed for iOS 26+ to take advantage of the latest Liquid Glass design language.

## Architecture Pattern: MVVM + Services

```
┌─────────────────────────────────────────────────────────┐
│                         Views                           │
│  (SwiftUI - Presentation Layer)                        │
│  • Declarative UI                                       │
│  • Bindings to ViewModels                              │
│  • Reusable Components                                 │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                     ViewModels                          │
│  (Business Logic Layer)                                 │
│  • State management                                     │
│  • Data transformation                                  │
│  • Orchestrates service calls                          │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                      Services                           │
│  (Data & Business Logic Layer)                          │
│  • AIService - Claude API integration                   │
│  • VisionService - Image processing                     │
│  • HealthKitService - Fitness data                      │
│  • FoodDatabaseService - Nutrition lookup               │
│  • PersistenceService - SwiftData operations            │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                       Models                            │
│  (Data Layer - SwiftData)                               │
│  • UserProfile                                          │
│  • Meal / FoodEntry                                     │
│  • PantryItem                                           │
│  • Workout                                              │
│  • HealthGoalProgress                                   │
└─────────────────────────────────────────────────────────┘
```

## Directory Structure

```
Vitality/
├── App/
│   └── VitalityApp.swift          # App entry point, ModelContainer setup
│
├── Models/                         # SwiftData models
│   ├── UserProfile.swift          # User info, health conditions, goals
│   ├── Meal.swift                 # Meal logging, nutrition data
│   ├── PantryItem.swift           # Pantry inventory management
│   ├── Workout.swift              # Fitness tracking
│   └── HealthGoalProgress.swift   # Goal tracking & milestones
│
├── Views/                          # SwiftUI Views
│   ├── MainTabView.swift          # Tab bar container
│   │
│   ├── Onboarding/                # First-launch experience
│   │   ├── OnboardingContainerView.swift
│   │   ├── WelcomeStepView.swift
│   │   ├── HealthProfileStepView.swift
│   │   ├── GoalsStepView.swift
│   │   ├── ActivityStepView.swift
│   │   └── PermissionsStepView.swift
│   │
│   ├── Home/                      # Dashboard
│   │   └── HomeDashboardView.swift
│   │
│   ├── Meals/                     # Meal tracking
│   │   └── MealsView.swift
│   │
│   ├── Pantry/                    # Pantry management
│   │   └── PantryView.swift
│   │
│   └── Fitness/                   # Activity tracking
│       └── FitnessView.swift
│
├── ViewModels/                     # (Future) MVVM ViewModels
│   ├── HomeViewModel.swift
│   ├── MealViewModel.swift
│   ├── PantryViewModel.swift
│   └── FitnessViewModel.swift
│
├── Services/                       # Business logic & data access
│   ├── AIService.swift            # Claude API integration
│   ├── VisionService.swift        # Image processing
│   ├── HealthKitService.swift     # HealthKit integration
│   ├── FoodDatabaseService.swift  # Open Food Facts API
│   └── PersistenceService.swift   # SwiftData helpers
│
├── Components/                     # Reusable UI components
│   ├── NutritionRing.swift        # Circular progress indicators
│   ├── QuickActionButton.swift    # CTA buttons
│   ├── InsightCard.swift          # AI insight display
│   ├── MealCard.swift             # Meal cards
│   └── GlassContainer.swift       # Liquid Glass effects
│
└── Utilities/                      # Helpers & extensions
    ├── Constants.swift            # Theme, colors, API keys
    └── Extensions.swift           # View, Date, String extensions
```

## Data Flow

### 1. User Action → View → Service → Model

```
User taps "Scan Meal"
         ↓
    MealScannerView
         ↓
    VisionService.prepareImage()
         ↓
    AIService.analyzeMealPhoto()
         ↓
    Returns MealAnalysis
         ↓
    Create Meal + FoodEntry models
         ↓
    PersistenceService.saveMeal()
         ↓
    SwiftData persists to disk
         ↓
    View updates via @Query
```

### 2. Background Data Sync

```
App Launch
    ↓
HealthKitService.requestAuthorization()
    ↓
HealthKitService.fetchTodayStats()
    ↓
Updates @Published properties
    ↓
SwiftUI automatically re-renders views
```

## Key Design Patterns

### 1. Dependency Injection

Services are injected via:
- `@StateObject` for observable services
- `@Environment(\.modelContext)` for SwiftData context
- Singleton pattern for stateless services (e.g., `AIService.shared`)

### 2. Async/Await

All network and heavy operations use Swift Concurrency:

```swift
Task {
    let analysis = try await aiService.analyzeMealPhoto(imageData)
    // Update UI on main actor
    await MainActor.run {
        self.meal = analysis
    }
}
```

### 3. SwiftData Queries

Views use `@Query` for reactive data:

```swift
@Query(sort: \Meal.timestamp, order: .reverse)
private var meals: [Meal]
```

SwiftData automatically updates the view when data changes.

### 4. Service Layer Abstraction

Services encapsulate external dependencies:

- **AIService**: All Claude API calls
- **VisionService**: All Vision framework operations
- **HealthKitService**: All HealthKit interactions
- **FoodDatabaseService**: All Open Food Facts API calls
- **PersistenceService**: All SwiftData CRUD operations

This makes testing easier and keeps views clean.

## State Management

### View-Level State

```swift
@State private var showingSheet = false
@State private var selectedDate = Date()
```

### App-Level State

```swift
@AppStorage("hasCompletedOnboarding")
private var hasCompletedOnboarding = false
```

### Observable Services

```swift
@StateObject private var healthKitService = HealthKitService.shared
```

### Persistent Data

```swift
@Query private var meals: [Meal]
@Environment(\.modelContext) private var modelContext
```

## Network Layer

### API Service Structure

```swift
actor AIService {
    private func makeAPICall() async throws -> String
    func analyzeMealPhoto() async throws -> MealAnalysis
    func suggestRecipes() async throws -> [RecipeSuggestion]
    func generateWorkoutPlan() async throws -> WorkoutPlan
}
```

**Actor Isolation**: `AIService` is an `actor` to ensure thread-safe API calls.

### Error Handling

```swift
enum AIServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case httpError(statusCode: Int)
    case parsingError

    var errorDescription: String? { ... }
}
```

## Data Persistence

### SwiftData Models

All models use `@Model` macro:

```swift
@Model
class Meal {
    var id: UUID
    var timestamp: Date
    var mealType: MealType
    @Relationship(deleteRule: .cascade) var foods: [FoodEntry]
    // ...
}
```

### Relationships

- **Meal → FoodEntry**: One-to-many with cascade delete
- **UserProfile → HealthGoalProgress**: Separate models linked by context

### Model Container

Created once in `VitalityApp.swift`:

```swift
var sharedModelContainer: ModelContainer = {
    let schema = Schema([...])
    let configuration = ModelConfiguration(...)
    return try! ModelContainer(for: schema, configurations: [configuration])
}()
```

## UI Components Architecture

### Component Hierarchy

```
GlassTabBar (Liquid Glass)
    ↓
TabButton × 4 (Home, Meals, Pantry, Fitness)
    ↓
Individual Tab Views
    ↓
Reusable Components (Cards, Rings, Buttons)
```

### Design Tokens

All design constants live in `VitalityTheme`:

```swift
VitalityTheme.primaryFallback
VitalityTheme.Typography.headline
VitalityTheme.Spacing.md
VitalityTheme.Radius.card
VitalityTheme.Animation.spring
```

### Adaptive UI

Components adapt to iOS version:

```swift
@ViewBuilder
func adaptiveGlass() -> some View {
    if #available(iOS 26.0, *) {
        self.glassEffect(.regular, in: .capsule)
    } else {
        self.background(.ultraThinMaterial)
    }
}
```

## AI Integration

### Photo Analysis Pipeline

```
1. User takes photo (AVFoundation)
   ↓
2. VisionService.prepareImage()
   - Resize to max 1024px
   - Compress to <500KB
   ↓
3. VisionService.detectFoodItems()
   - Vision framework pre-processing
   ↓
4. AIService.analyzeMealPhoto()
   - Send to Claude API
   - Receive structured JSON
   ↓
5. Parse JSON → MealAnalysis
   ↓
6. Create SwiftData models
   ↓
7. Save to persistence layer
```

### Prompt Engineering

Prompts are carefully crafted for:
- **Structured output**: Always request JSON
- **Confidence scores**: AI provides certainty levels
- **Conservative estimates**: Better to underestimate than overestimate

## Testing Strategy

### Unit Tests

Test services in isolation:

```swift
func testAIServiceParsing() async throws {
    let mockResponse = """
    {"foods": [...]}
    """
    let result = try parseJSON(mockResponse)
    XCTAssertEqual(result.foods.count, 2)
}
```

### Preview Tests

All views include SwiftUI previews:

```swift
#Preview {
    HomeDashboardView()
        .modelContainer(for: [...], inMemory: true)
}
```

### Integration Tests

Test full flows:
1. Onboarding → Profile creation
2. Meal logging → Nutrition calculation
3. HealthKit → Activity sync

## Performance Considerations

### Image Processing

- Resize images before sending to API
- Use `.task` for async loading
- Cache analyzed meals

### SwiftData Optimization

- Use `@Query` predicates to limit results
- Avoid loading all relationships at once
- Delete old data periodically

### HealthKit Queries

- Batch queries by date range
- Use statistics queries for aggregates
- Cache recent results

## Security & Privacy

### API Keys

- **Development**: Stored in `Constants.swift` (gitignored)
- **Production**: Should use Keychain Services

### Health Data

- All data stored locally with SwiftData
- HealthKit data never leaves the device
- User can delete all data anytime

### Network Security

- HTTPS only
- API keys in headers, not URLs
- No persistent image storage on servers

## Future Enhancements

### Planned Features

1. **ViewModels Layer**: Move business logic from views
2. **CloudKit Sync**: Optional iCloud backup
3. **Widgets**: Home screen widgets for quick stats
4. **Watch App**: Apple Watch companion
5. **Shortcuts**: Siri integration for meal logging
6. **Export**: PDF reports for doctors

### Technical Debt

- [ ] Add comprehensive error handling
- [ ] Implement proper loading states
- [ ] Add offline mode support
- [ ] Improve accessibility
- [ ] Add haptic feedback
- [ ] Implement data encryption for sensitive info

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [HealthKit Framework](https://developer.apple.com/documentation/healthkit)
- [Vision Framework](https://developer.apple.com/documentation/vision)
- [Claude API Docs](https://docs.anthropic.com/)

---

**Last Updated**: 2026-01-30
**iOS Target**: 26.0+
**Swift Version**: 6.0
