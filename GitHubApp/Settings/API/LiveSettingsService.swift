//
//  LiveSettingsService.swift
//  GitHubApp
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Combine
import Foundation
import UIKit

/**
 * Live implementation of SettingsService.
 *
 * This implementation handles real settings operations using UserDefaults
 * and StorageService for data persistence.
 */
final class LiveSettingsService: SettingsService {
    // MARK: - Dependencies

    /// Storage service for handling favorite movies operations
    private let storageService: StorageServiceProtocol

    /// UserDefaults keys
    private enum Keys {
        static let profileImageData = "profileImageData"
        static let hasRatedApp = "hasRatedApp"
    }

    // MARK: - Initialization

    /**
     * Initialize the service with dependencies.
     *
     * - Parameter storageService: Optional storage service (defaults to shared instance)
     */
    init(storageService: StorageServiceProtocol? = nil) {
        if let storageService {
            self.storageService = storageService
        } else {
            do {
                self.storageService = try StorageServiceFactory.shared.getStorageService()
            } catch {
                fatalError("Failed to initialize storage service: \(error)")
            }
        }
    }

    // MARK: - Profile Image Operations

    func loadProfileImage() -> AnyPublisher<UIImage?, Never> {
        Future<UIImage?, Never> { promise in
            guard let imageData = UserDefaults.standard.data(forKey: Keys.profileImageData),
                  let image = UIImage(data: imageData)
            else {
                promise(.success(nil))
                return
            }

            promise(.success(image))
        }
        .eraseToAnyPublisher()
    }

    func saveProfileImage(_ image: UIImage) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                promise(.failure(SettingsError.imageCompressionFailed))
                return
            }

            UserDefaults.standard.set(imageData, forKey: Keys.profileImageData)
            UserDefaults.standard.synchronize()
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    func clearProfileImage() -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            UserDefaults.standard.removeObject(forKey: Keys.profileImageData)
            UserDefaults.standard.synchronize()
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    // MARK: - App Rating Operations

    func hasRatedApp() -> AnyPublisher<Bool, Never> {
        Just(UserDefaults.standard.bool(forKey: Keys.hasRatedApp))
            .eraseToAnyPublisher()
    }

    func markAppAsRated() -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            UserDefaults.standard.set(true, forKey: Keys.hasRatedApp)
            UserDefaults.standard.synchronize()
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Favorite Movies Operations

    func clearAllFavoriteMovies() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self else {
                promise(.failure(SettingsError.serviceUnavailable))
                return
            }

            Task {
                do {
                    try await self.storageService.clearFavoriteMovies()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - App Version Operations

    func getAppVersionInfo() -> AnyPublisher<(version: String, buildNumber: String), Never> {
        Future<(version: String, buildNumber: String), Never> { promise in
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

            promise(.success((version: version, buildNumber: buildNumber)))
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Settings Errors

/**
 * Errors that can occur during settings operations.
 */
enum SettingsError: Error, LocalizedError {
    case imageCompressionFailed
    case serviceUnavailable
    case operationFailed(String)

    var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            "Failed to compress image data"
        case .serviceUnavailable:
            "Settings service is unavailable"
        case let .operationFailed(message):
            "Settings operation failed: \(message)"
        }
    }
}
