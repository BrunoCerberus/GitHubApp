//
//  MovieDetailsDomainInteractor.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Combine
import EntropyCore
import Foundation
import SwiftData

/**
 * Domain interactor for the MovieDetails feature business logic.
 *
 * This interactor demonstrates the **Service Bridging Pattern** where it
 * acts as a coordinator for multiple independent services, implementing business logic
 * that spans across service boundaries.
 */
@MainActor
final class MovieDetailsDomainInteractor: ObservableObject, CombineInteractor {
    // MARK: - CombineInteractor Requirements

    /// Input type for the interactor
    typealias Input = MovieDetailsDomainAction

    /// Input error type
    typealias InputError = Never

    /// Output type for the interactor
    typealias Output = MovieDetailsDomainState

    /// Output error type
    typealias OutputError = Never

    /// Current state of the interactor
    @Published var currentState: MovieDetailsDomainState

    // MARK: - Dependencies

    /// Service for fetching movie data from external APIs
    private let homeService: HomeService

    /// Storage service for persisting favorite movies and user data
    private let storageService: StorageService

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /**
     * Initialize the domain interactor with required dependencies via ServiceLocator.
     *
     * - Parameters:
     *   - serviceLocator: Central service registry for dependency injection
     *   - movie: The movie to display details for
     *   - initialState: Initial domain state (defaults to MovieDetailsDomainState.initial)
     */
    init(
        serviceLocator: ServiceLocator,
        movie: Movie,
        initialState: MovieDetailsDomainState? = nil
    ) {
        // Retrieve HomeService from ServiceLocator with fallback
        do {
            homeService = try serviceLocator.retrieve(HomeService.self)
        } catch {
            Logger.shared.service("Failed to retrieve HomeService from ServiceLocator: \(error)", level: .warning)
            homeService = LiveHomeService() // Fallback to Live implementation
        }

        // Retrieve StorageService from ServiceLocator with fallback
        do {
            storageService = try serviceLocator.retrieve(StorageService.self)
        } catch {
            Logger.shared.service("Failed to retrieve StorageService from ServiceLocator: \(error)", level: .warning)
            storageService = try! LiveStorageService() // Fallback to Live implementation
        }

        currentState = initialState ?? MovieDetailsDomainState.initial(for: movie)

        // Listen for favorite movies updates from other features (cross-feature communication)
        setupFavoritesNotificationObserver()
    }

    // MARK: - CombineInteractor Implementation

    /**
     * Interact method required by CombineInteractor protocol.
     *
     * This method processes the input stream of actions and returns the output state stream.
     *
     * - Parameter upstream: Publisher of domain actions
     * - Returns: Publisher of domain states
     */
    func interact(upstream: AnyPublisher<MovieDetailsDomainAction, Never>) -> AnyPublisher<MovieDetailsDomainState, Never> {
        upstream
            .sink { [weak self] action in
                self?.handleAction(action)
            }
            .store(in: &cancellables)

        return $currentState
            .eraseToAnyPublisher()
    }

    /**
     * Process domain actions and update state accordingly.
     *
     * - Parameter action: The domain action to process
     */
    func handleAction(_ action: MovieDetailsDomainAction) {
        switch action {
        case .fetchMovieDetails:
            handleFetchMovieDetails()
        case let .toggleMovieFavorite(movie):
            handleToggleMovieFavorite(movie: movie)
        }
    }

    // MARK: - Private Setup Methods

    /**
     * Setup notification observer for favorite movies updates from other features.
     */
    private func setupFavoritesNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoriteMoviesDidUpdate(_:)),
            name: .favoriteMoviesDidUpdate,
            object: nil
        )
    }

    /**
     * Handle favorite movies update notifications from other features.
     */
    @objc private func favoriteMoviesDidUpdate(_: Notification) {
        Task {
            await handleLoadPersistedFavoriteMoviesAsync()
        }
    }

    // MARK: - Private Action Handlers

    /**
     * Handle fetching movie details (credits and reviews).
     */
    private func handleFetchMovieDetails() {
        // Set loading state
        currentState = currentState.copy(isLoading: true, error: nil)

        // Fetch credits and reviews in parallel
        Publishers.Zip(
            homeService.fetchCredits(with: currentState.movie.id)
                .map(\.cast),
            homeService.fetchReviews(with: currentState.movie.id)
                .map(\.results)
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    let movie = self?.currentState.movie ?? Movie(
                        id: 0,
                        title: "",
                        overview: "",
                        posterPath: nil
                    )
                    self?.currentState = self?.currentState.copy(
                        isLoading: false,
                        error: error.localizedDescription
                    ) ?? MovieDetailsDomainState.initial(for: movie)
                }
            },
            receiveValue: { [weak self] credits, reviews in
                let movie = self?.currentState.movie ?? Movie(
                    id: 0,
                    title: "",
                    overview: "",
                    posterPath: nil
                )
                self?.currentState = self?.currentState.copy(
                    credits: credits,
                    reviews: reviews,
                    isLoading: false,
                    error: nil
                ) ?? MovieDetailsDomainState.initial(for: movie)
            }
        )
        .store(in: &cancellables)
    }

    /**
     * Handle toggling the favorite status of a movie.
     *
     * - Parameter movie: The movie to toggle favorite status for
     */
    private func handleToggleMovieFavorite(movie: Movie) {
        Task {
            do {
                // Toggle the movie favorite status and get updated list
                let updatedFavorites = try await storageService.toggleMovieFavorite(movie)

                // Update local state
                currentState = currentState.copy(favoriteMovies: updatedFavorites)

                // Notify other features about the change
                NotificationCenter.default.post(name: .favoriteMoviesDidUpdate, object: updatedFavorites)
            } catch {
                Logger.shared.service("Failed to toggle favorite: \(error)", level: .error)
            }
        }
    }

    /**
     * Handle loading persisted favorite movies asynchronously.
     */
    private func handleLoadPersistedFavoriteMoviesAsync() async {
        do {
            let favorites = try await storageService.fetchLikedMovies()
            currentState = currentState.copy(favoriteMovies: favorites)
        } catch {
            Logger.shared.service("Failed to load favorites: \(error)", level: .error)
        }
    }

    /**
     * Cleanup method called when interactor is deallocated.
     */
    deinit {
        Logger.shared.viewModel("MovieDetailsDomainInteractor deallocated", level: .debug)
    }
}

// MARK: - Copy Helper

extension MovieDetailsDomainState {
    /**
     * Create a copy of this state with updated values.
     *
     * - Parameters:
     *   - credits: Updated credits (defaults to current value)
     *   - reviews: Updated reviews (defaults to current value)
     *   - favoriteMovies: Updated favorite movies (defaults to current value)
     *   - isLoading: Updated loading state (defaults to current value)
     *   - error: Updated error (defaults to current value)
     * - Returns: New state with updated values
     */
    func copy(
        credits: [MovieCastMember]? = nil,
        reviews: [MovieReview]? = nil,
        favoriteMovies: [Movie]? = nil,
        isLoading: Bool? = nil,
        error: String?? = nil
    ) -> MovieDetailsDomainState {
        MovieDetailsDomainState(
            movie: movie,
            credits: credits ?? self.credits,
            reviews: reviews ?? self.reviews,
            favoriteMovies: favoriteMovies ?? self.favoriteMovies,
            isLoading: isLoading ?? self.isLoading,
            error: error ?? self.error
        )
    }
}
