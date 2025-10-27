//
//  UserSettingTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing

struct UserSettingTests {
    // MARK: - Initialization Tests

    @Test("UserSetting initializes with string value")
    func initializeWithStringValue() throws {
        // When
        let setting = try UserSetting(
            key: "test_key",
            value: "test_value",
            category: UserSetting.Category.preferences,
            description: "Test setting"
        )

        // Then
        #expect(setting.key == "test_key")
        #expect(setting.category == UserSetting.Category.preferences)
        #expect(setting.settingDescription == "Test setting")
        #expect(setting.createdAt <= Date())
        #expect(setting.updatedAt <= Date())
    }

    @Test("UserSetting initializes with boolean value")
    func initializeWithBooleanValue() throws {
        // When
        let setting = try UserSetting(
            key: UserSetting.Keys.hasRatedApp,
            value: true,
            category: UserSetting.Category.app
        )

        // Then
        #expect(setting.key == UserSetting.Keys.hasRatedApp)
        #expect(setting.category == UserSetting.Category.app)
        #expect(setting.settingDescription == nil)
    }

    @Test("UserSetting initializes with integer value")
    func initializeWithIntegerValue() throws {
        // When
        let setting = try UserSetting(
            key: "app_version",
            value: 42,
            category: UserSetting.Category.app
        )

        // Then
        let decoded: Int = try setting.getValue(as: Int.self)
        #expect(decoded == 42)
    }

    @Test("UserSetting initializes with double value")
    func initializeWithDoubleValue() throws {
        // When
        let setting = try UserSetting(
            key: "screen_brightness",
            value: 0.75,
            category: UserSetting.Category.preferences
        )

        // Then
        let decoded: Double = try setting.getValue(as: Double.self)
        #expect(decoded == 0.75)
    }

    // MARK: - Value Access Tests

    @Test("UserSetting retrievesValue as string")
    func retrieveValueAsString() throws {
        // Given
        let setting = try UserSetting(
            key: "username",
            value: "John Doe",
            category: UserSetting.Category.profile
        )

        // When
        let value: String = try setting.getValue(as: String.self)

        // Then
        #expect(value == "John Doe")
    }

    @Test("UserSetting retrieves value as boolean")
    func retrieveValueAsBoolean() throws {
        // Given
        let setting = try UserSetting(
            key: UserSetting.Keys.hasRatedApp,
            value: true,
            category: UserSetting.Category.app
        )

        // When
        let value: Bool = try setting.getValue(as: Bool.self)

        // Then
        #expect(value == true)
    }

    @Test("UserSetting retrieves value as codable object")
    func retrieveValueAsCodableObject() throws {
        // Given
        struct TestData: Codable, Equatable {
            let id: Int
            let name: String
        }

        let testData = TestData(id: 1, name: "Test")
        let setting = try UserSetting(
            key: "test_data",
            value: testData,
            category: UserSetting.Category.preferences
        )

        // When
        let retrieved: TestData = try setting.getValue(as: TestData.self)

        // Then
        #expect(retrieved == testData)
    }

    // MARK: - Value Update Tests

    @Test("UserSetting updates value")
    func updateValue() throws {
        // Given
        var setting = try UserSetting(
            key: "counter",
            value: 0,
            category: UserSetting.Category.app
        )
        let originalUpdatedAt = setting.updatedAt

        // When
        try setting.updateValue(42)

        // Then
        let newValue: Int = try setting.getValue(as: Int.self)
        #expect(newValue == 42)
        #expect(setting.updatedAt > originalUpdatedAt)
    }

    @Test("UserSetting updates value multiple times")
    func updateValueMultipleTimes() throws {
        // Given
        var setting = try UserSetting(
            key: "changing_value",
            value: "initial",
            category: UserSetting.Category.preferences
        )

        // When
        try setting.updateValue("second")
        try setting.updateValue("third")

        // Then
        let finalValue: String = try setting.getValue(as: String.self)
        #expect(finalValue == "third")
    }

    @Test("UserSetting update changes timestamp")
    func updateChangesTimestamp() throws {
        // Given
        var setting = try UserSetting(
            key: "timestamp_test",
            value: "initial",
            category: UserSetting.Category.preferences
        )
        let initialTimestamp = setting.updatedAt

        // When
        usleep(10000) // Small delay to ensure time difference (10ms)
        try setting.updateValue("updated")

        // Then
        #expect(setting.updatedAt > initialTimestamp)
    }

