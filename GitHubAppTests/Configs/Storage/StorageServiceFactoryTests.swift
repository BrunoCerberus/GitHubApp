//
//  StorageServiceFactoryTests.swift
//  GitHubAppTests
//
//  Created by bruno on storage-migration.
//

@testable import GitHubApp
import XCTest

final class StorageServiceFactoryTests: XCTestCase {
    private var factory: StorageServiceFactory!

    override func setUp() {
        super.setUp()
        factory = StorageServiceFactory.shared
        factory.resetCache() // Ensure clean state for each test
    }

    override func tearDown() {
        factory.resetCache()
        super.tearDown()
    }

    func testGetStorageServiceReturnsSameInstance() throws {
        // When
        let service1 = try factory.getStorageService()
        let service2 = try factory.getStorageService()

        // Then
        XCTAssertTrue(service1 === service2, "Should return the same cached instance")
    }

    func testCreateTestStorageServiceReturnsNewInstance() throws {
        // When
        let service1 = try factory.createTestStorageService()
        let service2 = try factory.createTestStorageService()

        // Then
        XCTAssertFalse(service1 === service2, "Should return new instances for testing")
    }

    func testResetCacheCreatesNewInstance() throws {
        // Given
        let service1 = try factory.getStorageService()

        // When
        factory.resetCache()
        let service2 = try factory.getStorageService()

        // Then
        XCTAssertFalse(service1 === service2, "Should return new instance after cache reset")
    }

    func testUpdateConfigurationResetsCache() throws {
        // Given
        let service1 = try factory.getStorageService()
        let newConfiguration = StorageConfiguration.testing

        // When
        factory.updateConfiguration(newConfiguration)
        let service2 = try factory.getStorageService()

        // Then
        XCTAssertFalse(service1 === service2, "Should return new instance after configuration update")
    }

    func testStorageConfigurationProduction() {
        // When
        let config = StorageConfiguration.production

        // Then
        XCTAssertEqual(config.type, .swiftData)
        XCTAssertFalse(config.isInMemory)
        XCTAssertTrue(config.performMigration)
    }

    func testStorageConfigurationTesting() {
        // When
        let config = StorageConfiguration.testing

        // Then
        XCTAssertEqual(config.type, .swiftData)
        XCTAssertTrue(config.isInMemory)
        XCTAssertFalse(config.performMigration)
    }

    func testStorageConfigurationLegacy() {
        // When
        let config = StorageConfiguration.legacy

        // Then
        XCTAssertEqual(config.type, .userDefaults)
        XCTAssertFalse(config.isInMemory)
        XCTAssertFalse(config.performMigration)
    }
}
