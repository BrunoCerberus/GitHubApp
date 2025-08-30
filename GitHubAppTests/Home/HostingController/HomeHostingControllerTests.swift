//
//  HomeHostingControllerTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing
import UIKit

@MainActor
struct HomeHostingControllerTests {
    private func createTestComponents() -> ServiceLocator {
        StorageServiceFactory.shared.resetCache()
        StorageServiceFactory.shared.updateConfiguration(.testing)
        // Ensure API key is available to avoid fatalError in HomeAPI
        try? APIKeysProvider.setMovieAPIKey("test-key")

        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        return serviceLocator
    }

    private func cleanupTest() {
        StorageServiceFactory.shared.resetCache()
        // Keep in testing mode to avoid interfering with other concurrent tests
        try? APIKeysProvider.removeMovieAPIKey()
    }

    @Test("ViewDidLoad sets title and large titles and router nav")
    func viewDidLoadSetsTitleAndLargeTitlesAndRouterNav() {
        defer { cleanupTest() }

        let router = HomeNavigationRouter()
        let serviceLocator = createTestComponents()
        let sut = HomeHostingController<HomeNavigationRouter>(navigationRouter: router, serviceLocator: serviceLocator)
        let nav = UINavigationController(rootViewController: sut)

        // Trigger lifecycle
        _ = sut.view
        sut.viewDidLoad()

        #expect(sut.title == "Upcoming Movies")
        #expect(nav.navigationBar.prefersLargeTitles)
        #expect(router.navigation === nav)
    }

    @Test("Initialization")
    func initialization() {
        defer { cleanupTest() }

        let router = HomeNavigationRouter()
        let serviceLocator = createTestComponents()
        let sut = HomeHostingController<HomeNavigationRouter>(navigationRouter: router, serviceLocator: serviceLocator)

        #expect(sut.router === router)
        #expect(sut.view != nil)
    }

    @Test("Init with coder returns nil")
    func initWithCoderReturnsNil() {
        defer { cleanupTest() }

        let sut = HomeHostingController<HomeNavigationRouter>(coder: NSCoder())

        #expect(sut == nil)
    }
}
