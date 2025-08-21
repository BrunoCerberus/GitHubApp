//
//  HomeViewModelCleanArchitectureTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import XCTest

final class HomeViewModelCleanArchitectureTests: XCTestCase {
    private var sut: HomeViewModel!
    private var mockHomeService: MockHomeService!
    private var mockStorageService: MockStorageService!
    private var mockDomainInteractor: HomeDomainInteractor!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        // Ensure API key exists in case anything inadvertently touches HomeAPI
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")

        mockHomeService = MockHomeService()
        mockStorageService = MockStorageService()
        mockDomainInteractor = HomeDomainInteractor(homeService: mockHomeService, storageService: mockStorageService)
        sut = HomeViewModel(service: mockHomeService, domainInteractor: mockDomainInteractor)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        try? APIKeysProvider.removeMovieAPIKey()
        cancellables.removeAll()
        sut = nil
        mockHomeService = nil
        mockStorageService = nil
        mockDomainInteractor = nil
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

            // Give it time to process the async storage operation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                expectation.fulfill()
            }
        }

        // Then
        wait(for: [expectation], timeout: 3.0)

        // Check that movie is marked as liked in the view model
        XCTAssertTrue(sut.isLiked(movie: movie))

        // Check persistence in mock storage service asynchronously
        let storageExpectation = XCTestExpectation(description: "check storage")
        Task {
            do {
                let likedMovies = try await self.mockStorageService.fetchLikedMovies()
                XCTAssertTrue(likedMovies.contains { $0.id == movie.id })
                storageExpectation.fulfill()
            } catch {
                XCTFail("Failed to fetch liked movies: \(error)")
                storageExpectation.fulfill()
            }
        }

        wait(for: [storageExpectation], timeout: 2.0)
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
        mockHomeService.shouldFail = true
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

        // Wait for the view state to update with the liked movie
        let toggleExpectation = XCTestExpectation(description: "movie liked")

        // Cancel previous subscription and create new one to observe state changes
        cancellables.removeAll()
        sut.$viewState
            .sink { viewState in
                if case let .success(dataViewState) = viewState,
                   dataViewState.likedMovies.contains(where: { $0.id == movie.id })
                {
                    toggleExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [toggleExpectation], timeout: 3.0)

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
