//
//  FavoritesDomainStateTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/liked-clean-architecture.
//

@testable import GitHubApp
import Testing

@MainActor
struct FavoritesDomainStateTests {
    @Test("Initial state has empty movies, not loading, and no error")
    func initialState() {
        // When
        let state = FavoritesDomainState.initial

        // Then
        #expect(state.favoriteMovies.isEmpty)
        #expect(!state.isLoading)
        #expect(state.error == nil)
    }

    @Test("States with same properties are equal")
    func stateEquality() {
        // Given
        let movie1 = Movie(id: 1, title: "Test Movie 1", overview: "Overview 1", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 2, title: "Test Movie 2", overview: "Overview 2", posterPath: "/test2.jpg")

        let state1 = FavoritesDomainState(favoriteMovies: [movie1], isLoading: false, error: nil)
        let state2 = FavoritesDomainState(favoriteMovies: [movie1], isLoading: false, error: nil)
        let state3 = FavoritesDomainState(favoriteMovies: [movie2], isLoading: false, error: nil)
        let state4 = FavoritesDomainState(favoriteMovies: [movie1], isLoading: true, error: nil)
        let state5 = FavoritesDomainState(favoriteMovies: [movie1], isLoading: false, error: "Error")

        // When & Then
        #expect(state1 == state2)
        #expect(state1 != state3)
        #expect(state1 != state4)
        #expect(state1 != state5)
    }

    @Test("State correctly stores multiple movies")
    func stateWithMovies() {
        // Given
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        // When
        let state = FavoritesDomainState(favoriteMovies: movies, isLoading: false, error: nil)

        // Then
        #expect(state.favoriteMovies.count == 2)
        #expect(state.favoriteMovies == movies)
        #expect(!state.isLoading)
        #expect(state.error == nil)
    }

    @Test("State correctly stores error message")
    func stateWithError() {
        // Given
        let errorMessage = "Failed to load favorite movies"

        // When
        let state = FavoritesDomainState(favoriteMovies: [], isLoading: false, error: errorMessage)

        // Then
        #expect(state.favoriteMovies.isEmpty)
        #expect(!state.isLoading)
        #expect(state.error == errorMessage)
    }

    @Test("Loading state has correct loading flag")
    func loadingState() {
        // When
        let state = FavoritesDomainState(favoriteMovies: [], isLoading: true, error: nil)

        // Then
        #expect(state.favoriteMovies.isEmpty)
        #expect(state.isLoading)
        #expect(state.error == nil)
    }
}
