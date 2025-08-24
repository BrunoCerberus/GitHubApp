//
//  SettingsViewStateReducingTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/settings-clean-architecture.
//

import UIKit
import XCTest

@testable import GitHubApp

/**
 * Unit tests for SettingsViewStateReducer.
 */
final class SettingsViewStateReducingTests: XCTestCase {
    var reducer: SettingsViewStateReducer!

    override func setUp() {
        super.setUp()
        reducer = SettingsViewStateReducer()
    }

    override func tearDown() {
        reducer = nil
        super.tearDown()
    }

    // MARK: - Loading State Tests

    func testReduceLoadingState() {
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
        XCTAssertEqual(viewState, .loading)
    }

    // MARK: - Error State Tests

    func testReduceErrorState() {
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
            XCTAssertEqual(message, errorMessage)
        } else {
            XCTFail("Expected error state")
        }
    }

    // MARK: - Success State Tests

    func testReduceSuccessState() {
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
            XCTAssertNotNil(dataViewState.profileImage)
            XCTAssertTrue(dataViewState.hasRatedApp)
            XCTAssertEqual(dataViewState.appVersion, "2.0.0")
            XCTAssertEqual(dataViewState.appBuildNumber, "456")
            XCTAssertFalse(dataViewState.isPhotoPickerPresented)
            XCTAssertFalse(dataViewState.isClearFavoriteMoviesConfirmationPresented)
            XCTAssertFalse(dataViewState.showClearFavoriteMoviesAlert)
            XCTAssertFalse(dataViewState.showRateAppThanks)
        } else {
            XCTFail("Expected success state")
        }
    }

    func testReduceSuccessStateWithUIFlags() {
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
            XCTAssertNil(dataViewState.profileImage)
            XCTAssertFalse(dataViewState.hasRatedApp)
            XCTAssertTrue(dataViewState.isPhotoPickerPresented)
            XCTAssertTrue(dataViewState.isClearFavoriteMoviesConfirmationPresented)
            XCTAssertTrue(dataViewState.showClearFavoriteMoviesAlert)
            XCTAssertTrue(dataViewState.showRateAppThanks)
        } else {
            XCTFail("Expected success state")
        }
    }

    // MARK: - State Precedence Tests

    func testErrorStateTakesPrecedenceOverLoading() {
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
            XCTAssertEqual(message, "Test error")
        } else {
            XCTFail("Expected error state to take precedence over loading")
        }
    }

    // MARK: - Edge Cases Tests

    func testReduceWithEmptyErrorString() {
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
            XCTAssertEqual(message, "")
        } else {
            XCTFail("Expected error state with empty message")
        }
    }

    func testReduceInitialState() {
        // Given
        let domainState = SettingsDomainState.initial

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            XCTAssertNil(dataViewState.profileImage)
            XCTAssertFalse(dataViewState.hasRatedApp)
            XCTAssertEqual(dataViewState.appVersion, "1.0")
            XCTAssertEqual(dataViewState.appBuildNumber, "1")
            XCTAssertFalse(dataViewState.isPhotoPickerPresented)
            XCTAssertFalse(dataViewState.isClearFavoriteMoviesConfirmationPresented)
            XCTAssertFalse(dataViewState.showClearFavoriteMoviesAlert)
            XCTAssertFalse(dataViewState.showRateAppThanks)
        } else {
            XCTFail("Expected success state for initial domain state")
        }
    }
}
