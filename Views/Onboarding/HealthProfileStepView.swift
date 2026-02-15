//
//  HealthProfileStepView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

struct HealthProfileStepView: View {
    @Binding var profile: OnboardingProfile
    @State private var showDatePicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Let's get to know you")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("This helps us personalize your experience and provide accurate recommendations.")
                        .font(VitalityTheme.Typography.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // Form fields
                VStack(spacing: 20) {
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(VitalityTheme.Typography.headline)
                            .foregroundStyle(.secondary)

                        TextField("Enter your name", text: $profile.name)
                            .textFieldStyle(CustomTextFieldStyle())
                    }

                    // Birth Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birth Date")
                            .font(VitalityTheme.Typography.headline)
                            .foregroundStyle(.secondary)

                        DatePicker(
                            "Birth Date",
                            selection: Binding(
                                get: { profile.birthDate ?? Date() },
                                set: { profile.birthDate = $0 }
                            ),
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Height
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height (cm)")
                            .font(VitalityTheme.Typography.headline)
                            .foregroundStyle(.secondary)

                        HStack {
                            TextField("170", value: $profile.heightCm, format: .number)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.decimalPad)

                            Text("cm")
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 8)
                        }
                    }

                    // Weight
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight (kg)")
                            .font(VitalityTheme.Typography.headline)
                            .foregroundStyle(.secondary)

                        HStack {
                            TextField("70", value: $profile.weightKg, format: .number)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.decimalPad)

                            Text("kg")
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 8)
                        }
                    }

                    // Health Conditions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Health Conditions (optional)")
                            .font(VitalityTheme.Typography.headline)
                            .foregroundStyle(.secondary)

                        Text("This helps us provide better nutrition recommendations.")
                            .font(VitalityTheme.Typography.caption)
                            .foregroundStyle(.tertiary)

                        FlowLayout(spacing: 8) {
                            ForEach(HealthCondition.allCases, id: \.self) { condition in
                                SelectableChip(
                                    title: condition.rawValue,
                                    icon: condition.icon,
                                    isSelected: profile.healthConditions.contains(condition)
                                ) {
                                    if profile.healthConditions.contains(condition) {
                                        profile.healthConditions.removeAll { $0 == condition }
                                    } else {
                                        profile.healthConditions.append(condition)
                                    }
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

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(VitalityTheme.Typography.body)
            .padding(VitalityTheme.Spacing.md)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.medium))
    }
}

struct SelectableChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    init(title: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }

                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? VitalityTheme.primaryFallback : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(VitalityTheme.primaryFallback.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    HealthProfileStepView(profile: .constant(OnboardingProfile()))
}
