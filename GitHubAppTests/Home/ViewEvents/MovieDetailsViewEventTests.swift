//
//  MovieDetailsViewEventTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing

/**
 * Tests for MovieDetailsViewEvent enum.
 */
struct MovieDetailsViewEventTests {
    private let testMovie = Movie(
        id: 555,
        title: "Event Test Movie",
        overview: "Test Overview",
        posterPath: nil
    )

    @Test("fetchData event can be created")
    func fetchDataEventCanBeCreated() {
        let event = MovieDetailsViewEvent.fetchData
        #expect(event == .fetchData)
    }

    @Test("toggleFavorite event can be created with movie")
    func toggleFavoriteEventCanBeCreatedWithMovie() {
        let event = MovieDetailsViewEvent.toggleFavorite(testMovie)
        #expect(event == .toggleFavorite(testMovie))
    }

    @Test("events are equatable")
    func eventsAreEquatable() {
        let event1 = MovieDetailsViewEvent.fetchData
        let event2 = MovieDetailsViewEvent.fetchData
        #expect(event1 == event2)
    }

    @Test("different events are not equal")
    func differentEventsAreNotEqual() {
        let event1 = MovieDetailsViewEvent.fetchData
        let event2 = MovieDetailsViewEvent.toggleFavorite(testMovie)
        #expect(event1 != event2)
    }

    @Test("toggleFavorite events with different movies are not equal")
    func toggleFavoriteEventsWithDifferentMoviesAreNotEqual() {
        let movie1 = Movie(id: 1, title: "Movie 1", overview: "Overview", posterPath: nil)
        let movie2 = Movie(id: 2, title: "Movie 2", overview: "Overview", posterPath: nil)

        let event1 = MovieDetailsViewEvent.toggleFavorite(movie1)
        let event2 = MovieDetailsViewEvent.toggleFavorite(movie2)
        #expect(event1 != event2)
    }

    @Test("toggleFavorite events preserve movie data")
    func toggleFavoriteEventsPreserveMovieData() {
        let movieWithData = Movie(
            id: 9999,
            title: "Complex Movie",
            overview: "A complex movie with lots of data",
            posterPath: "complex.jpg"
        )

        let event = MovieDetailsViewEvent.toggleFavorite(movieWithData)

        if case let .toggleFavorite(movie) = event {
            #expect(movie.id == movieWithData.id)
            #expect(movie.title == movieWithData.title)
            #expect(movie.overview == movieWithData.overview)
            #expect(movie.posterPath == movieWithData.posterPath)
        } else {
            #expect(Bool(false), "Expected toggleFavorite event")
        }
    }
}
