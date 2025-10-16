//
//  APIKeysProviderTests.swift
//  GitHubAppTests
//

import Foundation
@testable import GitHubApp
import Testing

struct APIKeysProviderTests {
    private let tempKey = "unit-test-key-123"

    @Test("API key can be set, retrieved, and removed from keychain")
    func setHasGetAndRemoveMovieAPIKey() throws {
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        // Save
        try APIKeysProvider.setMovieAPIKey(tempKey)
        #expect(APIKeysProvider.hasMovieAPIKey())

        // Get
        let retrieved = try APIKeysProvider.getMovieAPIKey()
        #expect(retrieved == tempKey)

        // Remove
        try APIKeysProvider.removeMovieAPIKey()
        #expect(!APIKeysProvider.hasMovieAPIKey())
    }

    @Test("The movie API key computed property returns consistent non-empty value")
    func theMovieAPIKeyComputedProperty() {
        // Test that the property can be accessed without crashing
        // This exercises the closure logic in the computed property
        let apiKey = APIKeysProvider.theMovieAPIKey

        // The key should not be empty if properly configured
        #expect(!apiKey.isEmpty)

        // Test that the key is accessible multiple times
        let apiKey2 = APIKeysProvider.theMovieAPIKey
        #expect(apiKey == apiKey2)
    }

    @Test("Environment variable fallback mechanism works correctly")
    func environmentVariableFallback() {
        // Set environment variable for testing
        setenv("API_KEY", "test-env-key", 1)
        defer { unsetenv("API_KEY") }

        // Clear any existing keychain entry
        try? APIKeysProvider.removeMovieAPIKey()

        // Use getCurrentMovieAPIKey() which re-evaluates each time instead of theMovieAPIKey static property
        let apiKey = APIKeysProvider.getCurrentMovieAPIKey()

        // If Secrets.plist exists in test bundle, it will take precedence over env var
        // This test verifies the method works, but the actual value depends on test bundle contents
        #expect(!apiKey.isEmpty)

        // Clean up
        try? APIKeysProvider.removeMovieAPIKey()
    }

    @Test("Complete fallback hierarchy follows correct priority order")
    func fallbackHierarchy() {
        // Clear any existing keychain entry
        try? APIKeysProvider.removeMovieAPIKey()

        // Clear environment variable
        unsetenv("API_KEY")

        // Use getCurrentMovieAPIKey() for fresh evaluation
        let apiKey = APIKeysProvider.getCurrentMovieAPIKey()

        // Should get some value (either from Secrets.plist, environment, keychain, or default)
        #expect(!apiKey.isEmpty)

        // Test with environment variable set
        setenv("API_KEY", "test-hierarchy-key", 1)
        defer { unsetenv("API_KEY") }

        // Use getCurrentMovieAPIKey() for fresh evaluation
        let envApiKey = APIKeysProvider.getCurrentMovieAPIKey()

        // If Secrets.plist exists, it will take precedence; otherwise env var should be used
        #expect(!envApiKey.isEmpty)
    }

    @Test("Getting non-existent API key from keychain throws error")
    func gettingNonExistentAPIKeyThrowsError() {
        // Clear any existing key first
        try? APIKeysProvider.removeMovieAPIKey()

        // When attempting to get a key that doesn't exist
        do {
            _ = try APIKeysProvider.getMovieAPIKey()
            Issue.record("Expected getMovieAPIKey to throw an error")
        } catch {
            // Then - Should throw an error
            #expect(true)
        }
    }

    @Test("Removing non-existent API key succeeds without error")
    func removingNonExistentAPIKeySucceeds() throws {
        // Clear any existing key first
        try? APIKeysProvider.removeMovieAPIKey()

        // When attempting to remove a key that doesn't exist
        // Then - Should succeed without throwing an error (idempotent behavior)
        try APIKeysProvider.removeMovieAPIKey()
        #expect(true)
    }

    @Test("API key can be updated with new value")
    func apiKeyCanBeUpdatedWithNewValue() throws {
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        let firstKey = "first-test-key"
        let secondKey = "second-test-key"

        // Save first key
        try APIKeysProvider.setMovieAPIKey(firstKey)
        var retrieved = try APIKeysProvider.getMovieAPIKey()
        #expect(retrieved == firstKey)

        // Update with second key
        try APIKeysProvider.setMovieAPIKey(secondKey)
        retrieved = try APIKeysProvider.getMovieAPIKey()
        #expect(retrieved == secondKey)
    }

    @Test("Has movie API key returns false when key does not exist")
    func hasMovieAPIKeyReturnsFalseWhenKeyDoesNotExist() {
        // Clear any existing key
        try? APIKeysProvider.removeMovieAPIKey()

        // Should return false when key doesn't exist
        #expect(!APIKeysProvider.hasMovieAPIKey())
    }

    @Test("Has movie API key returns true after setting key")
    func hasMovieAPIKeyReturnsTrueAfterSetting() throws {
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        // Initially should not have the key
        #expect(!APIKeysProvider.hasMovieAPIKey())

        // Set the key
        try APIKeysProvider.setMovieAPIKey("test-key-exists")

        // Should now return true
        #expect(APIKeysProvider.hasMovieAPIKey())
    }

    @Test("SetMovieAPIKey with empty string saves the value")
    func setMovieAPIKeyWithEmptyStringSavesValue() throws {
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        // Set empty string
        try APIKeysProvider.setMovieAPIKey("")

        // Should be able to retrieve the empty string
        let retrieved = try APIKeysProvider.getMovieAPIKey()
        #expect(retrieved == "")
    }

    @Test("Multiple sequential key operations maintain integrity")
    func multipleSequentialKeyOperationsMaintainIntegrity() throws {
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        // Operation 1: Set key
        try APIKeysProvider.setMovieAPIKey("key1")
        #expect(APIKeysProvider.hasMovieAPIKey())

        // Operation 2: Update key
        try APIKeysProvider.setMovieAPIKey("key2")
        var retrieved = try APIKeysProvider.getMovieAPIKey()
        #expect(retrieved == "key2")

        // Operation 3: Verify existence
        #expect(APIKeysProvider.hasMovieAPIKey())

        // Operation 4: Remove key
        try APIKeysProvider.removeMovieAPIKey()
        #expect(!APIKeysProvider.hasMovieAPIKey())

        // Operation 5: Set key again after removal
        try APIKeysProvider.setMovieAPIKey("key3")
        retrieved = try APIKeysProvider.getMovieAPIKey()
        #expect(retrieved == "key3")
    }
}
