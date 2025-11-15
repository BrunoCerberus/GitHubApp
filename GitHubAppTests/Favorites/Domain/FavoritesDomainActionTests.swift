//
//  FavoritesDomainActionTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/liked-clean-architecture.
//

@testable import GitHubApp
import Testing

@MainActor
struct FavoritesDomainActionTests {
    @Test("Favorites domain action equality comparison works correctly")
    func favoritesDomainActionEquality() {
        // Given
        let movie1 = Movie(id: 1, title: "Test Movie 1", overview: "Overview 1", posterPath: "/test1.jpg")
        let movie2 = Movie(id: 2, title: "Test Movie 2", overview: "Overview 2", posterPath: "/test2.jpg")

        // When & Then - Test equality
        #expect(FavoritesDomainAction.loadFavoriteMovies == FavoritesDomainAction.loadFavoriteMovies)
        #expect(FavoritesDomainAction.clearAllFavoriteMovies == FavoritesDomainAction.clearAllFavoriteMovies)
        #expect(FavoritesDomainAction.refreshFavoriteMovies == FavoritesDomainAction.refreshFavoriteMovies)
        #expect(FavoritesDomainAction.toggleMovieFavorite(movie1) == FavoritesDomainAction.toggleMovieFavorite(movie1))

        // Test inequality
        #expect(FavoritesDomainAction.loadFavoriteMovies != FavoritesDomainAction.clearAllFavoriteMovies)
        #expect(FavoritesDomainAction.toggleMovieFavorite(movie1) != FavoritesDomainAction.toggleMovieFavorite(movie2))
    }

    @Test("Toggle movie favorite action contains correct movie")
    func toggleMovieLikeAction() {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: "/test.jpg")

        // When
        let action = FavoritesDomainAction.toggleMovieFavorite(movie)

        // Then
        if case let .toggleMovieFavorite(actionMovie) = action {
            #expect(actionMovie == movie)
        } else {
            Issue.record("Expected toggleMovieFavorite action")
        }
    }
}
