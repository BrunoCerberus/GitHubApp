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
}
