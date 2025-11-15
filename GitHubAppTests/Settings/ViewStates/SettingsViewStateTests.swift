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

    @Test("SettingsViewState loading case can be created")
    func viewStateLoadingCase() {
        // When
        let viewState = SettingsViewState.loading

        // Then
        if case .loading = viewState {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected loading case")
        }
    }

    @Test("SettingsViewState error case stores message")
    func viewStateErrorCase() {
        // Given
        let errorMessage = "Test error message"

        // When
        let viewState = SettingsViewState.error(errorMessage)

        // Then
        if case let .error(message) = viewState {
            #expect(message == errorMessage)
        } else {
            #expect(Bool(false), "Expected error case")
        }
    }

    @Test("SettingsViewState success case stores data")
    func viewStateSuccessCase() {
        // Given
        let dataViewState = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: true,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        // When
        let viewState = SettingsViewState.success(dataViewState)

        // Then
        if case let .success(state) = viewState {
            #expect(state.hasRatedApp == true)
            #expect(state.appVersion == "1.0.0")
        } else {
            #expect(Bool(false), "Expected success case")
        }
    }

    @Test("SettingsViewState loading equals loading")
    func viewStateLoadingEqualsLoading() {
        // When
        let state1 = SettingsViewState.loading
        let state2 = SettingsViewState.loading

        // Then
        #expect(state1 == state2)
    }

    @Test("SettingsViewState error equals error with same message")
    func viewStateErrorEqualsErrorSameMessage() {
        // When
        let state1 = SettingsViewState.error("Error")
        let state2 = SettingsViewState.error("Error")

        // Then
        #expect(state1 == state2)
    }

    @Test("SettingsViewState error not equals error with different message")
    func viewStateErrorNotEqualsErrorDifferentMessage() {
        // When
        let state1 = SettingsViewState.error("Error 1")
        let state2 = SettingsViewState.error("Error 2")

        // Then
        #expect(state1 != state2)
    }

    @Test("SettingsViewState loading not equals error")
    func viewStateLoadingNotEqualsError() {
        // When
        let state1 = SettingsViewState.loading
        let state2 = SettingsViewState.error("Error")

        // Then
        #expect(state1 != state2)
    }

    @Test("SettingsViewState loading not equals success")
    func viewStateLoadingNotEqualsSuccess() {
        // Given
        let dataViewState = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        // When
        let state1 = SettingsViewState.loading
        let state2 = SettingsViewState.success(dataViewState)

        // Then
        #expect(state1 != state2)
    }

    // MARK: - SettingsDataViewState Tests

    @Test("SettingsDataViewState initializes with correct values")
    func dataViewStateInitialization() {
        // When
        let dataViewState = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: true,
            appVersion: "2.0.0",
            appBuildNumber: "5",
            isPhotoPickerPresented: true,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: true,
            showRateAppThanks: false
        )

        // Then
        #expect(dataViewState.hasRatedApp == true)
        #expect(dataViewState.appVersion == "2.0.0")
        #expect(dataViewState.appBuildNumber == "5")
        #expect(dataViewState.isPhotoPickerPresented == true)
        #expect(dataViewState.showClearFavoriteMoviesAlert == true)
    }

    @Test("SettingsDataViewState with nil image equals another with nil image")
    func dataViewStateNilImageEquals() {
        // When
        let state1 = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        let state2 = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        // Then
        #expect(state1 == state2)
    }

    @Test("SettingsDataViewState with same image data equals")
    func dataViewStateSameImageDataEquals() {
        // Given
        let testImage = UIImage(color: .blue, size: CGSize(width: 1, height: 1))

        // When
        let state1 = SettingsDataViewState(
            profileImage: testImage,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        let state2 = SettingsDataViewState(
            profileImage: testImage,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        // Then
        #expect(state1 == state2)
    }

    @Test("SettingsDataViewState not equals with different flags")
    func dataViewStateNotEqualsWithDifferentFlags() {
        // When
        let state1 = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: true,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        let state2 = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        // Then
        #expect(state1 != state2)
    }

    @Test("SettingsDataViewState not equals with different versions")
    func dataViewStateNotEqualsWithDifferentVersions() {
        // When
        let state1 = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        let state2 = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "2.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        // Then
        #expect(state1 != state2)
    }

    @Test("SettingsDataViewState not equals with different image presence")
    func dataViewStateNotEqualsWithDifferentImagePresence() {
        // Given
        let testImage = UIImage(color: .red, size: CGSize(width: 1, height: 1))

        // When
        let state1 = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        let state2 = SettingsDataViewState(
            profileImage: testImage,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false
        )

        // Then
        #expect(state1 != state2)
    }

    @Test("SettingsDataViewState tracks all dialog presentation states")
    func dataViewStateAllDialogStates() {
        // When
        let state = SettingsDataViewState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: true,
            isClearFavoriteMoviesConfirmationPresented: true,
            showClearFavoriteMoviesAlert: true,
            showRateAppThanks: true
        )

        // Then
        #expect(state.isPhotoPickerPresented == true)
        #expect(state.isClearFavoriteMoviesConfirmationPresented == true)
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
