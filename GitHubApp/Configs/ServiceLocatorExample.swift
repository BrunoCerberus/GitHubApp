//
//  ServiceLocatorExample.swift
//  GitHubApp
//
//  Created by bruno on 05/08/25.
//

import Foundation

/**
 * Example demonstrating how to use the ServiceLocator pattern.
 *
 * This file shows practical examples of how to register and retrieve
 * services using the ServiceLocator. It's for documentation purposes only.
 */
enum ServiceLocatorExample {
    /**
     * Example: How to create and use a ServiceLocator instance
     */
    static func exampleCreateAndUseServiceLocator() {
        // Create a new ServiceLocator instance
        let serviceLocator = ServiceLocator()

        // Register a service
        serviceLocator.register(HomeService.self, instance: LiveHomeService())

        // Retrieve a service
        do {
            let homeService = try serviceLocator.retrieve(HomeService.self)
            LogManager.shared.info("Successfully retrieved HomeService", category: "Service")
        } catch {
            LogManager.shared.error("Failed to retrieve HomeService: \(error)", category: "Service")
        }
    }

    /**
     * Example: How to retrieve a service from ServiceLocator
     */
    static func exampleRetrieveService() {
        let serviceLocator = ServiceLocator()

        // Register a service first
        serviceLocator.register(HomeService.self, instance: LiveHomeService())

        // Retrieve a service (this is what ViewModels do automatically)
        do {
            let homeService = try serviceLocator.retrieve(HomeService.self)
            LogManager.shared.info("Successfully retrieved HomeService", category: "Service")
        } catch {
            LogManager.shared.error("Failed to retrieve HomeService: \(error)", category: "Service")
        }
    }

    /**
     * Example: How to safely retrieve a service (returns nil if not found)
     */
    static func exampleSafeRetrieveService() {
        let serviceLocator = ServiceLocator()

        // Safe retrieval that returns nil if service is not registered
        if let homeService = serviceLocator.safeRetrieve(HomeService.self) {
            LogManager.shared.info("Successfully retrieved HomeService safely", category: "Service")
        } else {
            LogManager.shared.warning("HomeService not registered in ServiceLocator", category: "Service")
        }
    }

    /**
     * Example: How to check if a service is registered
     */
    static func exampleCheckServiceRegistration() {
        let serviceLocator = ServiceLocator()

        // Check if a service is registered before trying to retrieve it
        if serviceLocator.isRegistered(HomeService.self) {
            LogManager.shared.info("HomeService is registered in ServiceLocator", category: "Service")
        } else {
            LogManager.shared.warning("HomeService is not registered in ServiceLocator", category: "Service")
        }
    }

    /**
     * Example: How to register a service manually (for testing or custom scenarios)
     */
    static func exampleRegisterService() {
        let serviceLocator = ServiceLocator()

        // Register a custom service instance
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        LogManager.shared.info("Registered MockService for HomeService", category: "Service")

        // Verify it's registered
        if serviceLocator.isRegistered(HomeService.self) {
            LogManager.shared.info("Service registration confirmed", category: "Service")
        }
    }

    /**
     * Example: How to register a service factory (for lazy instantiation)
     */
    static func exampleRegisterServiceFactory() {
        let serviceLocator = ServiceLocator()

        // Register a factory that creates the service when needed
        serviceLocator.register(HomeService.self) {
            // This closure will be called each time the service is retrieved
            LiveHomeService()
        }
        LogManager.shared.info("Registered HomeService factory", category: "Service")
    }

    /**
     * Example: How to clear all registered services
     */
    static func exampleClearServices() {
        let serviceLocator = ServiceLocator()

        // Clear all registered services (useful for testing)
        serviceLocator.clear()
        LogManager.shared.info("Cleared all registered services", category: "Service")
    }
}

/**
 * Usage in ViewModels (this is what actually happens):
 *
 * ```swift
 * class HomeViewModel {
 *     private let service: HomeService
 *
 *     init(service: HomeService? = nil, serviceLocator: ServiceLocator? = nil) {
 *         // Try to get service from ServiceLocator, fallback to HomeService if not registered
 *         if let service = service {
 *             self.service = service
 *         } else if let serviceLocator = serviceLocator {
 *             do {
 *                 self.service = try serviceLocator.retrieve(HomeService.self)
 *             } catch {
 *                 // Fallback to HomeService if not registered in ServiceLocator
 *                 self.service = LiveHomeService()
 *             }
 *         } else {
 *             // Fallback to HomeService if no ServiceLocator provided
 *             self.service = LiveHomeService()
 *         }
 *     }
 * }
 * ```
 *
 * Usage in SceneDelegate (this is what actually happens):
 *
 * ```swift
 * final class GitHubAppSceneDelegate: UIResponder, UIWindowSceneDelegate {
 *     private let serviceLocator = ServiceLocator()
 *
 *     private func setupServices() {
 *         // Register HomeService based on environment
 *         #if DEBUG
 *             if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
 *                 serviceLocator.register(HomeService.self, instance: MockHomeService())
 *             } else {
 *                 serviceLocator.register(HomeService.self, instance: LiveHomeService())
 *             }
 *         #else
 *             serviceLocator.register(HomeService.self, instance: LiveHomeService())
 *         #endif
 *     }
 * }
 * ```
 */
