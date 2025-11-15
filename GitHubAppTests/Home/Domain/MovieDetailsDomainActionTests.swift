//
//  MovieDetailsDomainActionTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing

/**
 * Tests for MovieDetailsDomainAction enum.
 */
@MainActor
struct MovieDetailsDomainActionTests {
    private let testMovie = Movie(
        id: 123,
        title: "Test Movie",
        overview: "Test Overview",
        posterPath: nil
    )

    @Test("fetchMovieDetails action can be created")
    func fetchMovieDetailsActionCanBeCreated() {
        let action = MovieDetailsDomainAction.fetchMovieDetails
        #expect(action == .fetchMovieDetails)
    }

    @Test("toggleMovieFavorite action can be created with movie")
    func toggleMovieFavoritActionCanBeCreatedWithMovie() {
        let action = MovieDetailsDomainAction.toggleMovieFavorite(testMovie)
        #expect(action == .toggleMovieFavorite(testMovie))
    }

    @Test("actions are equatable")
    func actionsAreEquatable() {
        let action1 = MovieDetailsDomainAction.fetchMovieDetails
        let action2 = MovieDetailsDomainAction.fetchMovieDetails
        #expect(action1 == action2)
    }

    @Test("different actions are not equal")
    func differentActionsAreNotEqual() {
        let action1 = MovieDetailsDomainAction.fetchMovieDetails
        let action2 = MovieDetailsDomainAction.toggleMovieFavorite(testMovie)
        #expect(action1 != action2)
    }

    @Test("toggleMovieFavorite actions with different movies are not equal")
    func toggleMovieFavoritActionsWithDifferentMoviesAreNotEqual() {
        let movie1 = Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: nil)
        let movie2 = Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: nil)

        let action1 = MovieDetailsDomainAction.toggleMovieFavorite(movie1)
        let action2 = MovieDetailsDomainAction.toggleMovieFavorite(movie2)
        #expect(action1 != action2)
    }
}
