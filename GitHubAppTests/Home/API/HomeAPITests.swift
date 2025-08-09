//
//  HomeAPITests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class HomeAPITests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Ensure API key is present so HomeAPI can build URLs
        try? APIKeysProvider.setMovieAPIKey("api-key-for-tests")
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
}
