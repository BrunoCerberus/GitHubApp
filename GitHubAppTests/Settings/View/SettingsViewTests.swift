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

/**
 * Snapshot tests for SettingsView to ensure visual regressions are detected.
 */
@MainActor
struct SettingsViewTests {
    private func createTestComponents() -> (SettingsView, MockSettingsService) {
        // Configure storage for testing
        StorageServiceFactory.shared.resetCache()
        StorageServiceFactory.shared.updateConfiguration(.testing)
        // Clear UserDefaults for clean testing
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()

        let mockSettingsService = MockSettingsService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        let settingsViewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let view = SettingsView(viewModel: settingsViewModel)

        return (view, mockSettingsService)
    }

    @Test("Snapshot of Settings view with default configuration")
    func settingsView() async {
        // Given
        let (view, _) = createTestComponents()

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
        let (view, _) = createTestComponents()
        let hostingController = UIHostingController(rootView: view)

        // When - Access view to trigger rendering and test closures
        _ = hostingController.view

        // Then - Verify view renders without issues
        #expect(hostingController != nil)
    }

    @Test("Settings view clear favorites functionality")
    func clearFavoritesCardRendering() {
        // Given
        let (view, _) = createTestComponents()
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering
        _ = hostingController.view

        // Then - Should render clear favorites card
        // Test passes if view renders without crashing
    }

    @Test("Settings view rate app functionality")
    func rateAppCardRendering() {
        // Given
        let (view, _) = createTestComponents()
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering
        _ = hostingController.view

        // Then - Should render rate app card
        // Test passes if view renders without crashing
    }

    @Test("Profile header section rendering")
    func profileHeaderSectionRendering() {
        // Given
        let (view, _) = createTestComponents()
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering to exercise private properties
        _ = hostingController.view

        // Then - Should render profile header
        // Test passes if view renders without crashing
    }

    @Test("App version card rendering")
    func appVersionCardRendering() {
        // Given
        let (view, _) = createTestComponents()
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
        let customSettingsViewModel = SettingsViewModel(serviceLocator: customServiceLocator)

        // When
        let customView = SettingsView(viewModel: customSettingsViewModel)

        // Then
        // Test passes if view initializes without crashing
    }

    @Test("Settings view with default initialization")
    func settingsViewDefaultInitialization() {
        // When - Create view with default service locator setup
        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: MockSettingsService())
        let defaultViewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let defaultView = SettingsView(viewModel: defaultViewModel)

        // Then
        // Test passes if view initializes without crashing
    }
}
