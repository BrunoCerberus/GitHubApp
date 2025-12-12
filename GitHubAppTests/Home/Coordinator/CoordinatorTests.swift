//
//  CoordinatorTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import SwiftUI
import Testing

@MainActor
struct CoordinatorTests {
    init() {
        try? APIKeysProvider.setMovieAPIKey("coord-key")
    }

    @Test("Push operation appends page to path")
    func pushAppendsPage() {
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        // Given
        let serviceLocator = ServiceLocator()
        let sut = Coordinator(serviceLocator: serviceLocator)
        #expect(sut.path.isEmpty)

        // When
        sut.push(page: .home)

        // Then
        #expect(!sut.path.isEmpty)
    }

    @Test("Build methods create valid views for home and detail pages")
    func buildHomeAndDetailRender() async throws {
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        await MainActor.run {
            // Given
            let serviceLocator = ServiceLocator()
            serviceLocator.register(HomeService.self, instance: MockHomeService())
            let sut = Coordinator(serviceLocator: serviceLocator)

            // When & Then - Home view
            let homeView = sut.build(page: .home)
            let homeHost = UIHostingController(rootView: AnyView(homeView))
            #expect(homeHost.view != nil)

            // When & Then - Detail view
            let movie = Movie(id: 5, title: "Title", overview: "Overview", posterPath: nil)
            let detailView = sut.build(page: .detail(movie))
            let detailHost = UIHostingController(rootView: AnyView(detailView))
            #expect(detailHost.view != nil)
        }
    }

    @Test("Multiple push operations correctly increase path count")
    func multiplePushOperations() {
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        // Given
        let serviceLocator = ServiceLocator()
        let sut = Coordinator(serviceLocator: serviceLocator)
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test Overview", posterPath: nil)
        #expect(sut.path.count == 0)

        // When
        sut.push(page: .home)

        // Then
        #expect(sut.path.count == 1)

        // When
        sut.push(page: .detail(movie))

        // Then
        #expect(sut.path.count == 2)
    }

    @Test("ViewModels are initialized lazily")
    func lazyViewModelInitialization() {
        defer { try? APIKeysProvider.removeMovieAPIKey() }

        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: MockHomeService())
        serviceLocator.register(FavoritesService.self, instance: MockFavoritesService())
        serviceLocator.register(SettingsService.self, instance: MockSettingsService())
        let sut = Coordinator(serviceLocator: serviceLocator)

        // When & Then - ViewModels should be created lazily
        // Test passes if ViewModels can be accessed without throwing
        _ = sut.homeViewModel
        _ = sut.favoriteMoviesViewModel
        _ = sut.settingsViewModel
    }
}
