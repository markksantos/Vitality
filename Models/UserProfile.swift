//
//  UserProfile.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import Foundation
import SwiftData

@Model
class UserProfile {
    var id: UUID
    var name: String
    var birthDate: Date
    var heightCm: Double
    var weightKg: Double
    var healthConditions: [HealthCondition]
    var medications: [String]  // Encrypted in production
    var primaryGoal: HealthGoal?
    var secondaryGoals: [HealthGoal]
    var activityLevel: ActivityLevel
    var preferredWorkouts: [WorkoutType]
    var availableEquipment: [Equipment]

    // Calculated nutrition targets based on goals and health conditions
    var calorieTarget: Int
    var proteinTarget: Int
    var carbsTarget: Int
    var fatTarget: Int
    var fiberTarget: Int
    var sodiumLimit: Int
    var cholesterolLimit: Int
    var saturatedFatLimit: Int

    // Activity targets
    var stepGoal: Int
    var activeCalorieGoal: Int
    var exerciseMinuteGoal: Int

    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        birthDate: Date,
        heightCm: Double,
        weightKg: Double,
        healthConditions: [HealthCondition] = [],
        medications: [String] = [],
        primaryGoal: HealthGoal? = nil,
        secondaryGoals: [HealthGoal] = [],
        activityLevel: ActivityLevel = .moderate,
        preferredWorkouts: [WorkoutType] = [],
        availableEquipment: [Equipment] = []
    ) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.healthConditions = healthConditions
        self.medications = medications
        self.primaryGoal = primaryGoal
        self.secondaryGoals = secondaryGoals
        self.activityLevel = activityLevel
        self.preferredWorkouts = preferredWorkouts
        self.availableEquipment = availableEquipment

        // Set default targets (should be calculated based on user data)
        self.calorieTarget = AppConstants.defaultCalorieTarget
        self.proteinTarget = AppConstants.defaultProteinTarget
        self.carbsTarget = AppConstants.defaultCarbsTarget
        self.fatTarget = AppConstants.defaultFatTarget
        self.fiberTarget = AppConstants.defaultFiberTarget
        self.sodiumLimit = AppConstants.defaultSodiumLimit
        self.cholesterolLimit = AppConstants.defaultCholesterolLimit
        self.saturatedFatLimit = 20

        self.stepGoal = AppConstants.defaultStepGoal
        self.activeCalorieGoal = AppConstants.defaultActiveCalorieGoal
        self.exerciseMinuteGoal = AppConstants.defaultExerciseMinuteGoal

        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    var bmi: Double {
        let heightM = heightCm / 100
        return weightKg / (heightM * heightM)
    }
}

// MARK: - Supporting Enums

enum HealthCondition: String, Codable, CaseIterable {
    case highCholesterol = "High Cholesterol"
    case highBloodPressure = "High Blood Pressure"
    case diabetes = "Diabetes"
    case preDiabetes = "Pre-Diabetes"
    case heartDisease = "Heart Disease"
    case kidneyDisease = "Kidney Disease"
    case celiacDisease = "Celiac Disease"
    case other = "Other"

    var icon: String {
        switch self {
        case .highCholesterol: return "heart.text.square"
        case .highBloodPressure: return "waveform.path.ecg"
        case .diabetes, .preDiabetes: return "drop.fill"
        case .heartDisease: return "heart.circle"
        case .kidneyDisease: return "cross.case"
        case .celiacDisease: return "leaf"
        case .other: return "stethoscope"
        }
    }

    var nutritionFocus: [String] {
        switch self {
        case .highCholesterol:
            return ["Low saturated fat", "High fiber", "Omega-3 fatty acids"]
        case .highBloodPressure:
            return ["Low sodium", "High potassium", "DASH diet"]
        case .diabetes, .preDiabetes:
            return ["Low glycemic index", "Balanced carbs", "High fiber"]
        case .heartDisease:
            return ["Heart-healthy fats", "Low sodium", "High fiber"]
        case .kidneyDisease:
            return ["Low sodium", "Moderate protein", "Low potassium"]
        case .celiacDisease:
            return ["Gluten-free", "Whole grains alternatives"]
        case .other:
            return []
        }
    }
}

enum HealthGoal: String, Codable, CaseIterable {
    case lowerCholesterol = "Lower my cholesterol"
    case reduceBloodPressure = "Reduce blood pressure"
    case loseWeight = "Lose weight"
    case buildMuscle = "Build muscle"
    case eatHealthier = "Eat healthier"
    case trackNutrition = "Track my nutrition"
    case improveEnergy = "Improve energy levels"
    case betterSleep = "Better sleep"

    var icon: String {
        switch self {
        case .lowerCholesterol: return "heart.text.square.fill"
        case .reduceBloodPressure: return "heart.circle.fill"
        case .loseWeight: return "figure.walk"
        case .buildMuscle: return "figure.strengthtraining.traditional"
        case .eatHealthier: return "leaf.fill"
        case .trackNutrition: return "chart.bar.fill"
        case .improveEnergy: return "bolt.fill"
        case .betterSleep: return "moon.stars.fill"
        }
    }

    var color: String {
        switch self {
        case .lowerCholesterol, .reduceBloodPressure: return "red"
        case .loseWeight, .buildMuscle: return "blue"
        case .eatHealthier, .trackNutrition: return "green"
        case .improveEnergy: return "yellow"
        case .betterSleep: return "purple"
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderate = "Moderately Active"
    case veryActive = "Very Active"
    case extremelyActive = "Extremely Active"

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderate: return 1.55
        case .veryActive: return 1.725
        case .extremelyActive: return 1.9
        }
    }

    var description: String {
        switch self {
        case .sedentary: return "Little to no exercise"
        case .lightlyActive: return "Light exercise 1-3 days/week"
        case .moderate: return "Moderate exercise 3-5 days/week"
        case .veryActive: return "Hard exercise 6-7 days/week"
        case .extremelyActive: return "Very hard exercise & physical job"
        }
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case walking = "Walking"
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case weightlifting = "Weight Lifting"
    case yoga = "Yoga"
    case pilates = "Pilates"
    case hiit = "HIIT"
    case sports = "Sports"
    case dancing = "Dancing"

    var icon: String {
        switch self {
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .weightlifting: return "dumbbell.fill"
        case .yoga: return "figure.yoga"
        case .pilates: return "figure.pilates"
        case .hiit: return "flame.fill"
        case .sports: return "sportscourt.fill"
        case .dancing: return "music.note"
        }
    }
}

enum Equipment: String, Codable, CaseIterable {
    case dumbbells = "Dumbbells"
    case barbells = "Barbells"
    case kettlebells = "Kettlebells"
    case resistanceBands = "Resistance Bands"
    case yogaMat = "Yoga Mat"
    case bench = "Bench"
    case pullUpBar = "Pull-up Bar"
    case cardioMachine = "Cardio Machine"

    var icon: String {
        switch self {
        case .dumbbells: return "dumbbell"
        case .barbells: return "dumbbell.fill"
        case .kettlebells: return "figure.strengthtraining.traditional"
        case .resistanceBands: return "line.diagonal"
        case .yogaMat: return "figure.yoga"
        case .bench: return "rectangle.fill"
        case .pullUpBar: return "figure.climbing"
        case .cardioMachine: return "figure.run"
        }
    }
}
