//
//  FavoritesDomainInteractor.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Combine
import EntropyCore
import Foundation

/**
 * Domain interactor for the Favorites feature business logic.
 *
 * This interactor handles all business logic for the Favorites feature using Clean Architecture principles.
 * It processes domain actions and manages domain state while handling persistence of favorite movies.
 *
 * Conforms to CombineInteractor to leverage reactive programming patterns.
 *
 * @MainActor ensures all state mutations happen on the main thread, preventing race conditions
 * and deadlocks when accessing @Published properties.
 */
@MainActor
final class FavoritesDomainInteractor: ObservableObject, CombineInteractor {
    // MARK: - CombineInteractor Requirements

    /// Input type for the interactor
    typealias Input = FavoritesDomainAction

    /// Input error type
    typealias InputError = Never

    /// Output type for the interactor
    typealias Output = FavoritesDomainState

    /// Output error type
    typealias OutputError = Never

    /// Current state of the interactor
    @Published var currentState: FavoritesDomainState

    // MARK: - Dependencies

    /// Storage service for handling favorite movies persistence
    private let storageService: StorageService

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /**
     * Initialize the interactor with dependencies.
     *
     * - Parameter serviceLocator: Service locator for dependency injection
     */
    init(serviceLocator: ServiceLocator) {
        // Retrieve StorageService from ServiceLocator
        do {
            storageService = try serviceLocator.retrieve(StorageService.self)
        } catch {
            Logger.shared.service("Failed to retrieve StorageService from ServiceLocator: \(error)", level: .warning)
            storageService = try! LiveStorageService()
        }

        // Initialize with empty state
        currentState = FavoritesDomainState(
            favoriteMovies: [],
            isLoading: false,
            error: nil
        )
    }

    // MARK: - CombineInteractor Implementation

    /**
     * Process input stream of actions and return output state stream.
     *
     * This method processes the input stream of actions and returns the output state stream.
     *
     * - Parameter upstream: Publisher of domain actions
     * - Returns: Publisher of domain states
     */
    func interact(upstream: AnyPublisher<FavoritesDomainAction, Never>) -> AnyPublisher<FavoritesDomainState, Never> {
        upstream
            .sink { [weak self] action in
                self?.handleAction(action)
            }
            .store(in: &cancellables)

        return $currentState.eraseToAnyPublisher()
    }

    /**
     * Process a domain action and update the state accordingly.
     *
     * This is the main entry point for business logic processing.
     * Each action is mapped to its corresponding business logic.
     *
     * - Parameter action: The domain action to process
     */
    func process(_ action: FavoritesDomainAction) {
        handleAction(action)
    }

    /**
     * Handle domain actions and update state accordingly.
     *
     * This method handles all business logic by processing actions and
     * producing appropriate state changes through reactive streams.
     *
     * - Parameter action: The domain action to handle
     */
    private func handleAction(_ action: FavoritesDomainAction) {
        switch action {
        case .loadFavoriteMovies:
            loadFavoriteMovies()
        case let .toggleMovieFavorite(movie):
            toggleMovieFavorite(movie)
        case .clearAllFavoriteMovies:
            clearAllFavoriteMovies()
        case .refreshFavoriteMovies:
            refreshFavoriteMovies()
        }
    }

    // MARK: - Private Business Logic

    /**
     * Load favorite movies from persistence.
     */
    private func loadFavoriteMovies() {
        currentState.isLoading = true
        currentState.error = nil

        Task {
            do {
                let movies = try await storageService.fetchLikedMovies()

                currentState.favoriteMovies = movies
                currentState.isLoading = false

                // Notify other components that favorites have been updated
                NotificationCenter.default.post(
                    name: .favoriteMoviesDidUpdate,
                    object: movies
                )
            } catch {
                currentState.isLoading = false
                currentState.error = error.localizedDescription
            }
        }
    }

    /**
     * Toggle the favorite status of a movie.
     *
     * - Parameter movie: The movie to toggle favorite status for
     */
    private func toggleMovieFavorite(_ movie: Movie) {
        currentState.error = nil

        Task {
            do {
                let movies = try await storageService.toggleMovieFavorite(movie)

                currentState.favoriteMovies = movies

                // Notify other components that favorites have been updated
                NotificationCenter.default.post(
                    name: .favoriteMoviesDidUpdate,
                    object: movies
                )
            } catch {
                currentState.error = error.localizedDescription
            }
        }
    }

    /**
     * Clear all favorite movies.
     */
    private func clearAllFavoriteMovies() {
        currentState.error = nil

        Task {
            do {
                try await storageService.clearFavoriteMovies()

                currentState.favoriteMovies = []

                // Notify other components that favorites have been updated
                NotificationCenter.default.post(
                    name: .favoriteMoviesDidUpdate,
                    object: []
                )
            } catch {
                currentState.error = error.localizedDescription
            }
        }
    }

    /**
     * Refresh the favorite movies list.
     */
    private func refreshFavoriteMovies() {
        loadFavoriteMovies()
    }
}
