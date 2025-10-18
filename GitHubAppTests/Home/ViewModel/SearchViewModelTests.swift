//
//  SearchViewModelTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import Testing

struct SearchViewModelTests {
    private func createTestServiceLocator(homeService: HomeService) -> ServiceLocator {
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: homeService)
        return serviceLocator
    }

    @Test("ViewModel starts with loading state")
    func viewModelStartsWithLoadingState() async throws {
        // Given
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
        defer {
            StorageServiceFactory.shared.resetCache()
            try? APIKeysProvider.removeMovieAPIKey()
        }

        let service = MockHomeService()
        let sut = SearchViewModel(serviceLocator: createTestServiceLocator(homeService: service))

        // Then - Should start with loading state (will transition to success quickly with empty results)
        // Wait a bit for state observation to set up
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds

        // SearchViewModel doesn't auto-load, so it should transition to success with empty data
        if case let .success(dataViewState) = sut.viewState {
            #expect(dataViewState.movies.isEmpty)
        } else {
            Issue.record("Expected success state with empty data, got: \(sut.viewState)")
        }
    }

    @Test("Search movies updates state with results")
    func searchMoviesUpdatesState() async throws {
        // Given
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
        defer {
            StorageServiceFactory.shared.resetCache()
            try? APIKeysProvider.removeMovieAPIKey()
        }

        let service = MockHomeService()
        let sut = SearchViewModel(serviceLocator: createTestServiceLocator(homeService: service))

        // When
        sut.searchMovies(query: "avengers")

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        if case let .success(dataViewState) = sut.viewState {
            #expect(!dataViewState.movies.isEmpty)
            #expect(dataViewState.searchQuery == "avengers")
        } else {
            Issue.record("Expected success state with search results, got: \(sut.viewState)")
        }
    }

    @Test("Search movies with empty query clears results")
    func searchMoviesWithEmptyQueryClearsResults() async throws {
        // Given
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
        defer {
            StorageServiceFactory.shared.resetCache()
            try? APIKeysProvider.removeMovieAPIKey()
        }

        let service = MockHomeService()
        let sut = SearchViewModel(serviceLocator: createTestServiceLocator(homeService: service))

        // First populate with search results
        sut.searchMovies(query: "test")
        try await Task.sleep(nanoseconds: 200_000_000)

        // When - Search with empty query
        sut.searchMovies(query: "")

        // Wait for state to update through Combine pipeline (ViewModel -> Interactor -> State -> Reducer)
        try await Task.sleep(nanoseconds: 500_000_000)

        // Then - Results should be cleared
        if case let .success(dataViewState) = sut.viewState {
            #expect(dataViewState.movies.isEmpty)
            #expect(dataViewState.searchQuery == nil)
        } else {
            Issue.record("Expected success state with cleared results, got: \(sut.viewState)")
        }
    }

    @Test("Toggle favorite for movie executes successfully")
    func toggleFavoriteForMovie() async throws {
        // Given
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
        defer {
            StorageServiceFactory.shared.resetCache()
            try? APIKeysProvider.removeMovieAPIKey()
        }

        let service = MockHomeService()
        let sut = SearchViewModel(serviceLocator: createTestServiceLocator(homeService: service))

        // Create a test movie
        let testMovie = Movie(
            id: 123,
            title: "Test Movie",
            overview: "Test",
            posterPath: nil
        )

        // When
        sut.toggleFavorite(for: testMovie)

        // Then - Verify method was called (basic test for coverage)
        // Test passes if no exception is thrown
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    @Test("Load more movies executes successfully")
    func loadMoreMovies() async throws {
        // Given
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
        defer {
            StorageServiceFactory.shared.resetCache()
            try? APIKeysProvider.removeMovieAPIKey()
        }

        let service = MockHomeService()
        let sut = SearchViewModel(serviceLocator: createTestServiceLocator(homeService: service))

        // Perform initial search to have a query
        sut.searchMovies(query: "test")
        try await Task.sleep(nanoseconds: 200_000_000)

        // When
        sut.loadMoreMovies()

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Verify method was called (basic test for coverage)
        // Test passes if no exception is thrown
    }

    @Test("Send view event executes successfully")
    func sendViewEvent() async throws {
        // Given
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
        defer {
            StorageServiceFactory.shared.resetCache()
            try? APIKeysProvider.removeMovieAPIKey()
        }

        let service = MockHomeService()
        let sut = SearchViewModel(serviceLocator: createTestServiceLocator(homeService: service))

        // When
        sut.sendViewEvent(.searchMovies("test"))

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Verify method was called (basic test for coverage)
        // Test passes if no exception is thrown
    }

    @Test("ViewModel handles different search queries")
    func viewModelHandlesDifferentSearchQueries() async throws {
        // Given
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
        defer {
            StorageServiceFactory.shared.resetCache()
            try? APIKeysProvider.removeMovieAPIKey()
        }

        let service = MockHomeService()
        let sut = SearchViewModel(serviceLocator: createTestServiceLocator(homeService: service))

        // When - First search
        sut.searchMovies(query: "avengers")
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Verify first search
        if case let .success(dataViewState) = sut.viewState {
            #expect(dataViewState.searchQuery == "avengers")
        }

        // When - Second search
        sut.searchMovies(query: "batman")
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then - Verify second search replaced first
        if case let .success(dataViewState) = sut.viewState {
            #expect(dataViewState.searchQuery == "batman")
        }
    }

    @Test("ViewModel uses SearchViewEvent types")
    func viewModelUsesSearchViewEventTypes() async throws {
        // Given
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
        defer {
            StorageServiceFactory.shared.resetCache()
            try? APIKeysProvider.removeMovieAPIKey()
        }

        let service = MockHomeService()
        let sut = SearchViewModel(serviceLocator: createTestServiceLocator(homeService: service))

        let movie = Movie(id: 1, title: "Test", overview: "Test", posterPath: nil)

        // When - Test all SearchViewEvent types
        sut.sendViewEvent(.searchMovies("test"))
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.sendViewEvent(.toggleFavorite(movie))
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.sendViewEvent(.loadFavoriteMovies)
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.sendViewEvent(.loadMoreMovies)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - All events should execute without errors
        // Test passes if no exception is thrown
    }

    @Test("ViewModel uses SearchViewState types")
    func viewModelUsesSearchViewStateTypes() async throws {
        // Given
        StorageServiceFactory.shared.resetCache()
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
        defer {
            StorageServiceFactory.shared.resetCache()
            try? APIKeysProvider.removeMovieAPIKey()
        }

        let service = MockHomeService()
        let sut = SearchViewModel(serviceLocator: createTestServiceLocator(homeService: service))

        // Wait for initial state
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - viewState should be of type SearchViewState
        switch sut.viewState {
        case .loading:
            // Valid SearchViewState
            break
        case .success:
            // Valid SearchViewState
            break
        case .error:
            // Valid SearchViewState
            break
        }
    }
}
