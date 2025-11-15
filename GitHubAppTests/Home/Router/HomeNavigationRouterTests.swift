//
//  HomeNavigationRouterTests.swift
//  GitHubAppTests
//
//  Created by bruno on 16/08/23.
//

@testable import GitHubApp
import Testing
import UIKit

@MainActor
struct HomeNavigationRouterTests {
    @Test("Pushing a detail event presents MovieDetailsHostingController")
    func router() async throws {
        await MainActor.run {
            // Given
            let mockMovie = Movie(id: 0, title: "The Movie", overview: "", posterPath: nil)
            let nav = UINavigationController(rootViewController: UIViewController())
            let serviceLocator = ServiceLocator()
            serviceLocator.register(HomeService.self, instance: MockHomeService())
            let router = HomeNavigationRouter(serviceLocator: serviceLocator)
            router.navigation = nav

            // When
            router.route(navigationEvent: .detail(mockMovie))

            // Then
            #expect(router.navigation?.topViewController is MovieDetailsHostingController)
        }
    }
}
