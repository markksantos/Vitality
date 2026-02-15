//
//  NutritionRing.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

struct NutritionRing: View {
    let consumed: Int
    let target: Int
    let nutrient: String
    let unit: String
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(consumed) / Double(target), 1.5)
    }

    private var isOverTarget: Bool {
        consumed > target
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)

                // Progress circle
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        isOverTarget ? VitalityTheme.warning : color,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(VitalityTheme.Animation.gentleSpring, value: progress)

                // Over-target indicator (if over)
                if progress > 1.0 {
                    Circle()
                        .trim(from: 1.0, to: min(progress, 1.5))
                        .stroke(
                            VitalityTheme.warning.opacity(0.5),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round, dash: [5, 5])
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(VitalityTheme.Animation.gentleSpring, value: progress)
                }

                // Center text
                VStack(spacing: 2) {
                    Text("\(consumed)")
                        .font(VitalityTheme.Typography.metric)
                        .foregroundStyle(isOverTarget ? VitalityTheme.warning : .primary)

                    Text("/ \(target)")
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)

            // Label
            VStack(spacing: 2) {
                Text(nutrient)
                    .font(VitalityTheme.Typography.caption)
                    .foregroundStyle(.secondary)

                Text(unit)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

struct MacroRingsView: View {
    let calories: Int
    let calorieTarget: Int
    let protein: Double
    let proteinTarget: Int
    let carbs: Double
    let carbsTarget: Int
    let fat: Double
    let fatTarget: Int

    var body: some View {
        HStack(spacing: 20) {
            NutritionRing(
                consumed: calories,
                target: calorieTarget,
                nutrient: "Calories",
                unit: "kcal",
                color: VitalityTheme.primary
            )

            NutritionRing(
                consumed: Int(protein),
                target: proteinTarget,
                nutrient: "Protein",
                unit: "g",
                color: .blue
            )

            NutritionRing(
                consumed: Int(carbs),
                target: carbsTarget,
                nutrient: "Carbs",
                unit: "g",
                color: .orange
            )

            NutritionRing(
                consumed: Int(fat),
                target: fatTarget,
                nutrient: "Fat",
                unit: "g",
                color: .purple
            )
        }
    }
}

struct MiniNutritionRing: View {
    let consumed: Int
    let target: Int
    let color: Color
    let size: CGFloat = 60

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(consumed) / Double(target), 1.0)
    }

    var body: some View {
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
                .animation(VitalityTheme.Animation.smoothSpring, value: progress)

            Text("\(consumed)")
                .font(VitalityTheme.Typography.smallMetric)
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
    }
}

#Preview("Nutrition Ring") {
    VStack(spacing: 30) {
        NutritionRing(
            consumed: 1240,
            target: 2000,
            nutrient: "Calories",
            unit: "kcal",
            color: VitalityTheme.primaryFallback
        )

        NutritionRing(
            consumed: 2100,
            target: 2000,
            nutrient: "Sodium",
            unit: "mg",
            color: .red
        )

        MacroRingsView(
            calories: 1240,
            calorieTarget: 2000,
            protein: 68,
            proteinTarget: 150,
            carbs: 120,
            carbsTarget: 250,
            fat: 42,
            fatTarget: 65
        )
    }
    .padding()
}
