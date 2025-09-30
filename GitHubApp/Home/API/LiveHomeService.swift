//
//  LiveHomeService.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine
import EntropyCore
import Foundation

/**
 * Live implementation of HomeService.
 *
 * This class handles all network requests for the Home module using
 * the EntropyCore framework for API requests and Combine for reactive programming.
 *
 * Features:
 * - Automatic main thread delivery for UI updates
 * - Type-safe API responses
 * - Error handling through Combine publishers
 * - Protocol conformance for testability
 */
final class LiveHomeService: APIRequest, HomeService {
    /**
     * Fetch upcoming movies from The Movie Database API.
     *
     * Makes a network request to the upcoming movies endpoint and
     * delivers the response on the main thread for UI updates.
     *
     * - Parameter page: Page number to fetch (defaults to 1)
     * - Returns: Publisher that emits MoviesResponse or Error
     */
    func fetchMovies(page: Int = 1) -> AnyPublisher<MoviesResponse, Error> {
        fetchRequest(target: HomeAPI.fetchMovies(page: page), dataType: MoviesResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /**
     * Search for movies by title query.
     *
     * Makes a network request to the search endpoint with the provided query
     * and delivers the response on the main thread for UI updates.
     *
     * - Parameter query: Search term to find movies
     * - Parameter page: Page number to fetch (defaults to 1)
     * - Returns: Publisher that emits MoviesResponse or Error
     */
    func searchMovies(with query: String, page: Int = 1) -> AnyPublisher<MoviesResponse, Error> {
        fetchRequest(target: HomeAPI.searchMovies(query: query, page: page), dataType: MoviesResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /**
     * Fetch cast and crew credits for a specific movie.
     *
     * Makes a network request to the credits endpoint for the specified movie
     * and delivers the response on the main thread for UI updates.
     *
     * - Parameter id: Movie ID from The Movie Database
     * - Returns: Publisher that emits MovieCreditsResponse or Error
     */
    func fetchCredits(with id: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
        fetchRequest(target: HomeAPI.fetchCredits(id), dataType: MovieCreditsResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /**
     * Fetch reviews for a specific movie.
     *
     * Makes a network request to the reviews endpoint for the specified movie
     * and delivers the response on the main thread for UI updates.
     *
     * - Parameter id: Movie ID from The Movie Database
     * - Returns: Publisher that emits MovieReviewsResponse or Error
     */
    func fetchReviews(with id: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
        fetchRequest(target: HomeAPI.fetchReviews(id), dataType: MovieReviewsResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
