//
//  PantryView.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import SwiftUI
import SwiftData

struct PantryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pantryItems: [PantryItem]
    @State private var selectedLocation: StorageLocation = .pantry
    @State private var showingScanner = false
    @State private var searchText = ""

    private var filteredItems: [PantryItem] {
        let locationFiltered = pantryItems.filter { $0.location == selectedLocation }

        if searchText.isEmpty {
            return locationFiltered
        } else {
            return locationFiltered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.brand?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    private var groupedItems: [FoodCategory: [PantryItem]] {
        Dictionary(grouping: filteredItems) { $0.category }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Location selector
                locationSelector

                // Search bar
                searchBar

                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    // Items list
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(FoodCategory.allCases, id: \.self) { category in
                                if let items = groupedItems[category], !items.isEmpty {
                                    categorySection(category: category, items: items)
                                }
                            }

                            Spacer()
                                .frame(height: 80)
                        }
                        .padding(.horizontal, VitalityTheme.Spacing.md)
                        .padding(.top, VitalityTheme.Spacing.md)
                    }
                }
            }
            .background(VitalityTheme.background)
            .navigationTitle("Pantry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingScanner = true }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(VitalityTheme.primaryFallback)
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                PantryScannerView()
            }
        }
    }

    // MARK: - Location Selector

    private var locationSelector: some View {
        HStack(spacing: 12) {
            ForEach(StorageLocation.allCases, id: \.self) { location in
                Button(action: {
                    withAnimation {
                        selectedLocation = location
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: location.icon)
                            .font(.system(size: 14))

                        Text(location.rawValue)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(selectedLocation == location ? .white : VitalityTheme.primaryFallback)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        selectedLocation == location ? VitalityTheme.primaryFallback : VitalityTheme.primaryFallback.opacity(0.1)
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, VitalityTheme.Spacing.md)
        .padding(.vertical, VitalityTheme.Spacing.sm)
        .background(.ultraThinMaterial)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search items", text: $searchText)
                .textFieldStyle(.plain)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(VitalityTheme.Spacing.sm)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: VitalityTheme.Radius.small))
        .padding(.horizontal, VitalityTheme.Spacing.md)
        .padding(.vertical, VitalityTheme.Spacing.sm)
    }

    // MARK: - Category Section

    private func categorySection(category: FoodCategory, items: [PantryItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(VitalityTheme.primaryFallback)

                Text(category.rawValue)
                    .font(VitalityTheme.Typography.title)

                Spacer()

                Text("\(items.count)")
                    .font(VitalityTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(items) { item in
                    PantryItemRow(item: item)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cabinet")
                .font(.system(size: 60))
                .foregroundStyle(VitalityTheme.primaryFallback.opacity(0.5))

            Text("No items in \(selectedLocation.rawValue.lowercased())")
                .font(VitalityTheme.Typography.title)
                .foregroundStyle(.primary)

            Text("Tap the camera button to scan and add items")
                .font(VitalityTheme.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: { showingScanner = true }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Scan \(selectedLocation.rawValue)")
                }
                .font(VitalityTheme.Typography.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(VitalityTheme.primaryFallback)
                .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct PantryItemRow: View {
    let item: PantryItem

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(Color(item.freshnessStatus.color))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(VitalityTheme.Typography.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    if let brand = item.brand {
                        Text(brand)
                            .font(VitalityTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }

                    if item.daysSinceAdded > 0 {
                        Text("• \(item.daysSinceAdded)d ago")
                            .font(VitalityTheme.Typography.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(item.quantity.formattedGrams) \(item.unit)")
                    .font(VitalityTheme.Typography.body)
                    .foregroundStyle(.primary)

                if item.isExpiringSoon {
                    Text("Expiring soon")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(VitalityTheme.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Pantry Scanner View (Placeholder)

struct PantryScannerView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Pantry Scanner")
                    .font(VitalityTheme.Typography.largeTitle)

                Text("Camera view will go here")
                    .font(VitalityTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .padding()

                // TODO: Implement camera view and AI analysis
            }
            .navigationTitle("Scan Pantry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PantryView()
        .modelContainer(for: [PantryItem.self], inMemory: true)
}
