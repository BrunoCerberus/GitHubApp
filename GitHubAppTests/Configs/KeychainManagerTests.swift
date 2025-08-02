//
//  KeychainManagerTests.swift
//  GitHubAppTests
//
//  Created by bruno on 06/08/23.
//

import XCTest
@testable import GitHubApp

final class KeychainManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    private var keychainManager: KeychainManager!
    private let testService = "com.bruno.GitHubApp.TestKeychain"
    private let testKey = "testKey"
    private let testValue = "testValue"
    
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
    
    func testSaveValue() throws {
        // When
        try keychainManager.save(testValue, for: testKey)
        
        // Then
        XCTAssertTrue(keychainManager.exists(for: testKey))
        let retrievedValue = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, testValue)
    }
    
    func testSaveEmptyValue() throws {
        // When
        try keychainManager.save("", for: testKey)
        
        // Then
        XCTAssertTrue(keychainManager.exists(for: testKey))
        let retrievedValue = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, "")
    }
    
    func testSaveSpecialCharacters() throws {
        // Given
        let specialValue = "!@#$%^&*()_+-=[]{}|;':\",./<>?"
        
        // When
        try keychainManager.save(specialValue, for: testKey)
        
        // Then
        let retrievedValue = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, specialValue)
    }
    
    func testSaveUnicodeCharacters() throws {
        // Given
        let unicodeValue = "Hello 世界 🌍 🚀"
        
        // When
        try keychainManager.save(unicodeValue, for: testKey)
        
        // Then
        let retrievedValue = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, unicodeValue)
    }
    
    // MARK: - Retrieve Tests
    
    func testRetrieveNonExistentKey() {
        // When & Then
        XCTAssertThrowsError(try keychainManager.retrieve(for: "nonExistentKey")) { error in
            XCTAssertTrue(error is KeychainManager.KeychainError)
        }
    }
    
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
    
    func testUpdateExistingValue() throws {
        // Given
        try keychainManager.save(testValue, for: testKey)
        let newValue = "updatedValue"
        
        // When
        try keychainManager.save(newValue, for: testKey)
        
        // Then
        let retrievedValue = try keychainManager.retrieve(for: testKey)
        XCTAssertEqual(retrievedValue, newValue)
    }
    
    // MARK: - Delete Tests
    
    func testDeleteNonExistentKey() throws {
        // When & Then - Should not throw error
        try keychainManager.delete(for: "nonExistentKey")
    }
    
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
    
    func testExistsForNonExistentKey() {
        // When & Then
        XCTAssertFalse(keychainManager.exists(for: "nonExistentKey"))
    }
    
    func testExistsForExistingKey() throws {
        // Given
        try keychainManager.save(testValue, for: testKey)
        
        // When & Then
        XCTAssertTrue(keychainManager.exists(for: testKey))
    }
    
    // MARK: - Multiple Keys Tests
    
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
        
        let retrievedValue1 = try keychainManager.retrieve(for: key1)
        let retrievedValue2 = try keychainManager.retrieve(for: key2)
        
        XCTAssertEqual(retrievedValue1, value1)
        XCTAssertEqual(retrievedValue2, value2)
        
        // Clean up
        try keychainManager.delete(for: key1)
        try keychainManager.delete(for: key2)
    }
    
    // MARK: - Service Isolation Tests
    
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
        let retrievedValue1 = try manager1.retrieve(for: testKey)
        let retrievedValue2 = try manager2.retrieve(for: testKey)
        
        XCTAssertEqual(retrievedValue1, value1)
        XCTAssertEqual(retrievedValue2, value2)
        
        // Clean up
        try manager1.delete(for: testKey)
        try manager2.delete(for: testKey)
    }
} 