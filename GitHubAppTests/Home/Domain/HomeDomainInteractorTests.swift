//
//  HomeDomainInteractorTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import XCTest

final class HomeDomainInteractorTests: XCTestCase {
    private var sut: HomeDomainInteractor!
    private var mockHomeService: MockHomeService!
    private var mockStorageService: MockStorageService!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockHomeService = MockHomeService()
        mockStorageService = MockStorageService()
        sut = HomeDomainInteractor(homeService: mockHomeService, storageService: mockStorageService)
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        // Ensure API key exists in case anything inadvertently touches HomeAPI
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        try? APIKeysProvider.removeMovieAPIKey()
        cancellables.removeAll()
        sut = nil
        mockHomeService = nil
        mockStorageService = nil
        super.tearDown()
    }

    func testInitialState() {
        // Given/When
        let initialState = sut.currentState

        // Then
        XCTAssertTrue(initialState.movies.isEmpty)
        XCTAssertTrue(initialState.likedMovies.isEmpty)
        XCTAssertFalse(initialState.isLoading)
        XCTAssertNil(initialState.error)
        XCTAssertNil(initialState.searchQuery)
    }

    func testFetchUpcomingMoviesSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "fetch movies success")

        // When
        sut.handleAction(.fetchUpcomingMovies)

        // Wait a moment for async operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Then - Check final state
            let finalState = self.sut.currentState
            XCTAssertFalse(finalState.isLoading)
            XCTAssertNil(finalState.error)
            XCTAssertFalse(finalState.movies.isEmpty)
            XCTAssertNil(finalState.searchQuery)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testSearchMoviesSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "search movies success")
        let query = "test query"

        // When
        sut.handleAction(.searchMovies(query))

        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Then
            let finalState = self.sut.currentState
            XCTAssertFalse(finalState.isLoading)
            XCTAssertNil(finalState.error)
            XCTAssertFalse(finalState.movies.isEmpty)
            XCTAssertEqual(finalState.searchQuery, query)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testSearchMoviesWithEmptyQueryFetchesUpcoming() {
        // Given
        let expectation = XCTestExpectation(description: "empty query fetches upcoming")

        // When
        sut.handleAction(.searchMovies(""))

        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Then
            let finalState = self.sut.currentState
            XCTAssertFalse(finalState.isLoading)
            XCTAssertNil(finalState.error)
            XCTAssertFalse(finalState.movies.isEmpty)
            XCTAssertNil(finalState.searchQuery) // Should be nil when fetching upcoming
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testToggleMovieLikeAddsToLikedMovies() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let expectation = XCTestExpectation(description: "toggle like adds movie")

        // First set up some movies in the current state
        sut.handleAction(.fetchUpcomingMovies)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // When - toggle like
            self.sut.handleAction(.toggleMovieLike(movie))

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // Then - Check if movie is in mock storage service
                Task {
                    do {
                        let likedMovies = try await self.mockStorageService.fetchLikedMovies()
                        XCTAssertTrue(likedMovies.contains { $0.id == movie.id })
                        expectation.fulfill()
                    } catch {
                        XCTFail("Failed to fetch liked movies: \(error)")
                        expectation.fulfill()
                    }
                }
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testToggleMovieLikeRemovesFromLikedMovies() {
        // Given
        let movie = createMockMovie(id: 1, title: "Test Movie")
        let expectation = XCTestExpectation(description: "toggle like removes movie")

        // First add the movie to test storage
        Task {
            try await self.mockStorageService.save([movie], context: StorageContext.likedMovies)

            // When - toggle to remove
            await MainActor.run {
                self.sut.handleAction(.toggleMovieLike(movie))
            }

            // Wait a bit for async operation
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

            // Then - Check if movie is removed from storage
            let likedMovies = try await self.mockStorageService.fetchLikedMovies()
            XCTAssertFalse(likedMovies.contains { $0.id == movie.id })
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testLoadPersistedLikedMovies() {
        // Given - Use the same movie IDs that MockHomeService returns (346698, 615656, 496450)
        let movie1 = createMockMovie(id: 346_698, title: "Barbie") // This matches MockHomeService
        let movie2 = createMockMovie(id: 615_656, title: "Meg 2") // This matches MockHomeService
        let likedMovies = [movie1, movie2]
        let expectation = XCTestExpectation(description: "load persisted liked movies")

        // Setup test storage with liked movies
        Task {
            try await self.mockStorageService.save(likedMovies, context: StorageContext.likedMovies)

            // First load some movies from MockHomeService
            await MainActor.run {
                self.sut.handleAction(.fetchUpcomingMovies)
            }

            // Wait for fetch to complete
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

            // When - load persisted liked movies
            await MainActor.run {
                self.sut.handleAction(.loadPersistedLikedMovies)
            }

            // Wait for load to complete
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

            // Then
            await MainActor.run {
                let finalState = self.sut.currentState
                // Should contain both movies since they're both in current movies and persisted liked movies
                XCTAssertTrue(finalState.likedMovies.contains { $0.id == movie1.id })
                XCTAssertTrue(finalState.likedMovies.contains { $0.id == movie2.id })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testFetchMoviesWithServiceError() {
        // Given
        let expectation = XCTestExpectation(description: "fetch movies with error")
        mockHomeService.shouldFail = true

        // When
        sut.handleAction(.fetchUpcomingMovies)

        // Wait for async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Then
            let finalState = self.sut.currentState
            XCTAssertFalse(finalState.isLoading)
            XCTAssertNotNil(finalState.error)
            XCTAssertTrue(finalState.movies.isEmpty)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
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
