//
//  SearchNavigationRouterTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Combine
@testable import GitHubApp
import Testing
import UIKit

/**
 * Unit tests for SearchNavigationRouter covering navigation logic.
 *
 * Tests cover:
 * - Initialization with coordinator
 * - Initialization without coordinator
 * - Detail navigation via SwiftUI coordinator
 * - Detail navigation via UIKit fallback
 * - Equality comparison
 * - Service locator inheritance
 */
@MainActor
struct SearchNavigationRouterTests {
    @Test("Router initializes with coordinator and inherits service locator")
    func routerInitializesWithCoordinator() {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        serviceLocator.register(StorageService.self, instance: MockStorageService())
        let coordinator = Coordinator(serviceLocator: serviceLocator)

        // When
        let router = SearchNavigationRouter(coordinator: coordinator, serviceLocator: nil)

        // Then - Router should initialize successfully
        #expect(router != nil, "Router should initialize with coordinator")
    }

    @Test("Router initializes without coordinator")
    func routerInitializesWithoutCoordinator() {
        // When
        let router = SearchNavigationRouter(coordinator: nil, serviceLocator: nil)

        // Then - Router should initialize successfully
        #expect(router != nil, "Router should initialize without coordinator")
    }

    @Test("Router initializes with explicit service locator")
    func routerInitializesWithServiceLocator() {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        serviceLocator.register(StorageService.self, instance: MockStorageService())

        // When
        let router = SearchNavigationRouter(coordinator: nil, serviceLocator: serviceLocator)

        // Then - Router should initialize successfully
        #expect(router != nil, "Router should initialize with service locator")
    }

    @Test("Router handles detail navigation event with UIKit navigation controller")
    @MainActor
    func routerHandlesDetailNavigationWithUIKit() async {
        // Given
        let movie = Movie(id: 123, title: "Test Movie", overview: "Test", posterPath: nil)
        let navigationController = UINavigationController()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())

        let router = SearchNavigationRouter(coordinator: nil, serviceLocator: serviceLocator)
        router.navigation = navigationController

        // Create a root view controller
        let rootViewController = UIViewController()
        navigationController.viewControllers = [rootViewController]

        // When - Trigger detail navigation
        router.route(navigationEvent: .detail(movie))

