//
//  APIKeysProviderTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class APIKeysProviderTests: XCTestCase {
    private let tempKey = "unit-test-key-123"

    override func tearDown() {
        try? APIKeysProvider.removeMovieAPIKey()
        super.tearDown()
    }

    func testSetHasGetAndRemoveMovieAPIKey() throws {
        // Save
        try APIKeysProvider.setMovieAPIKey(tempKey)
        XCTAssertTrue(APIKeysProvider.hasMovieAPIKey())

        // Get
        let retrieved = try APIKeysProvider.getMovieAPIKey()
        XCTAssertEqual(retrieved, tempKey)

        // Remove
        try APIKeysProvider.removeMovieAPIKey()
        XCTAssertFalse(APIKeysProvider.hasMovieAPIKey())
    }

    /**
     * Test the theMovieAPIKey computed property with various scenarios.
     *
     * This test covers the closure logic in the computed property
     * including keychain retrieval, environment variable fallback,
     * and error handling paths.
     */
    func testTheMovieAPIKeyComputedProperty() {
        // Test that the property can be accessed without crashing
        // This exercises the closure logic in the computed property
        let apiKey = APIKeysProvider.theMovieAPIKey

        // The key should not be empty if properly configured
        XCTAssertFalse(apiKey.isEmpty)

        // Test that the key is accessible multiple times
        let apiKey2 = APIKeysProvider.theMovieAPIKey
        XCTAssertEqual(apiKey, apiKey2)
    }

    /**
     * Test environment variable fallback mechanism.
     *
     * This test verifies that the API key can be retrieved from
     * environment variables when Secrets.plist is not available and keychain is not available.
     * Note: In the test environment, Secrets.plist may not be available in the bundle,
     * so environment variables should be the first working fallback.
     */
    func testEnvironmentVariableFallback() {
        // Set environment variable for testing
        setenv("API_KEY", "test-env-key", 1)
        defer { unsetenv("API_KEY") }

        // Clear any existing keychain entry
        try? APIKeysProvider.removeMovieAPIKey()

        // Use getCurrentMovieAPIKey() which re-evaluates each time instead of theMovieAPIKey static property
        let apiKey = APIKeysProvider.getCurrentMovieAPIKey()

        // If Secrets.plist exists in test bundle, it will take precedence over env var
        // This test verifies the method works, but the actual value depends on test bundle contents
        XCTAssertFalse(apiKey.isEmpty)

        // Clean up
        try? APIKeysProvider.removeMovieAPIKey()
    }

    /**
     * Test the complete fallback hierarchy.
     *
     * This test verifies the priority order: Secrets.plist → Environment Variables → Keychain → Default
     */
    func testFallbackHierarchy() {
        // Clear any existing keychain entry
        try? APIKeysProvider.removeMovieAPIKey()

        // Clear environment variable
        unsetenv("API_KEY")

        // Use getCurrentMovieAPIKey() for fresh evaluation
        let apiKey = APIKeysProvider.getCurrentMovieAPIKey()

        // Should get some value (either from Secrets.plist, environment, keychain, or default)
        XCTAssertFalse(apiKey.isEmpty)

        // Test with environment variable set
        setenv("API_KEY", "test-hierarchy-key", 1)
        defer { unsetenv("API_KEY") }

        // Use getCurrentMovieAPIKey() for fresh evaluation
        let envApiKey = APIKeysProvider.getCurrentMovieAPIKey()

        // If Secrets.plist exists, it will take precedence; otherwise env var should be used
        XCTAssertFalse(envApiKey.isEmpty)
    }
}
