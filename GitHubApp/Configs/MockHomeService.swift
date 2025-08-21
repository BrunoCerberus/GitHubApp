//
//  MockHomeService.swift
//  GitHubApp
//
//  Created by bruno on 05/08/25.
//

import Combine
import Foundation

/**
 * Mock implementation of HomeService for testing.
 *
 * This service provides mock data when running in test environment
 * to avoid real network requests during testing.
 */
struct MockHomeService: HomeService {
    private let mockMoviesResponse = MoviesResponse(results: [
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
    ])

    private let mockMovieCreditsResponse = MovieCreditsResponse(cast: [
        MovieCastMember(
            id: 234_352,
            name: "Margot Robbie",
            character: "Barbie"
        ),
        MovieCastMember(
            id: 30614,
            name: "Ryan Gosling",
            character: "Ken"
        ),
        MovieCastMember(
            id: 59174,
            name: "America Ferrera",
            character: "Gloria"
        ),
    ])

    private let mockMovieReviewsResponse = MovieReviewsResponse(results: [
        MovieReview(
            id: "64bb00dc357c00021de27485",
            author: "Chris Sawin",
            content: "Barbie_ reels you in with its silly humor and fantastical ideas. " +
                "The war of Kens during the last half hour of the film is an all-timer because " +
                "a battle full of handsome maneuvers, like showing off their naked chest and manly " +
                "noogies, turns into a full on dance off between Ryan Gosling and Simu Liu.\r\n\r\nBut " +
                "the second half of the film leaves a thought-provoking message in your brain regarding " +
                "both men and women. The Kens gaining respect little by little mirrors how women " +
                "eventually earned their rights to be respected individuals — after being considered " +
                "as only being useful in the kitchen or for making babies — except with the gender roles " +
                "reversed and nude blobs instead of genitalia.\r\n\r\n**Full review:** https://bit.ly/beachoff"
        ),
        MovieReview(
            id: "64be2c5ce9da6900eceae0cc",
            author: "MovieGuys",
            content: "I took my daughter along to see this, naively expecting light, family friendly " +
                "fun and well, its not. Not even a little.\r\n\r\nThe kindest way I can describe this " +
                "monstrosity is mean spirited, misandry. The message is simply not one I want my child " +
                "taking on board.\r\n\r\nMy daughter wanted to leave before I'd even suggested it, so we " +
                "did and had a better time doing something else together.\r\n\r\nIn summary, in my opinion, " +
                "nasty and spiteful. Hollywood deserves its declining viewership, if this is all it has left to offer."
        ),
        MovieReview(
            id: "64bea9e3c51acd00af638e02",
            author: "Manuel São Bento",
            content: "Barbie is hilariously meta, containing spectacularly funny musical " +
                "numbers, and an efficient tonal balance between over-the-top comedy and rich, " +
                "thought-provoking social commentary. Inevitable awards are on the way for the brightly " +
                "colored production design, costumes, and makeup.\r\n\r\nGreta Gerwig and Noah Baumbach's " +
                "narrative unapologetically tackles quite serious topics, from sociopolitical matters like " +
                "patriarchy and sexual harassment to questions about existential crises, personal identity, " +
                "self-love, and, of course, the roles of women and men in today's society.\r\n\r\nMargot Robbie " +
                "was destined to play Barbie just as Ryan Gosling was born with Kenergy in his veins. Absolutely " +
                "fantastic, as are the rest of the Barbies and Kens.\r\n\r\nA must-see in a packed " +
                "theater!\"\r\n\r\nRating: A-"
        ),
    ])

    func fetchMovies() -> AnyPublisher<MoviesResponse, Error> {
        Just(mockMoviesResponse)
            .setFailureType(to: Error.self)
            .receive(on: RunLoop.current)
            .eraseToAnyPublisher()
    }

    func searchMovies(with _: String) -> AnyPublisher<MoviesResponse, Error> {
        Just(mockMoviesResponse)
            .setFailureType(to: Error.self)
            .receive(on: RunLoop.current)
            .eraseToAnyPublisher()
    }

    func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
        Just(mockMovieCreditsResponse)
            .setFailureType(to: Error.self)
            .receive(on: RunLoop.current)
            .eraseToAnyPublisher()
    }

    func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
        Just(mockMovieReviewsResponse)
            .setFailureType(to: Error.self)
            .receive(on: RunLoop.current)
            .eraseToAnyPublisher()
    }
}
