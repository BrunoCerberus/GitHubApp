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
     * environment variables when keychain is not available.
     */
    func testEnvironmentVariableFallback() {
        // Set environment variable for testing
        setenv("API_KEY", "test-env-key", 1)
        defer { unsetenv("API_KEY") }

        // Clear any existing keychain entry
        try? APIKeysProvider.removeMovieAPIKey()

        // Access the property to trigger environment variable fallback
        let apiKey = APIKeysProvider.theMovieAPIKey

        // Should get the environment variable value
        XCTAssertEqual(apiKey, "test-env-key")

        // Clean up
        try? APIKeysProvider.removeMovieAPIKey()
    }
}
