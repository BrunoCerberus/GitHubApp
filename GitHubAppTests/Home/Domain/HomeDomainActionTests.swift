//
//  HomeDomainActionTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

struct HomeDomainActionTests {
    @Test("Domain actions with same cases and parameters are equal")
    func domainActionEquality() {
        // Given
        let action1 = HomeDomainAction.fetchUpcomingMovies
        let action2 = HomeDomainAction.fetchUpcomingMovies
        let action3 = HomeDomainAction.searchMovies("test")
        let action4 = HomeDomainAction.searchMovies("test")
        let action5 = HomeDomainAction.searchMovies("different")

        let movie = createMockMovie(id: 1, title: "Test Movie")
        let action6 = HomeDomainAction.toggleMovieFavorite(movie)
        let action7 = HomeDomainAction.toggleMovieFavorite(movie)

        let action8 = HomeDomainAction.loadPersistedFavoriteMovies
        let action9 = HomeDomainAction.loadPersistedFavoriteMovies

        // Then
        #expect(action1 == action2)
        #expect(action3 == action4)
        #expect(action6 == action7)
        #expect(action8 == action9)

        #expect(action1 != action3)
        #expect(action3 != action5)
        #expect(action1 != action6)
        #expect(action1 != action8)
    }

    @Test("All domain action cases can be instantiated")
    func domainActionCases() {
        // Given/When/Then
        let fetchAction = HomeDomainAction.fetchUpcomingMovies
        let searchAction = HomeDomainAction.searchMovies("query")
        let toggleAction = HomeDomainAction.toggleMovieFavorite(createMockMovie(id: 1, title: "Test"))
        let loadAction = HomeDomainAction.loadPersistedFavoriteMovies

        // Verify that all cases can be instantiated
        #expect(fetchAction != nil)
        #expect(searchAction != nil)
        #expect(toggleAction != nil)
        #expect(loadAction != nil)
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
