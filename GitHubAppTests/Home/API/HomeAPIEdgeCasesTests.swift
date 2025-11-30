//
//  HomeAPIEdgeCasesTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

import EntropyCore
import Foundation
@testable import GitHubApp
import Testing

/**
 * Comprehensive edge case tests for HomeAPI to improve test coverage.
 * These tests focus on boundary conditions and error handling.
 */
@MainActor
struct HomeAPIEdgeCasesTests {
    private func ensureAPIKey() {
        // Ensure API key is present for URL construction
        try? APIKeysProvider.setMovieAPIKey("test-api-key-for-edge-cases")
    }

    // MARK: - Search Query Edge Cases

    @Test("Search movies with very long query")
    func searchMoviesWithVeryLongQuery() {
        // Given - A very long search query
        ensureAPIKey()
        let longQuery = String(repeating: "a", count: 1000)

        // When
        let searchAPI = HomeAPI.searchMovies(query: longQuery, page: 1)
        let path = searchAPI.path

        // Then - Should handle long queries without crashing
        // API key is now in header, not URL
        #expect(path.contains("/search/movie"))
        #expect(!path.contains("api_key="))
        #expect(path.contains("query="))
    }

    @Test("Search movies with unicode characters")
    func searchMoviesWithUnicodeCharacters() {
        // Given - Search query with Unicode characters
        let unicodeQuery = "🎬 Movie with émojis and àccénts"

        // When
        let searchAPI = HomeAPI.searchMovies(query: unicodeQuery, page: 1)
        let path = searchAPI.path

        // Then - Should properly handle Unicode characters
        // API key is now in header, not URL
        #expect(path.contains("/search/movie"))
        #expect(!path.contains("api_key="))
        #expect(path.contains("query="))
    }

    @Test("Search movies with whitespace only")
    func searchMoviesWithWhitespaceOnly() {
        // Given - Search query with only whitespace
        let whitespaceQuery = "   \t\n  "

        // When
        let searchAPI = HomeAPI.searchMovies(query: whitespaceQuery, page: 1)
        let path = searchAPI.path

        // Then - Should handle whitespace-only queries
        // API key is now in header, not URL
        #expect(path.contains("/search/movie"))
        #expect(!path.contains("api_key="))
        #expect(path.contains("query="))
    }

    @Test("Search movies with URL unsafe characters")
    func searchMoviesWithURLUnsafeCharacters() {
        // Given - Search query with URL-unsafe characters
        let unsafeQuery = "movie?query=test&param=value#fragment"

        // When
        let searchAPI = HomeAPI.searchMovies(query: unsafeQuery, page: 1)
        let path = searchAPI.path

        // Then - Should properly encode unsafe characters
        // API key is now in header, not URL
        #expect(path.contains("/search/movie"))
        #expect(!path.contains("api_key="))
        #expect(path.contains("query="))
    }

    // MARK: - Movie ID Edge Cases

    @Test("Fetch credits with very large movie ID")
    func fetchCreditsWithVeryLargeMovieID() {
        // Given - Very large movie ID
        let largeID = Int.max

        // When
        let creditsAPI = HomeAPI.fetchCredits(largeID)
        let path = creditsAPI.path

        // Then - Should handle large IDs without overflow
        // API key is now in header, not URL
        #expect(path.contains("/movie/\(largeID)/credits"))
        #expect(!path.contains("api_key="))
    }

    @Test("Fetch reviews with very large movie ID")
    func fetchReviewsWithVeryLargeMovieID() {
        // Given - Very large movie ID
        let largeID = Int.max - 1

        // When
        let reviewsAPI = HomeAPI.fetchReviews(largeID)
        let path = reviewsAPI.path

        // Then - Should handle large IDs without overflow
        // API key is now in header, not URL
        #expect(path.contains("/movie/\(largeID)/reviews"))
        #expect(!path.contains("api_key="))
    }

    @Test("Fetch credits with very small movie ID")
    func fetchCreditsWithVerySmallMovieID() {
        // Given - Very small (negative) movie ID
        let smallID = Int.min

        // When
        let creditsAPI = HomeAPI.fetchCredits(smallID)
        let path = creditsAPI.path

        // Then - Should handle small IDs without underflow
        // API key is now in header, not URL
        #expect(path.contains("/movie/\(smallID)/credits"))
        #expect(!path.contains("api_key="))
    }

    @Test("Fetch reviews with very small movie ID")
    func fetchReviewsWithVerySmallMovieID() {
        // Given - Very small (negative) movie ID
        let smallID = Int.min + 1

        // When
        let reviewsAPI = HomeAPI.fetchReviews(smallID)
        let path = reviewsAPI.path

        // Then - Should handle small IDs without underflow
        // API key is now in header, not URL
        #expect(path.contains("/movie/\(smallID)/reviews"))
        #expect(!path.contains("api_key="))
    }

    // MARK: - API Configuration Edge Cases

