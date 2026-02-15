//
//  GoalsStepView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

struct GoalsStepView: View {
    @Binding var profile: OnboardingProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's your main goal?")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("Choose one primary goal. You can select additional goals next.")
                        .font(VitalityTheme.Typography.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // Primary Goal
                VStack(spacing: 12) {
                    ForEach(HealthGoal.allCases, id: \.self) { goal in
                        GoalCard(
                            goal: goal,
                            isSelected: profile.primaryGoal == goal,
                            isPrimary: true
                        ) {
                            withAnimation(VitalityTheme.Animation.spring) {
                                profile.primaryGoal = goal
                            }
                        }
                    }
                }

                // Secondary Goals
                if profile.primaryGoal != nil {
                    VStack(alignment: .leading, spacing: 16) {
                        Divider()
                            .padding(.vertical, 8)

                        Text("Any additional goals?")
                            .font(VitalityTheme.Typography.title)
                            .foregroundStyle(.primary)

                        Text("Select as many as you'd like")
                            .font(VitalityTheme.Typography.caption)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 12) {
                            ForEach(HealthGoal.allCases.filter { $0 != profile.primaryGoal }, id: \.self) { goal in
                                GoalCard(
                                    goal: goal,
                                    isSelected: profile.secondaryGoals.contains(goal),
                                    isPrimary: false
                                ) {
                                    withAnimation(VitalityTheme.Animation.spring) {
                                        if profile.secondaryGoals.contains(goal) {
                                            profile.secondaryGoals.removeAll { $0 == goal }
                                        } else {
                                            profile.secondaryGoals.append(goal)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, VitalityTheme.Spacing.md)
            .padding(.bottom, 100)
        }
    }
}

struct GoalCard: View {
    let goal: HealthGoal
    let isSelected: Bool
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: goal.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(isSelected ? .white : Color(goal.color))
                    .frame(width: 60, height: 60)
                    .background(
                        isSelected ? Color(goal.color) : Color(goal.color).opacity(0.15)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.rawValue)
                        .font(VitalityTheme.Typography.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    if isSelected && isPrimary {
                        Text("Primary Goal")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(goal.color))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(goal.color).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(goal.color))
                }
            }
            .padding(VitalityTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: VitalityTheme.Radius.card)
                    .fill(isSelected ? Color(goal.color).opacity(0.05) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: VitalityTheme.Radius.card)
                    .stroke(
                        isSelected ? Color(goal.color) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GoalsStepView(profile: .constant(OnboardingProfile()))
}
