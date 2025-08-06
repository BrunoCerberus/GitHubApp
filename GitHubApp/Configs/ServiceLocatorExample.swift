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
     * Example: How to retrieve a service from ServiceLocator
     */
    static func exampleRetrieveService() {
        // Retrieve a service (this is what ViewModels do automatically)
        do {
            let homeService = try ServiceLocator.shared.retrieve(HomeServiceProtocol.self)
            print("✅ Successfully retrieved HomeService")
        } catch {
            print("❌ Failed to retrieve HomeService: \(error)")
        }
    }

    /**
     * Example: How to safely retrieve a service (returns nil if not found)
     */
    static func exampleSafeRetrieveService() {
        // Safe retrieval that returns nil if service is not registered
        if let homeService = ServiceLocator.shared.safeRetrieve(HomeServiceProtocol.self) {
            print("✅ Successfully retrieved HomeService safely")
        } else {
            print("⚠️ HomeService not registered in ServiceLocator")
        }
    }

    /**
     * Example: How to check if a service is registered
     */
    static func exampleCheckServiceRegistration() {
        // Check if a service is registered before trying to retrieve it
        if ServiceLocator.shared.isRegistered(HomeServiceProtocol.self) {
            print("✅ HomeService is registered in ServiceLocator")
        } else {
            print("❌ HomeService is not registered in ServiceLocator")
        }
    }

    /**
     * Example: How to register a service manually (for testing or custom scenarios)
     */
    static func exampleRegisterService() {
        // Register a custom service instance
        ServiceLocator.shared.register(HomeServiceProtocol.self, instance: MockService())
        print("✅ Registered MockService for HomeServiceProtocol")

        // Verify it's registered
        if ServiceLocator.shared.isRegistered(HomeServiceProtocol.self) {
            print("✅ Service registration confirmed")
        }
    }

    /**
     * Example: How to register a service factory (for lazy instantiation)
     */
    static func exampleRegisterServiceFactory() {
        // Register a factory that creates the service when needed
        ServiceLocator.shared.register(HomeServiceProtocol.self) {
            // This closure will be called each time the service is retrieved
            HomeService()
        }
        print("✅ Registered HomeService factory")
    }

    /**
     * Example: How to clear all registered services
     */
    static func exampleClearServices() {
        // Clear all registered services (useful for testing)
        ServiceLocator.shared.clear()
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
 *     init(service: HomeServiceProtocol? = nil) {
 *         // Try to get service from ServiceLocator, fallback to HomeService if not registered
 *         if let service = service {
 *             self.service = service
 *         } else {
 *             do {
 *                 self.service = try ServiceLocator.shared.retrieve(HomeServiceProtocol.self)
 *             } catch {
 *                 // Fallback to HomeService if not registered in ServiceLocator
 *                 self.service = HomeService()
 *             }
 *         }
 *     }
 * }
 * ```
 *
 * Usage in SceneDelegate (this is what actually happens):
 *
 * ```swift
 * private func setupServices() {
 *     let serviceLocator = ServiceLocator.shared
 *
 *     // Register HomeService based on environment
 *     #if DEBUG
 *         // Check if running in test environment
 *         if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
 *             // Use mock service for tests
 *             serviceLocator.register(HomeServiceProtocol.self, instance: MockService())
 *         } else {
 *             // Use real service for debug builds
 *             serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())
 *         }
 *     #else
 *         // Use real service for release builds
 *         serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())
 *     #endif
 * }
 * ```
 */
