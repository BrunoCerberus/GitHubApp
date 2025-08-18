//
//  HomeDomainInteractor.swift
//  GitHubApp
//
//  Created by bruno on feature/home-clean-architecture.
//

import Combine
import EntropyCore
import Foundation

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
    private let homeService: HomeServiceProtocol

    /// UserDefaults key for persisting liked movies
    private let likedMoviesKey: String = "likedMoviesKey"

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /**
     * Initialize the domain interactor with required dependencies.
     *
     * - Parameter homeService: Service for movie data operations
     * - Parameter initialState: Initial domain state (defaults to HomeDomainState.initial)
     */
    init(homeService: HomeServiceProtocol, initialState: HomeDomainState = .initial) {
        self.homeService = homeService
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
        case let .toggleMovieLike(movie):
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
                        likedMovies: updatedLikedMovies,
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
                        likedMovies: updatedLikedMovies,
                        isLoading: false,
                        error: nil,
                        searchQuery: query
                    )
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Handle toggling like status for a movie.
     */
    private func handleToggleMovieLike(movie: Movie) {
        var persistedLikedMovies = loadPersistedLikedMovies()

        if let index = persistedLikedMovies.firstIndex(where: { $0.id == movie.id }) {
            // Remove from liked movies if already liked
            persistedLikedMovies.remove(at: index)
        } else {
            // Add to liked movies if not liked
            persistedLikedMovies.append(movie)
        }

        savePersistedLikedMovies(persistedLikedMovies)

        let updatedLikedMovies = filterLikedMovies(from: currentState.movies, persistedLikedMovies: persistedLikedMovies)

        currentState = currentState.copy(likedMovies: updatedLikedMovies)
    }

    /**
     * Handle loading persisted liked movies.
     */
    private func handleLoadPersistedLikedMovies() {
        let updatedLikedMovies = filterLikedMovies(from: currentState.movies)
        currentState = currentState.copy(likedMovies: updatedLikedMovies)
    }

    // MARK: - Private Helper Methods

    /**
     * Filter liked movies to only include those currently in the movies list.
     */
    private func filterLikedMovies(from movies: [Movie], persistedLikedMovies: [Movie]? = nil) -> [Movie] {
        let persisted = persistedLikedMovies ?? loadPersistedLikedMovies()
        return movies.filter { movie in
            persisted.contains(where: { $0.id == movie.id })
        }
    }

    /**
     * Save liked movies to UserDefaults for persistence.
     */
    private func savePersistedLikedMovies(_ movies: [Movie]) {
        if let data = try? JSONEncoder().encode(movies) {
            UserDefaults.standard.set(data, forKey: likedMoviesKey)
        }
    }

    /**
     * Load liked movies from UserDefaults.
     */
    private func loadPersistedLikedMovies() -> [Movie] {
        guard let data = UserDefaults.standard.data(forKey: likedMoviesKey),
              let movies = try? JSONDecoder().decode([Movie].self, from: data)
        else {
            return []
        }
        return movies
    }
}

// MARK: - HomeDomainState Helper Extension

private extension HomeDomainState {
    /**
     * Create a copy of the current state with modified properties.
     */
    func copy(
        movies: [Movie]? = nil,
        likedMovies: [Movie]? = nil,
        isLoading: Bool? = nil,
        error: String?? = nil,
        searchQuery: String?? = nil
    ) -> HomeDomainState {
        HomeDomainState(
            movies: movies ?? self.movies,
            likedMovies: likedMovies ?? self.likedMovies,
            isLoading: isLoading ?? self.isLoading,
            error: error ?? self.error,
            searchQuery: searchQuery ?? self.searchQuery
        )
    }
}
