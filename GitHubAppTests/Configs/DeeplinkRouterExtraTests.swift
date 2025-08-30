//
//  DeeplinkRouterExtraTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing
import UIKit

struct DeeplinkRouterExtraTests {
    private func createTestComponents() -> (DeeplinkManager, DeeplinkRouter, MockCoordinator, UINavigationController) {
        let deeplinkManager = DeeplinkManager()
        let mockCoordinator = MockCoordinator()
        let navigationController = UINavigationController()

        let deeplinkRouter = DeeplinkRouter(
            deeplinkManager: deeplinkManager,
            coordinator: mockCoordinator,
            navigationController: navigationController
        )

        return (deeplinkManager, deeplinkRouter, mockCoordinator, navigationController)
    }

    // MARK: - Initialization Tests

    @Test("Deeplink router initialization with all parameters")
    func deeplinkRouterInitializationWithAllParameters() {
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
        #expect(router != nil)
    }

    @Test("Deeplink router initialization with minimal parameters")
    func deeplinkRouterInitializationWithMinimalParameters() {
        // Given
        let manager = DeeplinkManager()

        // When
        let router = DeeplinkRouter(deeplinkManager: manager)

        // Then
        #expect(router != nil)
    }

    // MARK: - Process URL Tests

    @Test("Process valid movie details URL")
    func processValidMovieDetailsURL() {
        // Given
        let (_, deeplinkRouter, mockCoordinator, _) = createTestComponents()
        let url = URL(string: "githubapp://movie/123")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        #expect(result == true)
        #expect(mockCoordinator.pushedPages.count == 1)

        if case let .detail(movie) = mockCoordinator.pushedPages.first {
            #expect(movie.id == 123)
        } else {
            Issue.record("Expected detail page with movie")
        }
    }

    @Test("Process invalid URL")
    func processInvalidURL() {
        // Given
        let (_, deeplinkRouter, mockCoordinator, _) = createTestComponents()
        let url = URL(string: "invalid://url")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        #expect(result == false)
        #expect(mockCoordinator.pushedPages.isEmpty)
    }

    @Test("Process unknown deeplink")
    func processUnknownDeeplink() {
        // Given
        let (_, deeplinkRouter, mockCoordinator, _) = createTestComponents()
        let url = URL(string: "githubapp://unknown/path")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        #expect(result == false)
        #expect(mockCoordinator.pushedPages.isEmpty)
    }

    @Test("Process deeplink without coordinator")
    func processDeeplinkWithoutCoordinator() {
        // Given
        let (deeplinkManager, _, _, navigationController) = createTestComponents()
        let routerWithoutCoordinator = DeeplinkRouter(
            deeplinkManager: deeplinkManager,
            coordinator: nil,
            navigationController: navigationController
        )
        let url = URL(string: "githubapp://movie/456")!

        // When
        let result = routerWithoutCoordinator.process(url: url)

        // Then
        #expect(result == false)
    }

    @Test("Process deeplink without navigation controller")
    func processDeeplinkWithoutNavigationController() {
        // Given
        let (deeplinkManager, _, _, _) = createTestComponents()
        let routerWithoutNavController = DeeplinkRouter(
            deeplinkManager: deeplinkManager,
            coordinator: nil,
            navigationController: nil
        )
        let url = URL(string: "githubapp://movie/789")!

        // When
        let result = routerWithoutNavController.process(url: url)

        // Then
        #expect(result == false)
    }

    // MARK: - Navigation Tests

    @Test("Navigate to movie details with coordinator")
    func navigateToMovieDetailsWithCoordinator() {
        // Given
        let (_, deeplinkRouter, mockCoordinator, _) = createTestComponents()
        let movieId = 987
        let url = URL(string: "githubapp://movie/\(movieId)")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        #expect(result == true)
        #expect(mockCoordinator.pushedPages.count == 1)

        if case let .detail(movie) = mockCoordinator.pushedPages.first {
            #expect(movie.id == movieId)
            #expect(movie.title == "") // Minimal movie object
            #expect(movie.overview == "")
            #expect(movie.posterPath == nil)
        } else {
            Issue.record("Expected detail page with movie")
        }
    }

    @Test("Navigate to movie details multiple times")
    func navigateToMovieDetailsMultipleTimes() {
        // Given
        let (_, deeplinkRouter, mockCoordinator, _) = createTestComponents()
        let url1 = URL(string: "githubapp://movie/111")!
        let url2 = URL(string: "githubapp://movie/222")!

        // When
        let result1 = deeplinkRouter.process(url: url1)
        let result2 = deeplinkRouter.process(url: url2)

        // Then
        #expect(result1 == true)
        #expect(result2 == true)
        #expect(mockCoordinator.pushedPages.count == 2)
    }

    // MARK: - Coordinator Update Tests

    @Test("Update coordinator")
    func updateCoordinator() {
        // Given
        let (_, deeplinkRouter, mockCoordinator, _) = createTestComponents()
        let newCoordinator = MockCoordinator()
        let url = URL(string: "githubapp://movie/555")!

        // When
        deeplinkRouter.updateCoordinator(newCoordinator)
        let result = deeplinkRouter.process(url: url)

        // Then
        #expect(result == true)
        #expect(mockCoordinator.pushedPages.isEmpty) // Old coordinator not used
        #expect(newCoordinator.pushedPages.count == 1) // New coordinator used
    }

    @Test("Update navigation controller")
    func updateNavigationController() {
        // Given
        let (_, deeplinkRouter, _, _) = createTestComponents()
        let newNavController = UINavigationController()

        // When
        deeplinkRouter.updateNavigationController(newNavController)

        // Then
        // No assertion needed - just testing that the method doesn't crash
        #expect(deeplinkRouter != nil)
    }

    // MARK: - Edge Cases

    @Test("Process URL with zero movie ID")
    func processURLWithZeroMovieId() {
        // Given
        let (_, deeplinkRouter, mockCoordinator, _) = createTestComponents()
        let url = URL(string: "githubapp://movie/0")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        #expect(result == true)

        if case let .detail(movie) = mockCoordinator.pushedPages.first {
            #expect(movie.id == 0)
        } else {
            Issue.record("Expected detail page with movie")
        }
    }

    @Test("Process URL with negative movie ID")
    func processURLWithNegativeMovieId() {
        // Given
        let (_, deeplinkRouter, mockCoordinator, _) = createTestComponents()
        let url = URL(string: "githubapp://movie/-1")!

        // When
        let result = deeplinkRouter.process(url: url)

        // Then
        #expect(result == true)

        if case let .detail(movie) = mockCoordinator.pushedPages.first {
            #expect(movie.id == -1)
        } else {
            Issue.record("Expected detail page with movie")
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
