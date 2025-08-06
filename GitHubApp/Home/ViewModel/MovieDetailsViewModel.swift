//
//  MovieDetailsViewModel.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine
import Foundation
import Observation

/**
 * Data structure for movie details information.
 *
 * Contains both cast/crew credits and reviews for a specific movie.
 * This structure is used to organize the data fetched for movie details.
 */
struct MovieDetailsData {
    /// Cast and crew members for the movie
    var credits: [MovieCastMember]

    /// User and critic reviews for the movie
    var reviews: [MovieReview]
}

/**
 * ViewModel for the Movie Details screen.
 *
 * This ViewModel handles:
 * - Fetching movie credits (cast and crew)
 * - Fetching movie reviews
 * - Managing loading states and errors
 * - Providing computed properties for UI state
 *
 * Uses @Observable for SwiftUI integration and Combine for reactive programming.
 */
@Observable
final class MovieDetailsViewModel {
    /// Combined data for movie credits and reviews
    var data: MovieDetailsData = .init(credits: [], reviews: [])

    /// Error message to display to the user
    var error: String?

    /// The movie being displayed
    let movie: Movie

    /// Network service for API calls
    let service: HomeServiceProtocol

    /// Combine cancellables for memory management
    private var cancellables: Set<AnyCancellable> = .init()

    /**
     * Initialize the ViewModel with a movie and optional service dependency.
     *
     * - Parameter movie: The movie to display details for
     * - Parameter service: Network service for API calls (retrieved from ServiceLocator)
     * - Parameter serviceLocator: Service locator for dependency injection
     */
    init(movie: Movie,
         service: HomeServiceProtocol? = nil,
         serviceLocator: ServiceLocator? = nil)
    {
        self.movie = movie

        // Try to get service from ServiceLocator, fallback to HomeService if not registered
        if let service {
            self.service = service
        } else if let serviceLocator {
            do {
                self.service = try serviceLocator.retrieve(HomeServiceProtocol.self)
            } catch {
                // Fallback to HomeService if not registered in ServiceLocator
                self.service = HomeService()
            }
        } else {
            // Fallback to HomeService if no ServiceLocator provided
            self.service = HomeService()
        }
    }

    /**
     * Fetch all movie details data (credits and reviews).
     *
     * Makes parallel requests for credits and reviews, then combines
     * the results into the data property. Handles errors appropriately.
     */
    func fetchData() {
        fetchCredits()
            .zip(fetchReviews())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] credits, reviews in
                self?.data = MovieDetailsData(credits: credits, reviews: reviews)
            })
            .store(in: &cancellables)
    }

    /**
     * Fetch movie credits (cast and crew).
     *
     * - Returns: Publisher that emits array of cast members or Error
     */
    private func fetchCredits() -> AnyPublisher<[MovieCastMember], Error> {
        service.fetchCredits(with: movie.id)
            .map(\.cast)
            .eraseToAnyPublisher()
    }

    /**
     * Fetch movie reviews.
     *
     * - Returns: Publisher that emits array of reviews or Error
     */
    private func fetchReviews() -> AnyPublisher<[MovieReview], Error> {
        service.fetchReviews(with: movie.id)
            .map(\.results)
            .eraseToAnyPublisher()
    }

    /**
     * Handle and display errors from API calls.
     *
     * Sets the error message for UI display and logs the error for debugging.
     *
     * - Parameter error: The error that occurred
     */
    private func handleError(_ error: Error) {
        self.error = "Failed to load data: \(error.localizedDescription)"
        debugPrint(error)
    }

    /**
     * Cleanup method called when ViewModel is deallocated.
     *
     * Logs deallocation for debugging purposes.
     */
    deinit {
        print("MovieDetailsViewModel deallocated")
    }
}

// MARK: - Computed Properties

extension MovieDetailsViewModel {
    /**
     * Check if credits section should be displayed.
     *
     * - Returns: True if there are credits to show, false otherwise
     */
    var showCredits: Bool {
        !data.credits.isEmpty
    }

    /**
     * Check if reviews section should be displayed.
     *
     * - Returns: True if there are reviews to show, false otherwise
     */
    var showReviews: Bool {
        !data.reviews.isEmpty
    }
}
