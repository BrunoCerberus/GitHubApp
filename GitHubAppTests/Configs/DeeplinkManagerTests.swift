//
//  DeeplinkManagerTests.swift
//  GitHubAppTests
//
//  Created by bruno on 29/05/23.
//

import Foundation
@testable import GitHubApp
import Testing

struct DeeplinkManagerTests {
    // MARK: - URL Scheme Tests

    @Test("Movie details URL scheme returns correct scheme string")
    func movieDetailsURLScheme() {
        let scheme = DeeplinkManager.URLScheme.movieDetails
        #expect(scheme.scheme == "githubapp://movie")
    }

    @Test("Movie details URL scheme returns correct universal link")
    func movieDetailsUniversalLink() {
        let scheme = DeeplinkManager.URLScheme.movieDetails
        #expect(scheme.universalLink == "https://githubapp.com/movie")
    }

    @Test("All URL schemes contain expected cases")
    func allURLSchemes() {
        let schemes = DeeplinkManager.URLScheme.allCases
        #expect(schemes.count == 1)
        #expect(schemes.contains(.movieDetails))
    }

    // MARK: - URL Parsing Tests

    @Test("Parse valid movie details URL returns correct movie ID")
    func parseValidMovieDetailsURL() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "githubapp://movie/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case let .movieDetails(movieId):
            #expect(movieId == 123)
        case .unknown:
            Issue.record("Expected movieDetails deeplink type")
        }
    }

    @Test("Parse movie details URL with trailing slash returns correct movie ID")
    func parseMovieDetailsURLWithTrailingSlash() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "githubapp://movie/456/")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case let .movieDetails(movieId):
            #expect(movieId == 456)
        case .unknown:
            Issue.record("Expected movieDetails deeplink type")
        }
    }

    @Test("Parse URL with invalid scheme returns unknown result")
    func parseInvalidScheme() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "http://movie/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    @Test("Parse invalid movie details URL returns unknown result")
    func parseInvalidMovieDetailsURL() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "githubapp://movie")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    @Test("Parse movie details URL with invalid ID returns unknown result")
    func parseMovieDetailsURLWithInvalidID() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "githubapp://movie/abc")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    @Test("Parse URL with unknown path returns unknown result")
    func parseUnknownPath() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "githubapp://unknown/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    @Test("Parse invalid URL returns unknown result")
    func parseInvalidURL() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "invalid://url")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    // MARK: - Universal Links Parsing Tests

    @Test("Parse valid universal link movie details returns correct movie ID")
    func parseValidUniversalLinkMovieDetails() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "https://githubapp.com/movie/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case let .movieDetails(movieId):
            #expect(movieId == 123)
        case .unknown:
            Issue.record("Expected movieDetails deeplink type")
        }
    }

    @Test("Parse universal link with trailing slash returns correct movie ID")
    func parseUniversalLinkWithTrailingSlash() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "https://githubapp.com/movie/456/")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case let .movieDetails(movieId):
            #expect(movieId == 456)
        case .unknown:
            Issue.record("Expected movieDetails deeplink type")
        }
    }

    @Test("Parse universal link with invalid host returns unknown result")
    func parseUniversalLinkInvalidHost() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "https://example.com/movie/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    @Test("Parse universal link with invalid path returns unknown result")
    func parseUniversalLinkInvalidPath() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "https://githubapp.com/movie")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    @Test("Parse universal link with invalid movie ID returns unknown result")
    func parseUniversalLinkInvalidMovieID() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "https://githubapp.com/movie/abc")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    @Test("Parse universal link with unknown section returns unknown result")
    func parseUniversalLinkUnknownSection() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "https://githubapp.com/unknown/123")!
        let result = deeplinkManager.parse(url: url)

        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type")
        case .unknown:
            // Expected result
            break
        }
    }

    // MARK: - URL Creation Tests

    @Test("Create movie details URL returns correct URL")
    func createMovieDetailsURL() {
        let deeplinkManager = DeeplinkManager()
        let movieId = 789
        let url = deeplinkManager.createMovieDetailsURL(movieId: movieId)

        #expect(url != nil)
        #expect(url?.absoluteString == "githubapp://movie/789")
    }

    @Test("Create movie details universal URL returns correct URL")
    func createMovieDetailsUniversalURL() {
        let deeplinkManager = DeeplinkManager()
        let movieId = 789
        let url = deeplinkManager.createMovieDetailsUniversalURL(movieId: movieId)

        #expect(url != nil)
        #expect(url?.absoluteString == "https://githubapp.com/movie/789")
    }

    @Test("Create movie details URL with zero ID returns correct URL")
    func createMovieDetailsURLWithZeroID() {
        let deeplinkManager = DeeplinkManager()
        let movieId = 0
        let url = deeplinkManager.createMovieDetailsURL(movieId: movieId)

        #expect(url != nil)
        #expect(url?.absoluteString == "githubapp://movie/0")
    }

    @Test("Create movie details URL with negative ID returns correct URL")
    func createMovieDetailsURLWithNegativeID() {
        let deeplinkManager = DeeplinkManager()
        let movieId = -123
        let url = deeplinkManager.createMovieDetailsURL(movieId: movieId)

        #expect(url != nil)
        #expect(url?.absoluteString == "githubapp://movie/-123")
    }

    @Test("Create movie details universal URL with zero ID returns correct URL")
    func createMovieDetailsUniversalURLWithZeroID() {
        let deeplinkManager = DeeplinkManager()
        let movieId = 0
        let url = deeplinkManager.createMovieDetailsUniversalURL(movieId: movieId)

        #expect(url != nil)
        #expect(url?.absoluteString == "https://githubapp.com/movie/0")
    }

    @Test("Create movie details universal URL with negative ID returns correct URL")
    func createMovieDetailsUniversalURLWithNegativeID() {
        let deeplinkManager = DeeplinkManager()
        let movieId = -123
        let url = deeplinkManager.createMovieDetailsUniversalURL(movieId: movieId)

        #expect(url != nil)
        #expect(url?.absoluteString == "https://githubapp.com/movie/-123")
    }

    // MARK: - URL Validation Tests

    @Test("Is valid deeplink returns true for valid URL")
    func isValidDeeplinkWithValidURL() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "githubapp://movie/123")!
        #expect(deeplinkManager.isValidDeeplink(url: url))
    }

    @Test("Is valid deeplink returns true for valid universal link")
    func isValidDeeplinkWithValidUniversalLink() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "https://githubapp.com/movie/123")!
        #expect(deeplinkManager.isValidDeeplink(url: url))
    }

    @Test("Is valid deeplink returns false for invalid URL")
    func isValidDeeplinkWithInvalidURL() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "https://example.com")!
        #expect(!deeplinkManager.isValidDeeplink(url: url))
    }

    @Test("Is valid deeplink returns false for invalid scheme")
    func isValidDeeplinkWithInvalidScheme() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "invalid://movie/123")!
        #expect(!deeplinkManager.isValidDeeplink(url: url))
    }

    @Test("Is valid deeplink returns false for invalid path")
    func isValidDeeplinkWithInvalidPath() {
        let deeplinkManager = DeeplinkManager()
        let url = URL(string: "githubapp://invalid/123")!
        #expect(!deeplinkManager.isValidDeeplink(url: url))
    }
}
