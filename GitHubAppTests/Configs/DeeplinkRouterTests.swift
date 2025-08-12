//
//  DeeplinkRouterTests.swift
//  GitHubAppTests
//
//  Created by bruno on 29/05/23.
//

@testable import GitHubApp
import XCTest

final class DeeplinkRouterTests: XCTestCase {
    var deeplinkManager: DeeplinkManager!
    var deeplinkRouter: DeeplinkRouter!

    override func setUp() {
        super.setUp()
        deeplinkManager = DeeplinkManager()
        deeplinkRouter = DeeplinkRouter(deeplinkManager: deeplinkManager)
    }

    override func tearDown() {
        deeplinkRouter = nil
        deeplinkManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationWithoutCoordinator() {
        let router = DeeplinkRouter(deeplinkManager: deeplinkManager)
        XCTAssertNotNil(router)
    }

    // MARK: - URL Processing Tests

    func testProcessInvalidURL() {
        let url = URL(string: "githubapp://invalid/123")!
        let result = deeplinkRouter.process(url: url)

        XCTAssertFalse(result)
    }

    func testProcessExternalURL() {
        let url = URL(string: "https://example.com")!
        let result = deeplinkRouter.process(url: url)

        XCTAssertFalse(result)
    }

    func testProcessURLWithoutCoordinator() {
        let router = DeeplinkRouter(deeplinkManager: deeplinkManager)
        let url = URL(string: "githubapp://movie/123")!
        let result = router.process(url: url)

        XCTAssertFalse(result)
    }

    // MARK: - Edge Cases

    func testProcessMultipleURLs() {
        let urls = [
            URL(string: "githubapp://movie/123")!,
            URL(string: "githubapp://movie/456")!,
            URL(string: "githubapp://movie/789")!,
        ]

        for url in urls {
            let result = deeplinkRouter.process(url: url)
            XCTAssertFalse(result) // Should fail without coordinator
        }
    }

    func testProcessURLWithLargeMovieID() {
        let largeID = Int.max
        let url = URL(string: "githubapp://movie/\(largeID)")!
        let result = deeplinkRouter.process(url: url)

        XCTAssertFalse(result) // Should fail without coordinator
    }
}
