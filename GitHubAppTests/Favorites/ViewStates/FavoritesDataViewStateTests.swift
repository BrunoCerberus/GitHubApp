//
//  FavoritesDataViewStateTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing

@MainActor
struct FavoritesDataViewStateTests {
    // MARK: - Initialization Tests

    @Test("FavoritesDataViewState initializes with empty movies")
    func initializeWithEmptyMovies() {
        // When
        let state = FavoritesDataViewState(
            title: "My Favorites",
            favoriteMovies: []
        )

        // Then
        #expect(state.title == "My Favorites")
        #expect(state.favoriteMovies.isEmpty)
        #expect(state.isEmpty == true)
        #expect(state.moviesCount == 0)
    }

    @Test("FavoritesDataViewState initializes with movies")
    func initializeWithMovies() {
        // Given
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/path2.jpg"),
            Movie(id: 3, title: "Movie 3", overview: "Overview 3", posterPath: "/path3.jpg"),
        ]

        // When
        let state = FavoritesDataViewState(
            title: "My Favorites",
            favoriteMovies: movies
        )

        // Then
        #expect(state.title == "My Favorites")
        #expect(state.favoriteMovies.count == 3)
        #expect(state.isEmpty == false)
        #expect(state.moviesCount == 3)
    }

    @Test("FavoritesDataViewState isEmpty computes correctly")
    func isEmptyComputesCorrectly() {
        // When - Empty state
        let emptyState = FavoritesDataViewState(title: "Empty", favoriteMovies: [])

        // Then
        #expect(emptyState.isEmpty == true)

        // When - Non-empty state
        let nonEmptyState = FavoritesDataViewState(
            title: "Not Empty",
            favoriteMovies: [
                Movie(id: 1, title: "Movie", overview: "Overview", posterPath: "/path.jpg"),
            ]
        )

        // Then
        #expect(nonEmptyState.isEmpty == false)
    }

    @Test("FavoritesDataViewState moviesCount computes correctly")
    func moviesCountComputesCorrectly() {
        // When - Empty state
        let emptyState = FavoritesDataViewState(title: "Empty", favoriteMovies: [])

        // Then
        #expect(emptyState.moviesCount == 0)

        // When - One movie
        let oneMovieState = FavoritesDataViewState(
            title: "One",
            favoriteMovies: [Movie(id: 1, title: "Movie", overview: "Overview", posterPath: "/path.jpg")]
        )

        // Then
        #expect(oneMovieState.moviesCount == 1)

        // When - Multiple movies
        let multiMovieState = FavoritesDataViewState(
            title: "Multiple",
            favoriteMovies: [
                Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path1.jpg"),
                Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/path2.jpg"),
                Movie(id: 3, title: "Movie 3", overview: "Overview 3", posterPath: "/path3.jpg"),
                Movie(id: 4, title: "Movie 4", overview: "Overview 4", posterPath: "/path4.jpg"),
            ]
        )

        // Then
        #expect(multiMovieState.moviesCount == 4)
    }

    // MARK: - Equality Tests

    @Test("FavoritesDataViewState empty states are equal")
    func emptyStatesAreEqual() {
        // When
        let state1 = FavoritesDataViewState(title: "Favorites", favoriteMovies: [])
        let state2 = FavoritesDataViewState(title: "Favorites", favoriteMovies: [])

        // Then
        #expect(state1 == state2)
    }

    @Test("FavoritesDataViewState with same movies are equal")
    func statesWithSameMoviesAreEqual() {
        // Given
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/path2.jpg"),
        ]

        // When
        let state1 = FavoritesDataViewState(title: "Favorites", favoriteMovies: movies)
        let state2 = FavoritesDataViewState(title: "Favorites", favoriteMovies: movies)

        // Then
        #expect(state1 == state2)
    }

    @Test("FavoritesDataViewState with different titles not equal")
    func statesWithDifferentTitlesNotEqual() {
        // Given
        let movies = [Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path.jpg")]

        // When
        let state1 = FavoritesDataViewState(title: "Favorites", favoriteMovies: movies)
        let state2 = FavoritesDataViewState(title: "My Likes", favoriteMovies: movies)

        // Then
        #expect(state1 != state2)
    }

    @Test("FavoritesDataViewState with different movie counts not equal")
    func statesWithDifferentMovieCountsNotEqual() {
        // When
        let state1 = FavoritesDataViewState(title: "Favorites", favoriteMovies: [])
        let state2 = FavoritesDataViewState(
            title: "Favorites",
            favoriteMovies: [Movie(id: 1, title: "Movie", overview: "Overview", posterPath: "/path.jpg")]
        )

        // Then
        #expect(state1 != state2)
    }

    @Test("FavoritesDataViewState with different movies not equal")
    func statesWithDifferentMoviesNotEqual() {
        // Given
        let movies1 = [Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path1.jpg")]
        let movies2 = [Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/path2.jpg")]

        // When
        let state1 = FavoritesDataViewState(title: "Favorites", favoriteMovies: movies1)
        let state2 = FavoritesDataViewState(title: "Favorites", favoriteMovies: movies2)

        // Then
        #expect(state1 != state2)
    }

    // MARK: - Mutation Tests

    @Test("FavoritesDataViewState title can be mutated")
    func titleCanBeMutated() {
        // Given
        var state = FavoritesDataViewState(title: "Original", favoriteMovies: [])

        // When
        state.title = "Updated"

        // Then
        #expect(state.title == "Updated")
    }

    @Test("FavoritesDataViewState movies can be mutated")
    func moviesCanBeMutated() {
        // Given
        var state = FavoritesDataViewState(title: "Favorites", favoriteMovies: [])

        // When
        let newMovies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/path2.jpg"),
        ]
        state.favoriteMovies = newMovies

        // Then
        #expect(state.moviesCount == 2)
        #expect(state.isEmpty == false)
    }

    @Test("FavoritesDataViewState appends movie to existing list")
    func appendsMovieToExistingList() {
        // Given
        var state = FavoritesDataViewState(
            title: "Favorites",
            favoriteMovies: [
                Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path1.jpg"),
            ]
        )

        // When
        let newMovie = Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/path2.jpg")
        state.favoriteMovies.append(newMovie)

        // Then
        #expect(state.moviesCount == 2)
        #expect(state.isEmpty == false)
    }

    @Test("FavoritesDataViewState removes movie from list")
    func removesMovieFromList() {
        // Given
        var state = FavoritesDataViewState(
            title: "Favorites",
            favoriteMovies: [
                Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path1.jpg"),
                Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/path2.jpg"),
            ]
        )

        // When
        state.favoriteMovies.removeAll { $0.id == 1 }

        // Then
        #expect(state.moviesCount == 1)
        #expect(state.isEmpty == false)
        #expect(state.favoriteMovies.first?.id == 2)
    }

    @Test("FavoritesDataViewState clears all movies")
    func clearsAllMovies() {
        // Given
        var state = FavoritesDataViewState(
            title: "Favorites",
            favoriteMovies: [
                Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/path1.jpg"),
                Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/path2.jpg"),
                Movie(id: 3, title: "Movie 3", overview: "Overview 3", posterPath: "/path3.jpg"),
            ]
        )

        // When
        state.favoriteMovies.removeAll()

        // Then
        #expect(state.moviesCount == 0)
        #expect(state.isEmpty == true)
    }

    @Test("FavoritesDataViewState large movie list")
    func largeMovieList() {
        // Given
        let largeMovieList = (1 ... 100).map { i in
            Movie(id: i, title: "Movie \(i)", overview: "Overview \(i)", posterPath: "/path\(i).jpg")
        }

        // When
        let state = FavoritesDataViewState(title: "100 Favorites", favoriteMovies: largeMovieList)

        // Then
        #expect(state.moviesCount == 100)
        #expect(state.isEmpty == false)
        #expect(state.favoriteMovies.count == 100)
    }
}
