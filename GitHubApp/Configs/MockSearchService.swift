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
 *
 * Returns different movies based on the page number to simulate pagination
 * and avoid duplicate movie IDs in the result set.
 */
struct MockSearchService: SearchService {
    // All available mock movies with unique IDs
    private let allMockMovies = [
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

        Movie(id: 550_988,
              title: "The Conjuring",
              overview: "Paranormal investigators work to help a family terrorized by a dark presence " +
                  "in their farmhouse.",
              posterPath: ""),

        Movie(id: 258_480,
              title: "The Fast and the Furious",
              overview: "A man is falsely imprisoned, and his only hope is to win a street race.",
              posterPath: ""),

        Movie(id: 76341,
              title: "Mad Max: Fury Road",
              overview: "An action-packed journey through the wasteland where survival is everything.",
              posterPath: ""),

        Movie(id: 100_402,
              title: "Captain America: The Winter Soldier",
              overview: "Steve Rogers struggles to embrace his role in the modern world.",
              posterPath: ""),

        Movie(id: 118_340,
              title: "Guardians of the Galaxy",
              overview: "A group of misfits must stop an alien plot to destroy the universe.",
              posterPath: ""),

        Movie(id: 99861,
              title: "The Avengers",
              overview: "Earth's mightiest heroes must work together to save the world.",
              posterPath: ""),

        Movie(id: 76479,
              title: "Avatar",
              overview: "A paraplegic Marine dispatched to the alien world Pandora on a unique mission.",
              posterPath: ""),

        Movie(id: 278_779,
              title: "The Shawshank Redemption",
              overview: "Two imprisoned men bond over a number of years, finding solace and eventual redemption.",
              posterPath: ""),

        Movie(id: 238_215,
              title: "The Godfather",
              overview: "The aging patriarch of an organized crime dynasty transfers control of his clandestine empire.",
              posterPath: ""),

        Movie(id: 240_832,
              title: "The Godfather: Part II",
              overview: "The early life and career of Vito Corleone in 1920s New York City.",
              posterPath: ""),

        Movie(id: 280_722,
              title: "Schindler's List",
              overview: "In German-occupied Poland during World War II, industrialist Oskar Schindler gradually becomes concerned.",
              posterPath: ""),

        Movie(id: 329_053,
              title: "The Lord of the Rings: The Fellowship of the Ring",
              overview: "A meek Hobbit from the Shire and eight companions embark on a journey to destroy the One Ring.",
              posterPath: ""),
    ]

    /**
     * Search for movies with pagination support.
     * Returns different movies based on the page number to simulate realistic pagination.
     *
     * - Parameter query: Search term (not used in mock, but required by protocol)
     * - Parameter page: Page number for pagination (1-5)
     * - Returns: Publisher emitting a MoviesResponse with 3 unique movies per page
     */
    func searchMovies(with _: String, page: Int = 1) -> AnyPublisher<MoviesResponse, Error> {
        // Calculate which movies to return for this page
        let itemsPerPage = 3
        let startIndex = (page - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, allMockMovies.count)

        // Get movies for this page, or empty array if page is beyond available movies
        let movies: [Movie] = startIndex < allMockMovies.count
            ? Array(allMockMovies[startIndex ..< endIndex])
            : []

        let response = MoviesResponse(
            results: movies,
            page: page,
            totalPages: 5,
            totalResults: allMockMovies.count
        )

        return Just(response)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