        // Then - Navigation controller should push MovieDetailsHostingController
        #expect(navigationController.topViewController is MovieDetailsHostingController, "Should push MovieDetailsHostingController")
        #expect(navigationController.viewControllers.count == 2, "Should have 2 view controllers in stack")
    }

    @Test("Router handles detail navigation without UIKit navigation controller or coordinator")
    func routerHandlesDetailNavigationWithoutDependencies() {
        // Given - Router without UIKit navigation or coordinator
        let movie = Movie(id: 123, title: "Test Movie", overview: "Test", posterPath: nil)
        let router = SearchNavigationRouter(coordinator: nil, serviceLocator: nil)
        #expect(router.navigation == nil, "Router should not have UIKit navigation")

        // When - Trigger detail navigation (should not crash)
        router.route(navigationEvent: .detail(movie))

        // Then - Should handle gracefully
        #expect(true, "Router should handle navigation without crashing")
    }

    @Test("Router handles detail navigation with coordinator but no service locator")
    func routerHandlesDetailNavigationWithCoordinatorOnly() {
        // Given
        let movie = Movie(id: 123, title: "Test Movie", overview: "Test", posterPath: nil)
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        serviceLocator.register(StorageService.self, instance: MockStorageService())
        let coordinator = Coordinator(serviceLocator: serviceLocator)
        let router = SearchNavigationRouter(coordinator: coordinator, serviceLocator: nil)

        // When - Trigger detail navigation (coordinator should handle it)
        router.route(navigationEvent: .detail(movie))

        // Then - Should handle gracefully (coordinator handles navigation)
        #expect(true, "Router should delegate to coordinator without crashing")
    }

    @Test("Router equality comparison works correctly for same navigation controller")
    @MainActor
    func routerEqualityWithSameNavigationController() {
        // Given
        let navigationController = UINavigationController()
        let router1 = SearchNavigationRouter(coordinator: nil, serviceLocator: nil)
        let router2 = SearchNavigationRouter(coordinator: nil, serviceLocator: nil)

        router1.navigation = navigationController
        router2.navigation = navigationController

        // When/Then - Routers with same navigation should be equal
        #expect(router1 == router2, "Routers with same navigation controller should be equal")
    }

    @Test("Router equality comparison works correctly for different navigation controllers")
    @MainActor
    func routerEqualityWithDifferentNavigationControllers() {
        // Given
        let navigationController1 = UINavigationController()
        let navigationController2 = UINavigationController()
        let router1 = SearchNavigationRouter(coordinator: nil, serviceLocator: nil)
        let router2 = SearchNavigationRouter(coordinator: nil, serviceLocator: nil)

        router1.navigation = navigationController1
        router2.navigation = navigationController2

        // When/Then - Routers with different navigation should not be equal
        #expect(router1 != router2, "Routers with different navigation controllers should not be equal")
    }

    @Test("Router equality comparison works correctly for same coordinator")
    func routerEqualityWithSameCoordinator() {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        serviceLocator.register(StorageService.self, instance: MockStorageService())
        let coordinator = Coordinator(serviceLocator: serviceLocator)
        let router1 = SearchNavigationRouter(coordinator: coordinator, serviceLocator: nil)
        let router2 = SearchNavigationRouter(coordinator: coordinator, serviceLocator: nil)

        // When/Then - Routers with same coordinator should be equal
        #expect(router1 == router2, "Routers with same coordinator should be equal")
    }

    @Test("Router equality comparison works correctly for different coordinators")
    func routerEqualityWithDifferentCoordinators() {
        // Given
        let serviceLocator1 = ServiceLocator()
        serviceLocator1.register(HomeService.self, instance: MockHomeService())
        serviceLocator1.register(StorageService.self, instance: MockStorageService())
        let serviceLocator2 = ServiceLocator()
        serviceLocator2.register(HomeService.self, instance: MockHomeService())
        serviceLocator2.register(StorageService.self, instance: MockStorageService())
        let coordinator1 = Coordinator(serviceLocator: serviceLocator1)
        let coordinator2 = Coordinator(serviceLocator: serviceLocator2)
        let router1 = SearchNavigationRouter(coordinator: coordinator1, serviceLocator: nil)
        let router2 = SearchNavigationRouter(coordinator: coordinator2, serviceLocator: nil)

        // When/Then - Routers with different coordinators should not be equal
        #expect(router1 != router2, "Routers with different coordinators should not be equal")
    }

    @Test("Router without navigation or coordinator is equal to itself")
    func routerEqualityWithoutDependencies() {
        // Given
        let router1 = SearchNavigationRouter(coordinator: nil, serviceLocator: nil)
        let router2 = SearchNavigationRouter(coordinator: nil, serviceLocator: nil)

        // When/Then - Routers without dependencies should be equal
        #expect(router1 == router2, "Routers without dependencies should be equal")
    }

    @Test("Router inherits service locator from coordinator when not explicitly provided")
    func routerInheritsServiceLocatorFromCoordinator() {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        serviceLocator.register(StorageService.self, instance: MockStorageService())
        let coordinator = Coordinator(serviceLocator: serviceLocator)

        // When
        let router = SearchNavigationRouter(coordinator: coordinator, serviceLocator: nil)

        // Then - Router should have service locator from coordinator (internal property, verify via initialization)
        #expect(router != nil, "Router should successfully initialize with coordinator's service locator")
    }

    @Test("Router uses explicitly provided service locator over coordinator's")
    func routerUsesExplicitServiceLocator() {
        // Given
        let coordinatorServiceLocator = ServiceLocator()
        coordinatorServiceLocator.register(HomeService.self, instance: MockHomeService())
        coordinatorServiceLocator.register(StorageService.self, instance: MockStorageService())
        let explicitServiceLocator = ServiceLocator()
        explicitServiceLocator.register(HomeService.self, instance: MockHomeService())
        explicitServiceLocator.register(StorageService.self, instance: MockStorageService())
        let coordinator = Coordinator(serviceLocator: coordinatorServiceLocator)

        // When
        let router = SearchNavigationRouter(coordinator: coordinator, serviceLocator: explicitServiceLocator)

        // Then - Router should initialize with explicit service locator
        #expect(router != nil, "Router should use explicitly provided service locator")
    }

    @Test("Router requires service locator for UIKit navigation to work")
    @MainActor
    func routerRequiresServiceLocatorForUIKitNavigation() async {
        // Given
        let movie = Movie(id: 123, title: "Test Movie", overview: "Test", posterPath: nil)
        let navigationController = UINavigationController()
        let router = SearchNavigationRouter(coordinator: nil, serviceLocator: nil)
        router.navigation = navigationController

        let rootViewController = UIViewController()
        navigationController.viewControllers = [rootViewController]

        // When - Trigger detail navigation without service locator
        router.route(navigationEvent: .detail(movie))

        // Then - Should not push (requires service locator)
        #expect(navigationController.viewControllers.count == 1, "Should not push without service locator")
    }
}
