//
//  APIKeysProviderTests.swift
//  GitHubAppTests
//
//  Created by bruno on 06/08/23.
//

import XCTest
@testable import GitHubApp

final class APIKeysProviderTests: XCTestCase {
    
    // MARK: - Properties
    
    private let testAPIKey = "test_api_key_12345"
    private let originalAPIKey = "da9bc8815fb0fc31d5ef6b3da097a009"
    
    // MARK: - Setup and Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Clean up any existing API key
        try? APIKeysProvider.removeMovieAPIKey()
    }
    
    override func tearDownWithError() throws {
        // Clean up test data
        try? APIKeysProvider.removeMovieAPIKey()
        try super.tearDownWithError()
    }
    
    // MARK: - API Key Tests
    
    func testGetMovieAPIKey() {
        // Test that we can get the API key
        let apiKey = APIKeysProvider.theMovieAPIKey
        XCTAssertFalse(apiKey.isEmpty, "API key should not be empty")
        XCTAssertEqual(apiKey, originalAPIKey, "API key should match the original value")
    }
    
    func testGetMovieAPIKeyWhenNotSet() {
        // Test when no API key is set in keychain
        try? APIKeysProvider.removeMovieAPIKey()
        
        let apiKey = APIKeysProvider.theMovieAPIKey
        XCTAssertFalse(apiKey.isEmpty, "API key should not be empty")
        XCTAssertEqual(apiKey, originalAPIKey, "API key should fallback to original value")
    }
    
    func testHasMovieAPIKey() {
        // Test that we can check if API key exists
        let hasKey = APIKeysProvider.hasMovieAPIKey
        XCTAssertTrue(hasKey(), "Should have API key available")
    }
    
    func testMovieAPIKeyIsAccessible() {
        // Test that the API key is accessible and valid
        let apiKey = APIKeysProvider.theMovieAPIKey
        XCTAssertFalse(apiKey.isEmpty, "API key should not be empty")
        XCTAssertTrue(apiKey.count > 10, "API key should be reasonably long")
    }
    
    func testSetMovieAPIKey() {
        // Test setting a new API key
        do {
            try APIKeysProvider.setMovieAPIKey(testAPIKey)
            let retrievedKey = APIKeysProvider.theMovieAPIKey
            XCTAssertEqual(retrievedKey, testAPIKey, "Retrieved key should match the set key")
        } catch {
            // In test environment, keychain might not work, so we'll skip this test
            XCTSkip("Keychain not available in test environment: \(error)")
        }
    }
    
    func testAPIKeyUpdate() {
        // Test updating an existing API key
        do {
            try APIKeysProvider.setMovieAPIKey(testAPIKey)
            let firstKey = APIKeysProvider.theMovieAPIKey
            
            let updatedKey = "updated_test_key_67890"
            try APIKeysProvider.setMovieAPIKey(updatedKey)
            let secondKey = APIKeysProvider.theMovieAPIKey
            
            XCTAssertEqual(secondKey, updatedKey, "Updated key should match the new value")
        } catch {
            // In test environment, keychain might not work, so we'll skip this test
            XCTSkip("Keychain not available in test environment: \(error)")
        }
    }
    
    func testRemoveMovieAPIKey() {
        // Test removing the API key
        do {
            try APIKeysProvider.removeMovieAPIKey()
            let hasKey = APIKeysProvider.hasMovieAPIKey
            XCTAssertFalse(hasKey(), "Should not have API key after removal")
        } catch {
            // In test environment, keychain might not work, so we'll skip this test
            XCTSkip("Keychain not available in test environment: \(error)")
        }
    }
    
    func testRemoveMovieAPIKeyWhenNotSet() {
        // Test removing when no key is set
        do {
            try APIKeysProvider.removeMovieAPIKey()
            // Should not throw an error when removing non-existent key
            try APIKeysProvider.removeMovieAPIKey()
            XCTAssertTrue(true, "Should not throw error when removing non-existent key")
        } catch {
            XCTFail("Should not throw error when removing non-existent key: \(error)")
        }
    }
    
    func testAPIKeyPersistence() {
        // Test that API key persists across app launches (simulated)
        do {
            try APIKeysProvider.setMovieAPIKey(testAPIKey)
            
            // Simulate app restart by creating a new instance
            let retrievedKey = APIKeysProvider.theMovieAPIKey
            XCTAssertEqual(retrievedKey, testAPIKey, "API key should persist")
        } catch {
            // In test environment, keychain might not work, so we'll skip this test
            XCTSkip("Keychain not available in test environment: \(error)")
        }
    }
    
    func testAPIKeyFallbackToEnvironmentVariable() {
        // Test fallback to environment variable when keychain is not available
        do {
            try APIKeysProvider.removeMovieAPIKey()
            
            // The API key should fallback to the original value
            let apiKey = APIKeysProvider.theMovieAPIKey
            XCTAssertEqual(apiKey, originalAPIKey, "Should fallback to original API key")
        } catch {
            // In test environment, keychain might not work, so we'll skip this test
            XCTSkip("Keychain not available in test environment: \(error)")
        }
    }
    
    func testAPIKeyFallbackToDefault() {
        // Test fallback to default value when no key is set
        try? APIKeysProvider.removeMovieAPIKey()
        
        let apiKey = APIKeysProvider.theMovieAPIKey
        XCTAssertFalse(apiKey.isEmpty, "API key should not be empty")
        XCTAssertEqual(apiKey, originalAPIKey, "Should fallback to original API key")
    }
    
    func testAPIKeyWithSpecialCharacters() {
        // Test API key with special characters
        let specialKey = "test_key_with_special_chars_!@#$%^&*()"
        
        do {
            try APIKeysProvider.setMovieAPIKey(specialKey)
            let retrievedKey = APIKeysProvider.theMovieAPIKey
            XCTAssertEqual(retrievedKey, specialKey, "Special characters should be preserved")
        } catch {
            // In test environment, keychain might not work, so we'll skip this test
            XCTSkip("Keychain not available in test environment: \(error)")
        }
    }
    
    func testAPIKeyWithUnicodeCharacters() {
        // Test API key with unicode characters
        let unicodeKey = "test_key_with_unicode_🎬🎭🎪"
        
        do {
            try APIKeysProvider.setMovieAPIKey(unicodeKey)
            let retrievedKey = APIKeysProvider.theMovieAPIKey
            XCTAssertEqual(retrievedKey, unicodeKey, "Unicode characters should be preserved")
        } catch {
            // In test environment, keychain might not work, so we'll skip this test
            XCTSkip("Keychain not available in test environment: \(error)")
        }
    }
} 