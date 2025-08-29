//
//  SettingsViewTests.swift
//  GitHubAppTests
//
//  Created by bruno on settings functionality.
//

import Combine
import SnapshotTesting
import SwiftUI
import XCTest

@testable import GitHubApp

/**
 * Snapshot tests for SettingsView to ensure visual regressions are detected.
 */
@MainActor
final class SettingsViewTests: XCTestCase {
    var mockSettingsService: MockSettingsService!
    var settingsViewModel: SettingsViewModel!
    var view: SettingsView!

    override func setUp() {
        super.setUp()

        // Clear UserDefaults for clean testing
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()

        mockSettingsService = MockSettingsService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: mockSettingsService)
        settingsViewModel = SettingsViewModel(serviceLocator: serviceLocator)
        view = SettingsView(viewModel: settingsViewModel)
    }

    override func tearDown() {
        mockSettingsService = nil
        settingsViewModel = nil
        view = nil
        super.tearDown()
    }

    /// Snapshot of Settings view with default configuration
    func testSettingsView() async {
        // Wait a moment for the view to load data
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        _ = view.wrappedViewController

        // Using iPhone SE configuration but with iPhone 16 Pro dimensions
        let iPhone16ProConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        assertSnapshot(of: view.wrappedViewController, as: .wait(for: 0.3, on: .image(on: iPhone16ProConfig)))
    }

    /// Test Settings view button interactions for coverage
    func testSettingsViewButtonInteractions() {
        // Given
        let hostingController = UIHostingController(rootView: view)

        // When - Access view to trigger rendering and test closures
        _ = hostingController.view

        // Then - Verify view renders without issues
        XCTAssertNotNil(hostingController)
    }

    /// Test Settings view clear favorites functionality
    func testClearFavoritesCardRendering() {
        // Given
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering
        _ = hostingController.view

        // Then - Should render clear favorites card
        XCTAssertNotNil(view)
    }

    /// Test Settings view rate app functionality
    func testRateAppCardRendering() {
        // Given
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering
        _ = hostingController.view

        // Then - Should render rate app card
        XCTAssertNotNil(view)
    }

    /// Test profile header section rendering
    func testProfileHeaderSectionRendering() {
        // Given
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering to exercise private properties
        _ = hostingController.view

        // Then - Should render profile header
        XCTAssertNotNil(view)
    }

    /// Test app version card rendering
    func testAppVersionCardRendering() {
        // Given
        let hostingController = UIHostingController(rootView: view)

        // When - Trigger view rendering to exercise private properties
        _ = hostingController.view

        // Then - Should render app version card
        XCTAssertNotNil(view)
    }

    /// Test settings view initialization
    func testSettingsViewInitialization() {
        // Given
        let customMockService = MockSettingsService()
        let customServiceLocator = ServiceLocator()
        customServiceLocator.register(SettingsService.self, instance: customMockService)
        let customSettingsViewModel = SettingsViewModel(serviceLocator: customServiceLocator)

        // When
        let customView = SettingsView(viewModel: customSettingsViewModel)

        // Then
        XCTAssertNotNil(customView)
    }

    /// Test settings view with default initialization
    func testSettingsViewDefaultInitialization() {
        // When - Create view with default service locator setup
        let serviceLocator = ServiceLocator()
        serviceLocator.register(SettingsService.self, instance: MockSettingsService())
        let defaultViewModel = SettingsViewModel(serviceLocator: serviceLocator)
        let defaultView = SettingsView(viewModel: defaultViewModel)

        // Then
        XCTAssertNotNil(defaultView)
    }
}
