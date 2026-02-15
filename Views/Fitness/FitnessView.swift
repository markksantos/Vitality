//
//  FitnessView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI
import SwiftData

struct FitnessView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.startTime, order: .reverse) private var workouts: [Workout]
    @StateObject private var healthKitService = HealthKitService.shared
    @State private var showingWorkoutLogger = false
    @State private var selectedDate = Date()

    private var todaysWorkouts: [Workout] {
        workouts.filter { workout in
            Calendar.current.isDate(workout.startTime, inSameDayAs: selectedDate)
        }
    }

    private var recentWorkouts: [Workout] {
        Array(workouts.prefix(10))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Activity rings
                    activityRingsCard

                    // Today's workouts
                    if !todaysWorkouts.isEmpty {
                        todaysWorkoutsSection
                    }

                    // Recent workouts
                    recentWorkoutsSection

                    // Generate workout plan button
                    generatePlanButton

                    Spacer()
                        .frame(height: 80)
                }
                .padding(.horizontal, VitalityTheme.Spacing.md)
                .padding(.top, VitalityTheme.Spacing.md)
            }
            .background(VitalityTheme.background)
            .navigationTitle("Fitness")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingWorkoutLogger = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(VitalityTheme.primaryFallback)
                    }
                }
            }
            .sheet(isPresented: $showingWorkoutLogger) {
                WorkoutLoggerView()
            }
            .task {
                await healthKitService.fetchTodayStats()
            }
        }
    }

    // MARK: - Activity Rings Card

    private var activityRingsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Activity")
                .font(VitalityTheme.Typography.headline)

            HStack(spacing: 30) {
                ActivityRing(
                    value: healthKitService.steps,
                    target: 10000,
                    icon: "figure.walk",
                    label: "Steps",
                    color: .green
                )

                ActivityRing(
                    value: healthKitService.activeCalories,
                    target: 400,
                    icon: "flame.fill",
                    label: "Active",
                    color: .red
                )

                ActivityRing(
                    value: healthKitService.exerciseMinutes,
                    target: 30,
                    icon: "figure.run",
                    label: "Exercise",
                    color: .cyan
                )
            }
            .frame(maxWidth: .infinity)

            Divider()

            // Additional stats
            VStack(spacing: 8) {
                HStack {
                    Label("Distance", systemImage: "map")
                        .font(VitalityTheme.Typography.body)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(String(format: "%.2f km", healthKitService.distance))
                        .font(VitalityTheme.Typography.headline)
                }

                if let heartRate = healthKitService.heartRate {
                    HStack {
                        Label("Heart Rate", systemImage: "heart.fill")
                            .font(VitalityTheme.Typography.body)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text("\(heartRate) bpm")
                            .font(VitalityTheme.Typography.headline)
                    }
                }
            }
        }
        .padding(VitalityTheme.Spacing.md)
        .cardStyle()
    }

    // MARK: - Today's Workouts

    private var todaysWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Workouts")
                .font(VitalityTheme.Typography.title)

            ForEach(todaysWorkouts) { workout in
                WorkoutCard(workout: workout)
            }
        }
    }

    // MARK: - Recent Workouts

    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Workouts")
                .font(VitalityTheme.Typography.title)

            if recentWorkouts.isEmpty {
                emptyStateView
            } else {
                ForEach(recentWorkouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        CompactWorkoutCard(workout: workout)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Generate Plan Button

    private var generatePlanButton: some View {
        Button(action: {
            // Generate AI workout plan
        }) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))

                Text("Generate AI Workout Plan")
                    .font(VitalityTheme.Typography.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [VitalityTheme.primaryFallback, VitalityTheme.primaryFallback.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.medium))
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 50))
                .foregroundStyle(VitalityTheme.primaryFallback.opacity(0.5))

            Text("No workouts yet")
                .font(VitalityTheme.Typography.headline)
                .foregroundStyle(.primary)

            Text("Start logging your fitness activities")
                .font(VitalityTheme.Typography.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .cardStyle()
    }
}

struct WorkoutCard: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: workout.workoutType.icon)
                .font(.system(size: 24))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    LinearGradient(
                        colors: [Color(workout.intensity.color), Color(workout.intensity.color).opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.workoutType.rawValue)
                    .font(VitalityTheme.Typography.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 12) {
                    Label(workout.formattedDuration, systemImage: "clock")
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.secondary)

                    if let calories = workout.caloriesBurned {
                        Label("\(calories) kcal", systemImage: "flame.fill")
                            .font(VitalityTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Intensity badge
            Text(workout.intensity.rawValue)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(workout.intensity.color))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(workout.intensity.color).opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(VitalityTheme.Spacing.md)
        .cardStyle()
    }
}

struct CompactWorkoutCard: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: workout.workoutType.icon)
                .font(.system(size: 18))
                .foregroundStyle(Color(workout.intensity.color))
                .frame(width: 40, height: 40)
                .background(Color(workout.intensity.color).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(workout.workoutType.rawValue)
                    .font(VitalityTheme.Typography.headline)
                    .foregroundStyle(.primary)

                Text(workout.startTime.formatted(date: .abbreviated, time: .shortened))
                    .font(VitalityTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(workout.formattedDuration)
                    .font(VitalityTheme.Typography.body)
                    .foregroundStyle(.primary)

                if let calories = workout.caloriesBurned {
                    Text("\(calories) kcal")
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(VitalityTheme.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Workout Detail View (Placeholder)

struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Workout Detail View")
                    .font(VitalityTheme.Typography.title)

                WorkoutCard(workout: workout)

                // TODO: Add detailed workout info, exercises, edit/delete options
            }
            .padding()
        }
        .navigationTitle(workout.workoutType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Workout Logger View (Placeholder)

struct WorkoutLoggerView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Workout Logger")
                    .font(VitalityTheme.Typography.largeTitle)

                Text("Log workout interface will go here")
                    .font(VitalityTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .padding()

                // TODO: Implement workout logging form
            }
            .navigationTitle("Log Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FitnessView()
        .modelContainer(for: [Workout.self], inMemory: true)
}
