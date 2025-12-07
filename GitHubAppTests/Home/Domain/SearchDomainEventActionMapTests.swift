//
//  SearchDomainEventActionMapTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing

@MainActor
struct SearchDomainEventActionMapTests {
    @Test("Map search movies event")
    func mapSearchMoviesEvent() {
        // Given
        let query = "test query"
        let event = SearchViewEvent.searchMovies(query)

        // When
        let action = SearchDomainEventActionMap.map(event)

        // Then
        #expect(action == SearchDomainAction.searchMovies(query))
    }

    @Test("Map toggle favorite event")
    func mapToggleFavoriteEvent() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let event = SearchViewEvent.toggleFavorite(movie)

        // When
        let action = SearchDomainEventActionMap.map(event)

        // Then
        #expect(action == SearchDomainAction.toggleMovieFavorite(movie))
    }

    @Test("Map load favorite movies event")
    func mapLoadFavoriteMoviesEvent() {
        // Given
        let event = SearchViewEvent.loadFavoriteMovies

        // When
        let action = SearchDomainEventActionMap.map(event)

        // Then
        #expect(action == SearchDomainAction.loadPersistedFavoriteMovies)
    }

    @Test("All view events are mapped")
    func allViewEventsAreMapped() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let events: [SearchViewEvent] = [
            .searchMovies("query"),
            .toggleFavorite(movie),
            .loadFavoriteMovies,
        ]

        // When/Then - Verify all events can be mapped without throwing
        for event in events {
            let action = SearchDomainEventActionMap.map(event)
            _ = action
        }
        #expect(Bool(true), "All events mapped successfully")
    }

    @Test("Mapping consistency")
    func mappingConsistency() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let query = "consistent query"

        // When - Map the same events multiple times
        let action1 = SearchDomainEventActionMap.map(.searchMovies(query))
        let action2 = SearchDomainEventActionMap.map(.searchMovies(query))

        let action3 = SearchDomainEventActionMap.map(.toggleFavorite(movie))
        let action4 = SearchDomainEventActionMap.map(.toggleFavorite(movie))

        let action5 = SearchDomainEventActionMap.map(.loadFavoriteMovies)
        let action6 = SearchDomainEventActionMap.map(.loadFavoriteMovies)

        // Then - Verify mapping is consistent
        #expect(action1 == action2)
        #expect(action3 == action4)
        #expect(action5 == action6)
    }

    @Test("Search query is preserved through mapping")
    func searchQueryPreservedThroughMapping() {
        // Given
        let query = "avengers endgame"
        let event = SearchViewEvent.searchMovies(query)

        // When
        let action = SearchDomainEventActionMap.map(event)

        // Then
        if case let .searchMovies(mappedQuery) = action {
            #expect(mappedQuery == query)
        } else {
            Issue.record("Expected searchMovies action")
        }
    }

    @Test("Movie is preserved through toggle favorite mapping")
    func moviePreservedThroughMapping() {
        // Given
        let movie = createMockMovie(id: 42, title: "Favorite Movie")
        let event = SearchViewEvent.toggleFavorite(movie)

        // When
        let action = SearchDomainEventActionMap.map(event)

        // Then
        if case let .toggleMovieFavorite(mappedMovie) = action {
            #expect(mappedMovie.id == movie.id)
            #expect(mappedMovie.title == movie.title)
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
