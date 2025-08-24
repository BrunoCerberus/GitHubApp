//
//  SettingsDomainEventActionMapTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/settings-clean-architecture.
//

import UIKit
import XCTest

@testable import GitHubApp

/**
 * Unit tests for SettingsDomainEventActionMap.
 */
final class SettingsDomainEventActionMapTests: XCTestCase {
    // MARK: - View Event to Domain Action Mapping Tests

    func testMapViewDidAppear() {
        // Given
        let event = SettingsViewEvent.viewDidAppear

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, .loadSettings)
    }

    func testMapProfileImageSelected() {
        // Given
        let testImage = UIImage(systemName: "person.fill")!
        let event = SettingsViewEvent.profileImageSelected(testImage)

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, .saveProfileImage(testImage))
    }

    func testMapClearProfileImageTapped() {
        // Given
        let event = SettingsViewEvent.clearProfileImageTapped

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, .clearProfileImage)
    }

    func testMapRateAppTapped() {
        // Given
        let event = SettingsViewEvent.rateAppTapped

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, .rateApp)
    }

    func testMapClearFavoriteMoviesTapped() {
        // Given
        let event = SettingsViewEvent.clearFavoriteMoviesTapped

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, .showClearFavoriteMoviesConfirmation)
    }

    func testMapClearFavoriteMoviesConfirmed() {
        // Given
        let event = SettingsViewEvent.clearFavoriteMoviesConfirmed

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, .clearAllFavoriteMovies)
    }

    func testMapShowPhotoPickerTapped() {
        // Given
        let event = SettingsViewEvent.showPhotoPickerTapped

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, .showPhotoPicker)
    }

    func testMapHidePhotoPicker() {
        // Given
        let event = SettingsViewEvent.hidePhotoPicker

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, .hidePhotoPicker)
    }

    func testMapShowClearFavoriteMoviesConfirmation() {
        // Given
        let event = SettingsViewEvent.showClearFavoriteMoviesConfirmation

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, .showClearFavoriteMoviesConfirmation)
    }

    func testMapHideClearFavoriteMoviesConfirmation() {
        // Given
        let event = SettingsViewEvent.hideClearFavoriteMoviesConfirmation

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action, .hideClearFavoriteMoviesConfirmation)
    }

    // MARK: - Comprehensive Mapping Tests

    func testAllViewEventsHaveCorrespondingActions() {
        // This test ensures we don't miss any mappings when adding new events

        let testImage = UIImage(systemName: "person.fill")!

        let viewEvents: [SettingsViewEvent] = [
            .viewDidAppear,
            .profileImageSelected(testImage),
            .clearProfileImageTapped,
            .rateAppTapped,
            .clearFavoriteMoviesTapped,
            .clearFavoriteMoviesConfirmed,
            .showPhotoPickerTapped,
            .hidePhotoPicker,
            .showClearFavoriteMoviesConfirmation,
            .hideClearFavoriteMoviesConfirmation,
        ]

        let expectedActions: [SettingsDomainAction] = [
            .loadSettings,
            .saveProfileImage(testImage),
            .clearProfileImage,
            .rateApp,
            .showClearFavoriteMoviesConfirmation,
            .clearAllFavoriteMovies,
            .showPhotoPicker,
            .hidePhotoPicker,
            .showClearFavoriteMoviesConfirmation,
            .hideClearFavoriteMoviesConfirmation,
        ]

        // When & Then
        for (index, event) in viewEvents.enumerated() {
            let action = SettingsDomainEventActionMap.map(event)
            XCTAssertEqual(action, expectedActions[index], "Event \(event) should map to action \(expectedActions[index])")
        }
    }

    // MARK: - Edge Cases Tests

    func testMappingWithDifferentImages() {
        // Given
        let image1 = UIImage(systemName: "person.fill")!
        let image2 = UIImage(systemName: "star.fill")!

        let event1 = SettingsViewEvent.profileImageSelected(image1)
        let event2 = SettingsViewEvent.profileImageSelected(image2)

        // When
        let action1 = SettingsDomainEventActionMap.map(event1)
        let action2 = SettingsDomainEventActionMap.map(event2)

        // Then
        if case let .saveProfileImage(mappedImage1) = action1,
           case let .saveProfileImage(mappedImage2) = action2
        {
            XCTAssertEqual(mappedImage1.pngData(), image1.pngData())
            XCTAssertEqual(mappedImage2.pngData(), image2.pngData())
            XCTAssertNotEqual(mappedImage1.pngData(), mappedImage2.pngData())
        } else {
            XCTFail("Expected saveProfileImage actions")
        }
    }

    // MARK: - Mapper Consistency Tests

    func testMapperIsStateless() {
        // Given
        let event = SettingsViewEvent.rateAppTapped

        // When
        let action1 = SettingsDomainEventActionMap.map(event)
        let action2 = SettingsDomainEventActionMap.map(event)

        // Then
        XCTAssertEqual(action1, action2, "Mapper should be stateless and return same result for same input")
    }
}
