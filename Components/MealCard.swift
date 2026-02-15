//
//  MealCard.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

struct MealCard: View {
    let meal: Meal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Meal type icon
                Image(systemName: meal.mealType.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(meal.mealType.color))
                    .frame(width: 32, height: 32)
                    .background(Color(meal.mealType.color).opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.mealType.rawValue)
                        .font(VitalityTheme.Typography.headline)
                        .foregroundStyle(.primary)

                    Text(meal.timestamp.formatted)
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Calories
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(meal.totalCalories)")
                        .font(VitalityTheme.Typography.title)
                        .foregroundStyle(.primary)

                    Text("kcal")
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Photo (if available)
            if let photoData = meal.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.small))
            }

            // Food items
            VStack(alignment: .leading, spacing: 4) {
                ForEach(meal.foods.prefix(3), id: \.id) { food in
                    HStack {
                        Text("•")
                            .foregroundStyle(.secondary)

                        Text("\(food.name) (\(food.portion))")
                            .font(VitalityTheme.Typography.body)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text("\(food.calories) kcal")
                            .font(VitalityTheme.Typography.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                if meal.foods.count > 3 {
                    Text("+\(meal.foods.count - 3) more items")
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.leading, 12)
                }
            }

            // Macros summary
            HStack(spacing: 16) {
                MacroChip(label: "P", value: Int(meal.totalProtein), color: .blue)
                MacroChip(label: "C", value: Int(meal.totalCarbs), color: .orange)
                MacroChip(label: "F", value: Int(meal.totalFat), color: .purple)

                Spacer()
            }
        }
        .padding(VitalityTheme.Spacing.md)
        .cardStyle()
    }
}

struct MacroChip: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text("\(value)g")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

struct CompactMealCard: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 12) {
            // Meal type icon
            Image(systemName: meal.mealType.icon)
                .font(.system(size: 18))
                .foregroundStyle(Color(meal.mealType.color))
                .frame(width: 40, height: 40)
                .background(Color(meal.mealType.color).opacity(0.15))
                .clipShape(Circle())

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.mealType.rawValue)
                    .font(VitalityTheme.Typography.headline)
                    .foregroundStyle(.primary)

                Text(meal.foods.map { $0.name }.joined(separator: ", "))
                    .font(VitalityTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(meal.timestamp.timeAgo)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // Calories
            Text("\(meal.totalCalories)")
                .font(VitalityTheme.Typography.title)
                .foregroundStyle(.primary)
            Text("kcal")
                .font(VitalityTheme.Typography.caption)
                .foregroundStyle(.secondary)
        }
        .padding(VitalityTheme.Spacing.md)
        .cardStyle()
    }
}

#Preview("Meal Card") {
    let sampleMeal = Meal(
        mealType: .breakfast,
        foods: [
            FoodEntry(
                name: "Oatmeal with berries",
                portion: "1 bowl",
                calories: 250,
                protein: 8,
                carbs: 45,
                fat: 5
            ),
            FoodEntry(
                name: "Banana",
                portion: "1 medium",
                calories: 105,
                protein: 1.3,
                carbs: 27,
                fat: 0.4
            )
        ]
    )

    VStack(spacing: 16) {
        MealCard(meal: sampleMeal)
        CompactMealCard(meal: sampleMeal)
    }
    .padding()
}
