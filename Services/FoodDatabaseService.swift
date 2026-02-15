//
//  FoodDatabaseService.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import Foundation

class FoodDatabaseService {
    static let shared = FoodDatabaseService()

    private let openFoodFactsURL = "https://world.openfoodfacts.org/api/v2/product/"

    private init() {}

    // MARK: - Barcode Lookup

    func lookupProduct(barcode: String) async throws -> ProductInfo? {
        let urlString = "\(openFoodFactsURL)\(barcode).json"

        guard let url = URL(string: urlString) else {
            throw FoodDatabaseError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw FoodDatabaseError.httpError
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenFoodFactsResponse.self, from: data)

        guard result.status == 1, let product = result.product else {
            return nil // Product not found
        }

        return mapToProductInfo(product)
    }

    private func mapToProductInfo(_ product: OpenFoodFactsProduct) -> ProductInfo {
        let nutrition = NutritionInfo(
            calories: Int(product.nutriments.energyKcal100g ?? 0),
            protein: product.nutriments.proteins100g ?? 0,
            carbs: product.nutriments.carbohydrates100g ?? 0,
            fat: product.nutriments.fat100g ?? 0,
            fiber: product.nutriments.fiber100g ?? 0,
            sodium: (product.nutriments.sodium100g ?? 0) * 1000, // Convert g to mg
            cholesterol: 0, // Not always available in Open Food Facts
            saturatedFat: product.nutriments.saturatedFat100g ?? 0,
            sugar: product.nutriments.sugars100g ?? 0,
            servingSize: product.servingSize
        )

        return ProductInfo(
            barcode: product.code ?? "",
            name: product.productName ?? "Unknown Product",
            brand: product.brands,
            categories: product.categories?.components(separatedBy: ",") ?? [],
            servingSize: product.servingSize,
            nutritionPer100g: nutrition,
            imageURL: product.imageFrontUrl
        )
    }

    // MARK: - Search Foods

    func searchFoods(query: String) async throws -> [FoodSearchResult] {
        let searchURL = "https://world.openfoodfacts.org/cgi/search.pl"

        var components = URLComponents(string: searchURL)
        components?.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "20")
        ]

        guard let url = components?.url else {
            throw FoodDatabaseError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw FoodDatabaseError.httpError
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenFoodFactsSearchResponse.self, from: data)

        return result.products.compactMap { product in
            guard let name = product.productName, !name.isEmpty else { return nil }

            let nutrition = NutritionInfo(
                calories: Int(product.nutriments.energyKcal100g ?? 0),
                protein: product.nutriments.proteins100g ?? 0,
                carbs: product.nutriments.carbohydrates100g ?? 0,
                fat: product.nutriments.fat100g ?? 0,
                fiber: product.nutriments.fiber100g ?? 0,
                sodium: (product.nutriments.sodium100g ?? 0) * 1000,
                cholesterol: 0,
                saturatedFat: product.nutriments.saturatedFat100g ?? 0,
                sugar: product.nutriments.sugars100g ?? 0,
                servingSize: product.servingSize
            )

            return FoodSearchResult(
                name: name,
                brand: product.brands,
                barcode: product.code,
                nutrition: nutrition
            )
        }
    }
}

// MARK: - Models

struct ProductInfo {
    let barcode: String
    let name: String
    let brand: String?
    let categories: [String]
    let servingSize: String?
    let nutritionPer100g: NutritionInfo
    let imageURL: String?
}

struct FoodSearchResult: Identifiable {
    let id = UUID()
    let name: String
    let brand: String?
    let barcode: String?
    let nutrition: NutritionInfo
}

// MARK: - Open Food Facts API Models

private struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: OpenFoodFactsProduct?
}

private struct OpenFoodFactsSearchResponse: Codable {
    let products: [OpenFoodFactsProduct]
}

private struct OpenFoodFactsProduct: Codable {
    let code: String?
    let productName: String?
    let brands: String?
    let categories: String?
    let servingSize: String?
    let nutriments: Nutriments
    let imageFrontUrl: String?

    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case brands
        case categories
        case servingSize = "serving_size"
        case nutriments
        case imageFrontUrl = "image_front_url"
    }
}

private struct Nutriments: Codable {
    let energyKcal100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?
    let fiber100g: Double?
    let sodium100g: Double?
    let saturatedFat100g: Double?
    let sugars100g: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        case fiber100g = "fiber_100g"
        case sodium100g = "sodium_100g"
        case saturatedFat100g = "saturated-fat_100g"
        case sugars100g = "sugars_100g"
    }
}

enum FoodDatabaseError: LocalizedError {
    case invalidURL
    case httpError
    case parsingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .httpError:
            return "Failed to fetch data from food database"
        case .parsingError:
            return "Failed to parse food data"
        }
    }
}
