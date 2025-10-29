//
//  InputValidator.swift
//  dash
//
//  Comprehensive input validation utility
//

import Foundation

enum ValidationError: Error {
    case tooShort(minLength: Int)
    case tooLong(maxLength: Int)
    case containsProfanity
    case invalidCharacters
    case empty
}

enum InputValidator {
    // Validation constants
    static let listNameMinLength = 3
    static let listNameMaxLength = 50
    static let itemNameMinLength = 2
    static let itemNameMaxLength = 100
    static let listCodeLength = 36 // UUID length

    private static let profanityList = [
        "damn", "hell", "crap", "fuck", "shit", "bitch", "ass", "bastard",
        "dick", "cock", "pussy", "slut", "whore", "fag", "nigger", "retard",
    ]

    // Updated pattern to support Unicode letters (including Hungarian: áéíóőűöü etc)
    private static let allowedPattern = "^[\\p{L}0-9\\s.,!?'-]+$"

    static func validateListName(_ name: String) -> Result<String, ValidationError> {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .failure(.empty)
        }

        if trimmed.count < listNameMinLength {
            return .failure(.tooShort(minLength: listNameMinLength))
        }

        if trimmed.count > listNameMaxLength {
            return .failure(.tooLong(maxLength: listNameMaxLength))
        }

        if containsProfanity(trimmed) {
            return .failure(.containsProfanity)
        }

        if !isValidCharacters(trimmed) {
            return .failure(.invalidCharacters)
        }

        return .success(trimmed)
    }

    static func validateItemName(_ name: String) -> Result<String, ValidationError> {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .failure(.empty)
        }

        if trimmed.count < itemNameMinLength {
            return .failure(.tooShort(minLength: itemNameMinLength))
        }

        if trimmed.count > itemNameMaxLength {
            return .failure(.tooLong(maxLength: itemNameMaxLength))
        }

        if containsProfanity(trimmed) {
            return .failure(.containsProfanity)
        }

        if !isValidCharacters(trimmed) {
            return .failure(.invalidCharacters)
        }

        return .success(trimmed)
    }

    /// Validates list code (UUID format)
    static func validateListCode(_ code: String) -> Result<String, ValidationError> {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .failure(.empty)
        }

        if UUID(uuidString: trimmed) == nil {
            return .failure(.invalidCharacters)
        }

        return .success(trimmed)
    }

    private static func containsProfanity(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        return profanityList.contains { lowercased.contains($0) }
    }

    private static func isValidCharacters(_ text: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: allowedPattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex?.firstMatch(in: text, range: range) != nil
    }
}
