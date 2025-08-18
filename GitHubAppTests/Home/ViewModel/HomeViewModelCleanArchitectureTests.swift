//
//  HomeViewModelCleanArchitectureTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import XCTest

final class HomeViewModelCleanArchitectureTests: XCTestCase {
    private var sut: HomeViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        // Ensure API key exists in case anything inadvertently touches HomeAPI
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")

        mockService = MockHomeService()
        sut = HomeViewModel(service: mockService)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        try? APIKeysProvider.removeMovieAPIKey()
        cancellables.removeAll()
        sut = nil
        mockService = nil
        super.tearDown()
    }

    func testInitialViewState() {
        // Given - ViewModel initializes and we manually trigger fetch to ensure loading
        let expectation = XCTestExpectation(description: "initial state")
        var receivedStates: [HomeViewState] = []

        sut.$viewState
            .sink { viewState in
                receivedStates.append(viewState)
                if receivedStates.count >= 2, !self.isLoadingState(viewState) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When - Manually trigger fetch to ensure reliable loading
        sut.fetchData()

        // Then
        wait(for: [expectation], timeout: 3.0)

        XCTAssertGreaterThanOrEqual(receivedStates.count, 2)

        // Should eventually reach success state with movies
        let finalState = receivedStates.last!
        if case let .success(dataViewState) = finalState {
            XCTAssertFalse(dataViewState.movies.isEmpty)
            XCTAssertTrue(dataViewState.likedMovies.isEmpty)
            XCTAssertEqual(dataViewState.title, "Upcoming Movies")
            XCTAssertNil(dataViewState.searchQuery)
        } else {
            XCTFail("Expected success state but got: \(finalState)")
        }
    }

    func testFetchDataUpdateViewState() {
        // Given
        let expectation = XCTestExpectation(description: "fetch data")
        var receivedStates: [HomeViewState] = []

        // Wait for initial state to stabilize
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.sut.$viewState
                .sink { viewState in
                    receivedStates.append(viewState)
                    if receivedStates.count >= 2, !self.isLoadingState(viewState) {
                        expectation.fulfill()
                    }
                }
                .store(in: &self.cancellables)

            // When
            self.sut.fetchData()
        }

        // Then
        wait(for: [expectation], timeout: 2.0)

        XCTAssertGreaterThanOrEqual(receivedStates.count, 2)

        // Should have loading state followed by success
        XCTAssertTrue(receivedStates.contains { self.isLoadingState($0) })

        let finalState = receivedStates.last!
        if case let .success(dataViewState) = finalState {
            XCTAssertFalse(dataViewState.movies.isEmpty)
            XCTAssertEqual(dataViewState.title, "Upcoming Movies")
        } else {
            XCTFail("Expected success state but got: \(finalState)")
        }
    }

    func testSearchMoviesUpdateViewState() {
        // Given
        let expectation = XCTestExpectation(description: "search movies")
        let query = "test search"
        var receivedStates: [HomeViewState] = []

        // Wait for initial state to stabilize
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.sut.$viewState
                .sink { viewState in
                    receivedStates.append(viewState)
                    if case let .success(dataViewState) = viewState,
                       dataViewState.searchQuery == query
                    {
                        expectation.fulfill()
                    }
                }
                .store(in: &self.cancellables)

            // When
            self.sut.searchMovies(query: query)
        }

        // Then
        wait(for: [expectation], timeout: 2.0)

        let finalState = receivedStates.last!
        if case let .success(dataViewState) = finalState {
            XCTAssertFalse(dataViewState.movies.isEmpty)
            XCTAssertEqual(dataViewState.title, "Search Results")
            XCTAssertEqual(dataViewState.searchQuery, query)
        } else {
            XCTFail("Expected success state but got: \(finalState)")
        }
    }

    func testToggleLikeUpdateViewState() {
        // Given - Use movie ID that matches MockHomeService
        let expectation = XCTestExpectation(description: "toggle like")
        let movie = createMockMovie(id: 346_698, title: "Barbie") // This matches MockHomeService

        // Wait for initial state to stabilize
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // When
            self.sut.toggleLike(for: movie)

            // Give it time to process
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
        }

        // Then
        wait(for: [expectation], timeout: 2.0)

        // Check that movie is marked as liked
        XCTAssertTrue(sut.isLiked(movie: movie))

        // Check persistence
        let persistedData = UserDefaults.standard.data(forKey: "likedMoviesKey")
        XCTAssertNotNil(persistedData)

        if let data = persistedData,
           let persistedMovies = try? JSONDecoder().decode([Movie].self, from: data)
        {
            XCTAssertTrue(persistedMovies.contains { $0.id == movie.id })
        }
    }

    func testMoviesPropertyFromViewState() {
        // Given
        let expectation = XCTestExpectation(description: "movies property")

        sut.$viewState
            .sink { viewState in
                if case .success = viewState {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When - Trigger fetch to ensure data is loaded
        sut.fetchData()

        // Then
        wait(for: [expectation], timeout: 3.0)

        // Movies should be accessible through computed property
        XCTAssertFalse(sut.movies.isEmpty)
    }

    func testLikedMoviesPropertyFromViewState() {
        // Given
        let expectation = XCTestExpectation(description: "liked movies property")

        sut.$viewState
            .sink { viewState in
                if case .success = viewState {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Then
        wait(for: [expectation], timeout: 2.0)

        // Initially no liked movies
        XCTAssertTrue(sut.likedMovies.isEmpty)
    }

    func testErrorPropertyFromViewState() {
        // Given
        mockService.shouldFail = true
        let expectation = XCTestExpectation(description: "error state")

        sut.$viewState
            .sink { viewState in
                if case .error = viewState {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.fetchData()

        // Then
        wait(for: [expectation], timeout: 2.0)

        // Error should be accessible through computed property
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error, "Mock fetch error")
    }

    func testIsLikedMethodWithDifferentViewStates() {
        // Given - Use movie ID that matches MockHomeService
        let movie = createMockMovie(id: 346_698, title: "Barbie") // This matches MockHomeService

        // When viewState is loading
        // Note: Initial state might be loading, so let's wait for success first
        let expectation = XCTestExpectation(description: "success state")

        sut.$viewState
            .sink { viewState in
                if case .success = viewState {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)

        // Then
        // Movie should not be liked initially
        XCTAssertFalse(sut.isLiked(movie: movie))

        // After toggling like
        sut.toggleLike(for: movie)

        // Give it time to process
        let toggleExpectation = XCTestExpectation(description: "toggle complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            toggleExpectation.fulfill()
        }
        wait(for: [toggleExpectation], timeout: 1.0)

        // Movie should be liked now
        XCTAssertTrue(sut.isLiked(movie: movie))
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

    private func isLoadingState(_ viewState: HomeViewState) -> Bool {
        if case .loading = viewState {
            return true
        }
        return false
    }
}
