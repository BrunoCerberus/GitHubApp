//
//  UniversalLinksSceneDelegateTests.swift
//  GitHubAppTests
//
//  Created by bruno on 20/08/25.
//

@testable import GitHubApp
import XCTest

final class UniversalLinksSceneDelegateTests: XCTestCase {
    var deeplinkManager: DeeplinkManager!

    override func setUp() {
        super.setUp()
        deeplinkManager = DeeplinkManager()
    }

    override func tearDown() {
        deeplinkManager = nil
        super.tearDown()
    }

    // MARK: - Universal Links URL Parsing Tests

    func testUniversalLinkURLParsing() {
        let url = URL(string: "https://githubapp.com/movie/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case let .movieDetails(movieId):
            XCTAssertEqual(movieId, 123)
        case .unknown:
            XCTFail("Expected movieDetails deeplink type for universal link")
        }
    }

    func testUniversalLinkValidation() {
        let validURL = URL(string: "https://githubapp.com/movie/123")!
        XCTAssertTrue(deeplinkManager.isValidDeeplink(url: validURL))

        let invalidURL = URL(string: "https://example.com/movie/123")!
        XCTAssertFalse(deeplinkManager.isValidDeeplink(url: invalidURL))
    }

    func testUniversalLinkCreation() {
        let movieId = 789
        let url = deeplinkManager.createMovieDetailsUniversalURL(movieId: movieId)

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://githubapp.com/movie/789")

        // Verify the created URL can be parsed back correctly
        if let createdURL = url {
            let parsedResult = deeplinkManager.parse(url: createdURL)
            switch parsedResult {
            case let .movieDetails(parsedMovieId):
                XCTAssertEqual(parsedMovieId, movieId)
            case .unknown:
                XCTFail("Created universal link should be parseable")
            }
        }
    }

    func testUniversalLinkWithInvalidMovieId() {
        let url = URL(string: "https://githubapp.com/movie/abc")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type for invalid movie ID")
        case .unknown:
            // Expected result
            break
        }
    }

    func testUniversalLinkWithMissingPath() {
        let url = URL(string: "https://githubapp.com/movie")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type for missing path")
        case .unknown:
            // Expected result
            break
        }
    }

    func testUniversalLinkWithUnknownPath() {
        let url = URL(string: "https://githubapp.com/unknown/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type for unknown path")
        case .unknown:
            // Expected result
            break
        }
    }

    func testBothCustomSchemeAndUniversalLinkWork() {
        let customSchemeURL = URL(string: "githubapp://movie/123")!
        let universalLinkURL = URL(string: "https://githubapp.com/movie/123")!

        let customResult = deeplinkManager.parse(url: customSchemeURL)
        let universalResult = deeplinkManager.parse(url: universalLinkURL)

        // Both should produce the same result
        XCTAssertEqual(customResult, universalResult)

        switch (customResult, universalResult) {
        case let (.movieDetails(customId), .movieDetails(universalId)):
            XCTAssertEqual(customId, 123)
            XCTAssertEqual(universalId, 123)
        default:
            XCTFail("Both custom scheme and universal link should parse to movieDetails")
        }
    }
}
