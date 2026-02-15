//
//  QuickActionButton.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(color)
                }

                Text(label)
                    .font(VitalityTheme.Typography.caption)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.quickActionButtonHeight)
            .background(VitalityTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: VitalityTheme.Radius.medium)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(VitalityTheme.Animation.quickSpring) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(VitalityTheme.Animation.quickSpring) {
                        isPressed = false
                    }
                }
        )
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
    }
}

struct QuickActionsGrid: View {
    let scanMealAction: () -> Void
    let logWalkAction: () -> Void
    let logWorkoutAction: () -> Void
    let logWaterAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(VitalityTheme.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                QuickActionButton(
                    icon: "camera.fill",
                    label: "Scan Meal",
                    color: VitalityTheme.primaryFallback,
                    action: scanMealAction
                )

                QuickActionButton(
                    icon: "figure.walk",
                    label: "Log Walk",
                    color: .blue,
                    action: logWalkAction
                )

                QuickActionButton(
                    icon: "dumbbell.fill",
                    label: "Workout",
                    color: .orange,
                    action: logWorkoutAction
                )

                QuickActionButton(
                    icon: "drop.fill",
                    label: "Water",
                    color: .cyan,
                    action: logWaterAction
                )
            }
        }
    }
}

#Preview("Quick Actions") {
    QuickActionsGrid(
        scanMealAction: {},
        logWalkAction: {},
        logWorkoutAction: {},
        logWaterAction: {}
    )
    .padding()
}
