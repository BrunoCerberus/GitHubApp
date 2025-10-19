//
//  SearchService.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Combine
import Foundation

/**
 * Protocol defining the interface for Search module API services.
 *
 * This protocol abstracts the network layer and provides a clean interface
 * for searching movie data. It enables easy mocking for testing and
 * dependency injection for better architecture.
 *
 * All methods return Combine publishers for reactive programming patterns.
 */
protocol SearchService {
    /**
     * Search for movies by title query.
     *
     * - Parameter query: Search term to find movies
     * - Parameter page: Page number to fetch (defaults to 1)
     * - Returns: Publisher that emits MoviesResponse or Error
     */
    func searchMovies(with query: String, page: Int) -> AnyPublisher<MoviesResponse, Error>
}
