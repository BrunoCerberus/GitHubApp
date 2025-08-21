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
    private let likedService: LikedServiceProtocol

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /**
     * Initialize the interactor with dependencies.
     *
     * - Parameter likedService: Service for handling liked movies persistence
     */
    init(likedService: LikedServiceProtocol = LikedService()) {
        self.likedService = likedService
        currentState = .initial
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
}
