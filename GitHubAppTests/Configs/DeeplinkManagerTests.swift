//
//  DeeplinkManagerTests.swift
//  GitHubAppTests
//
//  Created by bruno on 29/05/23.
//

@testable import GitHubApp
import XCTest

final class DeeplinkManagerTests: XCTestCase {
    var deeplinkManager: DeeplinkManager!

    override func setUp() {
        super.setUp()
        deeplinkManager = DeeplinkManager()
    }

    override func tearDown() {
        deeplinkManager = nil
        super.tearDown()
    }

    // MARK: - URL Scheme Tests

    func testMovieDetailsURLScheme() {
        let scheme = DeeplinkManager.URLScheme.movieDetails
        XCTAssertEqual(scheme.scheme, "githubapp://movie")
    }

    func testMovieDetailsUniversalLink() {
        let scheme = DeeplinkManager.URLScheme.movieDetails
        XCTAssertEqual(scheme.universalLink, "https://githubapp.com/movie")
    }

    func testAllURLSchemes() {
        let schemes = DeeplinkManager.URLScheme.allCases
        XCTAssertEqual(schemes.count, 1)
        XCTAssertTrue(schemes.contains(.movieDetails))
    }

    // MARK: - URL Parsing Tests

    func testParseValidMovieDetailsURL() {
        let url = URL(string: "githubapp://movie/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case let .movieDetails(movieId):
            XCTAssertEqual(movieId, 123)
        case .unknown:
            XCTFail("Expected movieDetails deeplink type")
        }
    }

    func testParseMovieDetailsURLWithTrailingSlash() {
        let url = URL(string: "githubapp://movie/456/")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case let .movieDetails(movieId):
            XCTAssertEqual(movieId, 456)
        case .unknown:
            XCTFail("Expected movieDetails deeplink type")
        }
    }

    func testParseInvalidScheme() {
        let url = URL(string: "http://movie/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    func testParseInvalidMovieDetailsURL() {
        let url = URL(string: "githubapp://movie")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    func testParseMovieDetailsURLWithInvalidID() {
        let url = URL(string: "githubapp://movie/abc")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    func testParseUnknownPath() {
        let url = URL(string: "githubapp://unknown/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    func testParseInvalidURL() {
        let url = URL(string: "invalid://url")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    // MARK: - Universal Links Parsing Tests

    func testParseValidUniversalLinkMovieDetails() {
        let url = URL(string: "https://githubapp.com/movie/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case let .movieDetails(movieId):
            XCTAssertEqual(movieId, 123)
        case .unknown:
            XCTFail("Expected movieDetails deeplink type")
        }
    }

    func testParseUniversalLinkWithTrailingSlash() {
        let url = URL(string: "https://githubapp.com/movie/456/")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case let .movieDetails(movieId):
            XCTAssertEqual(movieId, 456)
        case .unknown:
            XCTFail("Expected movieDetails deeplink type")
        }
    }

    func testParseUniversalLinkInvalidHost() {
        let url = URL(string: "https://example.com/movie/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    func testParseUniversalLinkInvalidPath() {
        let url = URL(string: "https://githubapp.com/movie")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    func testParseUniversalLinkInvalidMovieID() {
        let url = URL(string: "https://githubapp.com/movie/abc")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    func testParseUniversalLinkUnknownSection() {
        let url = URL(string: "https://githubapp.com/unknown/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            XCTFail("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    // MARK: - URL Creation Tests

    func testCreateMovieDetailsURL() {
        let movieId = 789
        let url = deeplinkManager.createMovieDetailsURL(movieId: movieId)

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "githubapp://movie/789")
    }

    func testCreateMovieDetailsUniversalURL() {
        let movieId = 789
        let url = deeplinkManager.createMovieDetailsUniversalURL(movieId: movieId)

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://githubapp.com/movie/789")
    }

    func testCreateMovieDetailsURLWithZeroID() {
        let movieId = 0
        let url = deeplinkManager.createMovieDetailsURL(movieId: movieId)

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "githubapp://movie/0")
    }

    func testCreateMovieDetailsURLWithNegativeID() {
        let movieId = -123
        let url = deeplinkManager.createMovieDetailsURL(movieId: movieId)

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "githubapp://movie/-123")
    }

    func testCreateMovieDetailsUniversalURLWithZeroID() {
        let movieId = 0
        let url = deeplinkManager.createMovieDetailsUniversalURL(movieId: movieId)

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://githubapp.com/movie/0")
    }

    func testCreateMovieDetailsUniversalURLWithNegativeID() {
        let movieId = -123
        let url = deeplinkManager.createMovieDetailsUniversalURL(movieId: movieId)

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://githubapp.com/movie/-123")
    }

    // MARK: - URL Validation Tests

    func testIsValidDeeplinkWithValidURL() {
        let url = URL(string: "githubapp://movie/123")!
        XCTAssertTrue(deeplinkManager.isValidDeeplink(url: url))
    }

    func testIsValidDeeplinkWithValidUniversalLink() {
        let url = URL(string: "https://githubapp.com/movie/123")!
        XCTAssertTrue(deeplinkManager.isValidDeeplink(url: url))
    }

    func testIsValidDeeplinkWithInvalidURL() {
        let url = URL(string: "https://example.com")!
        XCTAssertFalse(deeplinkManager.isValidDeeplink(url: url))
    }

    func testIsValidDeeplinkWithInvalidScheme() {
        let url = URL(string: "invalid://movie/123")!
        XCTAssertFalse(deeplinkManager.isValidDeeplink(url: url))
    }

    func testIsValidDeeplinkWithInvalidPath() {
        let url = URL(string: "githubapp://invalid/123")!
        XCTAssertFalse(deeplinkManager.isValidDeeplink(url: url))
    }
}
