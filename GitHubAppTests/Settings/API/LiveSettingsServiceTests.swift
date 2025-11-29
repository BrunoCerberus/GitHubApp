//
//  LiveSettingsServiceTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Combine
@testable import GitHubApp
import Testing
import UIKit

@MainActor
struct LiveSettingsServiceTests {
    private func createTestComponents() -> (LiveSettingsService, ServiceLocator) {
        let mockStorageService = MockStorageService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let settingsService = LiveSettingsService()
        return (settingsService, serviceLocator)
    }

    private func cleanup() {
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()
    }

    @Test("Load profile image returns nil when not saved")
    func loadProfileImageReturnsNilWhenNotSaved() throws {
        // Given
        let (settingsService, _) = createTestComponents()
        defer { cleanup() }

        // When
        var resultImage: UIImage?
        var cancelled = false

        let cancellable = settingsService.loadProfileImage()
            .sink { image in
                resultImage = image
            }

        // Small delay to allow publisher to emit
        usleep(100_000)

        // Then
        #expect(resultImage == nil)
        cancellable.cancel()
    }

    @Test("Save and load profile image works correctly")
    func saveAndLoadProfileImageWorks() throws {
        // Given
        let (settingsService, _) = createTestComponents()
        defer { cleanup() }

        // Create a test image
        let testImage = UIImage(systemName: "star.fill") ?? UIImage()
        var saveCompleted = false
        var loadedImage: UIImage?

        // When - Save image
        let saveCancellable = settingsService.saveProfileImage(testImage)
            .sink(
                receiveCompletion: { _ in saveCompleted = true },
                receiveValue: { _ in }
            )

        usleep(100_000) // Wait for save

        // Then - Load and verify
        let loadCancellable = settingsService.loadProfileImage()
            .sink { image in
                loadedImage = image
            }

        usleep(100_000) // Wait for load

        #expect(saveCompleted)
        #expect(loadedImage != nil)

        saveCancellable.cancel()
        loadCancellable.cancel()
    }

    @Test("Clear profile image removes saved image")
    func clearProfileImageRemovesSavedImage() throws {
        // Given
        let (settingsService, _) = createTestComponents()
        defer { cleanup() }

        // Create and save a test image
        let testImage = UIImage(systemName: "star.fill") ?? UIImage()
        let saveCancellable = settingsService.saveProfileImage(testImage).sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
        usleep(100_000)

        // When - Clear image
        let clearCancellable = settingsService.clearProfileImage().sink { _ in }
        usleep(100_000)

        // Then - Verify cleared
        var loadedImage: UIImage?
        let loadCancellable = settingsService.loadProfileImage()
            .sink { image in
                loadedImage = image
            }
        usleep(100_000)

        #expect(loadedImage == nil)

        saveCancellable.cancel()
        clearCancellable.cancel()
        loadCancellable.cancel()
    }

    @Test("Has rated app returns false by default")
    func hasRatedAppReturnsFalseByDefault() throws {
        // Given
        let (settingsService, _) = createTestComponents()
        defer { cleanup() }

        // When
        var hasRated = true
        let cancellable = settingsService.hasRatedApp()
            .sink { result in
                hasRated = result
            }

        usleep(100_000)

        // Then
        #expect(hasRated == false)
        cancellable.cancel()
    }

    @Test("Mark app as rated updates state correctly")
    func markAppAsRatedUpdatesStateCorrectly() throws {
        // Given
        let (settingsService, _) = createTestComponents()
        defer { cleanup() }

        // When - Mark as rated
        let markCancellable = settingsService.markAppAsRated().sink { _ in }
        usleep(100_000)

        // Then - Verify marked
        var hasRated = false
        let getCancellable = settingsService.hasRatedApp()
            .sink { result in
                hasRated = result
            }
        usleep(100_000)

        #expect(hasRated == true)

        markCancellable.cancel()
        getCancellable.cancel()
    }

