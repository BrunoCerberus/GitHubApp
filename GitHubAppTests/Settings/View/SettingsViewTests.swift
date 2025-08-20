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
    var likedMoviesViewModel: LikedMoviesViewModel!
    var settingsViewModel: SettingsViewModel!
    var view: SettingsView!

    override func setUp() {
        super.setUp()

        // Clear UserDefaults for clean testing
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        UserDefaults.standard.removeObject(forKey: "hasRatedApp")
        UserDefaults.standard.synchronize()

        likedMoviesViewModel = LikedMoviesViewModel()
        settingsViewModel = SettingsViewModel(likedMoviesViewModel: likedMoviesViewModel)
        view = SettingsView(viewModel: settingsViewModel)
    }

    /// Snapshot of Settings view with default configuration
    func testSettingsView() async {
        _ = view.wrappedViewController

        // Using iPhone SE configuration but with iPhone 16 Pro dimensions
        let iPhone16ProConfig = ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 393, height: 852),
            traits: UITraitCollection()
        )

        assertSnapshot(of: view.wrappedViewController, as: .wait(for: 0.3, on: .image(on: iPhone16ProConfig)))
    }
}