    @Test("All endpoints have correct HTTP method")
    func allEndpointsHaveCorrectHTTPMethod() {
        // Given - All possible API endpoints
        let endpoints: [HomeAPI] = [
            .fetchMovies(page: 1),
            .searchMovies(query: "test", page: 1),
            .fetchCredits(1),
            .fetchReviews(1),
        ]

        // When & Then - All should use GET method
        for endpoint in endpoints {
            #expect(endpoint.method == .GET)
        }
    }

    @Test("All endpoints have nil task")
    func allEndpointsHaveNilTask() {
        // Given - All possible API endpoints
        let endpoints: [HomeAPI] = [
            .fetchMovies(page: 1),
            .searchMovies(query: "test", page: 1),
            .fetchCredits(1),
            .fetchReviews(1),
        ]

        // When & Then - All should have nil task (no request body)
        for endpoint in endpoints {
            #expect(endpoint.task == nil)
        }
    }

    @Test("All endpoints have Authorization header with Bearer token")
    func allEndpointsHaveAuthorizationHeader() {
        // Given - All possible API endpoints
        let endpoints: [HomeAPI] = [
            .fetchMovies(page: 1),
            .searchMovies(query: "test", page: 1),
            .fetchCredits(1),
            .fetchReviews(1),
        ]

        // When & Then - All should have Authorization header with Bearer token
        for endpoint in endpoints {
            let header = endpoint.header as? APIAuthorizationHeader
            #expect(header != nil, "Endpoint should have Authorization header")
            #expect(header?.authorization.hasPrefix("Bearer ") == true)
        }
    }

    @Test("Debug configuration consistency")
    func debugConfigurationConsistency() {
        // Given - All possible API endpoints
        let endpoints: [HomeAPI] = [
            .fetchMovies(page: 1),
            .searchMovies(query: "debug_test", page: 1),
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
            #expect(endpoint.debug == expectedDebug)
        }
    }

    // MARK: - URL Construction Stress Tests

    @Test("URL construction with many query parameters")
    func urlConstructionWithManyQueryParameters() {
        // Given - Multiple endpoints that would create complex URLs
        let endpoints: [(HomeAPI, String)] = [
            (.fetchMovies(page: 1), "fetchMovies"),
            (.searchMovies(query: "complex query with spaces", page: 1), "searchMovies"),
            (.fetchCredits(12345), "fetchCredits"),
            (.fetchReviews(67890), "fetchReviews"),
        ]

        // When & Then - All should construct valid URLs
        for (endpoint, name) in endpoints {
            let path = endpoint.path

            // Basic URL validity checks
            #expect(!path.isEmpty, "\(name) should not produce empty path")
            // API key is now in header, not URL
            #expect(!path.contains("api_key="), "\(name) should NOT contain API key (now in header)")
            #expect(path.hasPrefix("http"), "\(name) should start with http protocol")

            // Verify URL can be constructed
            #expect(URL(string: path) != nil, "\(name) should produce valid URL: \(path)")
        }
    }

    @Test("API error description complete")
    func apiErrorDescriptionComplete() {
        // Given - Both API error types
        let invalidBaseError = APIError.invalidBaseURL("invalid://malformed-url")
        let constructionFailedError = APIError.urlConstructionFailed

        // When & Then - Both should have non-empty descriptions
        #expect(invalidBaseError.errorDescription != nil)
        #expect(!invalidBaseError.errorDescription!.isEmpty)

        #expect(constructionFailedError.errorDescription != nil)
        #expect(!constructionFailedError.errorDescription!.isEmpty)

        // Descriptions should be different
        #expect(invalidBaseError.errorDescription != constructionFailedError.errorDescription)
    }

    // MARK: - Multiple Query Parameters Test

    @Test("Search movies URL structure")
    func searchMoviesURLStructure() {
        // Given
        let query = "action movie"
        let searchAPI = HomeAPI.searchMovies(query: query, page: 1)

        // When
        let path = searchAPI.path

        // Then - Should have proper query parameter structure
        #expect(path.contains("?"), "URL should contain query separator")

        // Count query parameters - should have query and page (API key is now in header)
        let components = URLComponents(string: path)
        #expect(components != nil)
        #expect(components?.queryItems != nil)
        #expect((components?.queryItems?.count ?? 0) == 2, "Should have query and page parameters")

        // Verify specific parameters exist
        // API key is now in header, not URL
        let queryItems = components?.queryItems ?? []
        #expect(queryItems.contains { $0.name == "query" })
        #expect(!queryItems.contains { $0.name == "api_key" }, "API key should be in header, not URL")
    }

    // MARK: - Protocol Compliance Tests

    @Test("API fetcher protocol compliance")
    func apiFetcherProtocolCompliance() {
        // Given - HomeAPI should conform to APIFetcher protocol
        let api: any APIFetcher = HomeAPI.fetchMovies(page: 1)

        // When & Then - Should have all required properties
        #expect(!api.path.isEmpty)
        _ = api.method // Should not crash
        // task and header can be nil for this protocol
        // debug should exist
        _ = api.debug // Should not crash
    }
}
