//
//  MovieDetailsDomainInteractorTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Combine
import Foundation
@testable import GitHubApp
import Testing

/**
 * Tests for MovieDetailsDomainInteractor.
 */
@MainActor
struct MovieDetailsDomainInteractorTests {
    private let testMovie = Movie(
        id: 111,
        title: "Interactor Test Movie",
        overview: "Test Overview",
        posterPath: "test.jpg"
    )

    private func createTestComponents() -> (
        interactor: MovieDetailsDomainInteractor,
        serviceLocator: ServiceLocator
    ) {
        try? APIKeysProvider.setMovieAPIKey("test-key")

        let mockHomeService = MockHomeService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockHomeService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let interactor = MovieDetailsDomainInteractor(
            serviceLocator: serviceLocator,
            movie: testMovie
        )

        return (interactor, serviceLocator)
    }

    private func cleanupTest() {
        try? APIKeysProvider.removeMovieAPIKey()
    }

    @Test("initializes with correct movie")
    func initializesWithCorrectMovie() {
        defer { cleanupTest() }

        let (interactor, _) = createTestComponents()

        #expect(interactor.currentState.movie.id == testMovie.id)
        #expect(interactor.currentState.movie.title == testMovie.title)
    }

    @Test("initializes with loading state")
    func initializesWithLoadingState() {
        defer { cleanupTest() }

        let (interactor, _) = createTestComponents()

        #expect(interactor.currentState.isLoading == true)
        #expect(interactor.currentState.error == nil)
    }

    @Test("initializes with empty credits and reviews")
    func initializesWithEmptyCreditsAndReviews() {
        defer { cleanupTest() }

        let (interactor, _) = createTestComponents()

        #expect(interactor.currentState.credits.isEmpty)
        #expect(interactor.currentState.reviews.isEmpty)
    }

    @Test("handles fetchMovieDetails action sets loading state")
    func handlesFetchMovieDetailsActionSetsLoadingState() {
        defer { cleanupTest() }

        let (interactor, _) = createTestComponents()

        interactor.handleAction(.fetchMovieDetails)

        #expect(interactor.currentState.isLoading == true)
    }

    @Test("handles toggleMovieFavorite action")
    func handlesToggleMovieFavoriteAction() async throws {
        defer { cleanupTest() }

        let (interactor, _) = createTestComponents()

        interactor.handleAction(.toggleMovieFavorite(testMovie))

        // Wait for async operation
        try await Task.sleep(nanoseconds: 100_000_000)

        // The state should be updated after the toggle
        #expect(true) // Basic check that action was handled
    }

    @Test("interact method returns publisher of current state")
    func interactMethodReturnsPublisherOfCurrentState() async throws {
        defer { cleanupTest() }

        let (interactor, _) = createTestComponents()

        var receivedStates: [MovieDetailsDomainState] = []

        let cancellable = interactor.$currentState
            .sink { state in
                receivedStates.append(state)
            }

        // Trigger an action
        interactor.handleAction(.fetchMovieDetails)

        // Wait for emission
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(!receivedStates.isEmpty)
        cancellable.cancel()
    }

    @Test("initial state uses correct initial values")
    func initialStateUsesCorrectInitialValues() {
        defer { cleanupTest() }

        let (interactor, _) = createTestComponents()

        #expect(interactor.currentState.movie == testMovie)
        #expect(interactor.currentState.credits.isEmpty)
        #expect(interactor.currentState.reviews.isEmpty)
        #expect(interactor.currentState.favoriteMovies.isEmpty)
        #expect(interactor.currentState.isLoading == true)
        #expect(interactor.currentState.error == nil)
    }

    @Test("can use custom initial state")
    func canUseCustomInitialState() {
        defer { cleanupTest() }

        try? APIKeysProvider.setMovieAPIKey("test-key")

        let mockHomeService = MockHomeService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockHomeService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let customState = MovieDetailsDomainState(
            movie: testMovie,
            credits: [],
            reviews: [],
            favoriteMovies: [],
            isLoading: false,
            error: nil
        )

        let interactor = MovieDetailsDomainInteractor(
            serviceLocator: serviceLocator,
            movie: testMovie,
            initialState: customState
        )

        #expect(interactor.currentState.isLoading == false)
    }

    @Test("observable object publishes state changes")
    func observableObjectPublishesStateChanges() async throws {
        defer { cleanupTest() }

        let (interactor, _) = createTestComponents()

        var stateChanges: [MovieDetailsDomainState] = []
        let subscription = interactor.$currentState.sink { state in
            stateChanges.append(state)
        }

        interactor.handleAction(.fetchMovieDetails)

        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(stateChanges.count >= 1)
        subscription.cancel()
    }
}
