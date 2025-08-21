//
//  LikedDomainInteractor.swift
//  GitHubApp
//
//  Created by bruno on feature/liked-clean-architecture.
//

import Combine
import EntropyCore
import Foundation

/**
 * Domain interactor for the Liked feature business logic.
 *
 * This interactor handles all business logic for the Liked feature using Clean Architecture principles.
 * It processes domain actions and manages domain state while handling persistence of liked movies.
 *
 * Conforms to CombineInteractor to leverage reactive programming patterns.
 */
final class LikedDomainInteractor: ObservableObject, CombineInteractor {
    // MARK: - CombineInteractor Requirements

    /// Input type for the interactor
    typealias Input = LikedDomainAction

    /// Input error type
    typealias InputError = Never

    /// Output type for the interactor
    typealias Output = LikedDomainState

    /// Output error type
    typealias OutputError = Never

    /// Current state of the interactor
    @Published var currentState: LikedDomainState

    // MARK: - Dependencies

    /// Service for handling liked movies persistence
    private let likedService: FavoritesService

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /**
     * Initialize the interactor with dependencies.
     *
     * - Parameter likedService: Service for handling liked movies persistence (optional, will use ServiceLocator if nil)
     * - Parameter serviceLocator: Service locator for dependency injection (optional)
     */
    init(likedService: FavoritesService? = nil, serviceLocator: ServiceLocator? = nil) {
        // Use provided service or get from ServiceLocator
        if let likedService {
            self.likedService = likedService
        } else if let serviceLocator {
            do {
                self.likedService = try serviceLocator.retrieve(FavoritesService.self)
            } catch {
                print("⚠️ Failed to retrieve LikedService from ServiceLocator: \(error)")
                self.likedService = LiveFavoritesService()
            }
        } else {
            self.likedService = LiveFavoritesService()
        }

        // Initialize with cached data to avoid loading flicker
        let cachedMovies = Self.loadCachedMovies(from: self.likedService)
        currentState = LikedDomainState(
            likedMovies: cachedMovies,
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
    func interact(upstream: AnyPublisher<LikedDomainAction, Never>) -> AnyPublisher<LikedDomainState, Never> {
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
    func process(_ action: LikedDomainAction) {
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
    private func handleAction(_ action: LikedDomainAction) {
        switch action {
        case .loadLikedMovies:
            loadLikedMovies()
        case let .toggleMovieLike(movie):
            toggleMovieLike(movie)
        case .clearAllLikedMovies:
            clearAllLikedMovies()
        case .refreshLikedMovies:
            refreshLikedMovies()
        }
    }

    // MARK: - Private Business Logic

    /**
     * Load liked movies from persistence.
     */
    private func loadLikedMovies() {
        currentState.isLoading = true
        currentState.error = nil

        likedService.loadLikedMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.currentState.isLoading = false
                    if case let .failure(error) = completion {
                        self?.currentState.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] movies in
                    self?.currentState.likedMovies = movies
                    self?.currentState.isLoading = false
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Toggle the liked status of a movie.
     *
     * - Parameter movie: The movie to toggle like status for
     */
    private func toggleMovieLike(_ movie: Movie) {
        currentState.error = nil

        likedService.toggleMovieLike(movie)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] movies in
                    self?.currentState.likedMovies = movies
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Clear all liked movies.
     */
    private func clearAllLikedMovies() {
        currentState.error = nil

        likedService.clearAllLikedMovies()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.currentState.likedMovies = []
                }
            )
            .store(in: &cancellables)
    }

    /**
     * Refresh the liked movies list.
     */
    private func refreshLikedMovies() {
        loadLikedMovies()
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
        // The data will be loaded via the normal loadLikedMovies flow
        []
    }
}
