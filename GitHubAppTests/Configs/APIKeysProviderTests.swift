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
}
