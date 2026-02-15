//
//  HealthGoalProgress.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import Foundation
import SwiftData

@Model
class HealthGoalProgress {
    var id: UUID
    var goal: HealthGoal
    var startDate: Date
    var targetDate: Date?
    var currentValue: Double?
    var targetValue: Double?
    var unit: String?
    var milestones: [Milestone]
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        goal: HealthGoal,
        startDate: Date = Date(),
        targetDate: Date? = nil,
        currentValue: Double? = nil,
        targetValue: Double? = nil,
        unit: String? = nil,
        milestones: [Milestone] = [],
        isCompleted: Bool = false
    ) {
        self.id = id
        self.goal = goal
        self.startDate = startDate
        self.targetDate = targetDate
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.unit = unit
        self.milestones = milestones
        self.isCompleted = isCompleted
    }

    var progressPercentage: Double {
        guard let current = currentValue,
              let target = targetValue,
              target != 0 else { return 0 }

        return min(max((current / target) * 100, 0), 100)
    }

    var daysRemaining: Int? {
        guard let targetDate = targetDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day
    }
}

struct Milestone: Codable, Identifiable {
    var id: UUID
    var title: String
    var description: String
    var targetValue: Double
    var achievedDate: Date?
    var isAchieved: Bool

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        targetValue: Double,
        achievedDate: Date? = nil,
        isAchieved: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetValue = targetValue
        self.achievedDate = achievedDate
        self.isAchieved = isAchieved
    }
}

// MARK: - Daily Summary Model

@Model
class DailySummary {
    var id: UUID
    var date: Date
    var totalCalories: Int
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double
    var totalFiber: Double
    var totalSodium: Double
    var totalCholesterol: Double
    var totalSaturatedFat: Double
    var steps: Int
    var activeCalories: Int
    var exerciseMinutes: Int
    var waterIntake: Double // in liters
    var mealsLogged: Int
    var workoutsCompleted: Int

    init(
        id: UUID = UUID(),
        date: Date,
        totalCalories: Int = 0,
        totalProtein: Double = 0,
        totalCarbs: Double = 0,
        totalFat: Double = 0,
        totalFiber: Double = 0,
        totalSodium: Double = 0,
        totalCholesterol: Double = 0,
        totalSaturatedFat: Double = 0,
        steps: Int = 0,
        activeCalories: Int = 0,
        exerciseMinutes: Int = 0,
        waterIntake: Double = 0,
        mealsLogged: Int = 0,
        workoutsCompleted: Int = 0
    ) {
        self.id = id
        self.date = date
        self.totalCalories = totalCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
        self.totalFiber = totalFiber
        self.totalSodium = totalSodium
        self.totalCholesterol = totalCholesterol
        self.totalSaturatedFat = totalSaturatedFat
        self.steps = steps
        self.activeCalories = activeCalories
        self.exerciseMinutes = exerciseMinutes
        self.waterIntake = waterIntake
        self.mealsLogged = mealsLogged
        self.workoutsCompleted = workoutsCompleted
    }
}
