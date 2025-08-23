//
//  HomeAPIEdgeCasesTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

import EntropyCore
@testable import GitHubApp
import XCTest

/**
 * Comprehensive edge case tests for HomeAPI to improve test coverage.
 * These tests focus on boundary conditions and error handling.
 */
final class HomeAPIEdgeCasesTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        // Ensure API key is present for URL construction
        try? APIKeysProvider.setMovieAPIKey("test-api-key-for-edge-cases")
    }

    override func tearDown() {
        try? APIKeysProvider.removeMovieAPIKey()
        super.tearDown()
    }

    // MARK: - Search Query Edge Cases

    func testSearchMoviesWithVeryLongQuery() {
        // Given - A very long search query
        let longQuery = String(repeating: "a", count: 1000)

        // When
        let searchAPI = HomeAPI.searchMovies(longQuery)
        let path = searchAPI.path

        // Then - Should handle long queries without crashing
        XCTAssertTrue(path.contains("/search/movie"))
        XCTAssertTrue(path.contains("api_key="))
        XCTAssertTrue(path.contains("query="))
    }

    func testSearchMoviesWithUnicodeCharacters() {
        // Given - Search query with Unicode characters
        let unicodeQuery = "🎬 Movie with émojis and àccénts"

        // When
        let searchAPI = HomeAPI.searchMovies(unicodeQuery)
        let path = searchAPI.path

        // Then - Should properly handle Unicode characters
        XCTAssertTrue(path.contains("/search/movie"))
        XCTAssertTrue(path.contains("api_key="))
        XCTAssertTrue(path.contains("query="))
    }

    func testSearchMoviesWithWhitespaceOnly() {
        // Given - Search query with only whitespace
        let whitespaceQuery = "   \t\n  "

        // When
        let searchAPI = HomeAPI.searchMovies(whitespaceQuery)
        let path = searchAPI.path

        // Then - Should handle whitespace-only queries
        XCTAssertTrue(path.contains("/search/movie"))
        XCTAssertTrue(path.contains("api_key="))
        XCTAssertTrue(path.contains("query="))
    }

    func testSearchMoviesWithURLUnsafeCharacters() {
        // Given - Search query with URL-unsafe characters
        let unsafeQuery = "movie?query=test&param=value#fragment"

        // When
        let searchAPI = HomeAPI.searchMovies(unsafeQuery)
        let path = searchAPI.path

        // Then - Should properly encode unsafe characters
        XCTAssertTrue(path.contains("/search/movie"))
        XCTAssertTrue(path.contains("api_key="))
        XCTAssertTrue(path.contains("query="))
    }

    // MARK: - Movie ID Edge Cases

    func testFetchCreditsWithVeryLargeMovieID() {
        // Given - Very large movie ID
        let largeID = Int.max

        // When
        let creditsAPI = HomeAPI.fetchCredits(largeID)
        let path = creditsAPI.path

        // Then - Should handle large IDs without overflow
        XCTAssertTrue(path.contains("/movie/\(largeID)/credits"))
        XCTAssertTrue(path.contains("api_key="))
    }

    func testFetchReviewsWithVeryLargeMovieID() {
        // Given - Very large movie ID
        let largeID = Int.max - 1

        // When
        let reviewsAPI = HomeAPI.fetchReviews(largeID)
        let path = reviewsAPI.path

        // Then - Should handle large IDs without overflow
        XCTAssertTrue(path.contains("/movie/\(largeID)/reviews"))
        XCTAssertTrue(path.contains("api_key="))
    }

    func testFetchCreditsWithVerySmallMovieID() {
        // Given - Very small (negative) movie ID
        let smallID = Int.min

        // When
        let creditsAPI = HomeAPI.fetchCredits(smallID)
        let path = creditsAPI.path

        // Then - Should handle small IDs without underflow
        XCTAssertTrue(path.contains("/movie/\(smallID)/credits"))
        XCTAssertTrue(path.contains("api_key="))
    }

    func testFetchReviewsWithVerySmallMovieID() {
        // Given - Very small (negative) movie ID
        let smallID = Int.min + 1

        // When
        let reviewsAPI = HomeAPI.fetchReviews(smallID)
        let path = reviewsAPI.path

        // Then - Should handle small IDs without underflow
        XCTAssertTrue(path.contains("/movie/\(smallID)/reviews"))
        XCTAssertTrue(path.contains("api_key="))
    }

    // MARK: - API Configuration Edge Cases

    func testAllEndpointsHaveCorrectHTTPMethod() {
        // Given - All possible API endpoints
        let endpoints: [HomeAPI] = [
            .fetchMovies,
            .searchMovies("test"),
            .fetchCredits(1),
            .fetchReviews(1),
        ]

        // When & Then - All should use GET method
        for endpoint in endpoints {
            XCTAssertEqual(endpoint.method, .GET, "Endpoint \(endpoint) should use GET method")
        }
    }

    func testAllEndpointsHaveNilTask() {
        // Given - All possible API endpoints
        let endpoints: [HomeAPI] = [
            .fetchMovies,
            .searchMovies("test"),
            .fetchCredits(1),
            .fetchReviews(1),
        ]

        // When & Then - All should have nil task (no request body)
        for endpoint in endpoints {
            XCTAssertNil(endpoint.task, "Endpoint \(endpoint) should have nil task")
        }
    }

    func testAllEndpointsHaveNilHeader() {
        // Given - All possible API endpoints
        let endpoints: [HomeAPI] = [
            .fetchMovies,
            .searchMovies("test"),
            .fetchCredits(1),
            .fetchReviews(1),
        ]

        // When & Then - All should have nil header (no custom headers)
        for endpoint in endpoints {
            XCTAssertNil(endpoint.header, "Endpoint \(endpoint) should have nil header")
        }
    }

    func testDebugConfigurationConsistency() {
        // Given - All possible API endpoints
        let endpoints: [HomeAPI] = [
            .fetchMovies,
            .searchMovies("debug_test"),
            .fetchCredits(999),
            .fetchReviews(888),
        ]

        // When & Then - Debug setting should be consistent across all endpoints
        let expectedDebug: Bool = {
            #if DEBUG
                return true
            #else
                return false
            #endif
        }()

        for endpoint in endpoints {
            XCTAssertEqual(endpoint.debug, expectedDebug, "Endpoint \(endpoint) should have consistent debug setting")
        }
    }

    // MARK: - URL Construction Stress Tests

    func testURLConstructionWithManyQueryParameters() {
        // Given - Multiple endpoints that would create complex URLs
        let endpoints: [(HomeAPI, String)] = [
            (.fetchMovies, "fetchMovies"),
            (.searchMovies("complex query with spaces"), "searchMovies"),
            (.fetchCredits(12345), "fetchCredits"),
            (.fetchReviews(67890), "fetchReviews"),
        ]

        // When & Then - All should construct valid URLs
        for (endpoint, name) in endpoints {
            let path = endpoint.path

            // Basic URL validity checks
            XCTAssertFalse(path.isEmpty, "\(name) should not produce empty path")
            XCTAssertTrue(path.contains("api_key="), "\(name) should contain API key")
            XCTAssertTrue(path.hasPrefix("http"), "\(name) should start with http protocol")

            // Verify URL can be constructed
            XCTAssertNotNil(URL(string: path), "\(name) should produce valid URL: \(path)")
        }
    }

    func testAPIErrorDescriptionComplete() {
        // Given - Both API error types
        let invalidBaseError = APIError.invalidBaseURL("invalid://malformed-url")
        let constructionFailedError = APIError.urlConstructionFailed

        // When & Then - Both should have non-empty descriptions
        XCTAssertNotNil(invalidBaseError.errorDescription)
        XCTAssertFalse(invalidBaseError.errorDescription!.isEmpty)

        XCTAssertNotNil(constructionFailedError.errorDescription)
        XCTAssertFalse(constructionFailedError.errorDescription!.isEmpty)

        // Descriptions should be different
        XCTAssertNotEqual(invalidBaseError.errorDescription, constructionFailedError.errorDescription)
    }

    // MARK: - Multiple Query Parameters Test

    func testSearchMoviesURLStructure() {
        // Given
        let query = "action movie"
        let searchAPI = HomeAPI.searchMovies(query)

        // When
        let path = searchAPI.path

        // Then - Should have proper query parameter structure
        XCTAssertTrue(path.contains("?"), "URL should contain query separator")

        // Count query parameters - should have at least query and api_key
        let components = URLComponents(string: path)
        XCTAssertNotNil(components)
        XCTAssertNotNil(components?.queryItems)
        XCTAssertGreaterThanOrEqual(components?.queryItems?.count ?? 0, 2)

        // Verify specific parameters exist
        let queryItems = components?.queryItems ?? []
        XCTAssertTrue(queryItems.contains { $0.name == "query" })
        XCTAssertTrue(queryItems.contains { $0.name == "api_key" })
    }

    // MARK: - Protocol Compliance Tests

    func testAPIFetcherProtocolCompliance() {
        // Given - HomeAPI should conform to APIFetcher protocol
        let api: any APIFetcher = HomeAPI.fetchMovies

        // When & Then - Should have all required properties
        XCTAssertNotNil(api.path)
        XCTAssertNotNil(api.method)
        // task and header can be nil for this protocol
        // debug should exist
        _ = api.debug // Should not crash
    }
}
