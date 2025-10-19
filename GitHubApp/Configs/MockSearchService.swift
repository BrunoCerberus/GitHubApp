//
//  MockSearchService.swift
//  GitHubApp
//
//  Created by Claude Code
//

import Combine
import Foundation

/**
 * Mock implementation of SearchService for testing.
 *
 * This service provides mock data when running in test environment
 * to avoid real network requests during testing.
 */
struct MockSearchService: SearchService {
    private let mockMovies = [
        Movie(id: 346_698,
              title: "Barbie",
              overview: "Barbie and Ken are having the time of their lives in the colorful " +
                  "and seemingly perfect world of Barbie Land. However, when they get a chance to " +
                  "go to the real world, they soon discover the joys and perils of living among humans.",
              posterPath: ""),

        Movie(id: 615_656,
              title: "Meg 2: The Trench",
              overview: "An exploratory dive into the deepest depths of the ocean of a daring " +
                  "research team spirals into chaos when a malevolent mining operation threatens " +
                  "their mission and forces them into a high-stakes battle for survival.",
              posterPath: ""),

        Movie(id: 496_450,
              title: "Miraculous: Ladybug & Cat Noir, The Movie",
              overview: "A life of an ordinary Parisian teenager Marinette goes superhuman " +
                  "when she becomes Ladybug. Bestowed with magical powers of creation, Ladybug " +
                  "must unite with her opposite, Cat Noir, to save Paris as a new villain unleashes chaos unto the city.",
              posterPath: ""),
    ]

    func searchMovies(with _: String, page: Int = 1) -> AnyPublisher<MoviesResponse, Error> {
        let response = MoviesResponse(
            results: mockMovies,
            page: page,
            totalPages: 5,
            totalResults: mockMovies.count * 5
        )
        return Just(response)
            .setFailureType(to: Error.self)
            .receive(on: RunLoop.current)
            .eraseToAnyPublisher()
    }
}
