//
//  LikedMoviesViewModelTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import XCTest

final class LikedMoviesViewModelTests: XCTestCase {
    private var mockFavoritesService: MockFavoritesService!
    private var mockDomainInteractor: LikedDomainInteractor!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        // Clear persisted state used by LikedMoviesViewModel
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")

        // Set up mock services
        mockFavoritesService = MockFavoritesService()
        mockDomainInteractor = LikedDomainInteractor(likedService: mockFavoritesService)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        cancellables.removeAll()
        mockFavoritesService = nil
        mockDomainInteractor = nil
        super.tearDown()
    }

    func testToggleLikeAddsAndRemovesMovie() {
        let movie = Movie(id: 1, title: "A", overview: "B", posterPath: nil)

        // Clear pre-populated mock data
        mockFavoritesService.setMockLikedMovies([])

        let sut = LikedMoviesViewModel(domainInteractor: mockDomainInteractor)
        let expectation = XCTestExpectation(description: "toggle like test")

        // Wait for initial state to load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(sut.isLiked(movie: movie))

            sut.toggleLike(for: movie)

            // Wait for async operation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                XCTAssertTrue(sut.isLiked(movie: movie))

                sut.toggleLike(for: movie)

                // Wait for second async operation to complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    XCTAssertFalse(sut.isLiked(movie: movie))
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testPersistenceAcrossInstances() {
        let movie = Movie(id: 42, title: "Persist", overview: "Test", posterPath: nil)
        let expectation = XCTestExpectation(description: "persistence test")

        // Clear pre-populated mock data
        mockFavoritesService.setMockLikedMovies([])

        // first instance writes
        let sut1 = LikedMoviesViewModel(domainInteractor: mockDomainInteractor)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut1.toggleLike(for: movie)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                XCTAssertTrue(sut1.isLiked(movie: movie))

                // second instance reads - use same mock service to ensure persistence
                let sut2 = LikedMoviesViewModel(domainInteractor: self.mockDomainInteractor)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    XCTAssertTrue(sut2.isLiked(movie: movie))
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }
}
