//
//  HomeViewModelTests.swift
//  GitHubAppTests
//

import Combine
@testable import GitHubApp
import XCTest

final class HomeViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = .init()

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        // Ensure API key exists in case anything inadvertently touches HomeAPI
        try? APIKeysProvider.setMovieAPIKey("unit-test-key")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        try? APIKeysProvider.removeMovieAPIKey()
        cancellables.removeAll()
        super.tearDown()
    }

    func testFetchDataPopulatesMoviesAndLikedSync() {
        let service = MockHomeService()
        let sut = HomeViewModel(service: service)

        let exp = expectation(description: "movies")
        // Give the Combine pipeline a short moment; MockHomeService uses RunLoop delivery
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(sut.movies.isEmpty)
            XCTAssertTrue(sut.likedMovies.isEmpty)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testSearchMoviesReplacesMovies() {
        let service = MockHomeService()
        let sut = HomeViewModel(service: service)

        let exp = expectation(description: "search")
        sut.searchMovies(query: "barbie")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(sut.movies.isEmpty)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    // DISABLED: This test was for the old MVVM architecture
    // Use HomeViewModelCleanArchitectureTests for Clean Architecture tests
    /*
     func testToggleLikePersistsAndUpdatesLikedMovies() {
         let service = MockHomeService()
         let sut = HomeViewModel(service: service)

         // Seed movies to allow liked sync to include movie
         let movie = Movie(id: 1, title: "A", overview: "B", posterPath: nil)
         sut.movies = [movie]
         sut.toggleLike(for: movie)

         XCTAssertTrue(sut.isLiked(movie: movie))
         XCTAssertEqual(sut.likedMovies, [movie])

         sut.toggleLike(for: movie)
         XCTAssertFalse(sut.isLiked(movie: movie))
         XCTAssertTrue(sut.likedMovies.isEmpty)
     }
     */

    // DISABLED: This test was for the old MVVM architecture
    // Use HomeViewModelCleanArchitectureTests for Clean Architecture tests
    /*
     func testErrorHandlingSetsErrorAndClearsMovies() {
         struct FailingService: HomeService {
             func fetchMovies() -> AnyPublisher<MoviesResponse, Error> { Fail(error: NSError(domain: "t", code: 1)).eraseToAnyPublisher() }
             func searchMovies(with _: String) -> AnyPublisher<MoviesResponse, Error> { Fail(error: NSError(domain: "t", code: 1)).eraseToAnyPublisher() }
             func fetchCredits(with _: Int) -> AnyPublisher<MovieCreditsResponse, Error> { Fail(error: NSError(domain: "t", code: 1)).eraseToAnyPublisher() }
             func fetchReviews(with _: Int) -> AnyPublisher<MovieReviewsResponse, Error> { Fail(error: NSError(domain: "t", code: 1)).eraseToAnyPublisher() }
         }

         let sut = HomeViewModel(service: FailingService())
         let exp = expectation(description: "error")
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             XCTAssertNotNil(sut.error)
             XCTAssertTrue(sut.movies.isEmpty)
             exp.fulfill()
         }
         wait(for: [exp], timeout: 1)
     }
     */
}
