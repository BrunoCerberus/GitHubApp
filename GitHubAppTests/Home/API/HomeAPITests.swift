//
//  HomeAPITests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

@MainActor
struct HomeAPITests {
    init() {
        // Ensure API key is present so HomeAPI can build URLs
        try? APIKeysProvider.setMovieAPIKey("api-key-for-tests")
    }

    @Test("API paths contain correct endpoints (API key now in header)")
    func pathsContainCorrectEndpoints() {
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        // API key is now passed via Authorization header, not in URL
        #expect(HomeAPI.fetchMovies(page: 1).path.contains("/movie/upcoming"))
        #expect(!HomeAPI.fetchMovies(page: 1).path.contains("api_key="))

        #expect(HomeAPI.searchMovies(query: "matrix", page: 1).path.contains("/search/movie"))
        #expect(HomeAPI.searchMovies(query: "matrix", page: 1).path.contains("query=matrix"))
        #expect(!HomeAPI.searchMovies(query: "matrix", page: 1).path.contains("api_key="))

        #expect(HomeAPI.fetchCredits(10).path.contains("/movie/10/credits"))
        #expect(!HomeAPI.fetchCredits(10).path.contains("api_key="))

        #expect(HomeAPI.fetchReviews(10).path.contains("/movie/10/reviews"))
        #expect(!HomeAPI.fetchReviews(10).path.contains("api_key="))
    }

    @Test("API error descriptions contain expected text")
    func apiErrorDescriptions() {
        let invalid = APIError.invalidBaseURL("bad://url")
        #expect(invalid.localizedDescription.contains("Invalid base URL"))

        let failed = APIError.urlConstructionFailed
        #expect(failed.localizedDescription.contains("Failed to construct URL"))
    }

    @Test("All API endpoints use GET HTTP method")
    func httpMethodConfiguration() {
        #expect(HomeAPI.fetchMovies(page: 1).method == .GET)
        #expect(HomeAPI.searchMovies(query: "test", page: 1).method == .GET)
        #expect(HomeAPI.fetchCredits(1).method == .GET)
        #expect(HomeAPI.fetchReviews(1).method == .GET)
    }

    @Test("All API endpoints have no request body for GET requests")
    func requestBodyConfiguration() {
        #expect(HomeAPI.fetchMovies(page: 1).task == nil)
        #expect(HomeAPI.searchMovies(query: "test", page: 1).task == nil)
        #expect(HomeAPI.fetchCredits(1).task == nil)
        #expect(HomeAPI.fetchReviews(1).task == nil)
    }

    @Test("All endpoints use Bearer token Authorization header for security")
    func authorizationHeaderConfiguration() {
        // All endpoints should have Authorization header with Bearer token
        let fetchHeader = HomeAPI.fetchMovies(page: 1).header as? APIAuthorizationHeader
        let searchHeader = HomeAPI.searchMovies(query: "test", page: 1).header as? APIAuthorizationHeader
        let creditsHeader = HomeAPI.fetchCredits(1).header as? APIAuthorizationHeader
        let reviewsHeader = HomeAPI.fetchReviews(1).header as? APIAuthorizationHeader

        #expect(fetchHeader != nil)
        #expect(searchHeader != nil)
        #expect(creditsHeader != nil)
        #expect(reviewsHeader != nil)

        // All should start with "Bearer "
        #expect(fetchHeader?.authorization.hasPrefix("Bearer ") == true)
        #expect(searchHeader?.authorization.hasPrefix("Bearer ") == true)
        #expect(creditsHeader?.authorization.hasPrefix("Bearer ") == true)
        #expect(reviewsHeader?.authorization.hasPrefix("Bearer ") == true)
    }

    @Test("Debug logging is configured correctly for build type")
    func debugLoggingConfiguration() {
        #if DEBUG
            #expect(HomeAPI.fetchMovies(page: 1).debug)
            #expect(HomeAPI.searchMovies(query: "test", page: 1).debug)
            #expect(HomeAPI.fetchCredits(1).debug)
            #expect(HomeAPI.fetchReviews(1).debug)
        #else
            #expect(!HomeAPI.fetchMovies(page: 1).debug)
            #expect(!HomeAPI.searchMovies(query: "test", page: 1).debug)
            #expect(!HomeAPI.fetchCredits(1).debug)
            #expect(!HomeAPI.fetchReviews(1).debug)
        #endif
    }

