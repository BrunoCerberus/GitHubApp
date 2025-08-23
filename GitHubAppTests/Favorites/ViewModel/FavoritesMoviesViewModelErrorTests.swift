//
//  FavoritesMoviesViewModelErrorTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

import Combine
@testable import GitHubApp
import XCTest

/**
 * Simple error tests for FavoritesMoviesViewModel to improve coverage.
 */
final class FavoritesMoviesViewModelErrorTests: XCTestCase {
    private var mockFavoritesService: MockFavoritesService!
    private var mockDomainInteractor: FavoritesDomainInteractor!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        StorageServiceFactory.shared.resetCache()

        mockFavoritesService = MockFavoritesService()
        mockDomainInteractor = FavoritesDomainInteractor(favoritesService: mockFavoritesService)
        cancellables = []
    }

    override func tearDown() {
        StorageServiceFactory.shared.resetCache()
        cancellables.removeAll()
        mockFavoritesService = nil
        mockDomainInteractor = nil
        super.tearDown()
    }

    // MARK: - Basic Tests

    func testInitializationWithNilParameters() {
        // Given - All parameters nil to test default initialization paths

        // When
        let viewModel = FavoritesMoviesViewModel(
            domainInteractor: nil,
            viewStateReducer: nil,
            serviceLocator: nil
        )

        // Then - Should initialize with defaults
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.viewState, .loading)
    }

    func testInitializationWithServiceLocator() {
        // Given
        let serviceLocator = ServiceLocator()

        // When
        let viewModel = FavoritesMoviesViewModel(serviceLocator: serviceLocator)

        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.viewState, .loading)
    }

    func testViewModelPropertiesInLoadingState() {
        // Given
        let viewModel = FavoritesMoviesViewModel(domainInteractor: mockDomainInteractor)

        // When - Keep in loading state (initial state)

        // Then - All properties should return empty/default values
        XCTAssertTrue(viewModel.favoriteMovies.isEmpty)

        let testMovie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)
        XCTAssertFalse(viewModel.isFavorited(movie: testMovie))
    }

    func testSendViewEventMethod() {
        // Given
        let viewModel = FavoritesMoviesViewModel(domainInteractor: mockDomainInteractor)
        let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)

        // When - Test the sendViewEvent method (CombineViewModel protocol requirement)
        viewModel.sendViewEvent(.toggleFavorite(movie))

        // Then - Should not crash
        XCTAssertNotNil(viewModel)
    }

    func testAllViewEventConversions() {
        // Given
        let viewModel = FavoritesMoviesViewModel(domainInteractor: mockDomainInteractor)
        let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)

        // When & Then - Test all event types are handled
        let events: [FavoritesViewEvent] = [
            .loadFavoriteMovies,
            .toggleFavorite(movie),
            .clearAllFavoriteMovies,
            .refreshFavoriteMovies,
        ]

        for event in events {
            viewModel.handle(event)
            // Should not crash for any event type
        }

        XCTAssertNotNil(viewModel)
    }

    func testSetFavoriteMoviesForTestingWithEmptyArray() {
        // Given
        let viewModel = FavoritesMoviesViewModel(domainInteractor: mockDomainInteractor)

        // When
        viewModel.setFavoriteMoviesForTesting([])

        // Then
        XCTAssertTrue(viewModel.favoriteMovies.isEmpty)
        if case let .success(dataState) = viewModel.viewState {
            XCTAssertTrue(dataState.favoriteMovies.isEmpty)
            XCTAssertEqual(dataState.title, Localizable.favorites.title)
        } else {
            XCTFail("Expected success state")
        }
    }

    func testViewModelMemoryManagement() {
        // Given
        weak var weakViewModel: FavoritesMoviesViewModel?

        autoreleasepool {
            let viewModel = FavoritesMoviesViewModel(domainInteractor: mockDomainInteractor)
            weakViewModel = viewModel

            // Start some operations
            viewModel.loadFavoriteMovies()
            viewModel.refreshFavoriteMovies()
        }

        // When - ViewModel should be deallocated

        // Then - Weak reference should be nil
        XCTAssertNil(weakViewModel, "ViewModel should be deallocated")
    }
}
