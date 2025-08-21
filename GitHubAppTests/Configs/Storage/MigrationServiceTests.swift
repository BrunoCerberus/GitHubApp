//
//  MigrationServiceTests.swift
//  GitHubAppTests
//
//  Created by bruno on storage-migration.
//

@testable import GitHubApp
import XCTest

final class MigrationServiceTests: XCTestCase {
    private var mockUserDefaults: UserDefaults!
    private var migrationService: MigrationService!
    private var testStorageService: StorageServiceProtocol!

    override func setUp() async throws {
        try await super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "MigrationServiceTests")
        mockUserDefaults.removePersistentDomain(forName: "MigrationServiceTests")
        migrationService = MigrationService(userDefaults: mockUserDefaults)
        testStorageService = try StorageServiceFactory.shared.createTestStorageService()
    }

    override func tearDown() async throws {
        mockUserDefaults.removePersistentDomain(forName: "MigrationServiceTests")
        mockUserDefaults = nil
        migrationService = nil
        testStorageService = nil
        try await super.tearDown()
    }

    func testMigrationWithNoDataDoesNotFail() async throws {
        // Given - No data in UserDefaults

        // When
        try await migrationService.migrateToSwiftData(storageService: testStorageService)

        // Then - Should complete without errors
        let likedMovies = try await testStorageService.fetchLikedMovies()
        XCTAssertTrue(likedMovies.isEmpty)
    }

    func testMigrationWithLikedMovies() async throws {
        // Given
        let movies = [
            Movie(id: 1, title: "Test Movie 1", overview: "Overview 1", posterPath: "/test1.jpg"),
            Movie(id: 2, title: "Test Movie 2", overview: "Overview 2", posterPath: "/test2.jpg"),
        ]
        let moviesData = try JSONEncoder().encode(movies)
        mockUserDefaults.set(moviesData, forKey: "likedMoviesKey")

        // When
        try await migrationService.migrateToSwiftData(storageService: testStorageService)

        // Then
        let migratedMovies = try await testStorageService.fetchLikedMovies()
        XCTAssertEqual(migratedMovies.count, 2)
        XCTAssertTrue(migratedMovies.contains { $0.id == 1 })
        XCTAssertTrue(migratedMovies.contains { $0.id == 2 })

        // Verify UserDefaults was cleaned up
        XCTAssertNil(mockUserDefaults.data(forKey: "likedMoviesKey"))
    }

    func testMigrationIsOnlyPerformedOnce() async throws {
        // Given
        let movies = [
            Movie(id: 1, title: "Test Movie", overview: "Overview", posterPath: "/test.jpg"),
        ]
        let moviesData = try JSONEncoder().encode(movies)
        mockUserDefaults.set(moviesData, forKey: "likedMoviesKey")

        // When - First migration
        try await migrationService.migrateToSwiftData(storageService: testStorageService)

        // Add new data to UserDefaults after migration
        let newMovies = [
            Movie(id: 2, title: "New Movie", overview: "New Overview", posterPath: "/new.jpg"),
        ]
        let newMoviesData = try JSONEncoder().encode(newMovies)
        mockUserDefaults.set(newMoviesData, forKey: "likedMoviesKey")

        // When - Second migration
        try await migrationService.migrateToSwiftData(storageService: testStorageService)

        // Then - Should only have original movies, not new ones
        let migratedMovies = try await testStorageService.fetchLikedMovies()
        XCTAssertEqual(migratedMovies.count, 1)
        XCTAssertEqual(migratedMovies.first?.id, 1)
    }

    func testMigrationWithInvalidData() async throws {
        // Given - Invalid JSON data
        mockUserDefaults.set("invalid json data".data(using: .utf8), forKey: "likedMoviesKey")

        // When & Then - Should not throw error
        try await migrationService.migrateToSwiftData(storageService: testStorageService)

        let migratedMovies = try await testStorageService.fetchLikedMovies()
        XCTAssertTrue(migratedMovies.isEmpty)
    }

    func testMigrationWithEmptyMoviesArray() async throws {
        // Given
        let emptyMovies: [Movie] = []
        let moviesData = try JSONEncoder().encode(emptyMovies)
        mockUserDefaults.set(moviesData, forKey: "likedMoviesKey")

        // When
        try await migrationService.migrateToSwiftData(storageService: testStorageService)

        // Then
        let migratedMovies = try await testStorageService.fetchLikedMovies()
        XCTAssertTrue(migratedMovies.isEmpty)

        // Verify UserDefaults was cleaned up even for empty array
        XCTAssertNil(mockUserDefaults.data(forKey: "likedMoviesKey"))
    }
}
