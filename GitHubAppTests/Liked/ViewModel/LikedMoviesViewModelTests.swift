//
//  LikedMoviesViewModelTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class LikedMoviesViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Clear persisted state used by LikedMoviesViewModel
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        super.tearDown()
    }

    func testToggleLikeAddsAndRemovesMovie() {
        let movie = Movie(id: 1, title: "A", overview: "B", posterPath: nil)
        let sut = LikedMoviesViewModel()

        XCTAssertFalse(sut.isLiked(movie: movie))

        sut.toggleLike(for: movie)
        XCTAssertTrue(sut.isLiked(movie: movie))

        sut.toggleLike(for: movie)
        XCTAssertFalse(sut.isLiked(movie: movie))
    }

    func testPersistenceAcrossInstances() {
        let movie = Movie(id: 42, title: "Persist", overview: "Test", posterPath: nil)

        do { // first instance writes
            let sut1 = LikedMoviesViewModel()
            sut1.toggleLike(for: movie)
            XCTAssertTrue(sut1.isLiked(movie: movie))
        }

        do { // second instance reads
            let sut2 = LikedMoviesViewModel()
            XCTAssertTrue(sut2.isLiked(movie: movie))
        }
    }
}
