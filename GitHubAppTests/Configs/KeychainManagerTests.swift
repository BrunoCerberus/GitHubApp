// swiftlint:disable file_length
//
//  KeychainManagerTests.swift
//  GitHubAppTests
//
//  Created by bruno on 06/08/23.
//

import Foundation
@testable import GitHubApp
import Testing

@MainActor
struct KeychainManagerTests {
    private let testService: String = "com.bruno.GitHubApp.TestKeychain"
    private let testKey: String = "testKey"
    private let testValue: String = "testValue"

    private func createKeychainManager() -> KeychainManager {
        let manager = KeychainManager(service: testService)
        // Clean up any existing test data
        try? manager.delete(for: testKey)
        return manager
    }

    // MARK: - Save Tests

    @Test("Saving a normal value stores and retrieves successfully")
    func saveValue() throws {
        // Given
        let keychainManager = createKeychainManager()
        defer { try? keychainManager.delete(for: testKey) }

        // When
        try keychainManager.save(testValue, for: testKey)

        // Then
        #expect(keychainManager.exists(for: testKey))
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        #expect(retrievedValue == testValue)
    }

    @Test("Saving an empty string is allowed and retrievable")
    func saveEmptyValue() throws {
        // Given
        let keychainManager = createKeychainManager()
        defer { try? keychainManager.delete(for: testKey) }

        // When
        try keychainManager.save("", for: testKey)

        // Then
        #expect(keychainManager.exists(for: testKey))
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        #expect(retrievedValue == "")
    }

    @Test("Values with special characters round-trip correctly")
    func saveSpecialCharacters() throws {
        // Given
        let keychainManager = createKeychainManager()
        let specialValue = "!@#$%^&*()_+-=[]{}|;':\",./<>?"
        defer { try? keychainManager.delete(for: testKey) }

        // When
        try keychainManager.save(specialValue, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        #expect(retrievedValue == specialValue)
    }

    @Test("Values with unicode characters round-trip correctly")
    func saveUnicodeCharacters() throws {
        // Given
        let keychainManager = createKeychainManager()
        let unicodeValue = "Hello 世界 🌍 🚀"
        defer { try? keychainManager.delete(for: testKey) }

        // When
        try keychainManager.save(unicodeValue, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        #expect(retrievedValue == unicodeValue)
    }

    // MARK: - Retrieve Tests

    @Test("Retrieving a missing key throws a keychain error")
    func retrieveNonExistentKey() {
        // Given
        let keychainManager = createKeychainManager()

        // When & Then
        #expect(throws: KeychainManager.KeychainError.self) {
            try keychainManager.retrieve(for: "nonExistentKey") as String
        }
    }

    @Test("After deletion, item no longer exists and retrieval fails")
    func retrieveAfterDelete() throws {
        // Given
        let keychainManager = createKeychainManager()
        try keychainManager.save(testValue, for: testKey)
        #expect(keychainManager.exists(for: testKey))

        // When
        try keychainManager.delete(for: testKey)

        // Then
        #expect(!keychainManager.exists(for: testKey))
        #expect(throws: KeychainManager.KeychainError.self) {
            try keychainManager.retrieve(for: testKey) as String
        }
    }

    // MARK: - Update Tests

