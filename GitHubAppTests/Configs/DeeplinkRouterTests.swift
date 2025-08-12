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
    var mockCoordinator: MockCoordinator!
    var deeplinkRouter: DeeplinkRouter!

    override func setUp() {
        super.setUp()
        deeplinkManager = DeeplinkManager()
        mockCoordinator = MockCoordinator()
        deeplinkRouter = DeeplinkRouter(
            deeplinkManager: deeplinkManager,
            coordinator: mockCoordinator
        )
    }

    override func tearDown() {
        deeplinkRouter = nil
        mockCoordinator = nil
        deeplinkManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationWithCoordinator() {
        XCTAssertNotNil(deeplinkRouter)
        XCTAssertEqual(mockCoordinator.pushPageCallCount, 0)
    }

    func testInitializationWithoutCoordinator() {
        let router = DeeplinkRouter(deeplinkManager: deeplinkManager)
        XCTAssertNotNil(router)
    }

    // MARK: - URL Processing Tests

    func testProcessValidMovieDetailsURL() {
        let url = URL(string: "githubapp://movie/123")!
        let result = deeplinkRouter.process(url: url)

        XCTAssertTrue(result)
        XCTAssertEqual(mockCoordinator.pushPageCallCount, 1)

        if case let .detail(movie) = mockCoordinator.lastPushedPage {
            XCTAssertEqual(movie.id, 123)
        } else {
            XCTFail("Expected detail page to be pushed")
        }
    }

    func testProcessInvalidURL() {
        let url = URL(string: "githubapp://invalid/123")!
        let result = deeplinkRouter.process(url: url)

        XCTAssertFalse(result)
        XCTAssertEqual(mockCoordinator.pushPageCallCount, 0)
    }

    func testProcessExternalURL() {
        let url = URL(string: "https://example.com")!
        let result = deeplinkRouter.process(url: url)

        XCTAssertFalse(result)
        XCTAssertEqual(mockCoordinator.pushPageCallCount, 0)
    }

    func testProcessURLWithoutCoordinator() {
        let router = DeeplinkRouter(deeplinkManager: deeplinkManager)
        let url = URL(string: "githubapp://movie/123")!
        let result = router.process(url: url)

        XCTAssertFalse(result)
    }

    // MARK: - Coordinator Update Tests

    func testUpdateCoordinator() {
        let newCoordinator = MockCoordinator()
        deeplinkRouter.updateCoordinator(newCoordinator)

        // Test that the new coordinator is used
        let url = URL(string: "githubapp://movie/456")!
        let result = deeplinkRouter.process(url: url)

        XCTAssertTrue(result)
        XCTAssertEqual(newCoordinator.pushPageCallCount, 1)
        XCTAssertEqual(mockCoordinator.pushPageCallCount, 0) // Old coordinator should not be called
    }

    func testUpdateNavigationController() {
        let mockNavigationController = MockNavigationController()
        deeplinkRouter.updateNavigationController(mockNavigationController)

        // This test verifies the method exists and can be called
        // The actual navigation logic would need more complex testing
        XCTAssertNotNil(mockNavigationController)
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
            XCTAssertTrue(result)
        }

        XCTAssertEqual(mockCoordinator.pushPageCallCount, 3)
    }

    func testProcessURLWithLargeMovieID() {
        let largeID = Int.max
        let url = URL(string: "githubapp://movie/\(largeID)")!
        let result = deeplinkRouter.process(url: url)

        XCTAssertTrue(result)
        XCTAssertEqual(mockCoordinator.pushPageCallCount, 1)

        if case let .detail(movie) = mockCoordinator.lastPushedPage {
            XCTAssertEqual(movie.id, largeID)
        } else {
            XCTFail("Expected detail page to be pushed")
        }
    }
}

// MARK: - Mock Classes

private class MockCoordinator: Coordinator {
    var pushPageCallCount = 0
    var lastPushedPage: Page?

    override func push(page: Page) {
        pushPageCallCount += 1
        lastPushedPage = page
    }

    // Required initializer for Coordinator
    required init(serviceLocator: ServiceLocator) {
        super.init(serviceLocator: serviceLocator)
    }
}

private class MockNavigationController: UINavigationController {
    // Mock implementation for testing
}
