//
//  UserSetting.swift
//  GitHubApp
//
//  Created by bruno on storage-migration.
//

import Foundation
import SwiftData

/**
 * SwiftData model for persisting user settings and preferences.
 *
 * This model provides a flexible key-value storage system for user settings,
 * supporting different data types through encoded values.
 */
@Model
final class UserSetting {
    /// Unique identifier for the setting
    @Attribute(.unique) var key: String

    /// Encoded value of the setting (supports various data types)
    var encodedValue: Data

    /// Human-readable description of the setting
    var settingDescription: String?

    /// Setting category for organization
    var category: String

    /// Timestamp when the setting was created
    var createdAt: Date

    /// Timestamp when the setting was last updated
    var updatedAt: Date

    // MARK: - Initialization

    /**
     * Initialize a UserSetting with a codable value.
     *
     * - Parameters:
     *   - key: Unique identifier for the setting
     *   - value: The value to store (must be Codable)
     *   - category: Setting category for organization
     *   - description: Optional description of the setting
     */
    init(key: String, value: some Codable, category: String, description: String? = nil) throws {
        self.key = key
        encodedValue = try JSONEncoder().encode(value)
        self.category = category
        settingDescription = description
        createdAt = Date()
        updatedAt = Date()
    }

    // MARK: - Value Access

    /**
     * Retrieve the stored value as a specific type.
     *
     * - Parameter type: The type to decode the value as
     * - Returns: The decoded value
     * - Throws: DecodingError if the value cannot be decoded as the specified type
     */
    func getValue<T: Codable>(as type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: encodedValue)
    }

    /**
     * Update the stored value.
     *
     * - Parameter value: The new value to store (must be Codable)
     * - Throws: EncodingError if the value cannot be encoded
     */
    func updateValue(_ value: some Codable) throws {
        encodedValue = try JSONEncoder().encode(value)
        updatedAt = Date()
    }
}

// MARK: - SwiftData Queries

extension UserSetting {
    /**
     * Predicate for fetching settings by category.
     *
     * - Parameter category: The category to filter by
     * - Returns: Predicate for SwiftData queries
     */
    static func categoryPredicate(_ category: String) -> Predicate<UserSetting> {
        #Predicate<UserSetting> { setting in
            setting.category == category
        }
    }

    /**
     * Predicate for fetching a specific setting by key.
     *
     * - Parameter key: The setting key to search for
     * - Returns: Predicate for SwiftData queries
     */
    static func keyPredicate(_ key: String) -> Predicate<UserSetting> {
        #Predicate<UserSetting> { setting in
            setting.key == key
        }
    }
}

// MARK: - Setting Categories

extension UserSetting {
    enum Category {
        static let profile = "profile"
        static let preferences = "preferences"
        static let app = "app"
        static let widget = "widget"
    }

    enum Keys {
        static let profileImageData = "profileImageData"
        static let hasRatedApp = "hasRatedApp"
    }
}
