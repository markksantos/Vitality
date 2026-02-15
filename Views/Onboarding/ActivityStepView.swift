//
//  ActivityStepView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

struct ActivityStepView: View {
    @Binding var profile: OnboardingProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity & Fitness")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("Help us understand your activity level and workout preferences.")
                        .font(VitalityTheme.Typography.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // Activity Level
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Activity Level")
                        .font(VitalityTheme.Typography.title)
                        .foregroundStyle(.primary)

                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        ActivityLevelCard(
                            level: level,
                            isSelected: profile.activityLevel == level
                        ) {
                            withAnimation(VitalityTheme.Animation.spring) {
                                profile.activityLevel = level
                            }
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                // Preferred Workouts
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preferred Workouts")
                        .font(VitalityTheme.Typography.title)
                        .foregroundStyle(.primary)

                    Text("Select all that apply")
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(WorkoutType.allCases, id: \.self) { workout in
                            SelectableChip(
                                title: workout.rawValue,
                                icon: workout.icon,
                                isSelected: profile.preferredWorkouts.contains(workout)
                            ) {
                                if profile.preferredWorkouts.contains(workout) {
                                    profile.preferredWorkouts.removeAll { $0 == workout }
                                } else {
                                    profile.preferredWorkouts.append(workout)
                                }
                            }
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                // Available Equipment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Available Equipment")
                        .font(VitalityTheme.Typography.title)
                        .foregroundStyle(.primary)

                    Text("This helps us recommend appropriate exercises")
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 8) {
                        // "None" option
                        SelectableChip(
                            title: "None",
                            isSelected: profile.availableEquipment.isEmpty
                        ) {
                            profile.availableEquipment.removeAll()
                        }

                        ForEach(Equipment.allCases, id: \.self) { equipment in
                            SelectableChip(
                                title: equipment.rawValue,
                                icon: equipment.icon,
                                isSelected: profile.availableEquipment.contains(equipment)
                            ) {
                                if profile.availableEquipment.contains(equipment) {
                                    profile.availableEquipment.removeAll { $0 == equipment }
                                } else {
                                    profile.availableEquipment.append(equipment)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, VitalityTheme.Spacing.md)
            .padding(.bottom, 100)
        }
    }
}

struct ActivityLevelCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue)
                        .font(VitalityTheme.Typography.headline)
                        .foregroundStyle(.primary)

                    Text(level.description)
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(VitalityTheme.primaryFallback)
                }
            }
            .padding(VitalityTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: VitalityTheme.Radius.card)
                    .fill(isSelected ? VitalityTheme.primaryFallback.opacity(0.05) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: VitalityTheme.Radius.card)
                    .stroke(
                        isSelected ? VitalityTheme.primaryFallback : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ActivityStepView(profile: .constant(OnboardingProfile()))
}
