//
//  Workout.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import Foundation
import SwiftData

@Model
class Workout {
    var id: UUID
    var workoutType: WorkoutType
    var startTime: Date
    var endTime: Date?
    var durationMinutes: Int
    var caloriesBurned: Int?
    var distance: Double? // in kilometers
    var averageHeartRate: Int?
    var maxHeartRate: Int?
    var notes: String?
    var intensity: WorkoutIntensity
    var exercises: [Exercise]

    init(
        id: UUID = UUID(),
        workoutType: WorkoutType,
        startTime: Date = Date(),
        endTime: Date? = nil,
        durationMinutes: Int = 0,
        caloriesBurned: Int? = nil,
        distance: Double? = nil,
        averageHeartRate: Int? = nil,
        maxHeartRate: Int? = nil,
        notes: String? = nil,
        intensity: WorkoutIntensity = .moderate,
        exercises: [Exercise] = []
    ) {
        self.id = id
        self.workoutType = workoutType
        self.startTime = startTime
        self.endTime = endTime
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.distance = distance
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.notes = notes
        self.intensity = intensity
        self.exercises = exercises
    }

    var isInProgress: Bool {
        endTime == nil
    }

    var formattedDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var formattedDistance: String? {
        guard let distance = distance else { return nil }
        return String(format: "%.2f km", distance)
    }
}

struct Exercise: Codable {
    var id: UUID
    var name: String
    var sets: Int?
    var reps: Int?
    var weight: Double? // in kg
    var duration: Int? // in seconds
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        sets: Int? = nil,
        reps: Int? = nil,
        weight: Double? = nil,
        duration: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.notes = notes
    }

    var formattedSetsReps: String? {
        guard let sets = sets, let reps = reps else { return nil }
        return "\(sets) × \(reps)"
    }

    var formattedWeight: String? {
        guard let weight = weight else { return nil }
        return String(format: "%.1f kg", weight)
    }
}

enum WorkoutIntensity: String, Codable, CaseIterable {
    case light = "Light"
    case moderate = "Moderate"
    case vigorous = "Vigorous"

    var color: String {
        switch self {
        case .light: return "green"
        case .moderate: return "orange"
        case .vigorous: return "red"
        }
    }

    var icon: String {
        switch self {
        case .light: return "tortoise.fill"
        case .moderate: return "hare.fill"
        case .vigorous: return "flame.fill"
        }
    }
}

// MARK: - Workout Plan Models

@Model
class WorkoutPlan {
    var id: UUID
    var name: String
    var daysPerWeek: Int
    var weeklySchedule: [WeekDay: WorkoutDay]
    var startDate: Date
    var endDate: Date?
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        daysPerWeek: Int,
        weeklySchedule: [WeekDay: WorkoutDay] = [:],
        startDate: Date = Date(),
        endDate: Date? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.daysPerWeek = daysPerWeek
        self.weeklySchedule = weeklySchedule
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
    }
}

struct WorkoutDay: Codable {
    var dayName: WeekDay
    var workoutType: WorkoutType
    var exercises: [PlannedExercise]
    var estimatedDuration: Int // minutes
    var notes: String?

    init(
        dayName: WeekDay,
        workoutType: WorkoutType,
        exercises: [PlannedExercise] = [],
        estimatedDuration: Int,
        notes: String? = nil
    ) {
        self.dayName = dayName
        self.workoutType = workoutType
        self.exercises = exercises
        self.estimatedDuration = estimatedDuration
        self.notes = notes
    }
}

struct PlannedExercise: Codable, Identifiable {
    var id: UUID
    var name: String
    var targetSets: Int?
    var targetReps: Int?
    var targetWeight: Double?
    var targetDuration: Int?
    var description: String?
    var videoURL: String?

    init(
        id: UUID = UUID(),
        name: String,
        targetSets: Int? = nil,
        targetReps: Int? = nil,
        targetWeight: Double? = nil,
        targetDuration: Int? = nil,
        description: String? = nil,
        videoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.targetDuration = targetDuration
        self.description = description
        self.videoURL = videoURL
    }
}

enum WeekDay: String, Codable, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"

    var shortName: String {
        String(self.rawValue.prefix(3))
    }
}
