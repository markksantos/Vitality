//
//  InsightCard.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

struct InsightCard: View {
    let icon: String
    let message: String
    let type: InsightType

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(type.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(type.color)
            }

            // Message
            Text(message)
                .font(VitalityTheme.Typography.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(VitalityTheme.Spacing.md)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

extension InsightType {
    var color: Color {
        switch self {
        case .positive: return VitalityTheme.successFallback
        case .neutral: return VitalityTheme.accentFallback
        case .suggestion: return VitalityTheme.primaryFallback
        case .warning: return VitalityTheme.warningFallback
        }
    }
}

struct InsightsSection: View {
    let insights: [AIInsight]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("AI Insights")
                    .font(VitalityTheme.Typography.headline)

                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(VitalityTheme.primaryFallback)
            }

            if insights.isEmpty {
                InsightCard(
                    icon: "lightbulb.fill",
                    message: "Keep logging your meals and workouts to get personalized insights!",
                    type: .neutral
                )
            } else {
                ForEach(insights.sorted(by: { $0.priority > $1.priority }).prefix(3)) { insight in
                    InsightCard(
                        icon: insight.icon,
                        message: insight.message,
                        type: insight.insightType
                    )
                }
            }
        }
    }
}

#Preview("Insight Card") {
    VStack(spacing: 16) {
        InsightCard(
            icon: "checkmark.circle.fill",
            message: "Your average daily sodium was 1,800mg this week – 25% lower than last month. Great progress for blood pressure!",
            type: .positive
        )

        InsightCard(
            icon: "lightbulb.fill",
            message: "You've had 180mg sodium so far – plenty of room for a salty snack!",
            type: .suggestion
        )

        InsightCard(
            icon: "exclamationmark.triangle.fill",
            message: "You've consumed 2,800mg of sodium today, which is above the recommended limit.",
            type: .warning
        )

        InsightCard(
            icon: "info.circle.fill",
            message: "Based on your pantry, how about salmon tonight? Great for heart health.",
            type: .neutral
        )
    }
    .padding()
}
