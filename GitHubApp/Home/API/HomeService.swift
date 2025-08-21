//
//  HomeService.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine
import Foundation

/**
 * Protocol defining the interface for Home module API services.
 *
 * This protocol abstracts the network layer and provides a clean interface
 * for fetching movie data. It enables easy mocking for testing and
 * dependency injection for better architecture.
 *
 * All methods return Combine publishers for reactive programming patterns.
 */
protocol HomeService {
    /**
     * Fetch upcoming movies from The Movie Database API.
     *
     * - Returns: Publisher that emits MoviesResponse or Error
     */
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error>

    /**
     * Search for movies by title query.
     *
     * - Parameter query: Search term to find movies
     * - Returns: Publisher that emits MoviesResponse or Error
     */
    func searchMovies(with query: String) -> AnyPublisher<MoviesResponse, Error>

    /**
     * Fetch cast and crew credits for a specific movie.
     *
     * - Parameter id: Movie ID from The Movie Database
     * - Returns: Publisher that emits MovieCreditsResponse or Error
     */
    func fetchCredits(with id: Int) -> AnyPublisher<MovieCreditsResponse, Error>

    /**
     * Fetch reviews for a specific movie.
     *
     * - Parameter id: Movie ID from The Movie Database
     * - Returns: Publisher that emits MovieReviewsResponse or Error
     */
    func fetchReviews(with id: Int) -> AnyPublisher<MovieReviewsResponse, Error>
}