    @Test("Get app version info returns valid version and build")
    func getAppVersionInfoReturnsValidVersionAndBuild() throws {
        // Given
        let (settingsService, _) = createTestComponents()
        defer { cleanup() }

        // When
        var versionInfo: (version: String, buildNumber: String) = ("", "")
        let cancellable = settingsService.getAppVersionInfo()
            .sink { info in
                versionInfo = info
            }

        usleep(100_000)

        // Then
        #expect(!versionInfo.version.isEmpty)
        #expect(!versionInfo.buildNumber.isEmpty)
        cancellable.cancel()
    }

    @Test("Get app version info returns expected format")
    func getAppVersionInfoReturnsExpectedFormat() throws {
        // Given
        let (settingsService, _) = createTestComponents()
        defer { cleanup() }

        // When
        var versionInfo: (version: String, buildNumber: String) = ("", "")
        let cancellable = settingsService.getAppVersionInfo()
            .sink { info in
                versionInfo = info
            }

        usleep(100_000)

        // Then - Verify version has semantic versioning format
        let versionComponents = versionInfo.version.split(separator: ".")
        #expect(versionComponents.count >= 1) // At least major version

        // Verify build number is not empty
        #expect(!versionInfo.buildNumber.isEmpty)
        cancellable.cancel()
    }

    @Test("Settings service conforms to SettingsService protocol")
    func serviceConformsToSettingsServiceProtocol() {
        // Given
        let (settingsService, _) = createTestComponents()
        defer { cleanup() }

        // When & Then
        let _: any SettingsService = settingsService
        #expect(true)
    }

    @Test("Multiple save operations work sequentially")
    func multipleProfileImagesSequentialOperations() throws {
        // Given
        let (settingsService, _) = createTestComponents()
        defer { cleanup() }

        let image1 = UIImage(systemName: "star.fill") ?? UIImage()
        let image2 = UIImage(systemName: "heart.fill") ?? UIImage()

        // When - Save first image
        let save1 = settingsService.saveProfileImage(image1).sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
        usleep(100_000)

        var loadedImage1: UIImage?
        let load1 = settingsService.loadProfileImage()
            .sink { image in
                loadedImage1 = image
            }
        usleep(100_000)

        #expect(loadedImage1 != nil)

        // When - Save second image
        let save2 = settingsService.saveProfileImage(image2).sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
        usleep(100_000)

        var loadedImage2: UIImage?
        let load2 = settingsService.loadProfileImage()
            .sink { image in
                loadedImage2 = image
            }
        usleep(100_000)

        #expect(loadedImage2 != nil)

        // When - Clear
        let clear = settingsService.clearProfileImage().sink { _ in }
        usleep(100_000)

        var loadedImage3: UIImage?
        let load3 = settingsService.loadProfileImage()
            .sink { image in
                loadedImage3 = image
            }
        usleep(100_000)

        #expect(loadedImage3 == nil)

        save1.cancel()
        load1.cancel()
        save2.cancel()
        load2.cancel()
        clear.cancel()
        load3.cancel()
    }

    @Test("Settings operations are independent")
    func settingsOperationsAreIndependent() throws {
        // Given
        let (settingsService, _) = createTestComponents()
        defer { cleanup() }

        // When - Mark as rated
        let markCancellable = settingsService.markAppAsRated().sink { _ in }
        usleep(100_000)

        // Save profile image
        let testImage = UIImage(systemName: "star.fill") ?? UIImage()
        let saveCancellable = settingsService.saveProfileImage(testImage).sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
        usleep(100_000)

        // Then - Verify both operations completed
        var hasRated = false
        let getRated = settingsService.hasRatedApp()
            .sink { result in
                hasRated = result
            }
        usleep(100_000)

        #expect(hasRated == true)

        var profileImage: UIImage?
        let getImage = settingsService.loadProfileImage()
            .sink { image in
                profileImage = image
            }
        usleep(100_000)

        #expect(profileImage != nil)

        markCancellable.cancel()
        saveCancellable.cancel()
        getRated.cancel()
        getImage.cancel()
    }
}
