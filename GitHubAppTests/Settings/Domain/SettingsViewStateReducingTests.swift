//
//  SettingsViewStateReducingTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Testing
import UIKit

@testable import GitHubApp

/**
 * Unit tests for SettingsViewStateReducer.
 */
struct SettingsViewStateReducingTests {
    let reducer = SettingsViewStateReducer()

    // MARK: - Loading State Tests

    @Test("Reduces to loading state when domain state is loading")
    func reduceLoadingState() {
        // Given
        let domainState = SettingsDomainState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false,
            isLoading: true,
            error: nil
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        #expect(viewState == .loading)
    }

    // MARK: - Error State Tests

    @Test("Reduces to error state when domain state has error")
    func reduceErrorState() {
        // Given
        let errorMessage = "Test error message"
        let domainState = SettingsDomainState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false,
            isLoading: false,
            error: errorMessage
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .error(message) = viewState {
            #expect(message == errorMessage)
        } else {
            Issue.record("Expected error state")
        }
    }

    // MARK: - Success State Tests

    @Test("Reduces to success state with correct data mapping")
    func reduceSuccessState() {
        // Given
        let testImage = UIImage(systemName: "person.fill")!
        let domainState = SettingsDomainState(
            profileImage: testImage,
            hasRatedApp: true,
            appVersion: "2.0.0",
            appBuildNumber: "456",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false,
            isLoading: false,
            error: nil
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.profileImage != nil)
            #expect(dataViewState.hasRatedApp)
            #expect(dataViewState.appVersion == "2.0.0")
            #expect(dataViewState.appBuildNumber == "456")
            #expect(!dataViewState.isPhotoPickerPresented)
            #expect(!dataViewState.isClearFavoriteMoviesConfirmationPresented)
            #expect(!dataViewState.showClearFavoriteMoviesAlert)
            #expect(!dataViewState.showRateAppThanks)
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test("Reduces to success state with UI flags enabled")
    func reduceSuccessStateWithUIFlags() {
        // Given
        let domainState = SettingsDomainState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: true,
            isClearFavoriteMoviesConfirmationPresented: true,
            showClearFavoriteMoviesAlert: true,
            showRateAppThanks: true,
            isLoading: false,
            error: nil
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.profileImage == nil)
            #expect(!dataViewState.hasRatedApp)
            #expect(dataViewState.isPhotoPickerPresented)
            #expect(dataViewState.isClearFavoriteMoviesConfirmationPresented)
            #expect(dataViewState.showClearFavoriteMoviesAlert)
            #expect(dataViewState.showRateAppThanks)
        } else {
            Issue.record("Expected success state")
        }
    }

    // MARK: - State Precedence Tests

    @Test("Error state takes precedence over loading state")
    func errorStateTakesPrecedenceOverLoading() {
        // Given
        let domainState = SettingsDomainState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false,
            isLoading: true,
            error: "Test error"
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .error(message) = viewState {
            #expect(message == "Test error")
        } else {
            Issue.record("Expected error state to take precedence over loading")
        }
    }

    // MARK: - Edge Cases Tests

    @Test("Handles empty error string correctly")
    func reduceWithEmptyErrorString() {
        // Given
        let domainState = SettingsDomainState(
            profileImage: nil,
            hasRatedApp: false,
            appVersion: "1.0",
            appBuildNumber: "1",
            isPhotoPickerPresented: false,
            isClearFavoriteMoviesConfirmationPresented: false,
            showClearFavoriteMoviesAlert: false,
            showRateAppThanks: false,
            isLoading: false,
            error: ""
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .error(message) = viewState {
            #expect(message == "")
        } else {
            Issue.record("Expected error state with empty message")
        }
    }

    @Test("Reduces initial domain state correctly")
    func reduceInitialState() {
        // Given
        let domainState = SettingsDomainState.initial

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.profileImage == nil)
            #expect(!dataViewState.hasRatedApp)
            #expect(dataViewState.appVersion == "1.0")
            #expect(dataViewState.appBuildNumber == "1")
            #expect(!dataViewState.isPhotoPickerPresented)
            #expect(!dataViewState.isClearFavoriteMoviesConfirmationPresented)
            #expect(!dataViewState.showClearFavoriteMoviesAlert)
            #expect(!dataViewState.showRateAppThanks)
        } else {
            Issue.record("Expected success state for initial domain state")
        }
    }
}
