//
//  MovieDetailsDomainStateTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing

/// Tests for MovieDetailsDomainState struct.
@MainActor
struct MovieDetailsDomainStateTests {
    private let testMovie = Movie(
        id: 456,
        title: "State Test Movie",
        overview: "Test Overview",
        posterPath: "test.jpg"
    )

    private let testCredit = MovieCastMember(
        id: 1,
        name: "Actor Name",
        character: "Character Name"
    )

    private let testReview = MovieReview(
        id: "review1",
        author: "Test Author",
        content: "Test review content"
    )

    @Test("initial state creates proper default values")
    func initialStateCreatesProperDefaultValues() {
        let state = MovieDetailsDomainState.initial(for: testMovie)

        #expect(state.movie.id == testMovie.id)
        #expect(state.movie.title == testMovie.title)
        #expect(state.credits.isEmpty)
        #expect(state.reviews.isEmpty)
        #expect(state.favoriteMovies.isEmpty)
        #expect(state.isLoading == true)
        #expect(state.error == nil)
    }

    @Test("state can be created with custom values")
    func stateCanBeCreatedWithCustomValues() {
        let credits = [testCredit]
        let reviews = [testReview]
        let favorites = [testMovie]

        let state = MovieDetailsDomainState(
            movie: testMovie,
            credits: credits,
            reviews: reviews,
            favoriteMovies: favorites,
            isLoading: false,
            error: nil
        )

        #expect(state.credits == credits)
        #expect(state.reviews == reviews)
        #expect(state.favoriteMovies == favorites)
        #expect(state.isLoading == false)
    }

    @Test("copy method creates new state with updated values")
    func copyMethodCreatesNewStateWithUpdatedValues() {
        let initialState = MovieDetailsDomainState.initial(for: testMovie)
        let credits = [testCredit]
        let reviews = [testReview]

        let updatedState = initialState.copy(
            credits: credits,
            reviews: reviews,
            isLoading: false,
            error: nil
        )

        #expect(updatedState.credits == credits)
        #expect(updatedState.reviews == reviews)
        #expect(updatedState.isLoading == false)
        #expect(updatedState.error == nil)
        #expect(updatedState.movie == initialState.movie)
    }

    @Test("copy method preserves unspecified values")
    func copyMethodPreservesUnspecifiedValues() {
        let credits = [testCredit]
        let initialState = MovieDetailsDomainState(
            movie: testMovie,
            credits: credits,
            reviews: [testReview],
            favoriteMovies: [testMovie],
            isLoading: true,
            error: "Some error"
        )

        let updatedState = initialState.copy(isLoading: false)

        #expect(updatedState.isLoading == false)
        #expect(updatedState.credits == credits)
        #expect(updatedState.reviews == [testReview])
        #expect(updatedState.favoriteMovies == [testMovie])
        #expect(updatedState.error == "Some error")
    }
}
