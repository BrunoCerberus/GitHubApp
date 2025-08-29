//
//  HomeHostingControllerTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import UIKit
import XCTest

final class HomeHostingControllerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Ensure API key is available to avoid fatalError in HomeAPI
        try? APIKeysProvider.setMovieAPIKey("test-key")
    }

    override func tearDown() {
        try? APIKeysProvider.removeMovieAPIKey()
        super.tearDown()
    }

    func testViewDidLoadSetsTitleAndLargeTitlesAndRouterNav() {
        let router = HomeNavigationRouter()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        let sut = HomeHostingController<HomeNavigationRouter>(navigationRouter: router, serviceLocator: serviceLocator)
        let nav = UINavigationController(rootViewController: sut)

        // Trigger lifecycle
        _ = sut.view
        sut.viewDidLoad()

        XCTAssertEqual(sut.title, "Upcoming Movies")
        XCTAssertTrue(nav.navigationBar.prefersLargeTitles)
        XCTAssertTrue(router.navigation === nav)
    }

    func testInitialization() {
        let router = HomeNavigationRouter()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        let sut = HomeHostingController<HomeNavigationRouter>(navigationRouter: router, serviceLocator: serviceLocator)

        XCTAssertTrue(sut.router === router)
        XCTAssertNotNil(sut.view)
    }

    @MainActor
    func testInitWithCoderReturnsNil() {
        let sut = HomeHostingController<HomeNavigationRouter>(coder: NSCoder())

        XCTAssertNil(sut)
    }
}
