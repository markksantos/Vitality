//
//  PersistenceService.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import Foundation
import SwiftData

@MainActor
class PersistenceService {
    static let shared = PersistenceService()

    private init() {}

    // MARK: - User Profile

    func getUserProfile(from context: ModelContext) -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        return try? context.fetch(descriptor).first
    }

    func saveUserProfile(_ profile: UserProfile, to context: ModelContext) throws {
        context.insert(profile)
        try context.save()
    }

    func updateUserProfile(in context: ModelContext, updates: (UserProfile) -> Void) throws {
        guard let profile = getUserProfile(from: context) else {
            throw PersistenceError.profileNotFound
        }

        updates(profile)
        profile.updatedAt = Date()
        try context.save()
    }

    // MARK: - Meals

    func getTodaysMeals(from context: ModelContext) -> [Meal] {
        let today = Date().startOfDay
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<Meal> { meal in
            meal.timestamp >= today && meal.timestamp < tomorrow
        }

        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])

        return (try? context.fetch(descriptor)) ?? []
    }

    func getMeals(from startDate: Date, to endDate: Date, context: ModelContext) -> [Meal] {
        let predicate = #Predicate<Meal> { meal in
            meal.timestamp >= startDate && meal.timestamp <= endDate
        }

        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])

        return (try? context.fetch(descriptor)) ?? []
    }

    func saveMeal(_ meal: Meal, to context: ModelContext) throws {
        context.insert(meal)
        try context.save()
    }

    func deleteMeal(_ meal: Meal, from context: ModelContext) throws {
        context.delete(meal)
        try context.save()
    }

    // MARK: - Pantry Items

    func getAllPantryItems(from context: ModelContext) -> [PantryItem] {
        let descriptor = FetchDescriptor<PantryItem>(sortBy: [SortDescriptor(\PantryItem.name)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func getPantryItems(byLocation location: StorageLocation, from context: ModelContext) -> [PantryItem] {
        let predicate = #Predicate<PantryItem> { item in
            item.location == location
        }

        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\PantryItem.name)])

        return (try? context.fetch(descriptor)) ?? []
    }

    func savePantryItem(_ item: PantryItem, to context: ModelContext) throws {
        context.insert(item)
        try context.save()
    }

    func savePantryItems(_ items: [PantryItem], to context: ModelContext) throws {
        for item in items {
            context.insert(item)
        }
        try context.save()
    }

    func deletePantryItem(_ item: PantryItem, from context: ModelContext) throws {
        context.delete(item)
        try context.save()
    }

    // MARK: - Workouts

    func getRecentWorkouts(limit: Int = 10, from context: ModelContext) -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        let allWorkouts = (try? context.fetch(descriptor)) ?? []
        return Array(allWorkouts.prefix(limit))
    }

    func getTodaysWorkouts(from context: ModelContext) -> [Workout] {
        let today = Date().startOfDay
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<Workout> { workout in
            workout.startTime >= today && workout.startTime < tomorrow
        }

        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.startTime, order: .reverse)])

        return (try? context.fetch(descriptor)) ?? []
    }

    func saveWorkout(_ workout: Workout, to context: ModelContext) throws {
        context.insert(workout)
        try context.save()
    }

    func deleteWorkout(_ workout: Workout, from context: ModelContext) throws {
        context.delete(workout)
        try context.save()
    }

    // MARK: - Daily Summaries

    func getDailySummary(for date: Date, from context: ModelContext) -> DailySummary? {
        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay

        let predicate = #Predicate<DailySummary> { summary in
            summary.date >= startOfDay && summary.date <= endOfDay
        }

        let descriptor = FetchDescriptor(predicate: predicate)

        return try? context.fetch(descriptor).first
    }

    func getRecentDailySummaries(days: Int = 7, from context: ModelContext) -> [DailySummary] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        let predicate = #Predicate<DailySummary> { summary in
            summary.date >= startDate
        }

        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.date, order: .reverse)])

        return (try? context.fetch(descriptor)) ?? []
    }

    func saveDailySummary(_ summary: DailySummary, to context: ModelContext) throws {
        context.insert(summary)
        try context.save()
    }

    func updateOrCreateDailySummary(for date: Date, in context: ModelContext, updates: (DailySummary) -> Void) throws {
        if let existing = getDailySummary(for: date, from: context) {
            updates(existing)
        } else {
            let newSummary = DailySummary(date: date)
            updates(newSummary)
            context.insert(newSummary)
        }

        try context.save()
    }

    // MARK: - Health Goal Progress

    func getHealthGoalProgress(from context: ModelContext) -> [HealthGoalProgress] {
        let descriptor = FetchDescriptor<HealthGoalProgress>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveHealthGoalProgress(_ progress: HealthGoalProgress, to context: ModelContext) throws {
        context.insert(progress)
        try context.save()
    }

    // MARK: - Statistics

    func calculateTodaysNutrition(from context: ModelContext) -> (calories: Int, protein: Double, carbs: Double, fat: Double, fiber: Double, sodium: Double, cholesterol: Double, saturatedFat: Double) {
        let meals = getTodaysMeals(from: context)

        let totalCalories = meals.reduce(0) { $0 + $1.totalCalories }
        let totalProtein = meals.reduce(0.0) { $0 + $1.totalProtein }
        let totalCarbs = meals.reduce(0.0) { $0 + $1.totalCarbs }
        let totalFat = meals.reduce(0.0) { $0 + $1.totalFat }
        let totalFiber = meals.reduce(0.0) { $0 + $1.totalFiber }
        let totalSodium = meals.reduce(0.0) { $0 + $1.totalSodium }
        let totalCholesterol = meals.reduce(0.0) { $0 + $1.totalCholesterol }
        let totalSaturatedFat = meals.reduce(0.0) { $0 + $1.totalSaturatedFat }

        return (
            calories: totalCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat,
            fiber: totalFiber,
            sodium: totalSodium,
            cholesterol: totalCholesterol,
            saturatedFat: totalSaturatedFat
        )
    }
}

enum PersistenceError: LocalizedError {
    case profileNotFound
    case saveFailed
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .profileNotFound:
            return "User profile not found"
        case .saveFailed:
            return "Failed to save data"
        case .fetchFailed:
            return "Failed to fetch data"
        }
    }
}
