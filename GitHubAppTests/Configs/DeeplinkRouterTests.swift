//
//  DeeplinkRouterTests.swift
//  GitHubAppTests
//
//  Created by bruno on 29/05/23.
//

import Foundation
@testable import GitHubApp
import Testing

struct DeeplinkRouterTests {
    // MARK: - Initialization Tests

    @Test("Router can be initialized without coordinator")
    func initializationWithoutCoordinator() {
        let deeplinkManager = DeeplinkManager()
        let router = DeeplinkRouter(deeplinkManager: deeplinkManager)
        #expect(router != nil)
    }

    // MARK: - URL Processing Tests

    @Test("Processing invalid URL returns false")
    func processInvalidURL() {
        let deeplinkManager = DeeplinkManager()
        let deeplinkRouter = DeeplinkRouter(deeplinkManager: deeplinkManager)
        let url = URL(string: "githubapp://invalid/123")!
        let result = deeplinkRouter.process(url: url)

        #expect(!result)
    }

    @Test("Processing external URL returns false")
    func processExternalURL() {
        let deeplinkManager = DeeplinkManager()
        let deeplinkRouter = DeeplinkRouter(deeplinkManager: deeplinkManager)
        let url = URL(string: "https://example.com")!
        let result = deeplinkRouter.process(url: url)

        #expect(!result)
    }

    @Test("Processing URL without coordinator returns false")
    func processURLWithoutCoordinator() {
        let deeplinkManager = DeeplinkManager()
        let router = DeeplinkRouter(deeplinkManager: deeplinkManager)
        let url = URL(string: "githubapp://movie/123")!
        let result = router.process(url: url)

        #expect(!result)
    }

    // MARK: - Edge Cases

    @Test("Processing multiple URLs without coordinator all return false")
    func processMultipleURLs() {
        let deeplinkManager = DeeplinkManager()
        let deeplinkRouter = DeeplinkRouter(deeplinkManager: deeplinkManager)
        let urls = [
            URL(string: "githubapp://movie/123")!,
            URL(string: "githubapp://movie/456")!,
            URL(string: "githubapp://movie/789")!,
        ]

        for url in urls {
            let result = deeplinkRouter.process(url: url)
            #expect(!result) // Should fail without coordinator
        }
    }

    @Test("Processing URL with large movie ID returns false without coordinator")
    func processURLWithLargeMovieID() {
        let deeplinkManager = DeeplinkManager()
        let deeplinkRouter = DeeplinkRouter(deeplinkManager: deeplinkManager)
        let largeID = Int.max
        let url = URL(string: "githubapp://movie/\(largeID)")!
        let result = deeplinkRouter.process(url: url)

        #expect(!result) // Should fail without coordinator
    }
}
