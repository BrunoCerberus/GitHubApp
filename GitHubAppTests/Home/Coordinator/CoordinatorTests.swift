//
//  CoordinatorTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import SwiftUI
import XCTest

final class CoordinatorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        try? APIKeysProvider.setMovieAPIKey("coord-key")
    }

    override func tearDown() {
        try? APIKeysProvider.removeMovieAPIKey()
        super.tearDown()
    }

    func testPushAppendsPage() {
        let serviceLocator = ServiceLocator()
        let sut = Coordinator(serviceLocator: serviceLocator)
        XCTAssertTrue(sut.path.isEmpty)
        sut.push(page: .home)
        XCTAssertFalse(sut.path.isEmpty)
    }

    func testBuildHomeAndDetailRender() {
        let serviceLocator = ServiceLocator()
        let sut = Coordinator(serviceLocator: serviceLocator)

        let homeView = sut.build(page: .home)
        let homeHost = UIHostingController(rootView: AnyView(homeView))
        XCTAssertNotNil(homeHost.view)

        let movie = Movie(id: 5, title: "Title", overview: "Overview", posterPath: nil)
        let detailView = sut.build(page: .detail(movie))
        let detailHost = UIHostingController(rootView: AnyView(detailView))
        XCTAssertNotNil(detailHost.view)
    }

    func testCoordinatorProtocolConformance() {
        let serviceLocator = ServiceLocator()
        let sut = Coordinator(serviceLocator: serviceLocator)

        // Test protocol method through protocol reference
        let coordinatorProtocol: CoordinatorProtocol = sut
        coordinatorProtocol.push(page: .home)
        XCTAssertFalse(sut.path.isEmpty)
    }

    func testMultiplePushOperations() {
        let serviceLocator = ServiceLocator()
        let sut = Coordinator(serviceLocator: serviceLocator)
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: nil)

        XCTAssertEqual(sut.path.count, 0)

        sut.push(page: .home)
        XCTAssertEqual(sut.path.count, 1)

        sut.push(page: .detail(movie))
        XCTAssertEqual(sut.path.count, 2)
    }

    func testLazyViewModelInitialization() {
        let serviceLocator = ServiceLocator()
        let sut = Coordinator(serviceLocator: serviceLocator)

        // ViewModels should be created lazily
        XCTAssertNotNil(sut.homeViewModel)
        XCTAssertNotNil(sut.favoriteMoviesViewModel)
        XCTAssertNotNil(sut.settingsViewModel)
    }
}