    @Test("URL construction handles special characters in search query")
    func urlConstructionWithSpecialCharacters() {
        let query = "movie & film: test"
        let searchPath = HomeAPI.searchMovies(query: query, page: 1).path

        #expect(searchPath.contains("/search/movie"))
        // API key is now in header, not URL
        #expect(!searchPath.contains("api_key="))
        // The query should be properly URL-encoded
        #expect(searchPath.contains("query="))
    }

    @Test("URL construction handles empty search query correctly")
    func urlConstructionWithEmptySearchQuery() {
        let searchPath = HomeAPI.searchMovies(query: "", page: 1).path

        #expect(searchPath.contains("/search/movie"))
        // API key is now in header, not URL
        #expect(!searchPath.contains("api_key="))
        #expect(searchPath.contains("query="))
    }

    @Test("URL construction properly interpolates numeric movie IDs")
    func urlConstructionWithNumericMovieIDs() {
        let creditsPath = HomeAPI.fetchCredits(12345).path
        let reviewsPath = HomeAPI.fetchReviews(67890).path

        #expect(creditsPath.contains("/movie/12345/credits"))
        #expect(reviewsPath.contains("/movie/67890/reviews"))
        // API key is now in header, not URL
        #expect(!creditsPath.contains("api_key="))
        #expect(!reviewsPath.contains("api_key="))
    }

    @Test("URL construction handles movie ID zero correctly")
    func urlConstructionWithZeroMovieID() {
        let creditsPath = HomeAPI.fetchCredits(0).path
        let reviewsPath = HomeAPI.fetchReviews(0).path

        #expect(creditsPath.contains("/movie/0/credits"))
        #expect(reviewsPath.contains("/movie/0/reviews"))
        // API key is now in header, not URL
        #expect(!creditsPath.contains("api_key="))
        #expect(!reviewsPath.contains("api_key="))
    }

    @Test("URL construction handles negative movie IDs correctly")
    func urlConstructionWithNegativeMovieID() {
        let creditsPath = HomeAPI.fetchCredits(-1).path
        let reviewsPath = HomeAPI.fetchReviews(-999).path

        #expect(creditsPath.contains("/movie/-1/credits"))
        #expect(reviewsPath.contains("/movie/-999/reviews"))
        // API key is now in header, not URL
        #expect(!creditsPath.contains("api_key="))
        #expect(!reviewsPath.contains("api_key="))
    }

    @Test("Access token is used in Authorization header for all endpoints")
    func accessTokenInAuthorizationHeader() {
        // Get the actual access token being used
        let actualAccessToken = APIKeysProvider.theMovieAccessToken

        // Verify all endpoints have Authorization header with the access token
        let endpoints = [
            HomeAPI.fetchMovies(page: 1),
            HomeAPI.searchMovies(query: "test", page: 1),
            HomeAPI.fetchCredits(1),
            HomeAPI.fetchReviews(1),
        ]

        for endpoint in endpoints {
            let header = endpoint.header as? APIAuthorizationHeader
            #expect(header != nil)
            #expect(header?.authorization == "Bearer \(actualAccessToken)")
        }
    }

    @Test("Base URL is properly configured for all endpoints")
    func baseURLConfiguration() {
        let fetchPath = HomeAPI.fetchMovies(page: 1).path
        let searchPath = HomeAPI.searchMovies(query: "test", page: 1).path
        let creditsPath = HomeAPI.fetchCredits(1).path
        let reviewsPath = HomeAPI.fetchReviews(1).path

        // All paths should start with the base URL
        #expect(fetchPath.hasPrefix("https://"))
        #expect(searchPath.hasPrefix("https://"))
        #expect(creditsPath.hasPrefix("https://"))
        #expect(reviewsPath.hasPrefix("https://"))
    }
}
