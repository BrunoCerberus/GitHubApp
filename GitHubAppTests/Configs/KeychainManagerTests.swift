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
}
