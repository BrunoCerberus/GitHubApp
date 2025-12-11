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
        let state = FavoritesDomainState.initial

        #expect(state.favoriteMovies.isEmpty)
        #expect(!state.isLoading)
        #expect(state.error == nil)
    }

    @Test("State correctly stores multiple movies")
    func stateWithMovies() {
        let movies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]

        let state = FavoritesDomainState(favoriteMovies: movies, isLoading: false, error: nil)

        #expect(state.favoriteMovies.count == 2)
        #expect(state.favoriteMovies == movies)
        #expect(!state.isLoading)
        #expect(state.error == nil)
    }

    @Test("State correctly stores error message")
    func stateWithError() {
        let errorMessage = "Failed to load favorite movies"
        let state = FavoritesDomainState(favoriteMovies: [], isLoading: false, error: errorMessage)

        #expect(state.favoriteMovies.isEmpty)
        #expect(!state.isLoading)
        #expect(state.error == errorMessage)
    }

    @Test("Loading state has correct loading flag")
    func loadingState() {
        let state = FavoritesDomainState(favoriteMovies: [], isLoading: true, error: nil)

        #expect(state.favoriteMovies.isEmpty)
        #expect(state.isLoading)
        #expect(state.error == nil)
    }
}
