//
//  LikedMoviesViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine
import EntropyCore
import Foundation

/**
 * ViewModel for the Liked screen using Clean Architecture principles.
 *
 * This ViewModel now follows Clean Architecture by:
 * - Using CombineViewModel from EntropyCore
 * - Having a single source of truth through viewState
 * - Delegating business logic to LikedDomainInteractor
 * - Converting view events to domain actions
 * - Converting domain state to view state
 *
 * Uses Combine for reactive programming and state management.
 */
final class LikedMoviesViewModel: CombineViewModel {
    /// Single source of truth for the view state
    @Published var viewState: LikedViewState = .loading

    // MARK: - CombineViewModel Requirements

    /// Type alias for the view event type
    typealias ViewEventType = LikedViewEvent

    /// Type alias for the view state type
    typealias ViewStateType = LikedViewState

    // MARK: - Dependencies

    /// Domain interactor handling business logic
    private let domainInteractor: LikedDomainInteractor

    /// Reducer for converting domain state to view state
    private let viewStateReducer: LikedViewStateReducing

    /// Service locator for dependency management
    private let serviceLocator: ServiceLocator?

    // MARK: - Initialization

    /**
     * Initialize the ViewModel with dependencies.
     *
     * - Parameters:
     *   - domainInteractor: Domain interactor for business logic (optional, will create default)
     *   - viewStateReducer: Reducer for view state conversion (optional, will create default)
     *   - serviceLocator: Service locator for dependency injection (optional)
     */
    init(
        domainInteractor: LikedDomainInteractor? = nil,
        viewStateReducer: LikedViewStateReducing? = nil,
        serviceLocator: ServiceLocator? = nil
    ) {
        self.domainInteractor = domainInteractor ?? LikedDomainInteractor()
        self.viewStateReducer = viewStateReducer ?? LikedViewStateReducer()
        self.serviceLocator = serviceLocator

        setupStateObservation()

        // Load liked movies on initialization
        loadLikedMovies()
    }

    // MARK: - Public Interface

    /**
     * Load liked movies from persistence.
     */
    func loadLikedMovies() {
        handle(.loadLikedMovies)
    }

    /**
     * Toggle the liked status of a movie.
     *
     * - Parameter movie: The movie to toggle like status for
     */
    func toggleLike(for movie: Movie) {
        handle(.toggleLike(movie))
    }

    /**
     * Check if a movie is currently liked by the user.
     *
     * - Parameter movie: The movie to check
     * - Returns: True if the movie is liked, false otherwise
     */
    func isLiked(movie: Movie) -> Bool {
        switch viewState {
        case let .success(dataViewState):
            dataViewState.likedMovies.contains(where: { $0.id == movie.id })
        default:
            false
        }
    }

    /**
     * Clear all liked movies.
     */
    func clearAllLikedMovies() {
        handle(.clearAllLikedMovies)
    }

    /**
     * Refresh the liked movies list.
     */
    func refreshLikedMovies() {
        handle(.refreshLikedMovies)
    }

    // MARK: - Test Support

    /**
     * Get current liked movies from view state - for backward compatibility with tests.
     *
     * - Returns: Array of liked movies, or empty array if not in success state
     */
    var likedMovies: [Movie] {
        switch viewState {
        case let .success(dataViewState):
            dataViewState.likedMovies
        default:
            []
        }
    }

    /**
     * Set liked movies directly for testing purposes.
     * This bypasses the normal Clean Architecture flow and should only be used in tests.
     *
     * - Parameter movies: Array of movies to set as liked
     */
    func setLikedMoviesForTesting(_ movies: [Movie]) {
        let dataViewState = LikedDataViewState(
            title: Localizable.likedMovies.title,
            likedMovies: movies
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
    func handle(_ event: LikedViewEvent) {
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
    func sendViewEvent(_ event: LikedViewEvent) {
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
    private func convertToDomainAction(_ event: LikedViewEvent) -> LikedDomainAction {
        switch event {
        case .loadLikedMovies:
            .loadLikedMovies
        case let .toggleLike(movie):
            .toggleMovieLike(movie)
        case .clearAllLikedMovies:
            .clearAllLikedMovies
        case .refreshLikedMovies:
            .refreshLikedMovies
        }
    }
}
