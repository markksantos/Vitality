//
//  PantryItem.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import Foundation
import SwiftData

@Model
class PantryItem {
    var id: UUID
    var name: String
    var brand: String?
    var category: FoodCategory
    var quantity: Double
    var unit: String
    var nutritionPer100g: NutritionInfo?
    var addedDate: Date
    var expirationDate: Date?
    var photoData: Data?
    var barcode: String?
    var location: StorageLocation

    init(
        id: UUID = UUID(),
        name: String,
        brand: String? = nil,
        category: FoodCategory,
        quantity: Double = 1.0,
        unit: String = "piece",
        nutritionPer100g: NutritionInfo? = nil,
        addedDate: Date = Date(),
        expirationDate: Date? = nil,
        photoData: Data? = nil,
        barcode: String? = nil,
        location: StorageLocation = .pantry
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.nutritionPer100g = nutritionPer100g
        self.addedDate = addedDate
        self.expirationDate = expirationDate
        self.photoData = photoData
        self.barcode = barcode
        self.location = location
    }

    var daysSinceAdded: Int {
        Calendar.current.dateComponents([.day], from: addedDate, to: Date()).day ?? 0
    }

    var isExpiringSoon: Bool {
        guard let expirationDate = expirationDate else { return false }
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return daysUntilExpiration <= 3 && daysUntilExpiration >= 0
    }

    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return expirationDate < Date()
    }

    var freshnessStatus: FreshnessStatus {
        if isExpired { return .expired }
        if isExpiringSoon { return .expiringSoon }
        return .fresh
    }
}

enum FoodCategory: String, Codable, CaseIterable, Comparable {
    static func < (lhs: FoodCategory, rhs: FoodCategory) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    case protein = "Protein"
    case dairy = "Dairy"
    case grains = "Grains"
    case produce = "Produce"
    case cannedGoods = "Canned Goods"
    case frozenFoods = "Frozen Foods"
    case snacks = "Snacks"
    case beverages = "Beverages"
    case condiments = "Condiments"
    case spices = "Spices & Seasonings"
    case oils = "Oils & Fats"
    case other = "Other"

    var icon: String {
        switch self {
        case .protein: return "fish.fill"
        case .dairy: return "cup.and.saucer.fill"
        case .grains: return "leaf.fill"
        case .produce: return "carrot.fill"
        case .cannedGoods: return "cylinder.fill"
        case .frozenFoods: return "snowflake"
        case .snacks: return "bag.fill"
        case .beverages: return "drop.fill"
        case .condiments: return "paintpalette.fill"
        case .spices: return "sparkles"
        case .oils: return "drop.circle.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

enum StorageLocation: String, Codable, CaseIterable {
    case pantry = "Pantry"
    case fridge = "Fridge"
    case freezer = "Freezer"

    var icon: String {
        switch self {
        case .pantry: return "cabinet.fill"
        case .fridge: return "refrigerator.fill"
        case .freezer: return "snowflake"
        }
    }
}

enum FreshnessStatus {
    case fresh
    case expiringSoon
    case expired

    var color: String {
        switch self {
        case .fresh: return "green"
        case .expiringSoon: return "orange"
        case .expired: return "red"
        }
    }

    var icon: String {
        switch self {
        case .fresh: return "checkmark.circle.fill"
        case .expiringSoon: return "exclamationmark.triangle.fill"
        case .expired: return "xmark.circle.fill"
        }
    }
}
