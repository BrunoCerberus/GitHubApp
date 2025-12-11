//
//  SettingsViewStateTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing
import UIKit

@MainActor
struct SettingsViewStateTests {
    // MARK: - SettingsViewState Tests

    @Test("SettingsViewState error case stores message")
    func viewStateErrorCase() {
        let errorMessage = "Test error message"
        let viewState = SettingsViewState.error(errorMessage)

        if case let .error(message) = viewState {
            #expect(message == errorMessage)
        } else {
            Issue.record("Expected error case")
        }
    }

    @Test("SettingsViewState success case stores data")
    func viewStateSuccessCase() {
        let dataViewState = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: true,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            showClearFavoritesConfirm: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        let viewState = SettingsViewState.success(dataViewState)

        if case let .success(state) = viewState {
            #expect(state.hasRatedApp == true)
            #expect(state.appVersion == "1.0.0")
        } else {
            Issue.record("Expected success case")
        }
    }

    // MARK: - SettingsDataViewState Tests

    @Test("SettingsDataViewState initializes with correct values")
    func dataViewStateInitialization() {
        let dataViewState = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: true,
            appVersion: "2.0.0",
            appBuildNumber: "5",
            isPhotoPickerPresented: true,
            showClearFavoritesConfirm: false,
            showClearFavoriteMoviesAlert: true,
            showRateAppThanks: false
        )

        #expect(dataViewState.hasRatedApp == true)
        #expect(dataViewState.appVersion == "2.0.0")
        #expect(dataViewState.appBuildNumber == "5")
        #expect(dataViewState.isPhotoPickerPresented == true)
        #expect(dataViewState.showClearFavoriteMoviesAlert == true)
    }

    @Test("SettingsDataViewState tracks all dialog presentation states")
    func dataViewStateAllDialogStates() {
        let state = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: true,
            showClearFavoritesConfirm: true,
            showClearFavoriteMoviesAlert: true,
            showRateAppThanks: true
        )

        #expect(state.isPhotoPickerPresented == true)
        #expect(state.showClearFavoritesConfirm == true)
        #expect(state.showClearFavoriteMoviesAlert == true)
        #expect(state.showRateAppThanks == true)
    }
}

// MARK: - Test Helper

extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.init(cgImage: (image?.cgImage)!)
    }
}
