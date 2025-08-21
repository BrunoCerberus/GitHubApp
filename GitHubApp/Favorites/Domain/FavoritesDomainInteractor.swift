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
 */
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

    /// Service for handling favorite movies persistence
    private let favoritesService: FavoritesService

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /**
     * Initialize the interactor with dependencies.
     *
     * - Parameter favoritesService: Service for handling favorite movies persistence (optional, will use ServiceLocator if nil)
     * - Parameter serviceLocator: Service locator for dependency injection (optional)
     */
    init(favoritesService: FavoritesService? = nil, serviceLocator: ServiceLocator? = nil) {
        // Use provided service or get from ServiceLocator
        if let favoritesService {
            self.favoritesService = favoritesService
        } else if let serviceLocator {
            do {
                self.favoritesService = try serviceLocator.retrieve(FavoritesService.self)
            } catch {
                print("⚠️ Failed to retrieve FavoritesService from ServiceLocator: \(error)")
                self.favoritesService = LiveFavoritesService()
            }
        } else {
            self.favoritesService = LiveFavoritesService()
        }

        // Initialize with cached data to avoid loading flicker
        let cachedMovies = Self.loadCachedMovies(from: self.favoritesService)
        currentState = FavoritesDomainState(
            favoriteMovies: cachedMovies,
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

        favoritesService.loadFavoriteMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.currentState.isLoading = false
                    if case let .failure(error) = completion {
                        self?.currentState.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] movies in
                    self?.currentState.favoriteMovies = movies
                    self?.currentState.isLoading = false
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Toggle the favorite status of a movie.
     *
     * - Parameter movie: The movie to toggle favorite status for
     */
    private func toggleMovieFavorite(_ movie: Movie) {
        currentState.error = nil

        favoritesService.toggleMovieFavorite(movie)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] movies in
                    self?.currentState.favoriteMovies = movies
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Clear all favorite movies.
     */
    private func clearAllFavoriteMovies() {
        currentState.error = nil

        favoritesService.clearAllFavoriteMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.currentState.favoriteMovies = []
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Refresh the favorite movies list.
     */
    private func refreshFavoriteMovies() {
        loadFavoriteMovies()
    }

    // MARK: - Static Helper Methods

    /**
     * Load cached movies synchronously to avoid loading flicker.
     * This provides immediate data on initialization.
     *
     * Since the StorageService is async, we'll return empty array for now
     * and let the normal loading process populate the data.
     */
    private static func loadCachedMovies(from _: FavoritesService) -> [Movie] {
        // For now, return empty array to avoid complex async initialization
        // The data will be loaded via the normal loadFavoriteMovies flow
        []
    }
}
