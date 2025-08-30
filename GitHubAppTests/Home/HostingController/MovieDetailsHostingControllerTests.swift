//
//  MovieDetailsHostingControllerTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing
import UIKit

struct MovieDetailsHostingControllerTests {
    private func createTestComponents(movie: Movie) -> MovieDetailsHostingController {
        // Configure storage for testing
        StorageServiceFactory.shared.resetCache()
        StorageServiceFactory.shared.updateConfiguration(.testing)
        // Ensure API key is available to avoid fatalError in HomeAPI
        try? APIKeysProvider.setMovieAPIKey("test-key")
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        return MovieDetailsHostingController(movie: movie, serviceLocator: serviceLocator)
    }

    private func cleanupTest() {
        StorageServiceFactory.shared.resetCache()
        StorageServiceFactory.shared.updateConfiguration(.production)
        try? APIKeysProvider.removeMovieAPIKey()
    }

    @Test("ViewDidLoad sets title from movie")
    @MainActor func viewDidLoadSetsTitleFromMovie() {
        defer { cleanupTest() }

        // Given
        let movie = Movie(id: 7, title: "Seven", overview: "o", posterPath: nil)
        let sut = createTestComponents(movie: movie)
        _ = UINavigationController(rootViewController: sut)

        // When - Trigger lifecycle
        _ = sut.view
        sut.viewDidLoad()

        // Then
        #expect(sut.title == movie.title)
    }

    @Test("Initialization")
    @MainActor func initialization() {
        defer { cleanupTest() }

        // Given
        let movie = Movie(id: 123, title: "Test Movie", overview: "Test overview", posterPath: "/test.jpg")

        // When
        let sut = createTestComponents(movie: movie)

        // Then
        #expect(sut.movie.id == movie.id)
        #expect(sut.movie.title == movie.title)
        // Test passes if view can be accessed without crashing
        _ = sut.view
    }

    @Test("Init with coder returns nil")
    @MainActor func initWithCoderReturnsNil() {
        defer { cleanupTest() }

        // When
        let sut = MovieDetailsHostingController(coder: NSCoder())

        // Then
        #expect(sut == nil)
    }
}
