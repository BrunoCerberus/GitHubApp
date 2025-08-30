//
//  StorageServiceFactoryTests.swift
//  GitHubAppTests
//
//  Created by bruno on storage-migration.
//

@testable import GitHubApp
import Testing

struct StorageServiceFactoryTests {
    @Test("Get storage service returns same cached instance")
    func getStorageServiceReturnsSameInstance() throws {
        // Given
        let factory = StorageServiceFactory.shared
        defer { factory.resetCache() }
        factory.resetCache() // Ensure clean state

        // When
        let service1 = try factory.getStorageService()
        let service2 = try factory.getStorageService()

        // Then
        #expect(service1 === service2)
    }

    @Test("Create test storage service returns new instances for testing")
    func createTestStorageServiceReturnsNewInstance() throws {
        // Given
        let factory = StorageServiceFactory.shared
        defer { factory.resetCache() }

        // When
        let service1 = try factory.createTestStorageService()
        let service2 = try factory.createTestStorageService()

        // Then
        #expect(service1 !== service2)
    }

    @Test("Reset cache creates new storage service instance")
    func resetCacheCreatesNewInstance() throws {
        // Given
        let factory = StorageServiceFactory.shared
        defer { factory.resetCache() }
        factory.resetCache() // Ensure clean state
        let service1 = try factory.getStorageService()

        // When
        factory.resetCache()
        let service2 = try factory.getStorageService()

        // Then
        #expect(service1 !== service2)
    }

    @Test("Update configuration resets cache and creates new instance")
    func updateConfigurationResetsCache() throws {
        // Given
        let factory = StorageServiceFactory.shared
        defer { factory.resetCache() }
        factory.resetCache() // Ensure clean state
        let service1 = try factory.getStorageService()
        let newConfiguration = StorageConfiguration.testing

        // When
        factory.updateConfiguration(newConfiguration)
        let service2 = try factory.getStorageService()

        // Then
        #expect(service1 !== service2)
    }

    @Test("Storage configuration production has correct settings")
    func storageConfigurationProduction() {
        // When
        let config = StorageConfiguration.production

        // Then
        #expect(config.type == .swiftData)
        #expect(!config.isInMemory)
    }

    @Test("Storage configuration testing has correct settings")
    func storageConfigurationTesting() {
        // When
        let config = StorageConfiguration.testing

        // Then
        #expect(config.type == .swiftData)
        #expect(config.isInMemory)
    }
}
