//
//  AIService.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import Foundation
import UIKit

actor AIService {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let model = "claude-3-5-sonnet-20241022"

    init(apiKey: String = APIKeys.claudeAPIKey) {
        self.apiKey = apiKey
    }

    // MARK: - Meal Photo Analysis

    func analyzeMealPhoto(_ imageData: Data) async throws -> MealAnalysis {
        let base64Image = imageData.base64EncodedString()

        let prompt = """
        Analyze this meal photo and identify all food items visible. For each item provide:
        - Name of the food (be specific)
        - Estimated portion size (use common measurements like "1 cup", "150g", "1 medium", etc.)
        - Estimated nutritional information per portion

        Return as JSON in this exact format:
        {
            "foods": [
                {
                    "name": "string",
                    "portion": "string",
                    "calories": number,
                    "protein": number,
                    "carbs": number,
                    "fat": number,
                    "fiber": number,
                    "sodium": number,
                    "cholesterol": number,
                    "saturatedFat": number,
                    "sugar": number,
                    "confidence": number (0-1)
                }
            ],
            "mealType": "breakfast|lunch|dinner|snack",
            "overallConfidence": number (0-1)
        }

        Be conservative with portion estimates. If you're unsure, indicate lower confidence.
        """

        let response = try await makeAPICall(
            imageBase64: base64Image,
            prompt: prompt
        )

        return try parseMealAnalysis(from: response)
    }

    // MARK: - Pantry Photo Analysis

    func analyzePantryPhoto(_ imageData: Data, location: StorageLocation) async throws -> [PantryDetection] {
        let base64Image = imageData.base64EncodedString()

        let prompt = """
        Analyze this photo of a \(location.rawValue.lowercased()) and identify all food products visible.
        For each product provide:
        - Product name
        - Brand name (if visible)
        - Estimated quantity (e.g., "1 jar", "2 cans", "1 package")
        - Food category
        - Confidence level

        Return as JSON array:
        [
            {
                "name": "string",
                "brand": "string or null",
                "quantity": number,
                "unit": "string",
                "category": "protein|dairy|grains|produce|cannedGoods|frozenFoods|snacks|beverages|condiments|spices|oils|other",
                "confidence": number (0-1)
            }
        ]
        """

        let response = try await makeAPICall(
            imageBase64: base64Image,
            prompt: prompt
        )

        return try parsePantryDetections(from: response)
    }

    // MARK: - Nutrition Label Extraction

    func extractNutritionLabel(_ imageData: Data) async throws -> NutritionInfo {
        let base64Image = imageData.base64EncodedString()

        let prompt = """
        Extract the nutrition facts from this food label photo.
        Return as JSON:
        {
            "servingSize": "string",
            "calories": number,
            "protein": number,
            "carbs": number,
            "fat": number,
            "fiber": number,
            "sodium": number,
            "cholesterol": number,
            "saturatedFat": number,
            "sugar": number
        }

        All values should be per serving. Use grams for macros (except sodium/cholesterol in mg).
        """

        let response = try await makeAPICall(
            imageBase64: base64Image,
            prompt: prompt
        )

        return try parseNutritionInfo(from: response)
    }

    // MARK: - Recipe Suggestions

    func suggestRecipes(
        pantryItems: [PantryItem],
        healthConditions: [HealthCondition],
        goals: [HealthGoal],
        preferences: [String] = []
    ) async throws -> [RecipeSuggestion] {
        let itemsList = pantryItems.map { "\($0.name) (\($0.quantity) \($0.unit))" }.joined(separator: ", ")

        let conditionsText = healthConditions.map { $0.rawValue }.joined(separator: ", ")
        let goalsText = goals.map { $0.rawValue }.joined(separator: ", ")

        let prompt = """
        Generate 3-5 healthy recipe suggestions based on:

        Available ingredients: \(itemsList)
        Health conditions: \(conditionsText)
        Goals: \(goalsText)

        For each recipe, provide:
        - Name
        - Brief description
        - Prep time (minutes)
        - Ingredients needed (mark which ones user already has)
        - Simple cooking instructions
        - Nutritional information (estimated per serving)
        - Why it's good for their health goals

        Return as JSON array:
        [
            {
                "name": "string",
                "description": "string",
                "prepTime": number,
                "servings": number,
                "ingredients": [
                    {
                        "name": "string",
                        "amount": "string",
                        "hasInPantry": boolean
                    }
                ],
                "instructions": ["string"],
                "nutrition": {
                    "calories": number,
                    "protein": number,
                    "carbs": number,
                    "fat": number,
                    "fiber": number,
                    "sodium": number
                },
                "healthBenefits": "string"
            }
        ]

        Prioritize recipes that:
        - Use mostly available ingredients
        - Align with their health conditions (e.g., low sodium for high blood pressure)
        - Support their goals
        - Are simple to prepare
        """

        let response = try await makeAPICall(
            imageBase64: nil,
            prompt: prompt
        )

        return try parseRecipeSuggestions(from: response)
    }

    // MARK: - Workout Plan Generation

    func generateWorkoutPlan(
        profile: UserProfile,
        weeksCount: Int = 4
    ) async throws -> GeneratedWorkoutPlan {
        let prompt = """
        Generate a \(weeksCount)-week personalized workout plan for:

        Age: \(profile.age)
        Activity level: \(profile.activityLevel.rawValue)
        Goals: \(profile.primaryGoal?.rawValue ?? "general fitness")
        Preferred workouts: \(profile.preferredWorkouts.map { $0.rawValue }.joined(separator: ", "))
        Available equipment: \(profile.availableEquipment.map { $0.rawValue }.joined(separator: ", "))
        Health conditions: \(profile.healthConditions.map { $0.rawValue }.joined(separator: ", "))

        Generate a progressive workout plan with:
        - 3-5 workout days per week
        - Mix of cardio and strength training
        - Exercises appropriate for their equipment and fitness level
        - Progressive overload week by week
        - Rest days for recovery
        - Modifications for any health conditions

        Return as JSON:
        {
            "planName": "string",
            "description": "string",
            "weeksCount": number,
            "daysPerWeek": number,
            "weeks": [
                {
                    "weekNumber": number,
                    "focus": "string",
                    "days": [
                        {
                            "dayNumber": number,
                            "dayName": "monday|tuesday|wednesday|thursday|friday|saturday|sunday",
                            "workoutType": "string",
                            "isRestDay": boolean,
                            "exercises": [
                                {
                                    "name": "string",
                                    "targetSets": number,
                                    "targetReps": number,
                                    "targetDuration": number (seconds, if applicable),
                                    "description": "string",
                                    "equipment": "string"
                                }
                            ],
                            "estimatedDuration": number,
                            "notes": "string"
                        }
                    ]
                }
            ]
        }
        """

        let response = try await makeAPICall(
            imageBase64: nil,
            prompt: prompt
        )

        return try parseWorkoutPlan(from: response)
    }

    // MARK: - Personalized Insights

    func generateInsights(
        recentMeals: [Meal],
        recentWorkouts: [Workout],
        profile: UserProfile,
        dailySummaries: [DailySummary]
    ) async throws -> [AIInsight] {
        let mealsData = recentMeals.prefix(7).map { meal in
            """
            \(meal.mealType.rawValue): \(meal.totalCalories) cal, \(Int(meal.totalProtein))g protein, \(Int(meal.totalSodium))mg sodium
            """
        }.joined(separator: "\n")

        let workoutsData = recentWorkouts.prefix(7).map { workout in
            "\(workout.workoutType.rawValue): \(workout.durationMinutes) min"
        }.joined(separator: "\n")

        let prompt = """
        Analyze this user's recent health data and provide 3-5 personalized insights:

        Profile:
        - Goals: \(profile.primaryGoal?.rawValue ?? "general wellness")
        - Health conditions: \(profile.healthConditions.map { $0.rawValue }.joined(separator: ", "))

        Recent meals (last 7 days):
        \(mealsData)

        Recent workouts:
        \(workoutsData)

        Generate insights as JSON array:
        [
            {
                "type": "positive|neutral|suggestion|warning",
                "title": "string (short, 5-7 words)",
                "message": "string (friendly, encouraging tone)",
                "icon": "string (SF Symbol name)",
                "priority": number (1-5, 5 being highest)
            }
        ]

        Focus on:
        - Positive reinforcement for good habits
        - Gentle suggestions for improvement
        - Patterns in eating or exercise
        - How their choices align with health goals
        - Specific, actionable recommendations

        Use a supportive, non-judgmental tone. Never shame or criticize.
        """

        let response = try await makeAPICall(
            imageBase64: nil,
            prompt: prompt
        )

        return try parseInsights(from: response)
    }

    // MARK: - API Call Helper

    private func makeAPICall(
        imageBase64: String?,
        prompt: String,
        maxTokens: Int = 4096
    ) async throws -> String {
        guard !apiKey.isEmpty && apiKey != "your-api-key-here" else {
            throw AIServiceError.missingAPIKey
        }

        var content: [[String: Any]] = []

        if let imageBase64 = imageBase64 {
            content.append([
                "type": "image",
                "source": [
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": imageBase64
                ]
            ])
        }

        content.append([
            "type": "text",
            "text": prompt
        ])

        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "messages": [
                [
                    "role": "user",
                    "content": content
                ]
            ]
        ]

        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIServiceError.invalidResponse
        }

        return text
    }

    // MARK: - Parsing Helpers

    private func parseMealAnalysis(from response: String) throws -> MealAnalysis {
        // Extract JSON from potential markdown code blocks
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw AIServiceError.parsingError
        }
        return try JSONDecoder().decode(MealAnalysis.self, from: data)
    }

    private func parsePantryDetections(from response: String) throws -> [PantryDetection] {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw AIServiceError.parsingError
        }
        return try JSONDecoder().decode([PantryDetection].self, from: data)
    }

    private func parseNutritionInfo(from response: String) throws -> NutritionInfo {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw AIServiceError.parsingError
        }
        return try JSONDecoder().decode(NutritionInfo.self, from: data)
    }

    private func parseRecipeSuggestions(from response: String) throws -> [RecipeSuggestion] {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw AIServiceError.parsingError
        }
        return try JSONDecoder().decode([RecipeSuggestion].self, from: data)
    }

    private func parseWorkoutPlan(from response: String) throws -> GeneratedWorkoutPlan {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw AIServiceError.parsingError
        }
        return try JSONDecoder().decode(GeneratedWorkoutPlan.self, from: data)
    }

    private func parseInsights(from response: String) throws -> [AIInsight] {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw AIServiceError.parsingError
        }
        return try JSONDecoder().decode([AIInsight].self, from: data)
    }

    private func extractJSON(from text: String) -> String {
        // Remove markdown code blocks if present
        let pattern = "```(?:json)?\\s*([\\s\\S]*?)```"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range(at: 1), in: text) {
            return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - AI Service Models

struct MealAnalysis: Codable {
    let foods: [FoodAnalysis]
    let mealType: String
    let overallConfidence: Double
}

struct FoodAnalysis: Codable {
    let name: String
    let portion: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sodium: Double
    let cholesterol: Double
    let saturatedFat: Double
    let sugar: Double
    let confidence: Double
}

struct PantryDetection: Codable {
    let name: String
    let brand: String?
    let quantity: Double
    let unit: String
    let category: String
    let confidence: Double
}

struct RecipeSuggestion: Codable, Identifiable {
    var id = UUID()
    let name: String
    let description: String
    let prepTime: Int
    let servings: Int
    let ingredients: [RecipeIngredient]
    let instructions: [String]
    let nutrition: NutritionInfo
    let healthBenefits: String

    enum CodingKeys: String, CodingKey {
        case name, description, prepTime, servings, ingredients, instructions, nutrition, healthBenefits
    }
}

struct RecipeIngredient: Codable {
    let name: String
    let amount: String
    let hasInPantry: Bool
}

struct GeneratedWorkoutPlan: Codable {
    let planName: String
    let description: String
    let weeksCount: Int
    let daysPerWeek: Int
    let weeks: [WeekPlan]
}

struct WeekPlan: Codable {
    let weekNumber: Int
    let focus: String
    let days: [DayPlan]
}

struct DayPlan: Codable {
    let dayNumber: Int
    let dayName: String
    let workoutType: String
    let isRestDay: Bool
    let exercises: [PlannedExercise]
    let estimatedDuration: Int
    let notes: String
}

struct AIInsight: Codable, Identifiable {
    var id = UUID()
    let type: String
    let title: String
    let message: String
    let icon: String
    let priority: Int

    enum CodingKeys: String, CodingKey {
        case type, title, message, icon, priority
    }

    var insightType: InsightType {
        InsightType(rawValue: type) ?? .neutral
    }
}

enum InsightType: String {
    case positive
    case neutral
    case suggestion
    case warning
}

enum AIServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case parsingError

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Claude API key not configured"
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .parsingError:
            return "Failed to parse AI response"
        }
    }
}
