//
//  SearchDomainActionTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

struct SearchDomainActionTests {
    @Test("Domain actions with same cases and parameters are equal")
    func domainActionEquality() {
        // Given
        let action1 = SearchDomainAction.searchMovies("test")
        let action2 = SearchDomainAction.searchMovies("test")
        let action3 = SearchDomainAction.searchMovies("different")

        let movie = createMockMovie(id: 1, title: "Test Movie")
        let action4 = SearchDomainAction.toggleMovieFavorite(movie)
        let action5 = SearchDomainAction.toggleMovieFavorite(movie)

        let action6 = SearchDomainAction.loadPersistedFavoriteMovies
        let action7 = SearchDomainAction.loadPersistedFavoriteMovies

        // Then
        #expect(action1 == action2)
        #expect(action4 == action5)
        #expect(action6 == action7)

        #expect(action1 != action3)
        #expect(action1 != action4)
        #expect(action1 != action6)
    }

    @Test("All domain action cases can be instantiated")
    func domainActionCases() {
        // Given/When/Then
        let searchAction = SearchDomainAction.searchMovies("query")
        let toggleAction = SearchDomainAction.toggleMovieFavorite(createMockMovie(id: 1, title: "Test"))
        let loadAction = SearchDomainAction.loadPersistedFavoriteMovies

        // Verify that all cases can be instantiated
        #expect(searchAction != nil)
        #expect(toggleAction != nil)
        #expect(loadAction != nil)
    }

    @Test("Search action preserves query string")
    func searchActionPreservesQuery() {
        // Given
        let query1 = "test query"
        let query2 = "another query"

        // When
        let action1 = SearchDomainAction.searchMovies(query1)
        let action2 = SearchDomainAction.searchMovies(query2)

        // Then
        if case let .searchMovies(q1) = action1 {
            #expect(q1 == query1)
        } else {
            Issue.record("Expected searchMovies action")
        }

        if case let .searchMovies(q2) = action2 {
            #expect(q2 == query2)
        } else {
            Issue.record("Expected searchMovies action")
        }
    }

    @Test("Toggle favorite action preserves movie")
    func toggleFavoriteActionPreservesMovie() {
        // Given
        let movie = createMockMovie(id: 123, title: "Favorite Movie")

        // When
        let action = SearchDomainAction.toggleMovieFavorite(movie)

        // Then
        if case let .toggleMovieFavorite(m) = action {
            #expect(m.id == movie.id)
            #expect(m.title == movie.title)
        } else {
            Issue.record("Expected toggleMovieFavorite action")
        }
    }

    // MARK: - Helper Methods

    private func createMockMovie(id: Int, title: String) -> Movie {
        Movie(
            id: id,
            title: title,
            overview: "Test overview",
            posterPath: "/test.jpg"
        )
    }
}
