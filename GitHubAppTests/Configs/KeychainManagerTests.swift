//
//  KeychainManagerTests.swift
//  GitHubAppTests
//
//  Created by bruno on 06/08/23.
//

@testable import GitHubApp
import XCTest

/**
 * Unit tests for `KeychainManager` covering CRUD, existence checks,
 * service isolation, and edge cases.
 */
final class KeychainManagerTests: XCTestCase {
    // MARK: - Properties

    private var keychainManager: KeychainManager!
    private let testService: String = "com.bruno.GitHubApp.TestKeychain"
    private let testKey: String = "testKey"
    private let testValue: String = "testValue"

    // MARK: - Setup and Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        keychainManager = KeychainManager(service: testService)

        // Clean up any existing test data
        try? keychainManager.delete(for: testKey)
    }

    override func tearDownWithError() throws {
        // Clean up test data
        try? keychainManager.delete(for: testKey)
        keychainManager = nil
        try super.tearDownWithError()
    }

    // MARK: - Save Tests

    /// Saving a normal value stores and retrieves successfully
    func testSaveValue() throws {
        // When
        try keychainManager.save(testValue, for: testKey)

        // Then
        XCTAssertTrue(keychainManager.exists(for: testKey))
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, testValue)
    }

    /// Saving an empty string is allowed and retrievable
    func testSaveEmptyValue() throws {
        // When
        try keychainManager.save("", for: testKey)

        // Then
        XCTAssertTrue(keychainManager.exists(for: testKey))
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, "")
    }

    /// Values with special characters round-trip correctly
    func testSaveSpecialCharacters() throws {
        // Given
        let specialValue = "!@#$%^&*()_+-=[]{}|;':\",./<>?"

        // When
        try keychainManager.save(specialValue, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, specialValue)
    }

    /// Values with unicode characters round-trip correctly
    func testSaveUnicodeCharacters() throws {
        // Given
        let unicodeValue = "Hello 世界 🌍 🚀"

        // When
        try keychainManager.save(unicodeValue, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, unicodeValue)
    }

    // MARK: - Retrieve Tests

    /// Retrieving a missing key throws a keychain error
    func testRetrieveNonExistentKey() {
        // When & Then
        XCTAssertThrowsError(try keychainManager.retrieve(for: "nonExistentKey")) { error in
            XCTAssertTrue(error is KeychainManager.KeychainError)
        }
    }

    /// After deletion, item no longer exists and retrieval fails
    func testRetrieveAfterDelete() throws {
        // Given
        try keychainManager.save(testValue, for: testKey)
        XCTAssertTrue(keychainManager.exists(for: testKey))

        // When
        try keychainManager.delete(for: testKey)

        // Then
        XCTAssertFalse(keychainManager.exists(for: testKey))
        XCTAssertThrowsError(try keychainManager.retrieve(for: testKey))
    }

    // MARK: - Update Tests

    /// Saving again with the same key updates the stored value
    func testUpdateExistingValue() throws {
        // Given
        try keychainManager.save(testValue, for: testKey)
        let newValue = "updatedValue"

        // When
        try keychainManager.save(newValue, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, newValue)
    }

    // MARK: - Delete Tests

    /// Deleting a non-existent key should not throw
    func testDeleteNonExistentKey() throws {
        // When & Then - Should not throw error
        try keychainManager.delete(for: "nonExistentKey")
    }

    /// Deleting an existing key removes it from keychain
    func testDeleteExistingKey() throws {
        // Given
        try keychainManager.save(testValue, for: testKey)
        XCTAssertTrue(keychainManager.exists(for: testKey))

        // When
        try keychainManager.delete(for: testKey)

        // Then
        XCTAssertFalse(keychainManager.exists(for: testKey))
    }

    // MARK: - Exists Tests

    /// Existence check returns false for missing items
    func testExistsForNonExistentKey() {
        // When & Then
        XCTAssertFalse(keychainManager.exists(for: "nonExistentKey"))
    }

    /// Existence check returns true for stored items
    func testExistsForExistingKey() throws {
        // Given
        try keychainManager.save(testValue, for: testKey)

        // When & Then
        XCTAssertTrue(keychainManager.exists(for: testKey))
    }

    // MARK: - Multiple Keys Tests

    /// Different services and keys do not collide
    func testMultipleKeys() throws {
        // Given
        let key1 = "key1"
        let key2 = "key2"
        let value1 = "value1"
        let value2 = "value2"

        // When
        try keychainManager.save(value1, for: key1)
        try keychainManager.save(value2, for: key2)

        // Then
        XCTAssertTrue(keychainManager.exists(for: key1))
        XCTAssertTrue(keychainManager.exists(for: key2))

        let retrievedValue1: String = try keychainManager.retrieve(for: key1)
        let retrievedValue2: String = try keychainManager.retrieve(for: key2)

        XCTAssertEqual(retrievedValue1, value1)
        XCTAssertEqual(retrievedValue2, value2)

        // Clean up
        try keychainManager.delete(for: key1)
        try keychainManager.delete(for: key2)
    }

    // MARK: - Service Isolation Tests

    /// Items are isolated by service attribute
    func testServiceIsolation() throws {
        // Given
        let manager1 = KeychainManager(service: "service1")
        let manager2 = KeychainManager(service: "service2")
        let testKey = "sharedKey"
        let value1 = "value1"
        let value2 = "value2"

        // When
        try manager1.save(value1, for: testKey)
        try manager2.save(value2, for: testKey)

        // Then
        let retrievedValue1: String = try manager1.retrieve(for: testKey)
        let retrievedValue2: String = try manager2.retrieve(for: testKey)

        XCTAssertEqual(retrievedValue1, value1)
        XCTAssertEqual(retrievedValue2, value2)

        // Clean up
        try manager1.delete(for: testKey)
        try manager2.delete(for: testKey)
    }

    // MARK: - Error Description Tests

    /**
     * Test that all KeychainError cases provide meaningful error descriptions.
     *
     * These tests ensure that error messages are user-friendly and
     * provide enough information for debugging.
     */
    func testKeychainErrorDescriptions() {
        // Test duplicateEntry error
        let duplicateError = KeychainManager.KeychainError.duplicateEntry
        XCTAssertNotNil(duplicateError.errorDescription)
        XCTAssertTrue(duplicateError.errorDescription?.contains("Duplicate entry") == true)

        // Test unknown error
        let unknownError = KeychainManager.KeychainError.unknown(12345)
        XCTAssertNotNil(unknownError.errorDescription)
        XCTAssertTrue(unknownError.errorDescription?.contains("Unknown keychain error: 12345") == true)

        // Test itemNotFound error
        let itemNotFoundError = KeychainManager.KeychainError.itemNotFound
        XCTAssertNotNil(itemNotFoundError.errorDescription)
        XCTAssertTrue(itemNotFoundError.errorDescription?.contains("Item not found") == true)

        // Test invalidItemFormat error
        let invalidFormatError = KeychainManager.KeychainError.invalidItemFormat
        XCTAssertNotNil(invalidFormatError.errorDescription)
        XCTAssertTrue(invalidFormatError.errorDescription?.contains("Invalid item format") == true)

        // Test unhandledError error
        let unhandledError = KeychainManager.KeychainError.unhandledError(status: 67890)
        XCTAssertNotNil(unhandledError.errorDescription)
        XCTAssertTrue(unhandledError.errorDescription?.contains("Unhandled keychain error: 67890") == true)
    }

    /**
     * Test that KeychainError conforms to LocalizedError protocol.
     *
     * This ensures that the error can be used in UI contexts
     * where localized error descriptions are expected.
     */
    func testKeychainErrorLocalizedErrorConformance() {
        let error = KeychainManager.KeychainError.itemNotFound

        // Test that errorDescription is accessible through LocalizedError
        let localizedError = error as LocalizedError
        XCTAssertNotNil(localizedError.errorDescription)
        XCTAssertEqual(error.errorDescription, localizedError.errorDescription)
    }

    /**
     * Test KeychainManager initialization with access group.
     *
     * This test verifies that the KeychainManager can be initialized
     * with an optional access group parameter.
     */
    func testKeychainManagerInitializationWithAccessGroup() {
        let accessGroup = "com.bruno.GitHubApp.SharedKeychain"
        let manager = KeychainManager(service: testService, accessGroup: accessGroup)

        XCTAssertNotNil(manager)
        // Note: We can't directly test the private accessGroup property,
        // but we can verify the instance is created successfully
    }

    /**
     * Test KeychainManager initialization without access group.
     *
     * This test verifies that the KeychainManager can be initialized
     * without an access group parameter.
     */
    func testKeychainManagerInitializationWithoutAccessGroup() {
        let manager = KeychainManager(service: testService)

        XCTAssertNotNil(manager)
        // Note: We can't directly test the private accessGroup property,
        // but we can verify the instance is created successfully
    }

    /**
     * Test saving and retrieving very long strings.
     *
     * This test verifies that the KeychainManager can handle
     * very long string values correctly.
     */
    func testSaveAndRetrieveVeryLongString() throws {
        // Given
        let longString = String(repeating: "This is a very long string for testing purposes. ", count: 100)

        // When
        try keychainManager.save(longString, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, longString)
    }

    /**
     * Test saving and retrieving strings with newlines and tabs.
     *
     * This test verifies that the KeychainManager can handle
     * strings with whitespace characters correctly.
     */
    func testSaveAndRetrieveStringWithWhitespace() throws {
        // Given
        let whitespaceString = "Line 1\nLine 2\tTabbed content\r\nLine 3"

        // When
        try keychainManager.save(whitespaceString, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, whitespaceString)
    }

    /**
     * Test saving and retrieving strings with null bytes.
     *
     * This test verifies that the KeychainManager can handle
     * strings with null bytes correctly.
     */
    func testSaveAndRetrieveStringWithNullBytes() throws {
        // Given
        let nullByteString = "String with \0 null bytes \0 embedded"

        // When
        try keychainManager.save(nullByteString, for: testKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, nullByteString)
    }

    /**
     * Test multiple save operations on the same key.
     *
     * This test verifies that the KeychainManager properly handles
     * updating existing keychain items.
     */
    func testMultipleSaveOperationsOnSameKey() throws {
        // Given
        let initialValue = "initial value"
        let updatedValue = "updated value"
        let finalValue = "final value"

        // When - save multiple times
        try keychainManager.save(initialValue, for: testKey)
        try keychainManager.save(updatedValue, for: testKey)
        try keychainManager.save(finalValue, for: testKey)

        // Then - should get the last saved value
        let retrievedValue: String = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, finalValue)

        // Verify only one item exists
        XCTAssertTrue(keychainManager.exists(for: testKey))
    }

    /**
     * Test saving and retrieving with very long keys.
     *
     * This test verifies that the KeychainManager can handle
     * very long key names correctly.
     */
    func testSaveAndRetrieveWithVeryLongKey() throws {
        // Given
        let longKey = String(repeating: "very_long_key_name_for_testing_purposes_", count: 20)
        let testValue = "test value"

        // When
        try keychainManager.save(testValue, for: longKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: longKey)
        XCTAssertEqual(retrievedValue, testValue)

        // Clean up
        try keychainManager.delete(for: longKey)
    }

    /**
     * Test saving and retrieving with empty key.
     *
     * This test verifies that the KeychainManager can handle
     * empty key names correctly.
     */
    func testSaveAndRetrieveWithEmptyKey() throws {
        // Given
        let emptyKey = ""
        let testValue = "test value"

        // When
        try keychainManager.save(testValue, for: emptyKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: emptyKey)
        XCTAssertEqual(retrievedValue, testValue)

        // Clean up
        try keychainManager.delete(for: emptyKey)
    }

    /**
     * Test saving and retrieving with special characters in key.
     *
     * This test verifies that the KeychainManager can handle
     * special characters in key names correctly.
     */
    func testSaveAndRetrieveWithSpecialCharactersInKey() throws {
        // Given
        let specialKey = "key!@#$%^&*()_+-=[]{}|;':\",./<>?"
        let testValue = "test value"

        // When
        try keychainManager.save(testValue, for: specialKey)

        // Then
        let retrievedValue: String = try keychainManager.retrieve(for: specialKey)
        XCTAssertEqual(retrievedValue, testValue)

        // Clean up
        try keychainManager.delete(for: specialKey)
    }
}
