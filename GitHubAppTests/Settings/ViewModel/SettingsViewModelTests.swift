//
//  SettingsViewModelTests.swift
//  GitHubAppTests
//
//  Created by bruno on settings functionality.
//

import Combine
import UIKit
import XCTest

@testable import GitHubApp

/**
 * Unit tests for SettingsViewModel functionality.
 */
@MainActor
final class SettingsViewModelTests: XCTestCase {
    var mockFavoritesService: MockFavoritesService!
    var mockDomainInteractor: FavoritesDomainInteractor!
    var favoriteMoviesViewModel: FavoritesMoviesViewModel!
    var settingsViewModel: SettingsViewModel!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockFavoritesService = MockFavoritesService()
        mockDomainInteractor = FavoritesDomainInteractor(favoritesService: mockFavoritesService)
        favoriteMoviesViewModel = FavoritesMoviesViewModel(domainInteractor: mockDomainInteractor)
        settingsViewModel = SettingsViewModel(favoriteMoviesViewModel: favoriteMoviesViewModel)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables.removeAll()
        mockFavoritesService = nil
        mockDomainInteractor = nil
        favoriteMoviesViewModel = nil
        settingsViewModel = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Then
        XCTAssertNotNil(settingsViewModel.settingsManager)
        XCTAssertNotNil(settingsViewModel.appVersion)
        XCTAssertNotNil(settingsViewModel.appBuildNumber)
        XCTAssertFalse(settingsViewModel.isPhotoPickerPresented)
        XCTAssertFalse(settingsViewModel.isClearLikedMoviesConfirmationPresented)
        XCTAssertFalse(settingsViewModel.showClearLikedMoviesAlert)
        XCTAssertFalse(settingsViewModel.showRateAppThanks)
    }

    // MARK: - App Version Tests

    func testAppVersion() {
        // Then
        XCTAssertFalse(settingsViewModel.appVersion.isEmpty)
        XCTAssertFalse(settingsViewModel.appBuildNumber.isEmpty)
    }

    // MARK: - Liked Movies Management Tests

    func testClearAllLikedMovies() {
        let expectation = XCTestExpectation(description: "clear favorite movies")

        // Given
        let testMovie = Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test Overview",
            posterPath: "/test.jpg"
        )

        // Clear pre-populated mock data and add test movie
        mockFavoritesService.setMockLikedMovies([testMovie])

        // Wait for initial state and then clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // When
            self.settingsViewModel.clearAllFavoriteMovies()

            // Wait for async clear operation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // Then
                XCTAssertEqual(self.favoriteMoviesViewModel.favoriteMovies.count, 0)
                XCTAssertTrue(self.settingsViewModel.showClearLikedMoviesAlert)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: - App Rating Tests

    func testRateApp() {
        // Given
        XCTAssertFalse(settingsViewModel.settingsManager.hasRatedApp)

        // When
        settingsViewModel.rateApp()

        // Then
        XCTAssertTrue(settingsViewModel.settingsManager.hasRatedApp)
        XCTAssertTrue(settingsViewModel.showRateAppThanks)
    }

    // MARK: - Photo Picker Tests

    func testShowPhotoPicker() {
        // When
        settingsViewModel.showPhotoPicker()

        // Then
        XCTAssertTrue(settingsViewModel.isPhotoPickerPresented)
    }

    func testHidePhotoPicker() {
        // Given
        settingsViewModel.isPhotoPickerPresented = true

        // When
        settingsViewModel.hidePhotoPicker()

        // Then
        XCTAssertFalse(settingsViewModel.isPhotoPickerPresented)
    }

    // MARK: - Clear Liked Movies Confirmation Tests

    func testShowClearLikedMoviesConfirmation() {
        // When
        settingsViewModel.showClearLikedMoviesConfirmation()

        // Then
        XCTAssertTrue(settingsViewModel.isClearLikedMoviesConfirmationPresented)
    }

    func testHideClearLikedMoviesConfirmation() {
        // Given
        settingsViewModel.isClearLikedMoviesConfirmationPresented = true

        // When
        settingsViewModel.hideClearLikedMoviesConfirmation()

        // Then
        XCTAssertFalse(settingsViewModel.isClearLikedMoviesConfirmationPresented)
    }
}
