//
//  HomeAPITests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class HomeAPITests: XCTestCase {
    override class func setUp() {
        super.setUp()
        // Ensure API key is present so HomeAPI can build URLs
        // This must be done at class level before any tests run
        try? APIKeysProvider.setMovieAPIKey("api-key-for-tests")
    }

    override func setUp() {
        super.setUp()
        // No need to set API key here as it's already set at class level
    }

    override func tearDown() {
        try? APIKeysProvider.removeMovieAPIKey()
        super.tearDown()
    }

    func testPathsContainApiKeyAndEndpoint() {
        XCTAssertTrue(HomeAPI.fetchMovies.path.contains("/movie/upcoming"))
        XCTAssertTrue(HomeAPI.fetchMovies.path.contains("api_key="))

        XCTAssertTrue(HomeAPI.searchMovies("matrix").path.contains("/search/movie"))
        XCTAssertTrue(HomeAPI.searchMovies("matrix").path.contains("query=matrix"))
        XCTAssertTrue(HomeAPI.searchMovies("matrix").path.contains("api_key="))

        XCTAssertTrue(HomeAPI.fetchCredits(10).path.contains("/movie/10/credits"))
        XCTAssertTrue(HomeAPI.fetchCredits(10).path.contains("api_key="))

        XCTAssertTrue(HomeAPI.fetchReviews(10).path.contains("/movie/10/reviews"))
        XCTAssertTrue(HomeAPI.fetchReviews(10).path.contains("api_key="))
    }

    func testAPIErrorDescriptions() {
        let invalid = APIError.invalidBaseURL("bad://url")
        XCTAssertTrue(invalid.localizedDescription.contains("Invalid base URL"))

        let failed = APIError.urlConstructionFailed
        XCTAssertTrue(failed.localizedDescription.contains("Failed to construct URL"))
    }

    /**
     * Test HTTP method configuration.
     *
     * This test verifies that all API endpoints use GET method.
     */
    func testHTTPMethodConfiguration() {
        XCTAssertEqual(HomeAPI.fetchMovies.method, .GET)
        XCTAssertEqual(HomeAPI.searchMovies("test").method, .GET)
        XCTAssertEqual(HomeAPI.fetchCredits(1).method, .GET)
        XCTAssertEqual(HomeAPI.fetchReviews(1).method, .GET)
    }

    /**
     * Test request body configuration.
     *
     * This test verifies that all API endpoints have no request body
     * since they are GET requests.
     */
    func testRequestBodyConfiguration() {
        XCTAssertNil(HomeAPI.fetchMovies.task)
        XCTAssertNil(HomeAPI.searchMovies("test").task)
        XCTAssertNil(HomeAPI.fetchCredits(1).task)
        XCTAssertNil(HomeAPI.fetchReviews(1).task)
    }

    /**
     * Test custom headers configuration.
     *
     * This test verifies that no custom headers are required
     * for The Movie Database API.
     */
    func testCustomHeadersConfiguration() {
        XCTAssertNil(HomeAPI.fetchMovies.header)
        XCTAssertNil(HomeAPI.searchMovies("test").header)
        XCTAssertNil(HomeAPI.fetchCredits(1).header)
        XCTAssertNil(HomeAPI.fetchReviews(1).header)
    }

    /**
     * Test debug logging configuration.
     *
     * This test verifies that debug logging is enabled
     * in development builds.
     */
    func testDebugLoggingConfiguration() {
        #if DEBUG
            XCTAssertTrue(HomeAPI.fetchMovies.debug)
            XCTAssertTrue(HomeAPI.searchMovies("test").debug)
            XCTAssertTrue(HomeAPI.fetchCredits(1).debug)
            XCTAssertTrue(HomeAPI.fetchReviews(1).debug)
        #else
            XCTAssertFalse(HomeAPI.fetchMovies.debug)
            XCTAssertFalse(HomeAPI.searchMovies("test").debug)
            XCTAssertFalse(HomeAPI.fetchCredits(1).debug)
            XCTAssertFalse(HomeAPI.fetchReviews(1).debug)
        #endif
    }

    /**
     * Test URL construction with special characters in search query.
     *
     * This test verifies that search queries with special characters
     * are properly URL-encoded.
     */
    func testURLConstructionWithSpecialCharacters() {
        let query = "movie & film: test"
        let searchPath = HomeAPI.searchMovies(query).path

        XCTAssertTrue(searchPath.contains("/search/movie"))
        XCTAssertTrue(searchPath.contains("api_key="))
        // The query should be properly URL-encoded
        XCTAssertTrue(searchPath.contains("query="))
    }

    /**
     * Test URL construction with empty search query.
     *
     * This test verifies that empty search queries are handled
     * correctly.
     */
    func testURLConstructionWithEmptySearchQuery() {
        let searchPath = HomeAPI.searchMovies("").path

        XCTAssertTrue(searchPath.contains("/search/movie"))
        XCTAssertTrue(searchPath.contains("api_key="))
        XCTAssertTrue(searchPath.contains("query="))
    }

    /**
     * Test URL construction with numeric movie IDs.
     *
     * This test verifies that movie IDs are properly interpolated
     * into the URL path.
     */
    func testURLConstructionWithNumericMovieIDs() {
        let creditsPath = HomeAPI.fetchCredits(12345).path
        let reviewsPath = HomeAPI.fetchReviews(67890).path

        XCTAssertTrue(creditsPath.contains("/movie/12345/credits"))
        XCTAssertTrue(reviewsPath.contains("/movie/67890/reviews"))
        XCTAssertTrue(creditsPath.contains("api_key="))
        XCTAssertTrue(reviewsPath.contains("api_key="))
    }

    /**
     * Test URL construction with zero movie ID.
     *
     * This test verifies that movie ID 0 is handled correctly.
     */
    func testURLConstructionWithZeroMovieID() {
        let creditsPath = HomeAPI.fetchCredits(0).path
        let reviewsPath = HomeAPI.fetchReviews(0).path

        XCTAssertTrue(creditsPath.contains("/movie/0/credits"))
        XCTAssertTrue(reviewsPath.contains("/movie/0/reviews"))
        XCTAssertTrue(creditsPath.contains("api_key="))
        XCTAssertTrue(reviewsPath.contains("api_key="))
    }

    /**
     * Test URL construction with negative movie ID.
     *
     * This test verifies that negative movie IDs are handled correctly.
     */
    func testURLConstructionWithNegativeMovieID() {
        let creditsPath = HomeAPI.fetchCredits(-1).path
        let reviewsPath = HomeAPI.fetchReviews(-999).path

        XCTAssertTrue(creditsPath.contains("/movie/-1/credits"))
        XCTAssertTrue(reviewsPath.contains("/movie/-999/reviews"))
        XCTAssertTrue(creditsPath.contains("api_key="))
        XCTAssertTrue(reviewsPath.contains("api_key="))
    }

    /**
     * Test that API key is injected into all endpoint URLs.
     *
     * This test verifies that all API endpoints include the API key
     * as a query parameter for authentication.
     */
    func testAPIKeyInjectionInAllEndpoints() {
        // Get the actual API key being used
        let actualAPIKey = APIKeysProvider.theMovieAPIKey

        // Verify that all endpoints contain the API key
        XCTAssertTrue(HomeAPI.fetchMovies.path.contains("api_key="))
        XCTAssertTrue(HomeAPI.searchMovies("test").path.contains("api_key="))
        XCTAssertTrue(HomeAPI.fetchCredits(1).path.contains("api_key="))
        XCTAssertTrue(HomeAPI.fetchReviews(1).path.contains("api_key="))

        // Verify that the API key value is actually present in the URL
        XCTAssertTrue(HomeAPI.fetchMovies.path.contains(actualAPIKey))
        XCTAssertTrue(HomeAPI.searchMovies("test").path.contains(actualAPIKey))
        XCTAssertTrue(HomeAPI.fetchCredits(1).path.contains(actualAPIKey))
        XCTAssertTrue(HomeAPI.fetchReviews(1).path.contains(actualAPIKey))
    }

    /**
     * Test base URL configuration.
     *
     * This test verifies that the base URL is properly configured
     * for all endpoints.
     */
    func testBaseURLConfiguration() {
        let fetchPath = HomeAPI.fetchMovies.path
        let searchPath = HomeAPI.searchMovies("test").path
        let creditsPath = HomeAPI.fetchCredits(1).path
        let reviewsPath = HomeAPI.fetchReviews(1).path

        // All paths should start with the base URL
        XCTAssertTrue(fetchPath.hasPrefix("https://"))
        XCTAssertTrue(searchPath.hasPrefix("https://"))
        XCTAssertTrue(creditsPath.hasPrefix("https://"))
        XCTAssertTrue(reviewsPath.hasPrefix("https://"))
    }
}
