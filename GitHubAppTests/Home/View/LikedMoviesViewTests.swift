//
//  LikedMoviesViewTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import SwiftUI
import XCTest

final class LikedMoviesViewTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        try? APIKeysProvider.setMovieAPIKey("ui-key")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "likedMoviesKey")
        try? APIKeysProvider.removeMovieAPIKey()
        super.tearDown()
    }

    func testEmptyStateRenders() {
        let vm = LikedMoviesViewModel()
        let view = LikedMoviesView(viewModel: vm)
        let host = UIHostingController(rootView: view)
        XCTAssertNotNil(host.view) // trigger load
    }

    func testListStateRenders() {
        let vm = LikedMoviesViewModel()
        vm.likedMovies = [
            Movie(id: 1, title: "A", overview: "B", posterPath: nil),
            Movie(id: 2, title: "C", overview: "D", posterPath: nil),
        ]
        let view = LikedMoviesView(viewModel: vm)
        let host = UIHostingController(rootView: view)
        XCTAssertNotNil(host.view) // trigger load
    }
}
