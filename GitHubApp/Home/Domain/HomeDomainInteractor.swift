//
//  HomeDomainInteractor.swift
//  GitHubApp
//
//  Created by bruno on feature/home-clean-architecture.
//

import Combine
import EntropyCore
import Foundation
import SwiftData

/**
 * Domain interactor for the Home feature business logic.
 *
 * This interactor handles all business logic for the Home feature using Clean Architecture principles.
 * It processes domain actions and manages domain state while communicating with external services.
 *
 * Conforms to CombineInteractor to leverage reactive programming patterns.
 */
final class HomeDomainInteractor: ObservableObject, CombineInteractor {
    // MARK: - CombineInteractor Requirements

    /// Input type for the interactor
    typealias Input = HomeDomainAction

    /// Input error type
    typealias InputError = Never

    /// Output type for the interactor
    typealias Output = HomeDomainState

    /// Output error type
    typealias OutputError = Never

    /// Current state of the interactor
    @Published var currentState: HomeDomainState

    // MARK: - Dependencies

    /// Service for fetching movie data from external APIs
    private let homeService: HomeService

    /// Storage service for persisting favorite movies
    private let storageService: StorageServiceProtocol

    /// UserDefaults key for persisting favorite movies (legacy, kept for migration)
    private let favoriteMoviesKey: String = "favoriteMoviesKey"

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /**
     * Initialize the domain interactor with required dependencies.
     *
     * - Parameter homeService: Service for movie data operations (optional, will use ServiceLocator if nil)
     * - Parameter storageService: Storage service for persistence (defaults to shared instance)
     * - Parameter serviceLocator: Service locator for dependency injection (optional)
     * - Parameter initialState: Initial domain state (defaults to HomeDomainState.initial)
     */
    init(
        homeService: HomeService? = nil,
        storageService: StorageServiceProtocol? = nil,
        serviceLocator: ServiceLocator? = nil,
        initialState: HomeDomainState = .initial
    ) {
        // Initialize home service
        if let homeService {
            self.homeService = homeService
        } else if let serviceLocator {
            do {
                self.homeService = try serviceLocator.retrieve(HomeService.self)
            } catch {
                print("⚠️ Failed to retrieve HomeService from ServiceLocator: \(error)")
                self.homeService = LiveHomeService()
            }
        } else {
            self.homeService = LiveHomeService()
        }

        // Initialize storage service
        if let storageService {
            self.storageService = storageService
        } else {
            do {
                self.storageService = try StorageServiceFactory.shared.getStorageService()
            } catch {
                // Fallback to legacy UserDefaults service if SwiftData fails
                print("⚠️ HomeDomainInteractor: Failed to initialize SwiftData storage, falling back to UserDefaults: \(error)")
                self.storageService = UserDefaultsStorageService()
            }
        }

        currentState = initialState
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
    func interact(upstream: AnyPublisher<HomeDomainAction, Never>) -> AnyPublisher<HomeDomainState, Never> {
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
    func handleAction(_ action: HomeDomainAction) {
        switch action {
        case .fetchUpcomingMovies:
            handleFetchUpcomingMovies()
        case let .searchMovies(query):
            handleSearchMovies(query: query)
        case let .toggleMovieFavorite(movie):
            handleToggleMovieLike(movie: movie)
        case .loadPersistedLikedMovies:
            handleLoadPersistedLikedMovies()
        }
    }

    // MARK: - Private Action Handlers

    /**
     * Handle fetching upcoming movies from the API.
     */
    private func handleFetchUpcomingMovies() {
        // Set loading state
        currentState = currentState.copy(isLoading: true, error: nil, searchQuery: nil)

        homeService.fetchMovies()
            .map(\.results)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState = self?.currentState.copy(
                            isLoading: false,
                            error: error.localizedDescription
                        ) ?? HomeDomainState.initial
                    }
                },
                receiveValue: { [weak self] movies in
                    guard let self else { return }
                    let updatedLikedMovies = filterLikedMovies(from: movies)

                    // Save movies to widget shared storage
                    WidgetDataManager.shared.saveUpcomingMovies(movies)

                    // Post notification for widget data manager
                    NotificationCenter.default.post(
                        name: .moviesDidUpdate,
                        object: movies
                    )

                    currentState = currentState.copy(
                        movies: movies,
                        favoriteMovies: updatedLikedMovies,
                        isLoading: false,
                        error: nil,
                        searchQuery: nil
                    )
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Handle searching for movies with a query.
     */
    private func handleSearchMovies(query: String) {
        guard !query.isEmpty else {
            handleFetchUpcomingMovies()
            return
        }

        // Set loading state with search query
        currentState = currentState.copy(isLoading: true, error: nil, searchQuery: query)

        homeService.searchMovies(with: query)
            .map(\.results)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState = self?.currentState.copy(
                            isLoading: false,
                            error: error.localizedDescription,
                            searchQuery: query
                        ) ?? HomeDomainState.initial
                    }
                },
                receiveValue: { [weak self] movies in
                    guard let self else { return }
                    let updatedLikedMovies = filterLikedMovies(from: movies)

                    currentState = currentState.copy(
                        movies: movies,
                        favoriteMovies: updatedLikedMovies,
                        isLoading: false,
                        error: nil,
                        searchQuery: query
                    )
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Handle toggling favorite status for a movie.
     */
    private func handleToggleMovieLike(movie: Movie) {
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
                print("⚠️ Failed to toggle movie like: \(error)")
                await MainActor.run {
                    currentState = currentState.copy(error: "Failed to update favorite status")
                }
            }
        }
    }

    /**
     * Handle loading persisted favorite movies.
     */
    private func handleLoadPersistedLikedMovies() {
        Task {
            do {
                let persistedLikedMovies = try await storageService.fetchLikedMovies()
                let filteredLikedMovies = filterLikedMovies(from: currentState.movies, persistedLikedMovies: persistedLikedMovies)

                await MainActor.run {
                    currentState = currentState.copy(favoriteMovies: filteredLikedMovies)
                }
            } catch {
                print("⚠️ Failed to load persisted favorite movies: \(error)")
            }
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
     * Save favorite movies using StorageService.
     */
    private func savePersistedLikedMovies(_ movies: [Movie]) {
        Task {
            do {
                try await storageService.save(movies, context: StorageContext.favoriteMovies)
            } catch {
                print("⚠️ Failed to save favorite movies: \(error)")
            }
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

    /**
     * Load favorite movies asynchronously using StorageService.
     */
    private func loadPersistedLikedMoviesAsync() async -> [Movie] {
        do {
            return try await storageService.fetchLikedMovies()
        } catch {
            print("⚠️ Failed to load favorite movies: \(error)")
            return []
        }
    }
}

// MARK: - HomeDomainState Helper Extension

private extension HomeDomainState {
    /**
     * Create a copy of the current state with modified properties.
     */
    func copy(
        movies: [Movie]? = nil,
        favoriteMovies: [Movie]? = nil,
        isLoading: Bool? = nil,
        error: String?? = nil,
        searchQuery: String?? = nil
    ) -> HomeDomainState {
        HomeDomainState(
            movies: movies ?? self.movies,
            favoriteMovies: favoriteMovies ?? self.favoriteMovies,
            isLoading: isLoading ?? self.isLoading,
            error: error ?? self.error,
            searchQuery: searchQuery ?? self.searchQuery
        )
    }
}
