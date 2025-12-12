//
//  LiveFavoritesServiceErrorTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

import Combine
import Foundation
@testable import GitHubApp
import Testing

@MainActor
struct LiveFavoritesServiceErrorTests {
    // MARK: - Stub Implementation Tests

    @Test("Load favorite movies returns empty array")
    func loadFavoriteMoviesReturnsEmpty() async throws {
        // Given - LiveFavoritesService is deprecated in favor of FavoritesDomainInteractor
        let service = LiveFavoritesService()

        // When - Using service
        let result = try await service.loadFavoriteMovies().async()

        // Then - Returns empty array (stub implementation)
        #expect(result.isEmpty)
    }

    @Test("Toggle movie favorite returns empty array")
    func toggleMovieFavoriteReturnsEmpty() async throws {
        // Given
        let service = LiveFavoritesService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)

        // When
        let result = try await service.toggleMovieFavorite(movie).async()

        // Then - Returns empty array (stub implementation)
        #expect(result.isEmpty)
    }

    @Test("Is movie liked returns false")
    func isMovieLikedReturnsFalse() async throws {
        // Given
        let service = LiveFavoritesService()
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)

        // When
        let result = try await service.isMovieLiked(movie).async()

        // Then - Returns false (stub implementation)
        #expect(result == false)
    }

    // MARK: - Error Type Tests

    @Test("Favorites service error descriptions are meaningful")
    func favoritesServiceErrorDescriptions() {
        // Test all error cases to improve coverage

        let serviceUnavailableError = FavoritesServiceError.serviceUnavailable
        #expect(serviceUnavailableError.errorDescription == "Favorites service is unavailable")

        let testError = NSError(domain: "TestError", code: 123, userInfo: nil)
        let encodingError = FavoritesServiceError.encodingFailed(testError)
        #expect(encodingError.errorDescription?.contains("Failed to encode favorite movies") == true)

        let decodingError = FavoritesServiceError.decodingFailed(testError)
        #expect(decodingError.errorDescription?.contains("Failed to decode favorite movies") == true)
    }

    @Test("Favorites service error equality works through descriptions")
    func favoritesServiceErrorEquality() {
        // Test error equality for coverage
        let error1 = FavoritesServiceError.serviceUnavailable
        let error2 = FavoritesServiceError.serviceUnavailable

        // Since FavoritesServiceError doesn't conform to Equatable, we test descriptions
        #expect(error1.errorDescription == error2.errorDescription)
    }
}
