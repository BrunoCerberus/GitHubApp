//
//  UniversalLinksSceneDelegateTests.swift
//  GitHubAppTests
//
//  Created by bruno on 20/08/25.
//

import Foundation
@testable import GitHubApp
import Testing

struct UniversalLinksSceneDelegateTests {
    private func createDeeplinkManager() -> DeeplinkManager {
        DeeplinkManager()
    }

    // MARK: - Universal Links URL Parsing Tests

    @Test("Universal link URL parsing")
    func universalLinkURLParsing() {
        // Given
        let deeplinkManager = createDeeplinkManager()
        let url = URL(string: "https://githubapp.com/movie/123")!

        // When
        let result = deeplinkManager.parse(url: url)

        // Then
        switch result {
        case let .movieDetails(movieId):
            #expect(movieId == 123)
        case .unknown:
            Issue.record("Expected movieDetails deeplink type for universal link")
        }
    }

    @Test("Universal link validation")
    func universalLinkValidation() {
        // Given
        let deeplinkManager = createDeeplinkManager()
        let validURL = URL(string: "https://githubapp.com/movie/123")!
        let invalidURL = URL(string: "https://example.com/movie/123")!

        // When & Then
        #expect(deeplinkManager.isValidDeeplink(url: validURL) == true)
        #expect(deeplinkManager.isValidDeeplink(url: invalidURL) == false)
    }

    @Test("Universal link creation")
    func universalLinkCreation() {
        // Given
        let deeplinkManager = createDeeplinkManager()
        let movieId = 789

        // When
        let url = deeplinkManager.createMovieDetailsUniversalURL(movieId: movieId)

        // Then
        #expect(url != nil)
        #expect(url?.absoluteString == "https://githubapp.com/movie/789")

        // Verify the created URL can be parsed back correctly
        if let createdURL = url {
            let parsedResult = deeplinkManager.parse(url: createdURL)
            switch parsedResult {
            case let .movieDetails(parsedMovieId):
                #expect(parsedMovieId == movieId)
            case .unknown:
                Issue.record("Created universal link should be parseable")
            }
        }
    }

    @Test("Universal link with invalid movie id")
    func universalLinkWithInvalidMovieId() {
        // Given
        let deeplinkManager = createDeeplinkManager()
        let url = URL(string: "https://githubapp.com/movie/abc")!

        // When
        let result = deeplinkManager.parse(url: url)

        // Then
        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type for invalid movie ID")
        case .unknown:
            // Expected result
            break
        }
    }

    @Test("Universal link with missing path")
    func universalLinkWithMissingPath() {
        // Given
        let deeplinkManager = createDeeplinkManager()
        let url = URL(string: "https://githubapp.com/movie")!

        // When
        let result = deeplinkManager.parse(url: url)

        // Then
        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type for missing path")
        case .unknown:
            // Expected result
            break
        }
    }

    @Test("Universal link with unknown path")
    func universalLinkWithUnknownPath() {
        // Given
        let deeplinkManager = createDeeplinkManager()
        let url = URL(string: "https://githubapp.com/unknown/123")!

        // When
        let result = deeplinkManager.parse(url: url)

        // Then
        switch result {
        case .movieDetails:
            Issue.record("Expected unknown deeplink type for unknown path")
        case .unknown:
            // Expected result
            break
        }
    }

    @Test("Both custom scheme and universal link work")
    func bothCustomSchemeAndUniversalLinkWork() {
        // Given
        let deeplinkManager = createDeeplinkManager()
        let customSchemeURL = URL(string: "githubapp://movie/123")!
        let universalLinkURL = URL(string: "https://githubapp.com/movie/123")!

        // When
        let customResult = deeplinkManager.parse(url: customSchemeURL)
        let universalResult = deeplinkManager.parse(url: universalLinkURL)

        // Then
        #expect(customResult == universalResult)

        switch (customResult, universalResult) {
        case let (.movieDetails(customId), .movieDetails(universalId)):
            #expect(customId == 123)
            #expect(universalId == 123)
        default:
            Issue.record("Both custom scheme and universal link should parse to movieDetails")
        }
    }
}
