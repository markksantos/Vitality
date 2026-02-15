//
//  PermissionsStepView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

struct PermissionsStepView: View {
    @Binding var profile: OnboardingProfile
    @State private var healthKitRequested = false
    @State private var cameraRequested = false
    @State private var notificationsRequested = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Almost there!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("Enable these features to get the most out of Vitality.")
                        .font(VitalityTheme.Typography.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // Permissions
                VStack(spacing: 16) {
                    PermissionCard(
                        icon: "heart.fill",
                        title: "HealthKit Integration",
                        description: "Sync your steps, workouts, and health data",
                        isEnabled: healthKitRequested,
                        color: .red
                    ) {
                        requestHealthKit()
                    }

                    PermissionCard(
                        icon: "camera.fill",
                        title: "Camera Access",
                        description: "Scan meals and nutrition labels with your camera",
                        isEnabled: cameraRequested,
                        color: VitalityTheme.primaryFallback
                    ) {
                        requestCamera()
                    }

                    PermissionCard(
                        icon: "bell.fill",
                        title: "Notifications",
                        description: "Get reminders and personalized insights",
                        isEnabled: notificationsRequested,
                        color: .blue
                    ) {
                        requestNotifications()
                    }
                }

                // Privacy note
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(VitalityTheme.accentFallback)

                        Text("Your Privacy Matters")
                            .font(VitalityTheme.Typography.headline)
                            .foregroundStyle(.primary)
                    }

                    Text("Your health data is stored securely on your device and never shared without your permission. You can change these permissions anytime in Settings.")
                        .font(VitalityTheme.Typography.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(VitalityTheme.Spacing.md)
                .background(VitalityTheme.accentFallback.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.card))
                .padding(.top, 8)

                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, VitalityTheme.Spacing.md)
            .padding(.bottom, 100)
        }
    }

    private func requestHealthKit() {
        Task {
            do {
                try await HealthKitService.shared.requestAuthorization()
                await MainActor.run {
                    healthKitRequested = true
                }
            } catch {
                print("HealthKit authorization failed: \(error)")
            }
        }
    }

    private func requestCamera() {
        // In a real app, this would request camera permission
        // For now, we'll just mark it as requested
        cameraRequested = true
    }

    private func requestNotifications() {
        // In a real app, this would request notification permission
        // For now, we'll just mark it as requested
        notificationsRequested = true
    }
}

struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(VitalityTheme.Typography.headline)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(VitalityTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // Button
            Button(action: action) {
                if isEnabled {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(color)
                } else {
                    Text("Enable")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .buttonStyle(.plain)
            .disabled(isEnabled)
        }
        .padding(VitalityTheme.Spacing.md)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.card))
    }
}

#Preview {
    PermissionsStepView(profile: .constant(OnboardingProfile()))
}
