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
        serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())

        // Retrieve a service
        do {
            let homeService = try serviceLocator.retrieve(HomeServiceProtocol.self)
            print("✅ Successfully retrieved HomeService")
        } catch {
            print("❌ Failed to retrieve HomeService: \(error)")
        }
    }

    /**
     * Example: How to retrieve a service from ServiceLocator
     */
    static func exampleRetrieveService() {
        let serviceLocator = ServiceLocator()

        // Register a service first
        serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())

        // Retrieve a service (this is what ViewModels do automatically)
        do {
            let homeService = try serviceLocator.retrieve(HomeServiceProtocol.self)
            print("✅ Successfully retrieved HomeService")
        } catch {
            print("❌ Failed to retrieve HomeService: \(error)")
        }
    }

    /**
     * Example: How to safely retrieve a service (returns nil if not found)
     */
    static func exampleSafeRetrieveService() {
        let serviceLocator = ServiceLocator()

        // Safe retrieval that returns nil if service is not registered
        if let homeService = serviceLocator.safeRetrieve(HomeServiceProtocol.self) {
            print("✅ Successfully retrieved HomeService safely")
        } else {
            print("⚠️ HomeService not registered in ServiceLocator")
        }
    }

    /**
     * Example: How to check if a service is registered
     */
    static func exampleCheckServiceRegistration() {
        let serviceLocator = ServiceLocator()

        // Check if a service is registered before trying to retrieve it
        if serviceLocator.isRegistered(HomeServiceProtocol.self) {
            print("✅ HomeService is registered in ServiceLocator")
        } else {
            print("❌ HomeService is not registered in ServiceLocator")
        }
    }

    /**
     * Example: How to register a service manually (for testing or custom scenarios)
     */
    static func exampleRegisterService() {
        let serviceLocator = ServiceLocator()

        // Register a custom service instance
        serviceLocator.register(HomeServiceProtocol.self, instance: MockService())
        print("✅ Registered MockService for HomeServiceProtocol")

        // Verify it's registered
        if serviceLocator.isRegistered(HomeServiceProtocol.self) {
            print("✅ Service registration confirmed")
        }
    }

    /**
     * Example: How to register a service factory (for lazy instantiation)
     */
    static func exampleRegisterServiceFactory() {
        let serviceLocator = ServiceLocator()

        // Register a factory that creates the service when needed
        serviceLocator.register(HomeServiceProtocol.self) {
            // This closure will be called each time the service is retrieved
            HomeService()
        }
        print("✅ Registered HomeService factory")
    }

    /**
     * Example: How to clear all registered services
     */
    static func exampleClearServices() {
        let serviceLocator = ServiceLocator()

        // Clear all registered services (useful for testing)
        serviceLocator.clear()
        print("🧹 Cleared all registered services")
    }
}

/**
 * Usage in ViewModels (this is what actually happens):
 *
 * ```swift
 * class HomeViewModel {
 *     private let service: HomeServiceProtocol
 *
 *     init(service: HomeServiceProtocol? = nil, serviceLocator: ServiceLocator? = nil) {
 *         // Try to get service from ServiceLocator, fallback to HomeService if not registered
 *         if let service = service {
 *             self.service = service
 *         } else if let serviceLocator = serviceLocator {
 *             do {
 *                 self.service = try serviceLocator.retrieve(HomeServiceProtocol.self)
 *             } catch {
 *                 // Fallback to HomeService if not registered in ServiceLocator
 *                 self.service = HomeService()
 *             }
 *         } else {
 *             // Fallback to HomeService if no ServiceLocator provided
 *             self.service = HomeService()
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
 *                 serviceLocator.register(HomeServiceProtocol.self, instance: MockService())
 *             } else {
 *                 serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())
 *             }
 *         #else
 *             serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())
 *         #endif
 *     }
 * }
 * ```
 */
