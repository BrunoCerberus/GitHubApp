//
//  MockSettingsService.swift
//  GitHubAppTests
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Combine
import Foundation
@testable import GitHubApp
import UIKit

/**
 * Mock implementation of SettingsService for testing.
 */
final class MockSettingsService: SettingsService {
    // MARK: - Mock State

    var mockProfileImage: UIImage?
    var mockHasRatedApp = false
    var mockAppVersion = "1.0"
    var mockAppBuildNumber = "1"
    var shouldFailSaveProfileImage = false
    var shouldFailClearFavoriteMovies = false

    // MARK: - Call Tracking

    var loadProfileImageCallCount = 0
    var saveProfileImageCallCount = 0
    var clearProfileImageCallCount = 0
    var hasRatedAppCallCount = 0
    var markAppAsRatedCallCount = 0
    var clearAllFavoriteMoviesCallCount = 0
    var getAppVersionInfoCallCount = 0

    // MARK: - SettingsService Implementation

    func loadProfileImage() -> AnyPublisher<UIImage?, Never> {
        loadProfileImageCallCount += 1
        return Just(mockProfileImage)
            .eraseToAnyPublisher()
    }

    func saveProfileImage(_ image: UIImage) -> AnyPublisher<Void, Error> {
        saveProfileImageCallCount += 1

        if shouldFailSaveProfileImage {
            return Fail(error: SettingsError.operationFailed("Failed to save image"))
                .eraseToAnyPublisher()
        }

        mockProfileImage = image
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func clearProfileImage() -> AnyPublisher<Void, Never> {
        clearProfileImageCallCount += 1
        mockProfileImage = nil
        return Just(())
            .eraseToAnyPublisher()
    }

    func hasRatedApp() -> AnyPublisher<Bool, Never> {
        hasRatedAppCallCount += 1
        return Just(mockHasRatedApp)
            .eraseToAnyPublisher()
    }

    func markAppAsRated() -> AnyPublisher<Void, Never> {
        markAppAsRatedCallCount += 1
        mockHasRatedApp = true
        return Just(())
            .eraseToAnyPublisher()
    }

    func clearAllFavoriteMovies() -> AnyPublisher<Void, Error> {
        clearAllFavoriteMoviesCallCount += 1

        if shouldFailClearFavoriteMovies {
            return Fail(error: SettingsError.operationFailed("Failed to clear favorite movies"))
                .eraseToAnyPublisher()
        }

        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getAppVersionInfo() -> AnyPublisher<(version: String, buildNumber: String), Never> {
        getAppVersionInfoCallCount += 1
        return Just((version: mockAppVersion, buildNumber: mockAppBuildNumber))
            .eraseToAnyPublisher()
    }

    // MARK: - Test Helpers

    func reset() {
        mockProfileImage = nil
        mockHasRatedApp = false
        mockAppVersion = "1.0.0"
        mockAppBuildNumber = "123"
        shouldFailSaveProfileImage = false
        shouldFailClearFavoriteMovies = false

        loadProfileImageCallCount = 0
        saveProfileImageCallCount = 0
        clearProfileImageCallCount = 0
        hasRatedAppCallCount = 0
        markAppAsRatedCallCount = 0
        clearAllFavoriteMoviesCallCount = 0
        getAppVersionInfoCallCount = 0
    }
}
