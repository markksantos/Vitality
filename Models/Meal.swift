//
//  Meal.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import Foundation
import SwiftData

@Model
class Meal {
    var id: UUID
    var timestamp: Date
    var mealType: MealType
    @Relationship(deleteRule: .cascade) var foods: [FoodEntry]
    var photoData: Data?
    var notes: String?
    var energyLevel: Int? // 1-5 scale, how user felt after
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        mealType: MealType,
        foods: [FoodEntry] = [],
        photoData: Data? = nil,
        notes: String? = nil,
        energyLevel: Int? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.mealType = mealType
        self.foods = foods
        self.photoData = photoData
        self.notes = notes
        self.energyLevel = energyLevel
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Computed properties for total nutrition
    var totalCalories: Int {
        foods.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        foods.reduce(0) { $0 + $1.protein }
    }

    var totalCarbs: Double {
        foods.reduce(0) { $0 + $1.carbs }
    }

    var totalFat: Double {
        foods.reduce(0) { $0 + $1.fat }
    }

    var totalFiber: Double {
        foods.reduce(0) { $0 + $1.fiber }
    }

    var totalSodium: Double {
        foods.reduce(0) { $0 + $1.sodium }
    }

    var totalCholesterol: Double {
        foods.reduce(0) { $0 + $1.cholesterol }
    }

    var totalSaturatedFat: Double {
        foods.reduce(0) { $0 + $1.saturatedFat }
    }

    var totalSugar: Double {
        foods.reduce(0) { $0 + $1.sugar }
    }
}

@Model
class FoodEntry {
    var id: UUID
    var name: String
    var portion: String
    var calories: Int
    var protein: Double // grams
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sodium: Double // mg
    var cholesterol: Double // mg
    var saturatedFat: Double // grams
    var sugar: Double // grams
    var confidence: Double // 0-1, from AI analysis
    var barcode: String? // if scanned
    var brandName: String?
    var servingSize: String?
    var servingsConsumed: Double

    init(
        id: UUID = UUID(),
        name: String,
        portion: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double = 0,
        sodium: Double = 0,
        cholesterol: Double = 0,
        saturatedFat: Double = 0,
        sugar: Double = 0,
        confidence: Double = 1.0,
        barcode: String? = nil,
        brandName: String? = nil,
        servingSize: String? = nil,
        servingsConsumed: Double = 1.0
    ) {
        self.id = id
        self.name = name
        self.portion = portion
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sodium = sodium
        self.cholesterol = cholesterol
        self.saturatedFat = saturatedFat
        self.sugar = sugar
        self.confidence = confidence
        self.barcode = barcode
        self.brandName = brandName
        self.servingSize = servingSize
        self.servingsConsumed = servingsConsumed
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }

    var color: String {
        switch self {
        case .breakfast: return "orange"
        case .lunch: return "yellow"
        case .dinner: return "purple"
        case .snack: return "green"
        }
    }

    static func detectFromTime(_ date: Date = Date()) -> MealType {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 5..<11: return .breakfast
        case 11..<16: return .lunch
        case 16..<22: return .dinner
        default: return .snack
        }
    }
}

// MARK: - Nutrition Info Structure
struct NutritionInfo: Codable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sodium: Double
    var cholesterol: Double
    var saturatedFat: Double
    var sugar: Double
    var servingSize: String?

    init(
        calories: Int = 0,
        protein: Double = 0,
        carbs: Double = 0,
        fat: Double = 0,
        fiber: Double = 0,
        sodium: Double = 0,
        cholesterol: Double = 0,
        saturatedFat: Double = 0,
        sugar: Double = 0,
        servingSize: String? = nil
    ) {
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sodium = sodium
        self.cholesterol = cholesterol
        self.saturatedFat = saturatedFat
        self.sugar = sugar
        self.servingSize = servingSize
    }
}
