//
//  OnboardingContainerView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var currentStep = 0
    @State private var profile = OnboardingProfile()

    private let totalSteps = 5

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        VitalityTheme.primaryFallback.opacity(0.1),
                        VitalityTheme.secondaryFallback.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress indicator
                    OnboardingProgressBar(
                        currentStep: currentStep,
                        totalSteps: totalSteps
                    )
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Content
                    TabView(selection: $currentStep) {
                        WelcomeStepView(profile: $profile)
                            .tag(0)

                        HealthProfileStepView(profile: $profile)
                            .tag(1)

                        GoalsStepView(profile: $profile)
                            .tag(2)

                        ActivityStepView(profile: $profile)
                            .tag(3)

                        PermissionsStepView(profile: $profile)
                            .tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(VitalityTheme.Animation.spring, value: currentStep)

                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentStep > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentStep -= 1
                                }
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }

                        Button(currentStep == totalSteps - 1 ? "Get Started" : "Continue") {
                            if currentStep == totalSteps - 1 {
                                completeOnboarding()
                            } else {
                                withAnimation {
                                    currentStep += 1
                                }
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!canProceed)
                    }
                    .padding(.horizontal, VitalityTheme.Spacing.md)
                    .padding(.vertical, VitalityTheme.Spacing.lg)
                }
            }
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return !profile.name.isEmpty && profile.birthDate != nil && profile.heightCm > 0 && profile.weightKg > 0
        case 2: return profile.primaryGoal != nil
        case 3: return true
        case 4: return true
        default: return false
        }
    }

    private func completeOnboarding() {
        // Create user profile
        let userProfile = UserProfile(
            name: profile.name,
            birthDate: profile.birthDate ?? Date(),
            heightCm: profile.heightCm,
            weightKg: profile.weightKg,
            healthConditions: profile.healthConditions,
            medications: profile.medications,
            primaryGoal: profile.primaryGoal,
            secondaryGoals: profile.secondaryGoals,
            activityLevel: profile.activityLevel,
            preferredWorkouts: profile.preferredWorkouts,
            availableEquipment: profile.availableEquipment
        )

        // Calculate personalized targets
        calculateTargets(for: userProfile)

        // Save to SwiftData
        modelContext.insert(userProfile)
        try? modelContext.save()

        // Mark onboarding as complete
        withAnimation {
            hasCompletedOnboarding = true
        }
    }

    private func calculateTargets(for profile: UserProfile) {
        // Basic BMR calculation using Mifflin-St Jeor equation
        let heightCm = profile.heightCm
        let weightKg = profile.weightKg
        let age = profile.age

        let bmr: Double
        // Assuming user can specify gender, defaulting to average
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) + 5

        // Apply activity multiplier
        let tdee = bmr * profile.activityLevel.multiplier

        // Adjust based on goals
        var calorieTarget = Int(tdee)

        if let primaryGoal = profile.primaryGoal {
            switch primaryGoal {
            case .loseWeight:
                calorieTarget -= 500 // 500 calorie deficit
            case .buildMuscle:
                calorieTarget += 300 // Slight surplus
            default:
                break
            }
        }

        profile.calorieTarget = calorieTarget
        profile.proteinTarget = Int(weightKg * 1.6) // 1.6g per kg for active individuals
        profile.carbsTarget = Int(Double(calorieTarget) * 0.45 / 4) // 45% of calories from carbs
        profile.fatTarget = Int(Double(calorieTarget) * 0.30 / 9) // 30% of calories from fat
        profile.fiberTarget = 30

        // Adjust sodium/cholesterol based on health conditions
        if profile.healthConditions.contains(.highBloodPressure) {
            profile.sodiumLimit = 1500 // Lower for high BP
        } else {
            profile.sodiumLimit = 2300
        }

        if profile.healthConditions.contains(.highCholesterol) {
            profile.cholesterolLimit = 200 // Lower for high cholesterol
            profile.saturatedFatLimit = 13
        } else {
            profile.cholesterolLimit = 300
            profile.saturatedFatLimit = 20
        }
    }
}

// MARK: - Onboarding Profile Model

@Observable
class OnboardingProfile {
    var name: String = ""
    var birthDate: Date?
    var heightCm: Double = 0
    var weightKg: Double = 0
    var healthConditions: [HealthCondition] = []
    var medications: [String] = []
    var primaryGoal: HealthGoal?
    var secondaryGoals: [HealthGoal] = []
    var activityLevel: ActivityLevel = .moderate
    var preferredWorkouts: [WorkoutType] = []
    var availableEquipment: [Equipment] = []

    // Calculated targets (set during onboarding completion)
    var calorieTarget: Int = 2000
    var proteinTarget: Int = 150
    var carbsTarget: Int = 250
    var fatTarget: Int = 65
    var fiberTarget: Int = 30
    var sodiumLimit: Int = 2300
    var cholesterolLimit: Int = 300
    var saturatedFatLimit: Int = 20
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 4)
                    .fill(step <= currentStep ? VitalityTheme.primaryFallback : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .animation(VitalityTheme.Animation.spring, value: currentStep)
            }
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(VitalityTheme.Typography.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(VitalityTheme.primaryFallback)
            .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.medium))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(VitalityTheme.Animation.quickSpring, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(VitalityTheme.Typography.headline)
            .foregroundStyle(VitalityTheme.primaryFallback)
            .frame(height: 52)
            .padding(.horizontal, VitalityTheme.Spacing.xl)
            .background(VitalityTheme.primaryFallback.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.medium))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(VitalityTheme.Animation.quickSpring, value: configuration.isPressed)
    }
}