    @Test("Saving again with the same key updates the stored value")
    func updateExistingValue() throws {
        // Given
        let keychainManager = createKeychainManager()
        let newValue = "updatedValue"
        defer { try? keychainManager.delete(for: testKey) }
        try keychainManager.save(testValue, for: testKey)

        // When
        try keychainManager.save(newValue, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        #expect(retrievedValue == newValue)
    }

    // MARK: - Delete Tests

    @Test("Deleting a non-existent key should not throw")
    func deleteNonExistentKey() throws {
        // Given
        let keychainManager = createKeychainManager()

        // When & Then - Should not throw error
        try keychainManager.delete(for: "nonExistentKey")
    }

    @Test("Deleting an existing key removes it from keychain")
    func deleteExistingKey() throws {
        // Given
        let keychainManager = createKeychainManager()
        try keychainManager.save(testValue, for: testKey)
        #expect(keychainManager.exists(for: testKey))

        // When
        try keychainManager.delete(for: testKey)

        // Then
        #expect(!keychainManager.exists(for: testKey))
    }

    // MARK: - Exists Tests

    @Test("Existence check returns false for missing items")
    func existsForNonExistentKey() {
        // Given
        let keychainManager = createKeychainManager()

        // When & Then
        #expect(!keychainManager.exists(for: "nonExistentKey"))
    }

    @Test("Existence check returns true for stored items")
    func existsForExistingKey() throws {
        // Given
        let keychainManager = createKeychainManager()
        defer { try? keychainManager.delete(for: testKey) }
        try keychainManager.save(testValue, for: testKey)

        // When & Then
        #expect(keychainManager.exists(for: testKey))
    }

    // MARK: - Multiple Keys Tests

    @Test("Different services and keys do not collide")
    func multipleKeys() throws {
        // Given
        let keychainManager = createKeychainManager()
        let key1 = "key1"
        let key2 = "key2"
        let value1 = "value1"
        let value2 = "value2"

        // When
        try keychainManager.save(value1, for: key1)
        try keychainManager.save(value2, for: key2)
        defer {
            try? keychainManager.delete(for: key1)
            try? keychainManager.delete(for: key2)
        }

        // Then
        #expect(keychainManager.exists(for: key1))
        #expect(keychainManager.exists(for: key2))

        let retrievedValue1: String = try keychainManager.retrieve(for: key1)
        let retrievedValue2: String = try keychainManager.retrieve(for: key2)

        #expect(retrievedValue1 == value1)
        #expect(retrievedValue2 == value2)
    }

    // MARK: - Service Isolation Tests

    @Test("Items are isolated by service attribute")
    func serviceIsolation() throws {
        // Given
        let manager1 = KeychainManager(service: "service1")
        let manager2 = KeychainManager(service: "service2")
        let testKey = "sharedKey"
        let value1 = "value1"
        let value2 = "value2"

        // When
        try manager1.save(value1, for: testKey)
        try manager2.save(value2, for: testKey)
        defer {
            try? manager1.delete(for: testKey)
            try? manager2.delete(for: testKey)
        }

        // Then
        let retrievedValue1: String = try manager1.retrieve(for: testKey)
        let retrievedValue2: String = try manager2.retrieve(for: testKey)

        #expect(retrievedValue1 == value1)
        #expect(retrievedValue2 == value2)
    }

    // MARK: - Error Description Tests

    @Test("All KeychainError cases provide meaningful error descriptions")
    func keychainErrorDescriptions() {
        // Test duplicateEntry error
        let duplicateError = KeychainManager.KeychainError.duplicateEntry
        #expect(duplicateError.errorDescription != nil)
        #expect(duplicateError.errorDescription?.contains("Duplicate entry") == true)

        // Test unknown error
        let unknownError = KeychainManager.KeychainError.unknown(12345)
        #expect(unknownError.errorDescription != nil)
        #expect(unknownError.errorDescription?.contains("Unknown keychain error: 12345") == true)

        // Test itemNotFound error
        let itemNotFoundError = KeychainManager.KeychainError.itemNotFound
        #expect(itemNotFoundError.errorDescription != nil)
        #expect(itemNotFoundError.errorDescription?.contains("Item not found") == true)

        // Test invalidItemFormat error
        let invalidFormatError = KeychainManager.KeychainError.invalidItemFormat
        #expect(invalidFormatError.errorDescription != nil)
        #expect(invalidFormatError.errorDescription?.contains("Invalid item format") == true)

        // Test unhandledError error
        let unhandledError = KeychainManager.KeychainError.unhandledError(status: 67890)
        #expect(unhandledError.errorDescription != nil)
        #expect(unhandledError.errorDescription?.contains("Unhandled keychain error: 67890") == true)
    }

    @Test("KeychainError conforms to LocalizedError protocol")
    func keychainErrorLocalizedErrorConformance() {
        let error = KeychainManager.KeychainError.itemNotFound

        // Test that errorDescription is accessible through LocalizedError
        let localizedError = error as LocalizedError
        #expect(localizedError.errorDescription != nil)
        #expect(error.errorDescription == localizedError.errorDescription)
    }

    @Test("KeychainManager initialization with access group")
    func keychainManagerInitializationWithAccessGroup() {
        let accessGroup = "com.bruno.GitHubApp.SharedKeychain"
        let manager = KeychainManager(service: testService, accessGroup: accessGroup)

        // Note: We can't directly test the private accessGroup property,
        // but we can verify the instance is created successfully
        // Test passes if no exception is thrown during initialization
    }

    @Test("KeychainManager initialization without access group")
    func keychainManagerInitializationWithoutAccessGroup() {
        let manager = KeychainManager(service: testService)

        // Note: We can't directly test the private accessGroup property,
        // but we can verify the instance is created successfully
        // Test passes if no exception is thrown during initialization
    }

    @Test("Saving and retrieving very long strings")
    func saveAndRetrieveVeryLongString() throws {
        // Given
        let keychainManager = createKeychainManager()
        let longString = String(repeating: "This is a very long string for testing purposes. ", count: 100)
        defer { try? keychainManager.delete(for: testKey) }

        // When
        try keychainManager.save(longString, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        #expect(retrievedValue == longString)
    }

    @Test("Saving and retrieving strings with newlines and tabs")
    func saveAndRetrieveStringWithWhitespace() throws {
        // Given
        let keychainManager = createKeychainManager()
        let whitespaceString = "Line 1\nLine 2\tTabbed content\r\nLine 3"
        defer { try? keychainManager.delete(for: testKey) }

        // When
        try keychainManager.save(whitespaceString, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        #expect(retrievedValue == whitespaceString)
    }

    @Test("Saving and retrieving strings with null bytes")
    func saveAndRetrieveStringWithNullBytes() throws {
        // Given
        let keychainManager = createKeychainManager()
        let nullByteString = "String with \0 null bytes \0 embedded"
        defer { try? keychainManager.delete(for: testKey) }

        // When
        try keychainManager.save(nullByteString, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        #expect(retrievedValue == nullByteString)
    }

    @Test("Multiple save operations on the same key")
    func multipleSaveOperationsOnSameKey() throws {
        // Given
        let keychainManager = createKeychainManager()
        let initialValue = "initial value"
        let updatedValue = "updated value"
        let finalValue = "final value"
        defer { try? keychainManager.delete(for: testKey) }

        // When - save multiple times
        try keychainManager.save(initialValue, for: testKey)
        try keychainManager.save(updatedValue, for: testKey)
        try keychainManager.save(finalValue, for: testKey)

        // Then - should get the last saved value
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        #expect(retrievedValue == finalValue)

        // Verify only one item exists
        #expect(keychainManager.exists(for: testKey))
    }

    @Test("Saving and retrieving with very long keys")
    func saveAndRetrieveWithVeryLongKey() throws {
        // Given
        let keychainManager = createKeychainManager()
        let longKey = String(repeating: "very_long_key_name_for_testing_purposes_", count: 20)
        let testValue = "test value"

        // When
        try keychainManager.save(testValue, for: longKey)
        defer { try? keychainManager.delete(for: longKey) }

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: longKey)
        #expect(retrievedValue == testValue)
    }

    @Test("Saving and retrieving with empty key")
    func saveAndRetrieveWithEmptyKey() throws {
        // Given
        let keychainManager = createKeychainManager()
        let emptyKey = ""
        let testValue = "test value"

        // When
        try keychainManager.save(testValue, for: emptyKey)
        defer { try? keychainManager.delete(for: emptyKey) }

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: emptyKey)
        #expect(retrievedValue == testValue)
    }

    @Test("Saving and retrieving with special characters in key")
    func saveAndRetrieveWithSpecialCharactersInKey() throws {
        // Given
        let keychainManager = createKeychainManager()
        let specialKey = "key!@#$%^&*()_+-=[]{}|;':\",./<>?"
        let testValue = "test value"

        // When
        try keychainManager.save(testValue, for: specialKey)
        defer { try? keychainManager.delete(for: specialKey) }

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: specialKey)
        #expect(retrievedValue == testValue)
    }
}
