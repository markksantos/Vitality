//
//  HealthKitService.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import Foundation
import HealthKit

@MainActor
class HealthKitService: ObservableObject {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()

    @Published var steps: Int = 0
    @Published var activeCalories: Int = 0
    @Published var exerciseMinutes: Int = 0
    @Published var distance: Double = 0
    @Published var heartRate: Int? = nil
    @Published var isAuthorized = false

    private init() {}

    // MARK: - Authorization

    private let readTypes: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.appleExerciseTime),
        HKQuantityType(.heartRate),
        HKQuantityType(.distanceWalkingRunning),
        HKQuantityType(.bodyMass),
        HKQuantityType(.height),
        HKQuantityType(.restingHeartRate),
        HKQuantityType(.vo2Max)
    ]

    private let writeTypes: Set<HKSampleType> = [
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.appleExerciseTime),
        HKWorkoutType.workoutType()
    ]

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        isAuthorized = true
    }

    // MARK: - Fetch Today's Stats

    func fetchTodayStats() async {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        await fetchSteps(predicate: predicate)
        await fetchActiveCalories(predicate: predicate)
        await fetchExerciseMinutes(predicate: predicate)
        await fetchDistance(predicate: predicate)
        await fetchHeartRate()
    }

    private func fetchSteps(predicate: NSPredicate) async {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        do {
            let sum = try await fetchSum(for: stepsType, predicate: predicate, unit: .count())
            steps = Int(sum)
        } catch {
            print("Failed to fetch steps: \(error)")
        }
    }

    private func fetchActiveCalories(predicate: NSPredicate) async {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }

        do {
            let sum = try await fetchSum(for: caloriesType, predicate: predicate, unit: .kilocalorie())
            activeCalories = Int(sum)
        } catch {
            print("Failed to fetch active calories: \(error)")
        }
    }

    private func fetchExerciseMinutes(predicate: NSPredicate) async {
        guard let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else { return }

        do {
            let sum = try await fetchSum(for: exerciseType, predicate: predicate, unit: .minute())
            exerciseMinutes = Int(sum)
        } catch {
            print("Failed to fetch exercise minutes: \(error)")
        }
    }

    private func fetchDistance(predicate: NSPredicate) async {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }

        do {
            let sum = try await fetchSum(for: distanceType, predicate: predicate, unit: .meter())
            distance = sum / 1000.0 // Convert to kilometers
        } catch {
            print("Failed to fetch distance: \(error)")
        }
    }

    private func fetchHeartRate() async {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        do {
            let samples = try await fetchSamples(for: heartRateType, limit: 1, sortDescriptors: [sortDescriptor])
            if let sample = samples.first as? HKQuantitySample {
                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                heartRate = Int(bpm)
            }
        } catch {
            print("Failed to fetch heart rate: \(error)")
        }
    }

    // MARK: - Save Workout

    func saveWorkout(_ workout: Workout) async throws {
        let workoutActivityType = mapWorkoutType(workout.workoutType)

        var metadata: [String: Any] = [:]
        if let avgHR = workout.averageHeartRate {
            metadata[HKMetadataKeyAverageHeartRate] = avgHR
        }

        let hkWorkout = HKWorkout(
            activityType: workoutActivityType,
            start: workout.startTime,
            end: workout.endTime ?? Date(),
            duration: TimeInterval(workout.durationMinutes * 60),
            totalEnergyBurned: workout.caloriesBurned.map { HKQuantity(unit: .kilocalorie(), doubleValue: Double($0)) },
            totalDistance: workout.distance.map { HKQuantity(unit: .meter(), doubleValue: $0 * 1000) },
            metadata: metadata.isEmpty ? nil : metadata
        )

        try await healthStore.save(hkWorkout)
    }

    // MARK: - Helper Methods

    private func fetchSum(for quantityType: HKQuantityType, predicate: NSPredicate, unit: HKUnit) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let sum = statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: sum)
            }

            healthStore.execute(query)
        }
    }

    private func fetchSamples(
        for quantityType: HKQuantityType,
        predicate: NSPredicate? = nil,
        limit: Int = HKObjectQueryNoLimit,
        sortDescriptors: [NSSortDescriptor]
    ) async throws -> [HKSample] {
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: limit,
                sortDescriptors: sortDescriptors
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: samples ?? [])
            }

            healthStore.execute(query)
        }
    }

    private func mapWorkoutType(_ workoutType: WorkoutType) -> HKWorkoutActivityType {
        switch workoutType {
        case .walking: return .walking
        case .running: return .running
        case .cycling: return .cycling
        case .swimming: return .swimming
        case .weightlifting: return .traditionalStrengthTraining
        case .yoga: return .yoga
        case .pilates: return .pilates
        case .hiit: return .highIntensityIntervalTraining
        case .sports: return .other
        case .dancing: return .dance
        }
    }
}

enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationFailed
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .authorizationFailed:
            return "Failed to get HealthKit authorization"
        case .fetchFailed:
            return "Failed to fetch health data"
        }
    }
}
