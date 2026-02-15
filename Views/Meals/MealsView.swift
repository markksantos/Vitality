//
//  MealsView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI
import SwiftData

struct MealsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meal.timestamp, order: .reverse) private var meals: [Meal]
    @State private var showingMealScanner = false
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false

    private var mealsForSelectedDate: [Meal] {
        meals.filter { meal in
            Calendar.current.isDate(meal.timestamp, inSameDayAs: selectedDate)
        }
    }

    private var groupedMeals: [MealType: [Meal]] {
        Dictionary(grouping: mealsForSelectedDate) { $0.mealType }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date selector
                dateSelector

                ScrollView {
                    VStack(spacing: 24) {
                        // Summary card
                        if !mealsForSelectedDate.isEmpty {
                            dailySummaryCard
                        }

                        // Meals by type
                        if mealsForSelectedDate.isEmpty {
                            emptyStateView
                        } else {
                            mealsListView
                        }

                        Spacer()
                            .frame(height: 80)
                    }
                    .padding(.horizontal, VitalityTheme.Spacing.md)
                    .padding(.top, VitalityTheme.Spacing.md)
                }
            }
            .background(VitalityTheme.background)
            .navigationTitle("Meals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingMealScanner = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(VitalityTheme.primaryFallback)
                    }
                }
            }
            .sheet(isPresented: $showingMealScanner) {
                MealScannerView()
            }
        }
    }

    // MARK: - Date Selector

    private var dateSelector: some View {
        HStack {
            Button(action: { previousDay() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
            }
            .disabled(!canGoPrevious)

            Spacer()

            Button(action: { showingDatePicker.toggle() }) {
                HStack(spacing: 8) {
                    Text(selectedDate.isToday ? "Today" : selectedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(VitalityTheme.Typography.headline)

                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                }
                .foregroundStyle(.primary)
            }
            .popover(isPresented: $showingDatePicker) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .presentationCompactAdaptation(.popover)
                .padding()
            }

            Spacer()

            Button(action: { nextDay() }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .disabled(!canGoNext)
        }
        .foregroundStyle(VitalityTheme.primaryFallback)
        .padding(.horizontal, VitalityTheme.Spacing.md)
        .padding(.vertical, VitalityTheme.Spacing.sm)
        .background(.ultraThinMaterial)
    }

    // MARK: - Daily Summary

    private var dailySummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Daily Total")
                    .font(VitalityTheme.Typography.headline)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(totalCalories)")
                        .font(VitalityTheme.Typography.metric)
                    Text("kcal")
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            HStack(spacing: 16) {
                MacroChip(label: "P", value: Int(totalProtein), color: .blue)
                MacroChip(label: "C", value: Int(totalCarbs), color: .orange)
                MacroChip(label: "F", value: Int(totalFat), color: .purple)
                MacroChip(label: "Fiber", value: Int(totalFiber), color: .green)
            }
        }
        .padding(VitalityTheme.Spacing.md)
        .cardStyle()
    }

    // MARK: - Meals List

    private var mealsListView: some View {
        ForEach(MealType.allCases, id: \.self) { mealType in
            if let meals = groupedMeals[mealType], !meals.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(mealType.rawValue)
                        .font(VitalityTheme.Typography.title)
                        .foregroundStyle(.primary)

                    ForEach(meals) { meal in
                        NavigationLink(destination: MealDetailView(meal: meal)) {
                            MealCard(meal: meal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundStyle(VitalityTheme.primaryFallback.opacity(0.5))

            Text("No meals logged")
                .font(VitalityTheme.Typography.title)
                .foregroundStyle(.primary)

            Text("Tap the + button to log your first meal")
                .font(VitalityTheme.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: { showingMealScanner = true }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Scan Meal")
                }
                .font(VitalityTheme.Typography.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(VitalityTheme.primaryFallback)
                .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Computed Properties

    private var totalCalories: Int {
        mealsForSelectedDate.reduce(0) { $0 + $1.totalCalories }
    }

    private var totalProtein: Double {
        mealsForSelectedDate.reduce(0) { $0 + $1.totalProtein }
    }

    private var totalCarbs: Double {
        mealsForSelectedDate.reduce(0) { $0 + $1.totalCarbs }
    }

    private var totalFat: Double {
        mealsForSelectedDate.reduce(0) { $0 + $1.totalFat }
    }

    private var totalFiber: Double {
        mealsForSelectedDate.reduce(0) { $0 + $1.totalFiber }
    }

    private var canGoPrevious: Bool {
        true // Can always go to previous days
    }

    private var canGoNext: Bool {
        !Calendar.current.isDate(selectedDate, inSameDayAs: Date())
    }

    // MARK: - Actions

    private func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }

    private func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
}

// MARK: - Meal Detail View (Placeholder)

struct MealDetailView: View {
    let meal: Meal

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Meal Detail View")
                    .font(VitalityTheme.Typography.title)

                MealCard(meal: meal)

                // TODO: Add detailed nutrition breakdown, edit/delete options, etc.
            }
            .padding()
        }
        .navigationTitle(meal.mealType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Meal Scanner View (Placeholder)

struct MealScannerView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Meal Scanner")
                    .font(VitalityTheme.Typography.largeTitle)

                Text("Camera view will go here")
                    .font(VitalityTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .padding()

                // TODO: Implement camera view and AI analysis
            }
            .navigationTitle("Scan Meal")
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
    MealsView()
        .modelContainer(for: [
            UserProfile.self,
            Meal.self,
            FoodEntry.self
        ], inMemory: true)
}