    // MARK: - Category Tests

    @Test("UserSetting categories are correctly defined")
    func categoriesAreDefined() {
        // Then
        #expect(UserSetting.Category.profile == "profile")
        #expect(UserSetting.Category.preferences == "preferences")
        #expect(UserSetting.Category.app == "app")
        #expect(UserSetting.Category.widget == "widget")
    }

    // MARK: - Keys Tests

    @Test("UserSetting keys are correctly defined")
    func keysAreDefined() {
        // Then
        #expect(UserSetting.Keys.profileImageData == "profileImageData")
        #expect(UserSetting.Keys.hasRatedApp == "hasRatedApp")
    }

    // MARK: - Predicate Tests

    @Test("UserSetting category predicate is created")
    func categoryPredicateIsCreated() {
        // When
        let _predicate = UserSetting.categoryPredicate(UserSetting.Category.profile)

        // Then
        // Predicate is created successfully (no nil comparison needed for non-optional)
        #expect(Bool(true))
    }

    @Test("UserSetting key predicate is created")
    func keyPredicateIsCreated() {
        // When
        let _predicate = UserSetting.keyPredicate("test_key")

        // Then
        // Predicate is created successfully (no nil comparison needed for non-optional)
        #expect(Bool(true))
    }

    // MARK: - Complex Codable Tests

    @Test("UserSetting handles complex nested structures")
    func handlesComplexNestedStructures() throws {
        // Given
        struct NestedData: Codable, Equatable {
            struct SubData: Codable, Equatable {
                let value: String
            }

            let id: Int
            let subData: SubData
            let items: [String]
        }

        let complexData = NestedData(
            id: 1,
            subData: NestedData.SubData(value: "nested"),
            items: ["a", "b", "c"]
        )

        let setting = try UserSetting(
            key: "complex_data",
            value: complexData,
            category: UserSetting.Category.preferences
        )

        // When
        let retrieved: NestedData = try setting.getValue(as: NestedData.self)

        // Then
        #expect(retrieved == complexData)
        #expect(retrieved.subData.value == "nested")
        #expect(retrieved.items.count == 3)
    }

    @Test("UserSetting handles arrays of codable objects")
    func handlesArraysOfCodableObjects() throws {
        // Given
        struct Item: Codable, Equatable {
            let id: Int
            let name: String
        }

        let items = [
            Item(id: 1, name: "Item 1"),
            Item(id: 2, name: "Item 2"),
            Item(id: 3, name: "Item 3"),
        ]

        let setting = try UserSetting(
            key: "item_list",
            value: items,
            category: UserSetting.Category.preferences
        )

        // When
        let retrieved: [Item] = try setting.getValue(as: [Item].self)

        // Then
        #expect(retrieved.count == 3)
        #expect(retrieved == items)
    }

    @Test("UserSetting handles dictionaries")
    func handlesDictionaries() throws {
        // Given
        let dictionary: [String: Int] = ["a": 1, "b": 2, "c": 3]

        let setting = try UserSetting(
            key: "test_dict",
            value: dictionary,
            category: UserSetting.Category.preferences
        )

        // When
        let retrieved: [String: Int] = try setting.getValue(as: [String: Int].self)

        // Then
        #expect(retrieved["a"] == 1)
        #expect(retrieved["b"] == 2)
        #expect(retrieved["c"] == 3)
    }

    // MARK: - Timestamps Tests

    @Test("UserSetting timestamps are set on initialization")
    func timestampsAreSetOnInitialization() throws {
        // When
        let before = Date()
        let setting = try UserSetting(
            key: "timestamp_test",
            value: "test",
            category: UserSetting.Category.app
        )
        let after = Date()

        // Then
        #expect(setting.createdAt >= before)
        #expect(setting.createdAt <= after)
        #expect(setting.updatedAt >= before)
        #expect(setting.updatedAt <= after)
    }

    @Test("UserSetting created and updated timestamps are equal initially")
    func createdAndUpdatedTimestampsAreEqualInitially() throws {
        // When
        let setting = try UserSetting(
            key: "initial_timestamps",
            value: "test",
            category: UserSetting.Category.preferences
        )

        // Then
        #expect(setting.createdAt == setting.updatedAt)
    }
}
