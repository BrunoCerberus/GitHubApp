//
//  MovieDetailsViewModel.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Combine
import EntropyCore
import Foundation

/**
 * ViewModel for the MovieDetails screen using Clean Architecture principles.
 *
 * This ViewModel follows Clean Architecture by:
 * - Using CombineViewModel from EntropyCore
 * - Having a single source of truth through viewState
 * - Delegating business logic to MovieDetailsDomainInteractor
 * - Converting view events to domain actions
 * - Converting domain state to view state
 *
 * Uses Combine for reactive programming and state management.
 */
@MainActor
final class MovieDetailsViewModel: CombineViewModel {
    /// Single source of truth for the view state
    @Published var viewState: MovieDetailsViewState = .loading

    // MARK: - CombineViewModel Requirements

    /// Type alias for the view event type
    typealias ViewEventType = MovieDetailsViewEvent

    /// Type alias for the view state type
    typealias ViewStateType = MovieDetailsViewState

    // MARK: - Dependencies

    /// Domain interactor handling business logic
    private let domainInteractor: MovieDetailsDomainInteractor

    /// Reducer for converting domain state to view state
    private let viewStateReducer: MovieDetailsViewStateReducing

    /// Service locator for dependency management
    private let serviceLocator: ServiceLocator

    /// The movie being displayed
    private let movie: Movie

    // MARK: - Initialization

    /**
     * Initialize the ViewModel with dependencies.
     *
     * - Parameters:
     *   - movie: The movie to display details for
     *   - serviceLocator: Service locator for dependency injection
     *   - domainInteractor: Optional domain interactor (created if not provided)
     *   - viewStateReducer: Optional view state reducer (created if not provided)
     */
    init(
        movie: Movie,
        serviceLocator: ServiceLocator,
        domainInteractor: MovieDetailsDomainInteractor? = nil,
        viewStateReducer: MovieDetailsViewStateReducing? = nil
    ) {
        self.movie = movie
        self.serviceLocator = serviceLocator

        // Initialize domain interactor
        self.domainInteractor = domainInteractor ?? MovieDetailsDomainInteractor(
            serviceLocator: serviceLocator,
            movie: movie
        )

        // Initialize view state reducer
        self.viewStateReducer = viewStateReducer ?? MovieDetailsViewStateReducer()

        // Set up state observation
        setupStateObservation()

        // Load initial data
        loadInitialData()
    }

    // MARK: - CombineViewModel Implementation

    /**
     * Handle incoming view events and delegate to domain interactor.
     *
     * This method implements the CombineViewModel protocol by processing view events,
     * converting them to domain actions, and sending them to the domain interactor.
     *
     * - Parameter event: The view event to handle
     */
    func handle(_ event: MovieDetailsViewEvent) {
        let domainAction = MovieDetailsDomainEventActionMap.map(event)
        domainInteractor.handleAction(domainAction)
    }

    /**
     * Send view event - required by CombineViewModel protocol.
     *
     * This method is the protocol requirement for sending view events.
     *
     * - Parameter event: The view event to send
     */
    func sendViewEvent(_ event: MovieDetailsViewEvent) {
        handle(event)
    }

    // MARK: - Public Interface Methods

    /**
     * Fetch movie details (credits and reviews).
     *
     * Delegates to domain interactor through view event handling.
     */
    func fetchData() {
        handle(.fetchData)
    }

    /**
     * Toggle the favorite status of the movie.
     *
     * Delegates to domain interactor through view event handling.
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
        guard case let .success(dataViewState) = viewState else {
            return false
        }
        return dataViewState.favoriteMovies.contains(where: { $0.id == movie.id })
    }

    /**
     * Get current favorite movies from view state.
     *
     * - Returns: Array of favorite movies, or empty array if not in success state
     */
    var favoriteMovies: [Movie] {
        guard case let .success(dataViewState) = viewState else {
            return []
        }
        return dataViewState.favoriteMovies
    }

    /**
     * Get current error message from view state.
     *
     * - Returns: Error message if in error state, nil otherwise
     */
    var error: String? {
        guard case let .error(errorMessage) = viewState else {
            return nil
        }
        return errorMessage
    }

    // MARK: - Private Methods

    /**
     * Set up observation of domain state changes.
     *
     * This method observes the domain interactor's state and converts it to view state
     * using the view state reducer.
     */
    private func setupStateObservation() {
        domainInteractor.$currentState
            .map { [weak self] domainState in
                self?.viewStateReducer.reduce(domainState) ?? .loading
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$viewState)
    }

    /**
     * Load initial data with appropriate timing to ensure state observation is established.
     */
    private func loadInitialData() {
        // Use a small delay to ensure the state observation pipeline is fully set up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { [weak self] in
            self?.handle(.fetchData)
        }
    }

    /**
     * Cleanup method called when ViewModel is deallocated.
     *
     * Logs deallocation for debugging purposes.
     */
    deinit {
        Logger.shared.viewModel("MovieDetailsViewModel deallocated", level: .debug)
    }
}
