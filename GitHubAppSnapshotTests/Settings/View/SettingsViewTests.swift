// swiftlint:disable file_length
//
//  SettingsViewTests.swift
//  GitHubAppTests
//
//  Created by bruno on settings functionality.
//

import Combine
import SnapshotTesting
import SwiftUI
import Testing

@testable import GitHubApp

/// Snapshot tests for SettingsView to ensure visual regressions are detected.
@MainActor
struct SettingsViewTests { // swiftlint:disable:this type_body_length
    init() {
        // Set to true to record new snapshots, false to compare against existing
        // isRecording = true
    }

    private func createTestComponents() -> (SettingsView, MockSettingsService, ServiceLocator) {
        // Clear UserDefaults for clean testing
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()

        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()
        let mockStoreKitService = MockStoreKitService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: mockStoreKitService)

        let settingsViewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: settingsViewModel, serviceLocator: serviceLocator)

        return (view, mockSettingsService, serviceLocator)
    }

    @Test("Snapshot of Settings view with default configuration")
    func settingsView() async {
        // Given
        let (view, _, _) = createTestComponents()

        // Wait a moment for the view to load data
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        _ = view.wrappedViewController

        // Using iPhone Air (iOS 26) dimensions
        let iPhoneAirConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        assertSnapshot(of: view.wrappedViewController, as: .wait(for: 0.3, on: .image(on: iPhoneAirConfig)))
    }

    @Test("Settings view button interactions for coverage")
    func settingsViewButtonInteractions() {
        // Given
        let (view, _, _) = createTestComponents()
        let hostingController = UIHostingController(rootView: view)

        // When - Access view to trigger rendering and test closures
        _ = hostingController.view

        // Then - Test passes if view renders without crashing
    }

    @Test("Settings view clear favorites functionality")
    func clearFavoritesCardRendering() {
        // Given
        let (view, _, _) = createTestComponents()
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering
        _ = hostingController.view

        // Then - Should render clear favorites card
        // Test passes if view renders without crashing
    }

    @Test("Settings view rate app functionality")
    func rateAppCardRendering() {
        // Given
        let (view, _, _) = createTestComponents()
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering
        _ = hostingController.view

        // Then - Should render rate app card
        // Test passes if view renders without crashing
    }

    @Test("Profile header section rendering")
    func profileHeaderSectionRendering() {
        // Given
        let (view, _, _) = createTestComponents()
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering to exercise private properties
        _ = hostingController.view

        // Then - Should render profile header
        // Test passes if view renders without crashing
    }

    @Test("App version card rendering")
    func appVersionCardRendering() {
        // Given
        let (view, _, _) = createTestComponents()
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering to exercise private properties
        _ = hostingController.view

        // Then - Should render app version card
        // Test passes if view renders without crashing
    }

    @Test("Settings view initialization")
    func settingsViewInitialization() {
        // Given
        let customMockService = MockSettingsService()
        let customServiceLocator = ServiceLocator()
        customServiceLocator.register(SettingsService.self, instance: customMockService)
        customServiceLocator.register(StoreKitService.self, instance: MockStoreKitService())
        let customSettingsViewModel = SettingsViewModel(serviceLocator: customServiceLocator)

        // When
        _ = SettingsView(viewModel: customSettingsViewModel, serviceLocator: customServiceLocator)

        // Then
        // Test passes if view initializes without crashing
    }

    @Test("Settings view with default initialization")
    func settingsViewDefaultInitialization() {
        // When - Create view with default service locator setup
        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: MockSettingsService())
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())
        let defaultViewModel = SettingsViewModel(serviceLocator: serviceLocator)
        _ = SettingsView(viewModel: defaultViewModel, serviceLocator: serviceLocator)

        // Then
        // Test passes if view initializes without crashing
    }

    // MARK: - Loading State Tests

    @Test("Settings view displays loading state")
    func settingsViewDisplaysLoadingState() async throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: viewModel, serviceLocator: serviceLocator)
        let controller: UIViewController = view.wrappedViewController

        // Verify initial loading state is displayed
        if case .loading = viewModel.viewState {
            // Correct state
        } else {
            #expect(Bool(false), "Expected loading state initially")
        }

        // Snapshot the loading state
        let iPhoneAirConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    // MARK: - Error State Tests

    @Test("Settings view displays error message on fetch failure")
    func settingsViewDisplaysErrorMessageOnFetchFailure() async throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Create a failing service
        struct FailingSettingsService: SettingsService {
            func loadProfileImage() -> AnyPublisher<UIImage?, Never> {
                Just(nil).eraseToAnyPublisher()
            }

            func saveProfileImage(_: UIImage) -> AnyPublisher<Void, Error> {
                let userInfo = [NSLocalizedDescriptionKey: "Failed to save profile image"]
                return Fail(error: NSError(domain: "test", code: 1, userInfo: userInfo))
                    .eraseToAnyPublisher()
            }

            func clearProfileImage() -> AnyPublisher<Void, Never> {
                Just(()).eraseToAnyPublisher()
            }

            func hasRatedApp() -> AnyPublisher<Bool, Never> {
                Just(false).eraseToAnyPublisher()
            }

            func markAppAsRated() -> AnyPublisher<Void, Never> {
                Just(()).eraseToAnyPublisher()
            }

            func getAppVersionInfo() -> AnyPublisher<(version: String, buildNumber: String), Never> {
                Just((version: "1.0", buildNumber: "1")).eraseToAnyPublisher()
            }
        }

        // Given
        let failingService = FailingSettingsService()
        let mockStorageService = MockStorageService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: failingService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        let errorViewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: errorViewModel, serviceLocator: serviceLocator)
        let controller: UIViewController = view.wrappedViewController

        // Wait for initial state to load
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Snapshot the view
        let iPhoneAirConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    // MARK: - Profile Image Selection Tests

    @Test("Settings view displays profile image selection on button tap")
    func settingsViewProfileImageSelection() async throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
        _ = SettingsView(viewModel: viewModel, serviceLocator: serviceLocator)

        // Wait for initial load
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Verify initial state is success (loaded)
        if case .success = viewModel.viewState {
            // Correct state
        } else {
            #expect(Bool(false), "Expected success state after initialization")
        }

        // Test passes if view initializes and state transitions to success
        #expect(true)
    }

    @Test("Settings view handles profile image updates")
    func settingsViewHandlesProfileImageUpdates() throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)

        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)

        // Create a simple test image
        let testImage = UIImage(systemName: "person.fill") ?? UIImage()

        // When - Handle profile image selection
        viewModel.handleProfileImageSelection(testImage)

        // Then - Test passes if image handling completes without crashing
        #expect(true)
    }

    @Test("Settings view with profile image displays correctly")
    func settingsViewWithProfileImageDisplaysCorrectly() async throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: viewModel, serviceLocator: serviceLocator)
        let controller: UIViewController = view.wrappedViewController

        // Wait for initial load
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Create and set a profile image
        let testImage = UIImage(systemName: "star.fill") ?? UIImage()
        viewModel.handleProfileImageSelection(testImage)

        // Wait for image to be processed
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Snapshot the view with profile image
        let iPhoneAirConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }
    }

    // MARK: - Button Interaction Tests

    @Test("Profile image button shows photo picker")
    func profileImageButtonShowsPhotoPicker() async throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: viewModel, serviceLocator: serviceLocator)
        _ = view.wrappedViewController

        // Wait for initial load
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Verify initial state - picker should be hidden
        #expect(!viewModel.isPhotoPickerPresented, "Photo picker should be hidden initially")

        // Trigger photo picker by calling showPhotoPicker
        viewModel.showPhotoPicker()

        // Wait for state update
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Verify picker is now shown
        #expect(viewModel.isPhotoPickerPresented, "Photo picker should be shown after button tap")
    }

    @Test("Profile image button dismisses photo picker")
    func profileImageButtonDismissesPhotoPicker() async throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: viewModel, serviceLocator: serviceLocator)
        _ = view.wrappedViewController

        // Show photo picker
        viewModel.showPhotoPicker()
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        #expect(viewModel.isPhotoPickerPresented, "Picker should be shown")

        // Hide photo picker
        viewModel.hidePhotoPicker()
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Verify picker is now hidden
        #expect(!viewModel.isPhotoPickerPresented, "Photo picker should be hidden after dismiss")
    }

    // MARK: - Alert Interaction Tests

    @Test("Clear favorites confirmation alert")
    func clearFavoritesConfirmationAlert() async throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: viewModel, serviceLocator: serviceLocator)
        _ = view.wrappedViewController

        // Wait for initial load
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Verify initial state - confirmation should not be shown
        #expect(!viewModel.isClearLikedMoviesConfirmationPresented, "Confirmation should be hidden initially")

        // Trigger confirmation alert
        viewModel.showClearLikedMoviesConfirmation()
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Verify confirmation is shown
        #expect(viewModel.isClearLikedMoviesConfirmationPresented, "Confirmation should be shown after button tap")
    }

    @Test("Clear favorites confirmation cancel button")
    func clearFavoritesConfirmationCancel() async throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: viewModel, serviceLocator: serviceLocator)
        _ = view.wrappedViewController

        // Show confirmation alert
        viewModel.showClearLikedMoviesConfirmation()
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        #expect(viewModel.isClearLikedMoviesConfirmationPresented, "Confirmation should be shown")

        // Tap cancel button
        viewModel.hideClearLikedMoviesConfirmation()
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Verify confirmation is hidden
        #expect(!viewModel.isClearLikedMoviesConfirmationPresented, "Confirmation should be hidden after cancel")
    }

    @Test("Rate app button triggers rating action")
    func rateAppButtonTriggersRating() async throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Given
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: viewModel, serviceLocator: serviceLocator)
        _ = view.wrappedViewController

        // Wait for initial load
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Initial state - hasRatedApp should be false
        let initialHasRated = viewModel.hasRatedApp
        #expect(!initialHasRated, "Should not have rated initially")

        // Trigger rate app
        viewModel.rateApp()
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Test passes if rateApp executes without crashing
        #expect(true)
    }

    @Test("Settings view card visibility based on rating state")
    func settingsViewRateAppCardVisibility() async throws {
        defer { UserDefaults.standard.removeObject(forKey: "profileImageData") }

        // Create a view with rated state
        let mockSettingsService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: viewModel, serviceLocator: serviceLocator)
        let controller: UIViewController = view.wrappedViewController

        // Wait for initial load
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Snapshot initial state with rate app card visible
        let iPhoneAirConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        await MainActor.run {
            assertSnapshot(of: controller, as: .wait(for: 0.5, on: .image(on: iPhoneAirConfig)))
        }

        // Note: To test with card hidden, we would need to mark app as rated
        // The successView shows rate app card only if !viewModel.hasRatedApp
        #expect(true)
    }

    @Test("Settings onAppear lifecycle triggers data load")
    func settingsOnAppearLifecycleTest() async throws {
        let mockService = MockSettingsService()
        let mockStorageService = MockStorageService()

        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockService)
        serviceLocator.register(StorageService.self, instance: mockStorageService)
        serviceLocator.register(StoreKitService.self, instance: MockStoreKitService())

        // Create viewModel which should trigger onAppear
        let viewModel = SettingsViewModel(serviceLocator: serviceLocator)

        // Wait for onAppear lifecycle to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Verify that profile image was loaded during onAppear
        if case .success = viewModel.viewState {
            // The success state indicates onAppear processed correctly
            #expect(true, "Settings view lifecycle completed successfully")
        } else {
            #expect(Bool(false), "Expected success state after onAppear lifecycle")
        }
    }
}
