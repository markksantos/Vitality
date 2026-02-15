//
//  HomeDashboardView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI
import SwiftData

struct HomeDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query(sort: \Meal.timestamp, order: .reverse) private var allMeals: [Meal]

    @StateObject private var healthKitService = HealthKitService.shared
    @State private var showingMealScanner = false
    @State private var todaysNutrition: (calories: Int, protein: Double, carbs: Double, fat: Double, fiber: Double, sodium: Double, cholesterol: Double, saturatedFat: Double) = (0, 0, 0, 0, 0, 0, 0, 0)
    @State private var insights: [AIInsight] = []

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    private var todaysMeals: [Meal] {
        allMeals.filter { $0.timestamp.isToday }
    }

    private var recentMeals: [Meal] {
        Array(todaysMeals.prefix(3))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView

                    // Today's Snapshot
                    todaysSnapshotCard

                    // Quick Actions
                    quickActionsSection

                    // Recent Meals
                    if !recentMeals.isEmpty {
                        recentMealsSection
                    }

                    // Today's Activity
                    todaysActivityCard

                    // AI Insights
                    InsightsSection(insights: insights)

                    Spacer()
                        .frame(height: 80)
                }
                .padding(.horizontal, VitalityTheme.Spacing.md)
                .padding(.top, VitalityTheme.Spacing.sm)
            }
            .background(VitalityTheme.background)
        }
        .task {
            await loadData()
        }
        .refreshable {
            await loadData()
        }
        .sheet(isPresented: $showingMealScanner) {
            MealScannerView()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(VitalityTheme.Typography.largeTitle)
                    .foregroundStyle(.primary)

                if let profile = userProfile {
                    Text(profile.name)
                        .font(VitalityTheme.Typography.title)
                        .foregroundStyle(VitalityTheme.primaryFallback)
                }
            }

            Spacer()

            Button(action: {
                // Navigate to settings
            }) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(VitalityTheme.primaryFallback)
            }
        }
    }

    // MARK: - Today's Snapshot

    private var todaysSnapshotCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Snapshot")
                .font(VitalityTheme.Typography.headline)

            if let profile = userProfile {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        NutritionRing(
                            consumed: todaysNutrition.calories,
                            target: profile.calorieTarget,
                            nutrient: "Calories",
                            unit: "kcal",
                            color: VitalityTheme.primaryFallback
                        )

                        NutritionRing(
                            consumed: Int(todaysNutrition.protein),
                            target: profile.proteinTarget,
                            nutrient: "Protein",
                            unit: "g",
                            color: .blue
                        )

                        NutritionRing(
                            consumed: Int(todaysNutrition.carbs),
                            target: profile.carbsTarget,
                            nutrient: "Carbs",
                            unit: "g",
                            color: .orange
                        )

                        NutritionRing(
                            consumed: Int(todaysNutrition.fat),
                            target: profile.fatTarget,
                            nutrient: "Fat",
                            unit: "g",
                            color: .purple
                        )

                        // Health-specific nutrients
                        if profile.healthConditions.contains(.highBloodPressure) {
                            NutritionRing(
                                consumed: Int(todaysNutrition.sodium),
                                target: profile.sodiumLimit,
                                nutrient: "Sodium",
                                unit: "mg",
                                color: .red
                            )
                        }

                        if profile.healthConditions.contains(.highCholesterol) {
                            NutritionRing(
                                consumed: Int(todaysNutrition.cholesterol),
                                target: profile.cholesterolLimit,
                                nutrient: "Cholesterol",
                                unit: "mg",
                                color: .pink
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(VitalityTheme.Spacing.md)
        .cardStyle()
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        QuickActionsGrid(
            scanMealAction: {
                showingMealScanner = true
            },
            logWalkAction: {
                // Log walk
            },
            logWorkoutAction: {
                // Log workout
            },
            logWaterAction: {
                // Log water
            }
        )
    }

    // MARK: - Recent Meals

    private var recentMealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Meals")
                    .font(VitalityTheme.Typography.headline)

                Spacer()

                NavigationLink(destination: MealsView()) {
                    Text("See All")
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(VitalityTheme.primaryFallback)
                }
            }

            ForEach(Array(recentMeals.enumerated()), id: \.element.id) { index, meal in
                CompactMealCard(meal: meal)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .animation(
                        VitalityTheme.Animation.spring.delay(Double(index) * 0.05),
                        value: recentMeals.count
                    )
            }
        }
    }

    // MARK: - Today's Activity

    private var todaysActivityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Activity")
                .font(VitalityTheme.Typography.headline)

            if let profile = userProfile {
                HStack(spacing: 20) {
                    ActivityRing(
                        value: healthKitService.steps,
                        target: profile.stepGoal,
                        icon: "figure.walk",
                        label: "Steps",
                        color: .green
                    )

                    ActivityRing(
                        value: healthKitService.activeCalories,
                        target: profile.activeCalorieGoal,
                        icon: "flame.fill",
                        label: "Active Cal",
                        color: .red
                    )

                    ActivityRing(
                        value: healthKitService.exerciseMinutes,
                        target: profile.exerciseMinuteGoal,
                        icon: "figure.run",
                        label: "Exercise",
                        color: .cyan
                    )
                }
            }

            if healthKitService.distance > 0 {
                HStack {
                    Image(systemName: "map")
                        .foregroundStyle(.secondary)

                    Text(String(format: "%.2f km walked today", healthKitService.distance))
                        .font(VitalityTheme.Typography.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(VitalityTheme.Spacing.md)
        .cardStyle()
    }

    // MARK: - Helpers

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private func loadData() async {
        // Calculate today's nutrition
        todaysNutrition = PersistenceService.shared.calculateTodaysNutrition(from: modelContext)

        // Fetch HealthKit data
        await healthKitService.fetchTodayStats()

        // Generate AI insights if we have enough data
        if todaysMeals.count >= 2 {
            do {
                let aiService = AIService()
                let recentWorkouts = PersistenceService.shared.getRecentWorkouts(limit: 7, from: modelContext)
                let recentSummaries = PersistenceService.shared.getRecentDailySummaries(days: 7, from: modelContext)

                if let profile = userProfile {
                    insights = try await aiService.generateInsights(
                        recentMeals: Array(allMeals.prefix(7)),
                        recentWorkouts: recentWorkouts,
                        profile: profile,
                        dailySummaries: recentSummaries
                    )
                }
            } catch {
                print("Failed to generate insights: \(error)")
            }
        }
    }
}

struct ActivityRing: View {
    let value: Int
    let target: Int
    let icon: String
    let label: String
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(value) / Double(target), 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(VitalityTheme.Animation.gentleSpring, value: progress)

                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(color)

                    Text("\(value)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
            .frame(width: 80, height: 80)

            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HomeDashboardView()
        .modelContainer(for: [
            UserProfile.self,
            Meal.self,
            FoodEntry.self,
            PantryItem.self,
            Workout.self,
            HealthGoalProgress.self
        ], inMemory: true)
}
