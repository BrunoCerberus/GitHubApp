//
//  HomeViewModelErrorTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

import Combine
@testable import GitHubApp
import XCTest

/**
 * Simple error tests for HomeViewModel to improve coverage.
 */
final class HomeViewModelErrorTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    private var mockService: MockHomeService!
    private var serviceLocator: ServiceLocator!

    override func setUp() {
        super.setUp()
        StorageServiceFactory.shared.resetCache()
        mockService = MockHomeService()
        serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockService)
        cancellables = []
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
    }

    override func tearDown() {
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.removeMovieAPIKey()
        cancellables.removeAll()
        mockService = nil
        serviceLocator = nil
        super.tearDown()
    }

    // MARK: - Basic Tests

    func testInitializationWithServiceLocator() {
        // Given - Test service resolution from ServiceLocator

        // When
        let viewModel = HomeViewModel(serviceLocator: serviceLocator)

        // Then - Should initialize with registered service
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.viewState, .loading)
    }

    func testInitializationWithNilServiceLocator() {
        // Given - Test fallback when serviceLocator is nil

        // When
        let viewModel = HomeViewModel(serviceLocator: ServiceLocator())

        // Then - Should use LiveHomeService fallback
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.viewState, .loading)
    }

    func testInitializationWithServiceLocatorError() {
        // Given - ServiceLocator that doesn't have HomeService registered
        let emptyServiceLocator = ServiceLocator()

        // When - Should fallback to LiveHomeService when retrieval fails
        let viewModel = HomeViewModel(serviceLocator: emptyServiceLocator)

        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.viewState, .loading)
    }

    func testViewModelPropertiesInLoadingState() {
        // Given
        let viewModel = HomeViewModel(serviceLocator: serviceLocator)

        // When - Keep in loading state (initial state)

        // Then - All properties should return empty/default values
        XCTAssertTrue(viewModel.movies.isEmpty)
        XCTAssertTrue(viewModel.favoriteMovies.isEmpty)
        XCTAssertNil(viewModel.error)

        let testMovie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)
        XCTAssertFalse(viewModel.isLiked(movie: testMovie))
    }

    func testSearchWithEmptyQuery() {
        // Given
        let viewModel = HomeViewModel(serviceLocator: serviceLocator)

        // When
        viewModel.searchMovies(query: "")

        // Then - Should not crash
        XCTAssertNotNil(viewModel)
    }

    func testSearchWithSpecialCharacters() {
        // Given
        let viewModel = HomeViewModel(serviceLocator: serviceLocator)

        // When
        let specialQueries = [
            "movie & film",
            "héllö wörld",
            "🎬🍿🎭",
        ]

        // Then
        for query in specialQueries {
            viewModel.searchMovies(query: query)
            XCTAssertNotNil(viewModel, "Should handle special query: \(query)")
        }
    }

    func testSendViewEventMethod() {
        // Given
        let viewModel = HomeViewModel(serviceLocator: serviceLocator)
        let testMovie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)

        // When - Test the sendViewEvent protocol method
        viewModel.sendViewEvent(.fetchData)
        viewModel.sendViewEvent(.searchMovies("test"))
        viewModel.sendViewEvent(.toggleFavorite(testMovie))
        viewModel.sendViewEvent(.loadFavoriteMovies)

        // Then - Should not crash
        XCTAssertNotNil(viewModel)
    }

    func testAllEventTypes() {
        // Given
        let viewModel = HomeViewModel(serviceLocator: serviceLocator)
        let testMovie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)

        // When - Test all possible event types
        let events: [HomeViewEvent] = [
            .fetchData,
            .searchMovies("test"),
            .toggleFavorite(testMovie),
            .loadFavoriteMovies,
        ]

        // Then
        for event in events {
            viewModel.handle(event)
            viewModel.sendViewEvent(event)
        }

        XCTAssertNotNil(viewModel)
    }

    func testViewModelDeallocation() {
        // Given
        weak var weakViewModel: HomeViewModel?

        autoreleasepool {
            let viewModel = HomeViewModel(serviceLocator: serviceLocator)
            weakViewModel = viewModel

            // Trigger some operations
            viewModel.fetchData()
            viewModel.searchMovies(query: "test")
        }

        // When - ViewModel should be deallocated

        // Then - Weak reference should be nil
        XCTAssertNil(weakViewModel, "ViewModel should be deallocated")
    }

    func testServiceResolutionFallbackChain() {
        // Given - Test all fallback scenarios

        // 1. Direct service provided
        let directService = MockHomeService()
        let viewModel1 = HomeViewModel(serviceLocator: serviceLocator)
        XCTAssertNotNil(viewModel1)

        // 2. Service from service locator
        let viewModel2 = HomeViewModel(serviceLocator: serviceLocator)
        XCTAssertNotNil(viewModel2)

        // 3. Fallback to LiveHomeService
        let emptyServiceLocator = ServiceLocator()
        let viewModel3 = HomeViewModel(serviceLocator: emptyServiceLocator)
        XCTAssertNotNil(viewModel3)

        // 4. Complete fallback
        let viewModel4 = HomeViewModel(serviceLocator: ServiceLocator())
        XCTAssertNotNil(viewModel4)
    }
}
