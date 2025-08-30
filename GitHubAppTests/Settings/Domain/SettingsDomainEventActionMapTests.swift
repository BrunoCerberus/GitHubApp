//
//  SettingsDomainEventActionMapTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Testing
import UIKit

@testable import GitHubApp

/**
 * Unit tests for SettingsDomainEventActionMap.
 */
struct SettingsDomainEventActionMapTests {
    // MARK: - View Event to Domain Action Mapping Tests

    @Test("Map view did appear event")
    func mapViewDidAppear() {
        // Given
        let event = SettingsViewEvent.viewDidAppear

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action == .loadSettings)
    }

    @Test("Map profile image selected event")
    func mapProfileImageSelected() {
        // Given
        let testImage = UIImage(systemName: "person.fill")!
        let event = SettingsViewEvent.profileImageSelected(testImage)

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action == .saveProfileImage(testImage))
    }

    @Test("Map clear profile image tapped event")
    func mapClearProfileImageTapped() {
        // Given
        let event = SettingsViewEvent.clearProfileImageTapped

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action == .clearProfileImage)
    }

    @Test("Map rate app tapped event")
    func mapRateAppTapped() {
        // Given
        let event = SettingsViewEvent.rateAppTapped

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action == .rateApp)
    }

    @Test("Map clear favorite movies tapped event")
    func mapClearFavoriteMoviesTapped() {
        // Given
        let event = SettingsViewEvent.clearFavoriteMoviesTapped

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action == .showClearFavoriteMoviesConfirmation)
    }

    @Test("Map clear favorite movies confirmed event")
    func mapClearFavoriteMoviesConfirmed() {
        // Given
        let event = SettingsViewEvent.clearFavoriteMoviesConfirmed

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action == .clearAllFavoriteMovies)
    }

    @Test("Map show photo picker tapped event")
    func mapShowPhotoPickerTapped() {
        // Given
        let event = SettingsViewEvent.showPhotoPickerTapped

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action == .showPhotoPicker)
    }

    @Test("Map hide photo picker event")
    func mapHidePhotoPicker() {
        // Given
        let event = SettingsViewEvent.hidePhotoPicker

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action == .hidePhotoPicker)
    }

    @Test("Map show clear favorite movies confirmation event")
    func mapShowClearFavoriteMoviesConfirmation() {
        // Given
        let event = SettingsViewEvent.showClearFavoriteMoviesConfirmation

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action == .showClearFavoriteMoviesConfirmation)
    }

    @Test("Map hide clear favorite movies confirmation event")
    func mapHideClearFavoriteMoviesConfirmation() {
        // Given
        let event = SettingsViewEvent.hideClearFavoriteMoviesConfirmation

        // When
        let action = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action == .hideClearFavoriteMoviesConfirmation)
    }

    // MARK: - Comprehensive Mapping Tests

    @Test("All view events have corresponding actions")
    func allViewEventsHaveCorrespondingActions() {
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
            #expect(action == expectedActions[index], "Event \(event) should map to action \(expectedActions[index])")
        }
    }

    // MARK: - Edge Cases Tests

    @Test("Mapping with different images")
    func mappingWithDifferentImages() {
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
            #expect(mappedImage1.pngData() == image1.pngData())
            #expect(mappedImage2.pngData() == image2.pngData())
            #expect(mappedImage1.pngData() != mappedImage2.pngData())
        } else {
            Issue.record("Expected saveProfileImage actions")
        }
    }

    // MARK: - Mapper Consistency Tests

    @Test("Mapper is stateless")
    func mapperIsStateless() {
        // Given
        let event = SettingsViewEvent.rateAppTapped

        // When
        let action1 = SettingsDomainEventActionMap.map(event)
        let action2 = SettingsDomainEventActionMap.map(event)

        // Then
        #expect(action1 == action2, "Mapper should be stateless and return same result for same input")
    }
}
