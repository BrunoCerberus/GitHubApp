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
        // Given
        let event = HomeViewEvent.fetchData

        // When
        let action = HomeDomainEventActionMap.map(event)

        // Then
        #expect(action == HomeDomainAction.fetchUpcomingMovies)
    }

    @Test("Map search movies event")
    func mapSearchMoviesEvent() {
        // Given
        let query = "test query"
        let event = HomeViewEvent.searchMovies(query)

        // When
        let action = HomeDomainEventActionMap.map(event)

        // Then
        #expect(action == HomeDomainAction.searchMovies(query))
    }

    @Test("Map toggle favorite event")
    func mapToggleFavoriteEvent() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let event = HomeViewEvent.toggleFavorite(movie)

        // When
        let action = HomeDomainEventActionMap.map(event)

        // Then
        #expect(action == HomeDomainAction.toggleMovieFavorite(movie))
    }

    @Test("Map load favorite movies event")
    func mapLoadFavoriteMoviesEvent() {
        // Given
        let event = HomeViewEvent.loadFavoriteMovies

        // When
        let action = HomeDomainEventActionMap.map(event)

        // Then
        #expect(action == HomeDomainAction.loadPersistedFavoriteMovies)
    }

    @Test("All view events are mapped")
    func allViewEventsAreMapped() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let events: [HomeViewEvent] = [
            .fetchData,
            .searchMovies("query"),
            .toggleFavorite(movie),
            .loadFavoriteMovies,
        ]

        // When/Then - Verify all events can be mapped without throwing
        for event in events {
            let action = HomeDomainEventActionMap.map(event)
            _ = action // Verify action was created
        }
        #expect(Bool(true))
    }

    @Test("Mapping consistency")
    func mappingConsistency() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let query = "consistent query"

        // When - Map the same events multiple times
        let action1 = HomeDomainEventActionMap.map(.fetchData)
        let action2 = HomeDomainEventActionMap.map(.fetchData)

        let action3 = HomeDomainEventActionMap.map(.searchMovies(query))
        let action4 = HomeDomainEventActionMap.map(.searchMovies(query))

        let action5 = HomeDomainEventActionMap.map(.toggleFavorite(movie))
        let action6 = HomeDomainEventActionMap.map(.toggleFavorite(movie))

        let action7 = HomeDomainEventActionMap.map(.loadFavoriteMovies)
        let action8 = HomeDomainEventActionMap.map(.loadFavoriteMovies)

        // Then - Verify mapping is consistent
        #expect(action1 == action2)
        #expect(action3 == action4)
        #expect(action5 == action6)
        #expect(action7 == action8)
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
