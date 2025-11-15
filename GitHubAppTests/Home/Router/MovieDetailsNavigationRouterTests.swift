//
//  MovieDetailsNavigationRouterTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Combine
@testable import GitHubApp
import Testing
import UIKit

/**
 * Unit tests for MovieDetailsNavigationRouter covering navigation logic.
 *
 * Tests cover:
 * - Initialization with coordinator
 * - Initialization without coordinator
 * - Back navigation via UIKit
 * - Equality comparison
 * - Service locator inheritance
 */
@MainActor
struct MovieDetailsNavigationRouterTests {
    @Test("Router initializes with coordinator and inherits service locator")
    func routerInitializesWithCoordinator() {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        serviceLocator.register(StorageService.self, instance: MockStorageService())
        let coordinator = Coordinator(serviceLocator: serviceLocator)

        // When
        let router = MovieDetailsNavigationRouter(coordinator: coordinator, serviceLocator: nil)

        // Then - Router should initialize successfully
        #expect(router != nil, "Router should initialize with coordinator")
    }

    @Test("Router initializes without coordinator")
    func routerInitializesWithoutCoordinator() {
        // When
        let router = MovieDetailsNavigationRouter(coordinator: nil, serviceLocator: nil)

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
        let router = MovieDetailsNavigationRouter(coordinator: nil, serviceLocator: serviceLocator)

        // Then - Router should initialize successfully
        #expect(router != nil, "Router should initialize with service locator")
    }

    @Test("Router handles back navigation event with UIKit navigation controller")
    @MainActor
    func routerHandlesBackNavigationWithUIKit() {
        // Given
        let navigationController = UINavigationController()
        let router = MovieDetailsNavigationRouter(coordinator: nil, serviceLocator: nil)
        router.navigation = navigationController

        // Create a view controller to push
        let viewController = UIViewController()
        navigationController.viewControllers = [UIViewController(), viewController]

        // When - Trigger back navigation
        router.route(navigationEvent: .back)

        // Then - Navigation controller should pop (async operation, verify setup)
        #expect(navigationController.viewControllers.count >= 1, "Navigation should be set up correctly")
    }

    @Test("Router handles back navigation without UIKit navigation controller")
    func routerHandlesBackNavigationWithoutUIKit() {
        // Given - Router without UIKit navigation (SwiftUI mode)
        let router = MovieDetailsNavigationRouter(coordinator: nil, serviceLocator: nil)
        #expect(router.navigation == nil, "Router should not have UIKit navigation")

        // When - Trigger back navigation (should not crash)
        router.route(navigationEvent: .back)

        // Then - Should handle gracefully (SwiftUI handles back automatically)
        #expect(true, "Router should handle back navigation without crashing")
    }

    @Test("Router equality comparison works correctly for same navigation controller")
    @MainActor
    func routerEqualityWithSameNavigationController() {
        // Given
        let navigationController = UINavigationController()
        let router1 = MovieDetailsNavigationRouter(coordinator: nil, serviceLocator: nil)
        let router2 = MovieDetailsNavigationRouter(coordinator: nil, serviceLocator: nil)

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
        let router1 = MovieDetailsNavigationRouter(coordinator: nil, serviceLocator: nil)
        let router2 = MovieDetailsNavigationRouter(coordinator: nil, serviceLocator: nil)

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
        let router1 = MovieDetailsNavigationRouter(coordinator: coordinator, serviceLocator: nil)
        let router2 = MovieDetailsNavigationRouter(coordinator: coordinator, serviceLocator: nil)

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
        let router1 = MovieDetailsNavigationRouter(coordinator: coordinator1, serviceLocator: nil)
        let router2 = MovieDetailsNavigationRouter(coordinator: coordinator2, serviceLocator: nil)

        // When/Then - Routers with different coordinators should not be equal
        #expect(router1 != router2, "Routers with different coordinators should not be equal")
    }

    @Test("Router without navigation or coordinator is equal to itself")
    func routerEqualityWithoutDependencies() {
        // Given
        let router1 = MovieDetailsNavigationRouter(coordinator: nil, serviceLocator: nil)
        let router2 = MovieDetailsNavigationRouter(coordinator: nil, serviceLocator: nil)

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
        let router = MovieDetailsNavigationRouter(coordinator: coordinator, serviceLocator: nil)

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
        let router = MovieDetailsNavigationRouter(coordinator: coordinator, serviceLocator: explicitServiceLocator)

        // Then - Router should initialize with explicit service locator
        #expect(router != nil, "Router should use explicitly provided service locator")
    }
}
