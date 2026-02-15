//
//  GlassContainer.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

struct GlassTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(VitalityTheme.Animation.spring) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background {
            if #available(iOS 26.0, *) {
                Capsule()
                    .fill(.regularMaterial)
            } else {
                Capsule()
                    .fill(.ultraThinMaterial)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
    }
}

struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.iconFilled : tab.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isSelected ? VitalityTheme.primaryFallback : .secondary)
                    .frame(height: 24)

                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundStyle(isSelected ? VitalityTheme.primaryFallback : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? VitalityTheme.primaryFallback.opacity(0.15) : .clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

enum Tab: String, CaseIterable {
    case home
    case meals
    case pantry
    case fitness

    var title: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .meals: return "fork.knife"
        case .pantry: return "cabinet"
        case .fitness: return "figure.run"
        }
    }

    var iconFilled: String {
        switch self {
        case .home: return "house.fill"
        case .meals: return "fork.knife.circle.fill"
        case .pantry: return "cabinet.fill"
        case .fitness: return "figure.run.circle.fill"
        }
    }
}

struct GlassNavBar: View {
    let title: String
    let subtitle: String?
    let trailingButton: (() -> AnyView)?

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailingButton: @escaping () -> some View = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingButton = { AnyView(trailingButton()) }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(VitalityTheme.Typography.largeTitle)
                    .foregroundStyle(.primary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(VitalityTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let button = trailingButton {
                button()
            }
        }
        .padding(.horizontal, VitalityTheme.Spacing.md)
        .padding(.vertical, VitalityTheme.Spacing.sm)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: VitalityTheme.Radius.medium)
                    .fill(.regularMaterial)
            } else {
                RoundedRectangle(cornerRadius: VitalityTheme.Radius.medium)
                    .fill(.ultraThinMaterial)
            }
        }
    }
}

#Preview("Glass Components") {
    VStack(spacing: 30) {
        GlassNavBar(
            title: "Good morning, Mark",
            subtitle: "Let's make today healthy"
        ) {
            Button(action: {}) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(VitalityTheme.primaryFallback)
            }
        }

        Spacer()

        GlassTabBar(selectedTab: .constant(.home))
    }
    .padding()
}
