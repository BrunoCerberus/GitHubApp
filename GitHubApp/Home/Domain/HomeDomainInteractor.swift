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
 * ## Service Bridging Pattern
 *
 * This interactor demonstrates the **Service Bridging Pattern** where DomainInteractors
 * act as coordinators for multiple independent services, implementing business logic
 * that spans across service boundaries.
 *
 * ### Architecture Role
 *
 * ```
 * ┌─────────────────────────────────────────────────┐
 * │      HomeDomainInteractor (Bridge/Coordinator)  │
 * │  • Retrieves services from ServiceLocator      │
 * │  • Coordinates HomeService + StorageService     │
 * │  • Implements cross-service business logic      │
 * └─────────────────────────────────────────────────┘
 *            │                    │
 *            ▼                    ▼
 * ┌──────────────────┐  ┌──────────────────┐
 * │  HomeService     │  │ StorageService   │
 * │  • Fetch movies  │  │ • Persist data   │
 * │  • Search movies │  │ • Fetch favorites│
 * │  • Independent   │  │ • Independent    │
 * └──────────────────┘  └──────────────────┘
 * ```
 *
 * ### Key Principles
 *
 * 1. **Services Don't Know Each Other**: HomeService and StorageService are completely independent
 * 2. **DomainInteractor Coordinates**: All multi-service operations happen here
 * 3. **ServiceLocator for DI**: All dependencies resolved through ServiceLocator
 * 4. **Business Logic Layer**: Complex operations that need multiple services
 *
 * ### Example: Fetching Movies with Favorites
 *
 * ```swift
 * // This requires coordination of TWO services:
 * // 1. HomeService.fetchMovies() - get movies from API
 * // 2. StorageService.fetchLikedMovies() - get favorites from storage
 * // 3. Business logic: merge the data to mark favorites
 *
 * // ❌ WRONG: Services calling other services
 * class HomeService {
 *     func fetchMovies() {
 *         let favorites = storageService.fetchLikedMovies() // NO!
 *     }
 * }
 *
 * // ✅ CORRECT: DomainInteractor coordinates both services
 * class HomeDomainInteractor {
 *     func handleFetchMovies() {
 *         let movies = homeService.fetchMovies()
 *         let favorites = storageService.fetchLikedMovies()
 *         return mergeMoviesWithFavorites(movies, favorites)
 *     }
 * }
 * ```
 *
 * - SeeAlso: `ARCHITECTURE_PATTERNS.md` for complete Service Bridging pattern documentation
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

    // MARK: - Dependencies (Retrieved from ServiceLocator)

    //
    // Following the Service Bridging pattern, this interactor coordinates
    // multiple independent services retrieved from the ServiceLocator.

    /// Service for fetching movie data from external APIs
    /// Retrieved from ServiceLocator during initialization
    private let homeService: HomeService

    /// Storage service for persisting favorite movies and user data
    /// Retrieved from ServiceLocator during initialization
    private let storageService: StorageService

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /**
     * Initialize the domain interactor with required dependencies via ServiceLocator.
     *
     * ## Dependency Injection via ServiceLocator
     *
     * This initializer demonstrates the **ServiceLocator pattern** for dependency injection:
     *
     * ### Service Retrieval Strategy
     *
     * 1. **Attempt retrieval from ServiceLocator**:
     *    - Try to get registered service (Mock in tests, Live in production)
     *    - ServiceLocator.retrieve() throws if service not registered
     *
     * 2. **Fallback to Live implementation**:
     *    - If retrieval fails, use Live service as fallback
     *    - Ensures app still works even if service not registered
     *    - Logs warning for debugging
     *
     * ### Why Fallback to Live Services?
     *
     * ```swift
     * do {
     *     homeService = try serviceLocator.retrieve(HomeService.self)
     * } catch {
     *     Logger.shared.service("Failed to retrieve...", level: .warning)
     *     homeService = LiveHomeService()  // Fallback ensures robustness
     * }
     * ```
     *
     * **Benefits**:
     * - **Robustness**: App doesn't crash if service not registered
     * - **Development**: Easy to test individual components
     * - **Production**: Graceful degradation if ServiceLocator misconfigured
     * - **Debugging**: Clear log warnings when fallback is used
     *
     * ### Service Registration
     *
     * Services are registered centrally in `GitHubAppSceneDelegate.swift`:
     * ```swift
     * // Production
     * serviceLocator.register(HomeService.self, instance: LiveHomeService())
     * serviceLocator.register(StorageService.self, instance: LiveStorageService())
     *
     * // Testing
     * serviceLocator.register(HomeService.self, instance: MockHomeService())
     * serviceLocator.register(StorageService.self, instance: MockStorageService())
     * ```
     *
     * - Parameters:
     *   - serviceLocator: Central service registry for dependency injection
     *   - initialState: Initial domain state (defaults to HomeDomainState.initial)
     *
     * - SeeAlso: `ARCHITECTURE_PATTERNS.md` for Service Bridging pattern details
     */
    init(
        serviceLocator: ServiceLocator,
        initialState: HomeDomainState = .initial
    ) {
        // Retrieve HomeService from ServiceLocator with fallback
        do {
            homeService = try serviceLocator.retrieve(HomeService.self)
        } catch {
            Logger.shared.service("Failed to retrieve HomeService from ServiceLocator: \(error)", level: .warning)
            homeService = LiveHomeService() // Fallback to Live implementation
        }

        // Retrieve StorageService from ServiceLocator with fallback
        do {
            storageService = try serviceLocator.retrieve(StorageService.self)
        } catch {
            Logger.shared.service("Failed to retrieve StorageService from ServiceLocator: \(error)", level: .warning)
            storageService = try! LiveStorageService() // Fallback to Live implementation
        }

        currentState = initialState

        // Listen for favorite movies updates from other features (cross-feature communication)
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
            handleToggleMovieFavorite(movie: movie)
        case .loadPersistedFavoriteMovies:
            handleLoadPersistedFavoriteMovies()
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
     * Handle fetching upcoming movies from the API.
     */
    private func handleFetchUpcomingMovies() {
        // Set loading state
        currentState = currentState.copy(
            isLoading: true,
            error: nil,
            searchQuery: nil
        )

        homeService.fetchMovies(page: 1)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState = self?.currentState.copy(
                            isLoading: false,
                            error: error.localizedDescription
                        ) ?? HomeDomainState.initial
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self else { return }
                    let updatedLikedMovies = filterLikedMovies(from: response.results)

                    // Save movies to widget shared storage
                    WidgetDataManager.shared.saveUpcomingMovies(response.results)

                    // Post notification for widget data manager
                    NotificationCenter.default.post(
                        name: .moviesDidUpdate,
                        object: response.results
                    )

                    currentState = currentState.copy(
                        movies: response.results,
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
        currentState = currentState.copy(
            isLoading: true,
            error: nil,
            searchQuery: query
        )

        homeService.searchMovies(with: query, page: 1)
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
                receiveValue: { [weak self] response in
                    guard let self else { return }
                    let updatedLikedMovies = filterLikedMovies(from: response.results)

                    currentState = currentState.copy(
                        movies: response.results,
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
     * Save favorite movies using StorageService.
     */
    private func savePersistedLikedMovies(_ movies: [Movie]) {
        Task {
            do {
                try await storageService.save(movies, context: StorageContext.favoriteMovies)
            } catch {
                Logger.shared.domain("Failed to save favorite movies: \(error)", level: .error)
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
            Logger.shared.domain("Failed to load favorite movies: \(error)", level: .error)
            return []
        }
    }

    // MARK: - Deinit

    /**
     * Cleanup method called when the interactor is deallocated.
     */
    deinit {
        NotificationCenter.default.removeObserver(self)
        Logger.shared.domain("HomeDomainInteractor deallocated", level: .debug)
    }
}

// MARK: - HomeDomainState Helper Extension

private extension HomeDomainState {
    /**
     * Create a copy of the current state with selectively modified properties.
     *
     * ## State Copy Helper Pattern
     *
     * This method enables **immutable state updates** following functional programming principles.
     * Instead of mutating the state directly, we create a new state object with only the
     * properties we want to change, while preserving all other properties.
     *
     * ### Double-Optional Syntax Explained
     *
     * Notice the `String??` syntax for optional properties:
     * ```swift
     * error: String?? = nil,
     * searchQuery: String?? = nil
     * ```
     *
     * **Why double-optional instead of single-optional?**
     *
     * The double-optional pattern solves a critical distinction problem:
     *
     * #### Single Optional (`String? = nil`)
     * - **Problem**: Cannot distinguish between:
     *   - "Don't update this property" (keep existing value)
     *   - "Update this property to nil" (clear the value)
     * - Both scenarios would pass `nil` as the parameter
     *
     * #### Double Optional (`String?? = nil`)
     * - `nil` (outer nil) = "Don't update this property" ✅ Default behavior
     * - `.some(nil)` (outer some, inner nil) = "Update this property to nil" ✅ Clear value
     * - `.some(.some(value))` (both some) = "Update to specific value" ✅ Set value
     *
     * ### Usage Examples
     *
     * ```swift
     * // Update only movies, keep everything else unchanged
     * let newState = currentState.copy(movies: updatedMovies)
     *
     * // Update multiple properties at once
     * let newState = currentState.copy(
     *     movies: updatedMovies,
     *     isLoading: false,
     *     error: nil  // Don't change error (keeps existing value)
     * )
     *
     * // Clear the search query (set to nil explicitly)
     * let newState = currentState.copy(searchQuery: .some(nil))
     *
     * // Update error to specific value
     * let newState = currentState.copy(error: .some("Network error"))
     * ```
     *
     * ### Benefits of This Pattern
     *
     * 1. **Immutability**: State objects are never mutated, only copied
     * 2. **Selective Updates**: Specify only the properties that need to change
     * 3. **Type Safety**: Compiler enforces correct types for all properties
     * 4. **Readability**: Clear intent about which properties are being updated
     * 5. **Testability**: Easy to verify state transitions in unit tests
     * 6. **Thread Safety**: Immutable objects are inherently thread-safe
     *
     * - Parameters:
     *   - movies: New movies array (or nil to keep current value)
     *   - favoriteMovies: New favorite movies array (or nil to keep current value)
     *   - isLoading: New loading state (or nil to keep current value)
     *   - error: New error message - use `.some(nil)` to clear (or nil to keep current value)
     *   - searchQuery: New search query - use `.some(nil)` to clear (or nil to keep current value)
     * - Returns: A new HomeDomainState with updated properties
     *
     * - SeeAlso: `ARCHITECTURE_PATTERNS.md` for comprehensive pattern explanation
     */
    func copy(
        movies: [Movie]? = nil,
        favoriteMovies: [Movie]? = nil,
        isLoading: Bool? = nil,
        error: String?? = nil, // Double-optional: distinguishes "don't update" from "set to nil"
        searchQuery: String?? = nil // Double-optional: distinguishes "don't update" from "set to nil"
    ) -> HomeDomainState {
        HomeDomainState(
            movies: movies ?? self.movies,
            favoriteMovies: favoriteMovies ?? self.favoriteMovies,
            isLoading: isLoading ?? self.isLoading,
            error: error ?? self.error, // Nil coalescing preserves existing value
            searchQuery: searchQuery ?? self.searchQuery // Nil coalescing preserves existing value
        )
    }
}
