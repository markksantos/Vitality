//
//  Extensions.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI

// MARK: - View Extensions

extension View {
    /// Applies adaptive glass effect for iOS 26+ with fallback for older versions
    @ViewBuilder
    func adaptiveGlass() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .capsule)
        } else {
            self
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
    }

    /// Applies glass effect for card-style components
    @ViewBuilder
    func glassCard() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: VitalityTheme.Radius.card))
        } else {
            self
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.card))
        }
    }

    /// Standard card styling
    func cardStyle() -> some View {
        self
            .background(VitalityTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.card))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    /// Button press animation
    func pressAnimation(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(VitalityTheme.Animation.quickSpring, value: isPressed)
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Date Extensions

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var formatted: String {
        let formatter = DateFormatter()
        if isToday {
            formatter.dateFormat = "h:mm a"
            return "Today, \(formatter.string(from: self))"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: self)
        }
    }
}

// MARK: - Double Extensions

extension Double {
    var formattedCalories: String {
        String(format: "%.0f", self)
    }

    var formattedGrams: String {
        String(format: "%.1f", self)
    }

    var formattedPercentage: String {
        String(format: "%.0f%%", self * 100)
    }
}

// MARK: - Int Extensions

extension Int {
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - String Extensions

extension String {
    var capitalizedFirstLetter: String {
        prefix(1).capitalized + dropFirst()
    }

    func matches(searchQuery: String) -> Bool {
        self.localizedCaseInsensitiveContains(searchQuery)
    }
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Binding Extensions

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
