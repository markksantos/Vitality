//
//  MainTabView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            Group {
                switch selectedTab {
                case .home:
                    HomeDashboardView()
                case .meals:
                    MealsView()
                case .pantry:
                    PantryView()
                case .fitness:
                    FitnessView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            GlassTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [
            UserProfile.self,
            Meal.self,
            FoodEntry.self,
            PantryItem.self,
            Workout.self,
            HealthGoalProgress.self
        ], inMemory: true)
}
