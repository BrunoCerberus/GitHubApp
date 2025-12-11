//
//  HomeDomainEventActionMapTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

@MainActor
struct HomeDomainEventActionMapTests {
    @Test("Map fetch data event")
    func mapFetchDataEvent() {
        let event = HomeViewEvent.fetchData
        let action = HomeDomainEventActionMap.map(event)
        #expect(action == HomeDomainAction.fetchUpcomingMovies)
    }

    @Test("Map search movies event")
    func mapSearchMoviesEvent() {
        let query = "test query"
        let event = HomeViewEvent.searchMovies(query)
        let action = HomeDomainEventActionMap.map(event)
        #expect(action == HomeDomainAction.searchMovies(query))
    }

    @Test("Map toggle favorite event")
    func mapToggleFavoriteEvent() {
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let event = HomeViewEvent.toggleFavorite(movie)
        let action = HomeDomainEventActionMap.map(event)
        #expect(action == HomeDomainAction.toggleMovieFavorite(movie))
    }

    @Test("Map load favorite movies event")
    func mapLoadFavoriteMoviesEvent() {
        let event = HomeViewEvent.loadFavoriteMovies
        let action = HomeDomainEventActionMap.map(event)
        #expect(action == HomeDomainAction.loadPersistedFavoriteMovies)
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
