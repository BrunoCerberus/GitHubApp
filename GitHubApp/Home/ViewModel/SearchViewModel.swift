//
//  SearchViewModel.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Combine
import EntropyCore
import Foundation
import SwiftUI

/**
 * ViewModel for the Search screen using Clean Architecture principles.
 *
 * This ViewModel is dedicated to search functionality and follows Clean Architecture by:
 * - Using CombineViewModel from EntropyCore
 * - Having a single source of truth through viewState
 * - Delegating business logic to HomeDomainInteractor (reused for movie search)
 * - Converting view events to domain actions
 * - Converting domain state to view state
 *
 * Uses Combine for reactive programming and state management.
 */
final class SearchViewModel: CombineViewModel {
    /// Single source of truth for the view state
    @Published var viewState: HomeViewState = .loading

    // MARK: - CombineViewModel Requirements

    /// Type alias for the view event type
    typealias ViewEventType = HomeViewEvent

    /// Type alias for the view state type
    typealias ViewStateType = HomeViewState

    // MARK: - Dependencies

    /// Domain interactor handling business logic (reused from Home domain)
    private let domainInteractor: HomeDomainInteractor

    /// Reducer for converting domain state to view state
    private let viewStateReducer: HomeViewStateReducing

    /// Service locator for dependency management
    let serviceLocator: ServiceLocator

    // MARK: - Initialization

    /**
     * Initialize the ViewModel with dependencies.
     *
     * - Parameter serviceLocator: Service locator for dependency injection
     * - Parameter domainInteractor: Optional domain interactor (created if not provided)
     * - Parameter viewStateReducer: Optional view state reducer (created if not provided)
     */
    init(
        serviceLocator: ServiceLocator,
        domainInteractor: HomeDomainInteractor? = nil,
        viewStateReducer: HomeViewStateReducing? = nil
    ) {
        // Store serviceLocator for dependency resolution
        self.serviceLocator = serviceLocator

        // Initialize domain interactor
        self.domainInteractor = domainInteractor ?? HomeDomainInteractor(
            serviceLocator: serviceLocator
        )

        // Initialize view state reducer
        self.viewStateReducer = viewStateReducer ?? HomeViewStateReducer()

        // Set up state observation
        setupStateObservation()

        // Note: SearchViewModel does NOT load initial data automatically
        // The search screen starts empty and only shows results when actively searching
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

    // MARK: - Public Methods

    /**
     * Search for movies with a given query.
     *
     * - Parameter query: The search query string
     */
    func searchMovies(query: String) {
        handle(.searchMovies(query))
    }

    /**
     * Toggle favorite status for a movie.
     *
     * - Parameter movie: The movie to toggle favorite status for
     */
    func toggleFavorite(for movie: Movie) {
        handle(.toggleFavorite(movie))
    }

    /**
     * Load more movies for pagination.
     *
     * Note: This method is included for API compatibility but does nothing
     * in search context since search doesn't support pagination in the current implementation.
     */
    func loadMoreMovies() {
        // Search doesn't support pagination in current implementation
        // This is here for API compatibility with SearchView
    }

    // MARK: - Private Methods

    /**
     * Set up observation of domain state and convert to view state.
     *
     * This method subscribes to the domain interactor's state publisher and
     * transforms domain state into view state using the reducer.
     */
    private func setupStateObservation() {
        domainInteractor.$currentState
            .map { [weak self] domainState in
                self?.viewStateReducer.reduce(domainState) ?? .loading
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$viewState)
    }
}
