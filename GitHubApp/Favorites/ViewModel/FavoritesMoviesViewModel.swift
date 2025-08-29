//
//  FavoritesMoviesViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine
import EntropyCore
import Foundation

/**
 * ViewModel for the Favorites screen using Clean Architecture principles.
 *
 * This ViewModel now follows Clean Architecture by:
 * - Using CombineViewModel from EntropyCore
 * - Having a single source of truth through viewState
 * - Delegating business logic to FavoritesDomainInteractor
 * - Converting view events to domain actions
 * - Converting domain state to view state
 *
 * Uses Combine for reactive programming and state management.
 */
final class FavoritesMoviesViewModel: CombineViewModel {
    /// Single source of truth for the view state
    @Published var viewState: FavoritesViewState = .loading

    // MARK: - CombineViewModel Requirements

    /// Type alias for the view event type
    typealias ViewEventType = FavoritesViewEvent

    /// Type alias for the view state type
    typealias ViewStateType = FavoritesViewState

    // MARK: - Dependencies

    /// Domain interactor handling business logic
    private let domainInteractor: FavoritesDomainInteractor

    /// Reducer for converting domain state to view state
    private let viewStateReducer: FavoritesViewStateReducing

    /// Service locator for dependency management
    let serviceLocator: ServiceLocator

    // MARK: - Initialization

    /**
     * Initialize the ViewModel with dependencies.
     *
     * - Parameters:
     *   - serviceLocator: Service locator for dependency injection
     *   - domainInteractor: Domain interactor for business logic (optional, will create default)
     *   - viewStateReducer: Reducer for view state conversion (optional, will create default)
     */
    init(
        serviceLocator: ServiceLocator,
        domainInteractor: FavoritesDomainInteractor? = nil,
        viewStateReducer: FavoritesViewStateReducing? = nil
    ) {
        self.serviceLocator = serviceLocator
        self.domainInteractor = domainInteractor ?? FavoritesDomainInteractor(serviceLocator: serviceLocator)
        self.viewStateReducer = viewStateReducer ?? FavoritesViewStateReducer()

        setupStateObservation()
    }

    // MARK: - Public Interface

    /**
     * Load favorite movies from persistence.
     */
    func loadFavoriteMovies() {
        handle(.loadFavoriteMovies)
    }

    /**
     * Toggle the favorite status of a movie.
     *
     * - Parameter movie: The movie to toggle favorite status for
     */
    func toggleFavorite(for movie: Movie) {
        handle(.toggleFavorite(movie))
    }

    /**
     * Check if a movie is currently favorited by the user.
     *
     * - Parameter movie: The movie to check
     * - Returns: True if the movie is favorited, false otherwise
     */
    func isFavorited(movie: Movie) -> Bool {
        switch viewState {
        case let .success(dataViewState):
            dataViewState.favoriteMovies.contains(where: { $0.id == movie.id })
        default:
            false
        }
    }

    /**
     * Clear all favorite movies.
     */
    func clearAllFavoriteMovies() {
        handle(.clearAllFavoriteMovies)
    }

    /**
     * Refresh the favorite movies list.
     */
    func refreshFavoriteMovies() {
        handle(.refreshFavoriteMovies)
    }

    // MARK: - Test Support

    /**
     * Get current favorite movies from view state - for backward compatibility with tests.
     *
     * - Returns: Array of favorite movies, or empty array if not in success state
     */
    var favoriteMovies: [Movie] {
        switch viewState {
        case let .success(dataViewState):
            dataViewState.favoriteMovies
        default:
            []
        }
    }

    /**
     * Set favorite movies directly for testing purposes.
     * This bypasses the normal Clean Architecture flow and should only be used in tests.
     *
     * - Parameter movies: Array of movies to set as favorites
     */
    func setFavoriteMoviesForTesting(_ movies: [Movie]) {
        let dataViewState = FavoritesDataViewState(
            title: Localizable.favorites.title,
            favoriteMovies: movies
        )
        viewState = .success(dataViewState)
    }

    // MARK: - CombineViewModel Implementation

    /**
     * Handle view events by converting them to domain actions.
     *
     * This method acts as a bridge between the UI layer and the domain layer,
     * converting view events into domain actions that the interactor can process.
     *
     * - Parameter event: The view event to handle
     */
    func handle(_ event: FavoritesViewEvent) {
        let domainAction = convertToDomainAction(event)
        domainInteractor.process(domainAction)
    }

    /**
     * Send view event - required by CombineViewModel protocol.
     *
     * This method is the protocol requirement for sending view events.
     *
     * - Parameter event: The view event to send
     */
    func sendViewEvent(_ event: FavoritesViewEvent) {
        handle(event)
    }

    // MARK: - Private Methods

    /**
     * Set up observation of domain state changes.
     *
     * This method establishes the reactive connection between the domain interactor
     * and the view model, automatically updating the view state when domain state changes.
     */
    private func setupStateObservation() {
        domainInteractor.$currentState
            .map { [weak self] domainState in
                self?.viewStateReducer.reduce(domainState) ?? .loading
            }
            .assign(to: &$viewState)
    }

    /**
     * Convert view events to domain actions.
     *
     * This method translates UI-specific events into domain-specific actions
     * that can be processed by the business logic layer.
     *
     * - Parameter event: The view event to convert
     * - Returns: The corresponding domain action
     */
    private func convertToDomainAction(_ event: FavoritesViewEvent) -> FavoritesDomainAction {
        switch event {
        case .loadFavoriteMovies:
            .loadFavoriteMovies
        case let .toggleFavorite(movie):
            .toggleMovieFavorite(movie)
        case .clearAllFavoriteMovies:
            .clearAllFavoriteMovies
        case .refreshFavoriteMovies:
            .refreshFavoriteMovies
        }
    }
}
