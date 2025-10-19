//
//  LiveSearchService.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Combine
import EntropyCore
import Foundation

/**
 * Live implementation of SearchService.
 *
 * This class handles all network requests for the Search module using
 * the EntropyCore framework for API requests and Combine for reactive programming.
 *
 * Features:
 * - Automatic main thread delivery for UI updates
 * - Type-safe API responses
 * - Error handling through Combine publishers
 * - Protocol conformance for testability
 */
final class LiveSearchService: APIRequest, SearchService {
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
        fetchRequest(target: SearchAPI.searchMovies(query: query, page: page), dataType: MoviesResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
