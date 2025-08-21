//
//  HomeViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine
import EntropyCore
import Foundation

/**
 * ViewModel for the Home screen using Clean Architecture principles.
 *
 * This ViewModel now follows Clean Architecture by:
 * - Using CombineViewModel from EntropyCore
 * - Having a single source of truth through viewState
 * - Delegating business logic to HomeDomainInteractor
 * - Converting view events to domain actions
 * - Converting domain state to view state
 *
 * Uses Combine for reactive programming and state management.
 */
final class HomeViewModel: CombineViewModel {
    /// Single source of truth for the view state
    @Published var viewState: HomeViewState = .loading

    // MARK: - CombineViewModel Requirements

    /// Type alias for the view event type
    typealias ViewEventType = HomeViewEvent

    /// Type alias for the view state type
    typealias ViewStateType = HomeViewState

    // MARK: - Dependencies

    /// Domain interactor handling business logic
    private let domainInteractor: HomeDomainInteractor

    /// Reducer for converting domain state to view state
    private let viewStateReducer: HomeViewStateReducing

    /// Service locator for dependency management
    private let serviceLocator: ServiceLocator?

    // MARK: - Initialization

    /**
     * Initialize the ViewModel with dependencies.
     *
     * - Parameter service: Network service for API calls (retrieved from ServiceLocator)
     * - Parameter serviceLocator: Service locator for dependency injection
     * - Parameter domainInteractor: Optional domain interactor (created if not provided)
     * - Parameter viewStateReducer: Optional view state reducer (created if not provided)
     */
    init(
        service: HomeServiceProtocol? = nil,
        serviceLocator: ServiceLocator? = nil,
        domainInteractor: HomeDomainInteractor? = nil,
        viewStateReducer: HomeViewStateReducing? = nil
    ) {
        // Store serviceLocator for dependency resolution
        self.serviceLocator = serviceLocator

        // Resolve service dependency
        let resolvedService: HomeServiceProtocol
        if let service {
            resolvedService = service
        } else if let serviceLocator {
            do {
                resolvedService = try serviceLocator.retrieve(HomeServiceProtocol.self)
            } catch {
                // Fallback to HomeService if not registered in ServiceLocator
                resolvedService = HomeService()
            }
        } else {
            // Fallback to HomeService if no ServiceLocator provided
            resolvedService = HomeService()
        }

        // Initialize domain interactor
        self.domainInteractor = domainInteractor ?? HomeDomainInteractor(homeService: resolvedService)

        // Initialize view state reducer
        self.viewStateReducer = viewStateReducer ?? HomeViewStateReducer()

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
    func handle(_ event: HomeViewEvent) {
        let domainAction = HomeDomainEventActionMap.map(event)
        domainInteractor.handleAction(domainAction)
    }

    /**
     * Send view event - required by CombineViewModel protocol.
     *
     * This method is the protocol requirement for sending view events.
     *
     * - Parameter event: The view event to send
     */
    func sendViewEvent(_ event: HomeViewEvent) {
        handle(event)
    }

    // MARK: - Public Interface Methods

    /**
     * Fetch upcoming movies from the API.
     *
     * Delegates to domain interactor through view event handling.
     */
    func fetchData() {
        handle(.fetchData)
    }

    /**
     * Search for movies by query string.
     *
     * Delegates to domain interactor through view event handling.
     *
     * - Parameter query: Search term to find movies
     */
    func searchMovies(query: String) {
        handle(.searchMovies(query))
    }

    /**
     * Toggle the liked status of a movie.
     *
     * Delegates to domain interactor through view event handling.
     *
     * - Parameter movie: The movie to toggle like status for
     */
    func toggleLike(for movie: Movie) {
        handle(.toggleLike(movie))
    }

    /**
     * Load liked movies from persistence.
     *
     * Delegates to domain interactor through view event handling.
     */
    func loadLikedMovies() {
        handle(.loadLikedMovies)
    }

    /**
     * Check if a movie is currently liked by the user.
     *
     * - Parameter movie: The movie to check
     * - Returns: True if the movie is liked, false otherwise
     */
    func isLiked(movie: Movie) -> Bool {
        guard case let .success(dataViewState) = viewState else {
            return false
        }
        return dataViewState.likedMovies.contains(where: { $0.id == movie.id })
    }

    /**
     * Get current movies from view state.
     *
     * - Returns: Array of current movies, or empty array if not in success state
     */
    var movies: [Movie] {
        guard case let .success(dataViewState) = viewState else {
            return []
        }
        return dataViewState.movies
    }

    /**
     * Get current liked movies from view state.
     *
     * - Returns: Array of liked movies, or empty array if not in success state
     */
    var likedMovies: [Movie] {
        guard case let .success(dataViewState) = viewState else {
            return []
        }
        return dataViewState.likedMovies
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
            self?.handle(.loadLikedMovies)
        }
    }

    /**
     * Cleanup method called when ViewModel is deallocated.
     *
     * Logs deallocation for debugging purposes.
     */
    deinit {
        #if DEBUG
            print("HomeViewModel deallocated")
        #endif
    }
}
