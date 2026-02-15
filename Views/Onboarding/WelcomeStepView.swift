//
//  WelcomeStepView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

struct WelcomeStepView: View {
    @Binding var profile: OnboardingProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 40)

                // App icon/logo placeholder
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    VitalityTheme.primaryFallback,
                                    VitalityTheme.primaryFallback.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                }
                .shadow(color: VitalityTheme.primaryFallback.opacity(0.3), radius: 20)

                // Title and description
                VStack(spacing: 16) {
                    Text("Welcome to Vitality")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("Your AI-powered health companion for balanced nutrition, fitness tracking, and personalized wellness insights.")
                        .font(VitalityTheme.Typography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, VitalityTheme.Spacing.lg)
                }

                // Features
                VStack(spacing: 20) {
                    FeatureRow(
                        icon: "camera.fill",
                        title: "AI Meal Scanning",
                        description: "Snap a photo to log meals instantly"
                    )

                    FeatureRow(
                        icon: "brain.head.profile",
                        title: "Personalized Insights",
                        description: "Get smart recommendations for your health goals"
                    )

                    FeatureRow(
                        icon: "heart.text.square.fill",
                        title: "Health-Focused",
                        description: "Tailored for cholesterol, blood pressure, and more"
                    )

                    FeatureRow(
                        icon: "figure.strengthtraining.traditional",
                        title: "Fitness Tracking",
                        description: "Log workouts and track your progress"
                    )
                }
                .padding(.horizontal, VitalityTheme.Spacing.lg)

                Spacer()
            }
            .padding(.vertical)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(VitalityTheme.primaryFallback)
                .frame(width: 50, height: 50)
                .background(VitalityTheme.primaryFallback.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(VitalityTheme.Typography.headline)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(VitalityTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    WelcomeStepView(profile: .constant(OnboardingProfile()))
}
