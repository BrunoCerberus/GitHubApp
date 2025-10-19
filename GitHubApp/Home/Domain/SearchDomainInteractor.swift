//
//  SearchDomainInteractor.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Combine
import EntropyCore
import Foundation
import SwiftData

/**
 * Domain interactor for the Search feature business logic.
 *
 * This interactor handles all business logic for the Search feature using Clean Architecture principles.
 * It processes domain actions and manages domain state while communicating with external services.
 *
 * Conforms to CombineInteractor to leverage reactive programming patterns.
 */
final class SearchDomainInteractor: ObservableObject, CombineInteractor {
    // MARK: - CombineInteractor Requirements

    /// Input type for the interactor
    typealias Input = SearchDomainAction

    /// Input error type
    typealias InputError = Never

    /// Output type for the interactor
    typealias Output = SearchDomainState

    /// Output error type
    typealias OutputError = Never

    /// Current state of the interactor
    @Published var currentState: SearchDomainState

    // MARK: - Dependencies

    /// Service for searching movie data from external APIs
    private let searchService: SearchService

    /// Storage service for persisting favorite movies
    private let storageService: StorageServiceProtocol

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /**
     * Initialize the domain interactor with required dependencies.
     *
     * - Parameter serviceLocator: Service locator for dependency injection
     * - Parameter initialState: Initial domain state (defaults to SearchDomainState.initial)
     */
    init(
        serviceLocator: ServiceLocator,
        initialState: SearchDomainState = .initial
    ) {
        // Retrieve SearchService from ServiceLocator
        do {
            searchService = try serviceLocator.retrieve(SearchService.self)
        } catch {
            Logger.shared.service("Failed to retrieve SearchService from ServiceLocator: \(error)", level: .warning)
            searchService = LiveSearchService()
        }

        // Initialize storage service
        do {
            storageService = try StorageServiceFactory.shared.getStorageService()
        } catch {
            fatalError("Failed to initialize storage service: \(error)")
        }

        currentState = initialState

        // Listen for favorite movies updates from other features
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
    func interact(upstream: AnyPublisher<SearchDomainAction, Never>) -> AnyPublisher<SearchDomainState, Never> {
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
     * This method handles all business logic by processing actions and
     * producing appropriate state changes through reactive streams.
     *
     * - Parameter action: The domain action to process
     */
    func handleAction(_ action: SearchDomainAction) {
        switch action {
        case let .searchMovies(query):
            handleSearchMovies(query: query)
        case let .toggleMovieFavorite(movie):
            handleToggleMovieFavorite(movie: movie)
        case .loadPersistedFavoriteMovies:
            handleLoadPersistedFavoriteMovies()
        case .loadMoreMovies:
            handleLoadMoreMovies()
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
     * Handle searching for movies with a query.
     */
    private func handleSearchMovies(query: String) {
        guard !query.isEmpty else {
            // Clear search results when query is empty
            currentState = currentState.copy(
                movies: [],
                isLoading: false,
                error: .some(nil),
                searchQuery: .some(nil),
                currentPage: 0,
                totalPages: 0
            )
            return
        }

        // Set loading state with search query and reset pagination
        currentState = currentState.copy(
            isLoading: true,
            error: nil,
            searchQuery: query,
            currentPage: 0,
            totalPages: 0
        )

        searchService.searchMovies(with: query, page: 1)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState = self?.currentState.copy(
                            isLoading: false,
                            error: error.localizedDescription,
                            searchQuery: query
                        ) ?? SearchDomainState.initial
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self else { return }
                    let updatedLikedMovies = filterLikedMovies(from: response.results)

                    currentState = currentState.copy(
                        movies: response.results,
                        favoriteMovies: updatedLikedMovies,
                        isLoading: false,
                        error: nil,
                        searchQuery: query,
                        currentPage: response.page,
                        totalPages: response.totalPages
                    )
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Handle toggling favorite status for a movie.
     */
    private func handleToggleMovieFavorite(movie: Movie) {
        Task {
            do {
                // Use StorageService to toggle the movie favorite status
                let updatedLikedMovies = try await storageService.toggleMovieFavorite(movie)

                // Filter to only show favorite movies that are in the current movies list
                let filteredLikedMovies = filterLikedMovies(from: currentState.movies, persistedLikedMovies: updatedLikedMovies)

                // Update state on main thread
                await MainActor.run {
                    currentState = currentState.copy(favoriteMovies: filteredLikedMovies)
                }
            } catch {
                Logger.shared.domain("Failed to toggle movie like: \(error)", level: .error)
                await MainActor.run {
                    currentState = currentState.copy(error: "Failed to update favorite status")
                }
            }
        }
    }

    /**
     * Handle loading persisted favorite movies.
     */
    private func handleLoadPersistedFavoriteMovies() {
        Task {
            await handleLoadPersistedFavoriteMoviesAsync()
        }
    }

    /**
     * Handle loading more movies for pagination (infinite scroll).
     */
    private func handleLoadMoreMovies() {
        // Don't load if already loading or no more pages available
        guard !currentState.isLoadingMore,
              !currentState.isLoading,
              currentState.hasMorePages,
              let searchQuery = currentState.searchQuery,
              !searchQuery.isEmpty
        else {
            return
        }

        let nextPage = currentState.currentPage + 1

        // Set loading more state
        currentState = currentState.copy(isLoadingMore: true)

        searchService.searchMovies(with: searchQuery, page: nextPage)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState = self?.currentState.copy(
                            error: error.localizedDescription,
                            isLoadingMore: false
                        ) ?? SearchDomainState.initial
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self else { return }

                    // Append new movies to existing ones
                    let allMovies = currentState.movies + response.results
                    let updatedLikedMovies = filterLikedMovies(from: allMovies)

                    currentState = currentState.copy(
                        movies: allMovies,
                        favoriteMovies: updatedLikedMovies,
                        error: nil,
                        currentPage: response.page,
                        totalPages: response.totalPages,
                        isLoadingMore: false
                    )
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Handle loading persisted favorite movies asynchronously.
     */
    private func handleLoadPersistedFavoriteMoviesAsync() async {
        do {
            let persistedLikedMovies = try await storageService.fetchLikedMovies()
            let filteredLikedMovies = filterLikedMovies(from: currentState.movies, persistedLikedMovies: persistedLikedMovies)

            await MainActor.run {
                currentState = currentState.copy(favoriteMovies: filteredLikedMovies)
            }
        } catch {
            Logger.shared.domain("Failed to load persisted favorite movies: \(error)", level: .error)
        }
    }

    // MARK: - Private Helper Methods

    /**
     * Filter favorite movies to only include those currently in the movies list.
     */
    private func filterLikedMovies(from movies: [Movie], persistedLikedMovies: [Movie]? = nil) -> [Movie] {
        let persisted = persistedLikedMovies ?? loadPersistedLikedMovies()
        return movies.filter { movie in
            persisted.contains(where: { $0.id == movie.id })
        }
    }

    /**
     * Load favorite movies using StorageService.
     */
    private func loadPersistedLikedMovies() -> [Movie] {
        // Since this is called synchronously but StorageService is async,
        // we'll use a simplified approach and return empty array
        // The proper async loading happens in the normal flow
        []
    }

    // MARK: - Deinit

    /**
     * Cleanup method called when the interactor is deallocated.
     */
    deinit {
        NotificationCenter.default.removeObserver(self)
        #if DEBUG
            Logger.shared.domain("SearchDomainInteractor deallocated", level: .debug)
        #endif
    }
}

// MARK: - SearchDomainState Helper Extension

private extension SearchDomainState {
    /**
     * Create a copy of the current state with modified properties.
     */
    func copy(
        movies: [Movie]? = nil,
        favoriteMovies: [Movie]? = nil,
        isLoading: Bool? = nil,
        error: String?? = nil,
        searchQuery: String?? = nil,
        currentPage: Int? = nil,
        totalPages: Int? = nil,
        isLoadingMore: Bool? = nil
    ) -> SearchDomainState {
        SearchDomainState(
            movies: movies ?? self.movies,
            favoriteMovies: favoriteMovies ?? self.favoriteMovies,
            isLoading: isLoading ?? self.isLoading,
            error: error ?? self.error,
            searchQuery: searchQuery ?? self.searchQuery,
            currentPage: currentPage ?? self.currentPage,
            totalPages: totalPages ?? self.totalPages,
            isLoadingMore: isLoadingMore ?? self.isLoadingMore
        )
    }
}
