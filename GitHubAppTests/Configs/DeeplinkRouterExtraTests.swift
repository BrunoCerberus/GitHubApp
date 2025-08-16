//
//  DeeplinkRouterExtraTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import UIKit
import XCTest

final class DeeplinkRouterExtraTests: XCTestCase {
    // MARK: - Properties

    private var deeplinkManager: DeeplinkManager!
    private var deeplinkRouter: DeeplinkRouter!
    private var mockCoordinator: MockCoordinator!
    private var navigationController: UINavigationController!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        deeplinkManager = DeeplinkManager()
        mockCoordinator = MockCoordinator()
        navigationController = UINavigationController()

        deeplinkRouter = DeeplinkRouter(
            deeplinkManager: deeplinkManager,
            coordinator: mockCoordinator,
            navigationController: navigationController
        )
    }

    override func tearDown() {
        deeplinkManager = nil
        deeplinkRouter = nil
        mockCoordinator = nil
        navigationController = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testDeeplinkRouterInitializationWithAllParameters() {
        // Given
        let manager = DeeplinkManager()
        let coordinator = MockCoordinator()
        let navController = UINavigationController()

        // When
        let router = DeeplinkRouter(
            deeplinkManager: manager,
            coordinator: coordinator,
            navigationController: navController
        )

        // Then
        XCTAssertNotNil(router)
    }

    func testDeeplinkRouterInitializationWithMinimalParameters() {
        // Given
        let manager = DeeplinkManager()

        // When
        let router = DeeplinkRouter(deeplinkManager: manager)

        // Then
        XCTAssertNotNil(router)
    }

    // MARK: - Process URL Tests

    func testProcessValidMovieDetailsURL() {
        // Given
        let url = URL(string: "githubapp://movie/123")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(mockCoordinator.pushedPages.count, 1)

        if case let .detail(movie) = mockCoordinator.pushedPages.first {
            XCTAssertEqual(movie.id, 123)
        } else {
            XCTFail("Expected detail page with movie")
        }
    }

    func testProcessInvalidURL() {
        // Given
        let url = URL(string: "invalid://url")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        XCTAssertFalse(result)
        XCTAssertTrue(mockCoordinator.pushedPages.isEmpty)
    }

    func testProcessUnknownDeeplink() {
        // Given
        let url = URL(string: "githubapp://unknown/path")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        XCTAssertFalse(result)
        XCTAssertTrue(mockCoordinator.pushedPages.isEmpty)
    }

    func testProcessDeeplinkWithoutCoordinator() {
        // Given
        let routerWithoutCoordinator = DeeplinkRouter(
            deeplinkManager: deeplinkManager,
            coordinator: nil,
            navigationController: navigationController
        )
        let url = URL(string: "githubapp://movie/456")!

        // When
        let result = routerWithoutCoordinator.process(url: url)

        // Then
        XCTAssertFalse(result)
    }

    func testProcessDeeplinkWithoutNavigationController() {
        // Given
        let routerWithoutNavController = DeeplinkRouter(
            deeplinkManager: deeplinkManager,
            coordinator: nil,
            navigationController: nil
        )
        let url = URL(string: "githubapp://movie/789")!

        // When
        let result = routerWithoutNavController.process(url: url)

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Navigation Tests

    func testNavigateToMovieDetailsWithCoordinator() {
        // Given
        let movieId = 987
        let url = URL(string: "githubapp://movie/\(movieId)")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(mockCoordinator.pushedPages.count, 1)

        if case let .detail(movie) = mockCoordinator.pushedPages.first {
            XCTAssertEqual(movie.id, movieId)
            XCTAssertEqual(movie.title, "") // Minimal movie object
            XCTAssertEqual(movie.overview, "")
            XCTAssertNil(movie.posterPath)
        } else {
            XCTFail("Expected detail page with movie")
        }
    }

    func testNavigateToMovieDetailsMultipleTimes() {
        // Given
        let url1 = URL(string: "githubapp://movie/111")!
        let url2 = URL(string: "githubapp://movie/222")!

        // When
        let result1 = deeplinkRouter.process(url: url1)
        let result2 = deeplinkRouter.process(url: url2)

        // Then
        XCTAssertTrue(result1)
        XCTAssertTrue(result2)
        XCTAssertEqual(mockCoordinator.pushedPages.count, 2)
    }

    // MARK: - Coordinator Update Tests

    func testUpdateCoordinator() {
        // Given
        let newCoordinator = MockCoordinator()
        let url = URL(string: "githubapp://movie/555")!

        // When
        deeplinkRouter.updateCoordinator(newCoordinator)
        let result = deeplinkRouter.process(url: url)

        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockCoordinator.pushedPages.isEmpty) // Old coordinator not used
        XCTAssertEqual(newCoordinator.pushedPages.count, 1) // New coordinator used
    }

    func testUpdateNavigationController() {
        // Given
        let newNavController = UINavigationController()

        // When
        deeplinkRouter.updateNavigationController(newNavController)

        // Then
        // No assertion needed - just testing that the method doesn't crash
        XCTAssertNotNil(deeplinkRouter)
    }

    // MARK: - Edge Cases

    func testProcessURLWithZeroMovieId() {
        // Given
        let url = URL(string: "githubapp://movie/0")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        XCTAssertTrue(result)

        if case let .detail(movie) = mockCoordinator.pushedPages.first {
            XCTAssertEqual(movie.id, 0)
        } else {
            XCTFail("Expected detail page with movie")
        }
    }

    func testProcessURLWithNegativeMovieId() {
        // Given
        let url = URL(string: "githubapp://movie/-1")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        XCTAssertTrue(result)

        if case let .detail(movie) = mockCoordinator.pushedPages.first {
            XCTAssertEqual(movie.id, -1)
        } else {
            XCTFail("Expected detail page with movie")
        }
    }
}

// MARK: - Mock Coordinator

private class MockCoordinator: CoordinatorProtocol {
    private(set) var pushedPages: [Page] = []

    func push(page: Page) {
        pushedPages.append(page)
    }
}
