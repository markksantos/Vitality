//
//  VisionService.swift
//  Vitality
//
//  Created by Claude on 2026-01-30.
//

import Foundation
import Vision
import UIKit

class VisionService {
    static let shared = VisionService()

    private init() {}

    // MARK: - Food Detection

    func detectFoodItems(in image: UIImage) async throws -> [VNRecognizedObjectObservation] {
        guard let cgImage = image.cgImage else {
            throw VisionServiceError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeAnimalsRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                continuation.resume(returning: results)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Barcode Scanning

    func scanBarcode(in image: UIImage) async throws -> String? {
        guard let cgImage = image.cgImage else {
            throw VisionServiceError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNBarcodeObservation],
                      let firstBarcode = results.first,
                      let payload = firstBarcode.payloadStringValue else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: payload)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Text Recognition (for nutrition labels)

    func recognizeText(in image: UIImage) async throws -> [String] {
        guard let cgImage = image.cgImage else {
            throw VisionServiceError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let recognizedStrings = results.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                continuation.resume(returning: recognizedStrings)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Image Preprocessing

    func prepareImageForAnalysis(_ image: UIImage, maxDimension: CGFloat = 1024) -> UIImage? {
        let size = image.size
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    func compressImage(_ image: UIImage, targetSizeKB: Int = 500) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)

        while let data = imageData, data.count > targetSizeKB * 1024 && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }

        return imageData
    }

    // MARK: - Detect Nutrition Label

    func detectNutritionLabel(in image: UIImage) async throws -> Bool {
        let recognizedText = try await recognizeText(in: image)
        let text = recognizedText.joined(separator: " ").lowercased()

        // Look for common nutrition label keywords
        let nutritionKeywords = [
            "nutrition facts",
            "serving size",
            "calories",
            "total fat",
            "saturated fat",
            "cholesterol",
            "sodium",
            "carbohydrate",
            "protein",
            "valeur nutritive"  // French labels
        ]

        let keywordCount = nutritionKeywords.filter { keyword in
            text.contains(keyword)
        }.count

        // If we find at least 4 nutrition keywords, it's likely a nutrition label
        return keywordCount >= 4
    }
}

enum VisionServiceError: LocalizedError {
    case invalidImage
    case processingFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided"
        case .processingFailed:
            return "Failed to process image"
        }
    }
}
