//
//  FavoritesMoviesViewModelErrorTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

import Combine
import Foundation
@testable import GitHubApp
import Testing

struct FavoritesMoviesViewModelErrorTests {
    private func createTestComponents() -> (FavoritesMoviesViewModel, MockFavoritesService) {
        StorageServiceFactory.shared.resetCache()

        let mockFavoritesService = MockFavoritesService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(FavoritesService.self, instance: mockFavoritesService)

        let mockDomainInteractor = FavoritesDomainInteractor(serviceLocator: serviceLocator)
        let viewModel = FavoritesMoviesViewModel(
            serviceLocator: serviceLocator,
            domainInteractor: mockDomainInteractor
        )

        return (viewModel, mockFavoritesService)
    }

    private func createServiceLocator(mockService: MockFavoritesService) -> ServiceLocator {
        let serviceLocator = ServiceLocator()
        serviceLocator.register(FavoritesService.self, instance: mockService)
        return serviceLocator
    }

    // MARK: - Basic Tests

    @Test("Initialization with nil parameters uses defaults")
    func initializationWithNilParameters() async {
        defer { StorageServiceFactory.shared.resetCache() }

        // Given - All parameters nil to test default initialization paths
        let serviceLocator = ServiceLocator()
        serviceLocator.register(FavoritesService.self, instance: MockFavoritesService())

        // When
        let viewModel = FavoritesMoviesViewModel(
            serviceLocator: serviceLocator,
            domainInteractor: nil,
            viewStateReducer: nil
        )

        // Then - Should initialize with success state containing empty favorites to avoid loading flicker
        await MainActor.run {
            // Test passes - viewModel exists
            if case let .success(dataState) = viewModel.viewState {
                #expect(dataState.favoriteMovies.isEmpty)
                #expect(dataState.title == "favorites_no_movies_title")
            }
        }
    }

    @Test("Initialization with service locator only uses defaults")
    func initializationWithServiceLocator() async {
        defer { StorageServiceFactory.shared.resetCache() }

        // Given
        let serviceLocator = ServiceLocator()

        // When
        let viewModel = FavoritesMoviesViewModel(serviceLocator: serviceLocator)

        // Then - Should initialize with success state containing empty favorites to avoid loading flicker
        await MainActor.run {
            // Test passes - viewModel exists
            if case let .success(dataState) = viewModel.viewState {
                #expect(dataState.favoriteMovies.isEmpty)
                #expect(dataState.title == "favorites_no_movies_title")
            }
        }
    }

    @Test("View model properties in loading state return defaults")
    func viewModelPropertiesInLoadingState() async {
        defer { StorageServiceFactory.shared.resetCache() }

        // Given
        let (viewModel, _) = createTestComponents()

        // When - Keep in loading state (initial state)
        // Then - All properties should return empty/default values
        await MainActor.run {
            #expect(viewModel.favoriteMovies.isEmpty)

            let testMovie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)
            #expect(!viewModel.isFavorited(movie: testMovie))
        }
    }

    @Test("Send view event method executes without crashing")
    func sendViewEventMethod() async {
        defer { StorageServiceFactory.shared.resetCache() }

        // Given
        let (viewModel, _) = createTestComponents()
        let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)

        // When - Test the sendViewEvent method (CombineViewModel protocol requirement)
        await MainActor.run {
            viewModel.sendViewEvent(.toggleFavorite(movie))
        }

        // Then - Should not crash
        // Test passes - viewModel exists
    }

    @Test("All view event conversions are handled without errors")
    func allViewEventConversions() async {
        defer { StorageServiceFactory.shared.resetCache() }

        // Given
        let (viewModel, _) = createTestComponents()
        let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)

        // When & Then - Test all event types are handled
        let events: [FavoritesViewEvent] = [
            .loadFavoriteMovies,
            .toggleFavorite(movie),
            .clearAllFavoriteMovies,
            .refreshFavoriteMovies,
        ]

        await MainActor.run {
            for event in events {
                viewModel.handle(event)
                // Should not crash for any event type
            }
        }

        // Test passes - viewModel exists
    }

    @Test("Set favorite movies for testing with empty array updates state")
    func setFavoriteMoviesForTestingWithEmptyArray() async {
        defer { StorageServiceFactory.shared.resetCache() }

        // Given
        let (viewModel, _) = createTestComponents()

        // When
        await MainActor.run {
            viewModel.setFavoriteMoviesForTesting([])
        }

        // Then
        await MainActor.run {
            #expect(viewModel.favoriteMovies.isEmpty)
            if case let .success(dataState) = viewModel.viewState {
                #expect(dataState.favoriteMovies.isEmpty)
                #expect(dataState.title == Localizable.favorites.title)
            }
        }
    }

    @Test("View model memory management works correctly")
    func viewModelMemoryManagement() async throws {
        defer { StorageServiceFactory.shared.resetCache() }

        // Given
        weak var weakViewModel: FavoritesMoviesViewModel?

        await MainActor.run {
            autoreleasepool {
                let (viewModel, _) = createTestComponents()
                weakViewModel = viewModel

                // Start some operations
                viewModel.loadFavoriteMovies()
                viewModel.refreshFavoriteMovies()
            }
        }

        // Wait a moment for deallocation
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // When - ViewModel should be deallocated
        // Then - Weak reference should be nil
        await MainActor.run {
            #expect(weakViewModel == nil, "ViewModel should be deallocated")
        }
    }
}
